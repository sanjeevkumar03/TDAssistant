// ExtendedAlertController.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

extension UIAlertController {
    static func openAlert(_ title: String?,
                          _ msg: String,
                          _ actions: [String],
                          _ actionStyles: [UIAlertAction.Style]? = nil,
                          _ style: UIAlertController.Style = .alert,
                          completion: @escaping ((Int) -> Void) ) {

        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: style)
        for (index, action) in actions.enumerated() {
            let tapAction = UIAlertAction.init(title: action, style: actionStyles?[index] ?? .default) { (_) in
                alertController.dismiss(animated: true, completion: {
                    completion(index)
                })
            }
            alertController.addAction(tapAction)
        }
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    static func openAlertWithOk(_ title: String?,
                                _ msg: String,
                                _ action: String,
                                completion: (() -> Void)?) {

        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)

        let tapAction = UIAlertAction.init(title: action, style: .default) { (_) in
            completion?()
            alertController.dismiss(animated: true, completion: {})
        }
        alertController.addAction(tapAction)

        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    static func openAlertWithOk(_ title: String?,
                                _ msg: String,
                                _ action: String,
                                view: UIViewController,
                                completion: (() -> Void)?) {

        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)

        let tapAction = UIAlertAction.init(title: action, style: .default) { (_) in
            completion?()
            alertController.dismiss(animated: true, completion: {})
        }
        alertController.addAction(tapAction)

        view.present(alertController, animated: true, completion: nil)
    }

    static func openAlertWithOk(_ title: String?,
                                _ msg: String,
                                _ action: String, in controller: UIViewController,
                                completion: (() -> Void)?) {

        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)

        let tapAction = UIAlertAction.init(title: action, style: .default) { (_) in
            completion?()
            alertController.dismiss(animated: true, completion: {})
        }
        alertController.addAction(tapAction)

        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func showAutoHideAlert(message: String, delay: Double, controller: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
}
