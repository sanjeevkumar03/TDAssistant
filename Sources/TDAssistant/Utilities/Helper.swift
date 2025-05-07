//  Helper.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation

class Helper {
    
    static func getYouTubeVideoIdForThumbnailGeneration(videoUrl: String) -> String {
        var videoId = ""
        if videoUrl.contains("youtu.be") {
            let sharedVideoId = videoUrl.components(separatedBy: ".be/").last ?? ""
            videoId = sharedVideoId.components(separatedBy: "?si=").first ?? ""
        } else if videoUrl.contains("www.youtube.com") {
            videoId = videoUrl.components(separatedBy: "v=").last ?? ""
            let channelSeparater = "&ab_channel="
            if videoId.contains(channelSeparater) {
                videoId = videoId.components(separatedBy: channelSeparater).first ?? ""
            }
        }
        return videoId
    }
    
    static func getYouTubeVideoIdToPlayVideo(videoUrl: String) -> String {
        var videoId = ""
        if videoUrl.contains("youtu.be") {
            videoId = videoUrl.components(separatedBy: ".be/").last ?? ""
        } else if videoUrl.contains("www.youtube.com") {
            videoId = videoUrl.components(separatedBy: "v=").last ?? ""
            let channelSeparater = "&ab_channel="
            if videoId.contains(channelSeparater) {
                videoId = videoId.components(separatedBy: channelSeparater).first ?? ""
            }
        }
        return videoId
    }
}
