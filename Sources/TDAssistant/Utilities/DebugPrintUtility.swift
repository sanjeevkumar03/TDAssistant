// DebugPrintUtility.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation

var releaseMode = false

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if !releaseMode {
        #if DEBUG
        Swift.print(items, separator: separator, terminator: terminator)
        #endif
    }
}
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if !releaseMode {
        #if DEBUG
        Swift.debugPrint(items, separator: separator, terminator: terminator)
        #endif
    }
}
