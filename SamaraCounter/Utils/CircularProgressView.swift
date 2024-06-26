//
//  CircularProgressView.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.06.2024.
//

import UIKit

class CircularProgressView: UIView {

    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }

    var progressColor = Settings.Color.brand {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    var trackColor = UIColor.lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    fileprivate let indeterminateDuration = 2.0

    fileprivate func generateAnimation() -> CAAnimationGroup {

        let headAnimation = CABasicAnimation(keyPath: "strokeEnd")
        headAnimation.fromValue = 0
        headAnimation.toValue = 1
        headAnimation.duration = indeterminateDuration
        headAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let stopAnimation = CABasicAnimation(keyPath: "strokeStart")
        stopAnimation.beginTime = indeterminateDuration / 3
        stopAnimation.fromValue = 0
        stopAnimation.toValue = 1
        stopAnimation.duration = indeterminateDuration / 3 * 2
        stopAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = indeterminateDuration
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.animations = [
            headAnimation,
            stopAnimation
        ]
        return groupAnimation
    }

    func startAnimation() {
        progressLayer.add(generateAnimation(), forKey: "strokeLineAnimation")
    }

    func stopAnimation() {
        progressLayer.removeAnimation(forKey: "strokeLineAnimation")
    }

}
