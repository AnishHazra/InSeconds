//
// FeedViewModel.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class FeedViewModel {
    let items: [VideoItem]

    var activeItemID: VideoItem.ID?

    private(set) var players: [VideoItem.ID: PlayerViewModel] = [:]

    @ObservationIgnored private var isAppActive = true

    init(items: [VideoItem]) {
        self.items = items
        self.activeItemID = items.first?.id
    }

    var activeIndex: Int {
        guard let activeItemID,
              let index = items.firstIndex(where: { $0.id == activeItemID }) else {
            return 0
        }
        return index
    }

    func player(for item: VideoItem) -> PlayerViewModel? {
        players[item.id]
    }

    // MARK: Feed events

    func onAppear() {
        updatePlayers()
    }

    func activeItemDidChange() {
        updatePlayers()
    }

    func retry(_ item: VideoItem) {
        guard let player = players[item.id] else { return }
        player.retry()
        if item.id == activeItemID && isAppActive {
            player.activate()
        }
    }

    func skipToNext() {
        guard !items.isEmpty else { return }
        let nextIndex = activeIndex + 1 < items.count ? activeIndex + 1 : 0
        debugLog("[Feed] skip to page \(nextIndex + 1)")
        activeItemID = items[nextIndex].id
    }

    // MARK: App lifecycle

    func appDidBecomeActive() {
        debugLog("[Feed] app active — resuming unless user paused")
        isAppActive = true
        activePlayer?.resumeIfNotPausedByUser()
    }

    func appDidLeaveForeground() {
        debugLog("[Feed] app inactive/background — pausing active video")
        isAppActive = false
        activePlayer?.pause()
    }

    // MARK: Player window

    private var activePlayer: PlayerViewModel? {
        guard let activeItemID else { return nil }
        return players[activeItemID]
    }

    private func updatePlayers() {
        guard !items.isEmpty else { return }

        let lower = max(activeIndex - 1, 0)
        let upper = min(activeIndex + 1, items.count - 1)
        let windowItems = items[lower...upper]
        let idsToKeep = Set(windowItems.map(\.id))
        let activeID = items[activeIndex].id

        // 1. Release players that left the window.
        for (id, player) in players where !idsToKeep.contains(id) {
            debugLog("[Feed] out of window, releasing \(player.item.title)")
            player.cleanup()
            players[id] = nil
        }

        // 2. Create players for new pages in the window. Neighbours start loading but stay paused,
        for item in windowItems where players[item.id] == nil {
            let player = PlayerViewModel(item: item)
            player.prepare()
            players[item.id] = player
        }

        // 3. Pause everything that isn't active first, then play the active one,
        for (id, player) in players where id != activeID {
            player.pause()
        }
        if isAppActive {
            players[activeID]?.activate()
        }

        // Should never be more than 3, no matter how far you scroll.
        let alive = items.filter { players[$0.id] != nil }.map(\.title)
        debugLog("[Feed] players alive: \(players.count) → \(alive)")
    }
}
