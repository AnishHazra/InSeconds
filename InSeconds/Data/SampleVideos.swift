//
// SampleVideos.swift
//  InSeconds
//
//  Created by Anish on 10/11/26.
//

import Foundation

enum SampleVideos {
    static let all: [VideoItem] = [
        VideoItem(
            videoURL: URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4"),
            title: "InSeconds",
            description: "India’s Next Big Idea Begins With One Reel.",
            founderName: "Pratham Pathak",
            founderRole: "Founder & CEO",
            initials: "PP",
            tag: "Looking for a iOS Developer"
        ),
        VideoItem(
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_2MB.mp4"),
            title: "Fieldnote — voice notes that become tasks",
            description: "Talk through your day in 30 seconds. We sort it into a plan.",
            founderName: "Arjun Mehta",
            founderRole: "Co-founder",
            initials: "AM",
            tag: "Raising pre-seed"
        ),
        VideoItem(
            videoURL: URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4"),
            title: "Kirana Cloud — billing for local stores",
            description: "One app for stock, khata and UPI payments.",
            founderName: "Avani Sharma",
            founderRole: "Founder",
            initials: "AS",
            tag: "Open to investors"
        ),
        VideoItem(
            videoURL: URL(string: "https://example.com/this-video-does-not-exist.mp4"),
            title: "Broken link test",
            description: "This item uses an invalid URL to show the error state.",
            founderName: "Rahul",
            founderRole: "QA",
            initials: "RK",
            tag: "Error demo"
        ),
    ]
}
