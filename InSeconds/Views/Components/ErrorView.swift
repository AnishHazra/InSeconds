//
// ErrorView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct ErrorView: View {
    let onRetry: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 52, height: 52)
                .background(AppTheme.accent.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            Text("Couldn’t play this video")
                .font(.system(size: 19, weight: .bold))
                .tracking(-0.3)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.top, 6)

            Text("Check your connection and try again, or keep scrolling.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            VStack(spacing: 4) {
                Button(action: onRetry) {
                    Label("Try again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.textOnAccent)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(AppTheme.accent, in: Capsule())
                }

                Button(action: onSkip) {
                    Text("Skip to next")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
        }
        .padding(.top, 28)
        .padding(.horizontal, 24)
        .padding(.bottom, 22)
        .background(AppTheme.errorCardFill, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.errorCardBorder, lineWidth: 1)
        )
    }
}
