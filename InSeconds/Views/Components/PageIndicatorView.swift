//
// PageIndicatorView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct PageIndicatorView: View {
    let count: Int
    let activeIndex: Int

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                let isActive = index == activeIndex
                Capsule()
                    .fill(isActive ? AppTheme.accent : Color.white.opacity(0.4))
                    .frame(width: 4, height: isActive ? 22 : 8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: activeIndex)
        .allowsHitTesting(false)
        .accessibilityElement()
        .accessibilityLabel("Video \(activeIndex + 1) of \(count)")
    }
}
