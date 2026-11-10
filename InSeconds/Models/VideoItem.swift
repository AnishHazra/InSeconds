//
// VideoItem.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import Foundation

struct VideoItem: Identifiable {
    let id = UUID()
    let videoURL: URL?
    let title: String
    let description: String
    let founderName: String
    let founderRole: String
    let initials: String
    let tag: String
}
