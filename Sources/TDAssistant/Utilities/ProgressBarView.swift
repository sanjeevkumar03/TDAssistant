//  ProgressBarView.swift
//  Copyright © 2024 Telus Digital. All rights reserved.

import UIKit
class ProgressBarView: UIView {

    // MARK: - Properties
    var progressLyr = CAShapeLayer()
    var trackLyr = CAShapeLayer()

    var progressClr = UIColor.white {
        didSet {
            progressLyr.strokeColor = progressClr.cgColor
        }
    }

    var trackClr = UIColor.white {
        didSet {
            trackLyr.strokeColor = trackClr.cgColor
        }
    }
    
    var trackLyrLineWidth: CGFloat = 1.0 {
        didSet {
            trackLyr.lineWidth = trackLyrLineWidth
            trackLyr.strokeEnd = trackLyrLineWidth
        }
    }

    var progress: Float = 0 {
        willSet(newValue) {
            // debugPrint(newValue)
            progressLyr.strokeEnd = CGFloat(newValue)
        }
    }
    // end

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 2, y: 4, width: self.frame.width - 8, height: self.frame.height - 8)
        self.makeCircularPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeCircularPath()
    }
    // end

    // MARK: - Draw Circular Path and add as a sublayer
    func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2),
                                                radius: (frame.size.width - 1.5)/2,
                                                startAngle: CGFloat(-0.5 * .pi),
                                                endAngle: CGFloat(1.5 * .pi),
                                                clockwise: true)
        trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor.clear.cgColor
        trackLyr.strokeColor = trackClr.cgColor
        trackLyr.lineWidth = trackLyrLineWidth
        trackLyr.strokeEnd = trackLyrLineWidth
        layer.addSublayer(trackLyr)
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr.cgColor
        progressLyr.lineWidth = 2.0
        progressLyr.strokeEnd = 0.0
        layer.addSublayer(progressLyr)
    }
}
