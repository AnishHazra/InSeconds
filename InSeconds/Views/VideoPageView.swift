//
// VideoPageView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct VideoPageView: View {
    let item: VideoItem
    let player: PlayerViewModel?
    let onRetry: () -> Void
    let onSkip: () -> Void

    private var isPausedByUser: Bool { player?.isPausedByUser ?? false }
    private var isFailed: Bool { player?.isFailed ?? false }
    private var isLoading: Bool { player?.isLoading ?? true }

    var body: some View {
        ZStack {
            AppTheme.background

            // 1. Video
            PlayerLayerView(player: player?.player)
                .allowsHitTesting(false)

            // 2. Tap anywhere to play/pause
            tapArea

            // 3. Paused overlay
            if isPausedByUser {
                PlayPauseOverlay()
            }

            // 4. Bottom gradient + title, description and progress
            bottomContent

            // 5. Loading or error state
            if isFailed {
                ErrorView(onRetry: onRetry, onSkip: onSkip)
                    .padding(.horizontal, 32)
            } else if isLoading {
                LoadingView()
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }

    private var tapArea: some View {
        Button {
            guard let player else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            player.togglePlayPause()
        } label: {
            Color.clear
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isFailed)
        .accessibilityLabel(isPausedByUser ? "Play video" : "Pause video")
    }

    private var bottomContent: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.85), location: 0),
                        .init(color: .black.opacity(0.55), location: 0.5),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: AppTheme.bottomGradientHeight)

                VStack(alignment: .leading, spacing: AppTheme.bottomContentSpacing) {
                    VideoInfoView(item: item)
                    if !isFailed {
                        ProgressBarView(
                            progress: player?.progress ?? 0,
                            timeText: player?.timeText ?? "--:--",
                            isPaused: isPausedByUser
                        )
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, AppTheme.bottomPadding)
            }
        }
        .allowsHitTesting(false)
    }
}
