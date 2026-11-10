//
// InSecondsApp.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI
import AVFoundation

@main
struct InSecondsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var feedViewModel = FeedViewModel(items: SampleVideos.all)

    init() {
        Self.configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: feedViewModel)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                feedViewModel.appDidBecomeActive()
            case .inactive, .background:
                feedViewModel.appDidLeaveForeground()
            @unknown default:
                break
            }
        }
    }

    private static func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        } catch {
            debugLog("Could not set up the audio session: \(error.localizedDescription)")
        }
    }
}
