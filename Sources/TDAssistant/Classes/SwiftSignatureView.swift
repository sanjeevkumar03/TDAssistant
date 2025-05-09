// SwiftSignatureView.swift
// Copyright © 2024 Telus Digital. All rights reserved.
/// Note:- Took reference from DM_YPDrawSignatureView library to build this functionality

import UIKit

public final class SwiftSignatureView: UIView {

    public weak var delegate: SwiftSignatureDelegate?

    // MARK: - Public Properties

    public var strokeWidth: CGFloat = 2.0
    public var strokeColor: UIColor = .black
    public var signatureBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = signatureBackgroundColor
        }
    }

    public var doesContainSignature: Bool {
        return !path.isEmpty
    }

    // MARK: - Private Properties

    private var path = UIBezierPath()
    private var points = [CGPoint](repeating: .zero, count: 5)
    private var controlPoint = 0

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = signatureBackgroundColor
        path.lineWidth = strokeWidth
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
    }

    // MARK: - Drawing

    public override func draw(_ rect: CGRect) {
        strokeColor.setStroke()
        path.stroke()
    }

    // MARK: - Touch Handling

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        points[0] = touch.location(in: self)
        controlPoint = 0
        delegate?.didStart()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let point = touch.location(in: self)
        controlPoint += 1
        points[controlPoint] = point

        if controlPoint == 4 {
            points[3] = CGPoint(
                x: (points[2].x + points[4].x) / 2.0,
                y: (points[2].y + points[4].y) / 2.0
            )

            path.move(to: points[0])
            path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])

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
            path.move(to: point)
            path.addLine(to: point)
        }
        controlPoint = 0
        setNeedsDisplay()
        delegate?.didFinish()
    }

    // MARK: - Public Methods

    public func clear() {
        path.removeAllPoints()
        path.lineWidth = strokeWidth // <-- Apply strokeWidth here instead of didSet
        setNeedsDisplay()
    }

    public func getSignature(scale: CGFloat = 1) -> UIImage? {
        guard doesContainSignature else { return nil }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        strokeColor.setStroke()
        path.stroke()
        let signatureImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return signatureImage
    }

    public func getCroppedSignature(scaleFactor: CGFloat = 1) -> UIImage? {
        guard let fullImage = getSignature(scale: scaleFactor) else { return nil }

        let bounds = scaleRect(path.bounds.insetBy(dx: -strokeWidth / 2, dy: -strokeWidth / 2), by: scaleFactor)
        guard let croppedCGImage = fullImage.cgImage?.cropping(to: bounds) else { return nil }

        return UIImage(cgImage: croppedCGImage)
    }

    public func getPDFSignature() -> Data {
        let mutableData = CFDataCreateMutable(nil, 0)!
        guard let dataConsumer = CGDataConsumer(data: mutableData) else { fatalError("Unable to create PDF data consumer") }

        var mediaBox = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        guard let pdfContext = CGContext(consumer: dataConsumer, mediaBox: &mediaBox, nil) else { fatalError("Unable to create PDF context") }

        pdfContext.beginPDFPage(nil)
        pdfContext.translateBy(x: 0, y: frame.height)
        pdfContext.scaleBy(x: 1, y: -1)
        pdfContext.addPath(path.cgPath)
        pdfContext.setStrokeColor(strokeColor.cgColor)
        pdfContext.strokePath()
        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return mutableData as Data
    }

    // MARK: - Helpers

    private func scaleRect(_ rect: CGRect, by factor: CGFloat) -> CGRect {
        return CGRect(
            x: rect.origin.x * factor,
            y: rect.origin.y * factor,
            width: rect.size.width * factor,
            height: rect.size.height * factor
        )
    }
}




// MARK: - Protocol definition

@objc
public protocol SwiftSignatureDelegate: AnyObject {
    func didStart()
    func didFinish()

    @available(*, unavailable, renamed: "didStart()")
    func startedDrawing()

    @available(*, unavailable, renamed: "didFinish()")
    func finishedDrawing()
}

public extension SwiftSignatureDelegate {
    func didStart() {}
    func didFinish() {}
}

