//  VAChatView+DigitalSignature.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import UIKit

extension VAChatViewController {
    // MARK: - Configure the signature view
    /// This function is used to configure digital signature view
    func configureSignatureView() {
        signatureContainerView.backgroundColor = .black.withAlphaComponent(0.35)

        signatureBackgroundView.layer.borderWidth = 2.0
        signatureBackgroundView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        signatureBackgroundView.layer.cornerRadius = 5.0

        signatureView.layer.borderWidth = isNewGenAITheme ? 1.0 : 2.0
        signatureView.layer.cornerRadius = 2.0
        signatureView.layer.borderColor = isNewGenAITheme ? VAColorUtility.borderColor_NT.cgColor : UIColor.lightGray.withAlphaComponent(0.35).cgColor

        signatureView.strokeWidth = 3.0
        signatureView.strokeColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor
        signatureView.backgroundColor = VAColorUtility.white
        signatureView.delegate = self
        
        self.signatureCloseImageView.tintColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor

        self.sendSignatureButton.setTitleColor(VAColorUtility.white, for: .normal)
        self.clearSignatureButton.setTitleColor(VAColorUtility.white, for: .normal)

        self.updateSignatureViewButtons()

        self.signatureTitleLabel.font = isNewGenAITheme ? GenAIFonts().bold() : UIFont.systemFont(ofSize: textFontSize, weight: .medium)
        self.sendSignatureButton.titleLabel?.font = isNewGenAITheme ? GenAIFonts().bold() : UIFont.systemFont(ofSize: 15, weight: .medium)
        self.clearSignatureButton.titleLabel?.font = isNewGenAITheme ? GenAIFonts().bold() : UIFont.systemFont(ofSize: 15, weight: .medium)
        self.signatureTitleLabel.textColor = isNewGenAITheme ? VAColorUtility.greyCharcoal_NT : VAColorUtility.senderBubbleColor
    }
    func localizeSignatureView() {
        self.sendSignatureButton.setTitle(LanguageManager.shared.localizedString(forKey: "Done"), for: .normal)
        self.clearSignatureButton.setTitle(LanguageManager.shared.localizedString(forKey: "Clear"), for: .normal)
        self.signatureTitleLabel.text = LanguageManager.shared.localizedString(forKey: "Draw your signature")
    }
    func updateSignatureViewButtons() {
        self.sendSignatureButton.layer.cornerRadius = 20.0
        self.clearSignatureButton.layer.cornerRadius = 20.0
        if hasSignatureAdded {
            self.sendSignatureButton.backgroundColor = VAColorUtility.defaultGreenColor
            self.sendSignatureButton.titleLabel?.textColor = VAColorUtility.white

            self.clearSignatureButton.layer.borderWidth = 1.0
            self.clearSignatureButton.layer.borderColor = VAColorUtility.defaultGreenColor.cgColor
            self.clearSignatureButton.backgroundColor = VAColorUtility.white
            self.clearSignatureButton.titleLabel?.textColor = VAColorUtility.defaultGreenColor

            self.clearSignatureButton.isUserInteractionEnabled = true
            self.sendSignatureButton.isUserInteractionEnabled = true
        } else {
            self.clearSignatureButton.layer.borderColor = UIColor.clear.cgColor
            self.clearSignatureButton.titleLabel?.textColor = VAColorUtility.white
            self.clearSignatureButton.backgroundColor = isNewGenAITheme ? VAColorUtility.borderColor_NT : UIColor.lightGray.withAlphaComponent(0.5)
            self.clearSignatureButton.isUserInteractionEnabled = false

            self.sendSignatureButton.titleLabel?.textColor = VAColorUtility.white
            self.sendSignatureButton.backgroundColor = isNewGenAITheme ? VAColorUtility.borderColor_NT : UIColor.lightGray.withAlphaComponent(0.5)
            self.sendSignatureButton.isUserInteractionEnabled = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.addSignatureView()
        }
    }
    func addSignatureView() {
        self.sendSignatureButton.isUserInteractionEnabled = true
        self.signatureContainerView.frame = self.view.bounds
        self.view.addSubview(self.signatureContainerView)
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.view.bringSubviewToFront(self.signatureContainerView)
        })
    }

    func removeSignatureView() {
        self.clearSignature()
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.signatureContainerView.removeFromSuperview()
        })
    }
    func clearSignature() {
        signatureView.clear()
        hasSignatureAdded = false
        self.updateSignatureViewButtons()
    }
    // MARK: Button Actions
    @IBAction func sendSignatureTapped(_ sender: UIButton) {
        if !self.signatureView.doesContainSignature {
            let alert = UIAlertController(title: "", message: LanguageManager.shared.localizedString(forKey: "Signature not found."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Ok"), style: .cancel))
            self.present(alert, animated: true)
            return
        }
        /*if let signatureImage = self.signatureView.getSignature(scale: 5) {
            let imageBase64String = convertImageToBase64String(img: signatureImage)
            UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            self.signatureView.clear()
        }*/
        self.sendSignatureButton.isUserInteractionEnabled = false
        if let signatureImage = self.signatureView.getCroppedSignature(scale: 2) {
            let imageBase64String = convertImageToBase64String(img: signatureImage)
            // UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.sendImageMessageToBot(image: signatureImage, messageStr: imageBase64String, messageType: SenderMessageType.signature)
                self.removeSignatureView()
            }
        }
    }
    @IBAction func clearSignatureTapped(_ sender: UIButton) {
        self.clearSignature()
    }
    @IBAction func closeSignatureViewTapped(_ sender: UIButton) {
        self.removeSignatureView()
    }
}
