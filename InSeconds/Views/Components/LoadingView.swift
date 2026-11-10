//
// LoadingView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct LoadingView: View {
    @State private var isSpinning = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.14), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: isSpinning)
            }
            .padding(1.5)
            .frame(width: 44, height: 44)

            Text("Loading video…")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .onAppear {
            isSpinning = true
        }
        .accessibilityElement(children: .combine)
    }
}
