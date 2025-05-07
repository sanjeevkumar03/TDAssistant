//  Timezone+Extension.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import Foundation

/// Date and Time formatting
extension TimeZone {
    func offsetFromUTC() -> String {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }

    func offsetInHours() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let formattedTime = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return formattedTime
    }
    func offsetInMinutes() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let differenceInMinutes = (hours*60)+minutes
        let difference = -differenceInMinutes
        return "\(difference)"
    }
}
