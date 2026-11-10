//
// PlayerViewModel.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//


import AVFoundation
import Observation

@Observable
@MainActor
final class PlayerViewModel {
    enum LoadState {
        case idle       // no AVPlayer yet
        case loading    // AVPlayerItem status is .unknown
        case ready      // AVPlayerItem status is .readyToPlay
        case failed     // bad URL or AVPlayerItem status is .failed
    }

    let item: VideoItem

    private(set) var player: AVPlayer?
    private(set) var loadState: LoadState = .idle
    private(set) var isBuffering = false
    private(set) var isPausedByUser = false
    private(set) var currentTime: Double = 0
    private(set) var duration: Double = 0

    // @ObservationIgnored because the UI never needs to redraw when these change.
    @ObservationIgnored private var timeObserverToken: Any?
    @ObservationIgnored private var statusObservation: NSKeyValueObservation?
    @ObservationIgnored private var timeControlObservation: NSKeyValueObservation?
    @ObservationIgnored private var endObserver: NSObjectProtocol?

    init(item: VideoItem) {
        self.item = item
        debugLog("[Player] init        \(item.title)")
    }

    deinit {
        statusObservation?.invalidate()
        timeControlObservation?.invalidate()
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        debugLog("[Player] deinit      \(item.title) — freed from memory")
    }

    // MARK: Derived state for the UI

    var isLoading: Bool {
        switch loadState {
        case .idle, .loading: return true
        case .ready: return isBuffering
        case .failed: return false
        }
    }

    var isFailed: Bool { loadState == .failed }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    var timeText: String {
        guard !isLoading, duration > 0 else { return "--:--" }
        return "\(Self.format(currentTime)) / \(Self.format(duration))"
    }

    // MARK: Lifecycle

    /// Creates the AVPlayer the first time this page is needed. Calling it again does nothing.
    func prepare() {
        guard player == nil else { return }
        guard let url = item.videoURL else {
            debugLog("[Player] invalid URL \(item.title)")
            loadState = .failed
            return
        }

        let playerItem = AVPlayerItem(url: url)
        // Only buffer ~5 seconds ahead so preloaded neighbours don't use much memory.
        playerItem.preferredForwardBufferDuration = 5

        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = true

        player = newPlayer
        loadState = .loading
        addObservers(to: newPlayer, playerItem: playerItem)
    }

    /// Releases the player and removes every observer, in the order AVFoundation expects.
    func cleanup() {
        debugLog("[Player] cleanup     \(item.title) — had player: \(player != nil), time observer: \(timeObserverToken != nil), KVO: \(statusObservation != nil), end observer: \(endObserver != nil)")

        // 1. Stop playback.
        player?.pause()

        // 2. Remove the periodic time observer from the same player that created it.
        if let timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        // 3. Stop the KVO observations.
        statusObservation?.invalidate()
        statusObservation = nil
        timeControlObservation?.invalidate()
        timeControlObservation = nil

        // 4. Stop listening for "video finished".
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }

        // 5. Drop the item (frees its buffers) and the player itself.
        player?.replaceCurrentItem(with: nil)
        player = nil

        loadState = .idle
        isBuffering = false
        debugLog("[Player] cleanup done \(item.title) — all observers removed, player released")
    }

    /// Rebuilds the player from scratch after a failure.
    func retry() {
        debugLog("[Player] retry       \(item.title)")
        cleanup()
        currentTime = 0
        duration = 0
        prepare()
    }

    // MARK: Playback

    func play() {
        guard loadState != .failed else { return }
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    /// Called when this page becomes the visible one: forget any old manual pause and start playing.
    func activate() {
        debugLog("[Player] play (active) \(item.title)")
        isPausedByUser = false
        play()
    }

    /// Called when the app comes back to the foreground.
    func resumeIfNotPausedByUser() {
        guard !isPausedByUser else { return }
        play()
    }

    func togglePlayPause() {
        guard loadState != .failed else { return }
        isPausedByUser.toggle()
        debugLog("[Player] user tapped \(isPausedByUser ? "PAUSE" : "PLAY")  \(item.title)")
        if isPausedByUser {
            pause()
        } else {
            play()
        }
    }

    // MARK: Observers

    private func addObservers(to player: AVPlayer, playerItem: AVPlayerItem) {

        // Item status tells us when the video is ready to play or has failed.
        statusObservation = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            let status = item.status
            Task { @MainActor [weak self] in
                self?.handleStatusChange(status)
            }
        }

        // timeControlStatus tells us when the player is stuck waiting for more data (buffering).
        timeControlObservation = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            let isWaiting = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
            Task { @MainActor [weak self] in
                guard let self, self.isBuffering != isWaiting else { return }
                self.isBuffering = isWaiting
                debugLog("[Player] \(isWaiting ? "buffering…" : "buffering done") \(self.item.title)")
            }
        }

        // Update the progress bar 4 times a second (often enough to look smooth, cheap enough).
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = time.seconds
            Task { @MainActor [weak self] in
                self?.currentTime = seconds.isFinite ? seconds : 0
            }
        }

        // Loop: when the video reaches the end, jump back to the start and keep playing.
        endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.loopToStart()
            }
        }
    }

    private func handleStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            loadState = .ready
            let seconds = player?.currentItem?.duration.seconds ?? 0
            duration = seconds.isFinite ? seconds : 0
            debugLog("[Player] ready to play \(item.title) — duration \(Self.format(duration))")
        case .failed:
            loadState = .failed
            player?.pause()
            let reason = player?.currentItem?.error?.localizedDescription ?? "unknown error"
            debugLog("[Player] failed      \(item.title) — \(reason)")
        case .unknown:
            loadState = .loading
        @unknown default:
            loadState = .loading
        }
    }

    private func loopToStart() {
        debugLog("[Player] reached end, looping \(item.title)")
        player?.seek(to: .zero)
        if !isPausedByUser {
            player?.play()
        }
    }

    private static func format(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds.rounded(.down))
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
