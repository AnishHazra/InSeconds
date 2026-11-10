//
// VideoInfoView.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

struct VideoInfoView: View {
    let item: VideoItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.bottomContentSpacing) {
            tagPill
            founderRow
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: AppTheme.titleSize, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(2)
                    .accessibilityAddTraits(.isHeader)
                Text(item.description)
                    .font(.system(size: AppTheme.descriptionSize))
                    .foregroundStyle(AppTheme.descriptionText)
                    .lineSpacing(3)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tagPill: some View {
        Text(item.tag)
            .font(.system(size: AppTheme.tagSize, weight: .semibold))
            .foregroundStyle(AppTheme.primaryText)
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .background(AppTheme.tagPurple, in: Capsule())
    }

    private var founderRow: some View {
        HStack(spacing: 10) {
            Text(item.initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.textOnAccent)
                .frame(width: 38, height: 38)
                .background(AppTheme.accent, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(item.founderName)
                    .font(.system(size: AppTheme.founderNameSize, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(item.founderRole)
                    .font(.system(size: AppTheme.founderRoleSize))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
