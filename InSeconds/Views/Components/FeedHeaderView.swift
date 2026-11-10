//
// FeedHeaderView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct FeedHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.accent)
                .frame(width: 9, height: 9)
            Text("InSeconds")
                .font(.system(size: AppTheme.logoSize, weight: .semibold))
                .tracking(-0.4)
                .foregroundStyle(AppTheme.primaryText)
            Spacer()
        }
        .padding(.horizontal, AppTheme.horizontalPadding)
        .padding(.top, 4)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
