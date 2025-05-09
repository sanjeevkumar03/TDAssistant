// SwiftSignatureView.swift
// Copyright © 2024 Telus Digital. All rights reserved.
/// Note:- Took reference from DM_YPDrawSignatureView library to build this functionality

import Foundation
import UIKit

public final class SwiftSignatureView: UIView {

    public weak var delegate: SwiftSignatureDelegate?

    public var strokeWidth: CGFloat = 2.0 {
        didSet {
            guard let path = path else { return }
            path.lineWidth = strokeWidth
        }
    }


    public var strokeColor: UIColor = .black {
        didSet {
            strokeColor.setStroke()
        }
    }

    public var signatureBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = signatureBackgroundColor
        }
    }

    public var doesContainSignature: Bool {
        guard let path = path else { return false }
        return !path.isEmpty
    }

    private var path: UIBezierPath? = UIBezierPath()
    private var points = [CGPoint](repeating: .zero, count: 5)
    private var controlPoint = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configurePath()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePath()
    }

    private func configurePath() {
        path?.lineWidth = strokeWidth
        path?.lineJoinStyle = .round
        path?.lineCapStyle = .round
    }

    public override func draw(_ rect: CGRect) {
        strokeColor.setStroke()
        path?.stroke()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            controlPoint = 0
            points[0] = point
        }
        delegate?.didStart()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        controlPoint += 1
        points[controlPoint] = point
        if controlPoint == 4 {
            points[3] = CGPoint(x: (points[2].x + points[4].x)/2, y: (points[2].y + points[4].y)/2)
            path?.move(to: points[0])
            path?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            setNeedsDisplay()
            points[0] = points[3]
            points[1] = points[4]
            controlPoint = 1
        }
        setNeedsDisplay()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if controlPoint < 4 {
            let point = points[0]
            path?.move(to: point)
            path?.addLine(to: point)
        } else {
            controlPoint = 0
        }
        setNeedsDisplay()
        delegate?.didFinish()
    }

    public func clear() {
        path?.removeAllPoints()
        setNeedsDisplay()
    }

    public func getSignature(scale: CGFloat = 1) -> UIImage? {
        guard doesContainSignature else { return nil }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        strokeColor.setStroke()
        path?.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func getCroppedSignature(scaleFactor: CGFloat = 1) -> UIImage? {
        guard let fullImage = getSignature(scale: scaleFactor),
              let bounds = path?.bounds.insetBy(dx: -strokeWidth / 2, dy: -strokeWidth / 2)
        else { return nil }

        let scaledBounds = scale(bounds, byFactor: scaleFactor)
        guard let cropped = fullImage.cgImage?.cropping(to: scaledBounds) else { return nil }
        return UIImage(cgImage: cropped)
    }


    private func scale(_ rect: CGRect, byFactor factor: CGFloat) -> CGRect {
        return CGRect(
            x: rect.origin.x * factor,
            y: rect.origin.y * factor,
            width: rect.size.width * factor,
            height: rect.size.height * factor
        )
    }

    public func getPDFSignature() -> Data {
        let mutableData = CFDataCreateMutable(nil, 0)!
        let consumer = CGDataConsumer(data: mutableData)!
        var rect = bounds

        guard let context = CGContext(consumer: consumer, mediaBox: &rect, nil) else { return Data() }

        context.beginPDFPage(nil)
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)

        if let path = path {
            context.addPath(path.cgPath)
        }
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
        context.endPDFPage()
        context.closePDF()

        return mutableData as Data
    }
}


// MARK: - Protocol definition

@objc
public protocol SwiftSignatureDelegate: AnyObject {
    func didStart()
    @available(*, unavailable, renamed: "didStart()")
    func startedDrawing()

    func didFinish()
    @available(*, unavailable, renamed: "didFinish()")
    func finishedDrawing()
}

public extension SwiftSignatureDelegate {
    func didStart() {}
    func didFinish() {}
}
