//
// PlayPauseOverlay.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct PlayPauseOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.22)

            Image(systemName: "play.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.black.opacity(0.55)))
                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
