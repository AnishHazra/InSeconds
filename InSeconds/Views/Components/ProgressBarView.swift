//
// ProgressBarView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct ProgressBarView: View {
    /// 0...1
    let progress: Double
    let timeText: String
    let isPaused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Capsule()
                .fill(Color.white.opacity(0.22))
                .frame(height: 3)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(isPaused ? Color.white.opacity(0.7) : AppTheme.accent)
                        .scaleEffect(x: progress, anchor: .leading)
                }
                .clipShape(Capsule())

            Text(timeText)
                .font(.system(size: AppTheme.timeLabelSize, weight: .medium))
                .monospacedDigit() // same width size
                .foregroundStyle(AppTheme.secondaryText)
        }
        .accessibilityElement()
        .accessibilityLabel("Playback position")
        .accessibilityValue(timeText)
    }
}
