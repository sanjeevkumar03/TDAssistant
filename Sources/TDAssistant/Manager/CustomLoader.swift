// CustomLoader.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import ProgressHUD

class CustomLoader {
    /// This function defines type, color of loader and shows over the view.
    /// - Parameter isUserInterationEnabled: Defines whether user interation is allowed when loader is spinning.
    static func show(isUserInterationEnabled: Bool = false) {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = VAColorUtility.defaultSenderBubbleColor
        ProgressHUD.colorHUD = .lightGray
        ProgressHUD.colorBackground = .black.withAlphaComponent(0.2)
        ProgressHUD.animate(interaction: isUserInterationEnabled)
    }

    /// Hides loader spinning over the view.
    static func hide() {
        ProgressHUD.remove()
    }
}
