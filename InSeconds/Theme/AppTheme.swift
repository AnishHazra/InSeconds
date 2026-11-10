//
// AppTheme.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import SwiftUI

enum AppTheme {
    // MARK: Colors
    // #0B0C0A
    static let background = Color(red: 11 / 255, green: 12 / 255, blue: 10 / 255)
    // #DDF763 (lime)
    static let accent = Color(red: 221 / 255, green: 247 / 255, blue: 99 / 255)
    // #0B0C0A
    static let textOnAccent = background
    // #6B5B7E
    static let tagPurple = Color(red: 107 / 255, green: 91 / 255, blue: 126 / 255)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.75)
    static let descriptionText = Color.white.opacity(0.82)
    static let errorCardFill = Color(red: 28 / 255, green: 27 / 255, blue: 31 / 255).opacity(0.92)
    static let errorCardBorder = Color.white.opacity(0.10)

    // MARK: Font sizes
    static let logoSize: CGFloat = 21
    static let titleSize: CGFloat = 26
    static let descriptionSize: CGFloat = 15
    static let founderNameSize: CGFloat = 15
    static let founderRoleSize: CGFloat = 12
    static let tagSize: CGFloat = 13
    static let timeLabelSize: CGFloat = 12

    // MARK: Spacing
    static let horizontalPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 40
    static let bottomContentSpacing: CGFloat = 14
    static let topGradientHeight: CGFloat = 150
    static let bottomGradientHeight: CGFloat = 380
}
