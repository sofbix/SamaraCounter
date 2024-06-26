//
//  ProgressItemView.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.06.2024.
//

import Foundation
import UIKit

enum ProgressItemStatus {
    case inProgress
    case done
    case error(message: String)
}

class ProgressItemView: UIView {

    static let height = 64.0
    static let width = 300.0
    static let font = UIFont.systemFont(ofSize: 14)
    static let color = UIColor.darkGray

    let title: String
    var status: ProgressItemStatus {
        didSet {
            updateStatus()
        }
    }

    private let titleLabel: UILabel = UILabel(frame: CGRect(x: height, y: 0, width: width - height, height: height))
    private let indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    private let iconView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))

    init(title: String, status: ProgressItemStatus = .inProgress) {
        self.title = title
        self.status = status
        super.init(frame: CGRect(x: 0, y: 0, width: Self.width, height: Self.height))

        titleLabel.font = Self.font
        titleLabel.textAlignment = .left
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)

        indicatorView.color = Settings.Color.brand
        indicatorView.center = CGPoint(x: Self.height / 2.0, y: Self.height / 2.0)
        addSubview(indicatorView)

        iconView.contentMode = .center
        iconView.tintColor = Settings.Color.brand
        addSubview(iconView)

        updateStatus()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateStatus() {
        switch status {
        case .inProgress:
            indicatorView.alpha = 1
            indicatorView.startAnimating()
            iconView.alpha = 0
            titleLabel.textColor = Self.color
            titleLabel.text = title
        case .done:
            indicatorView.alpha = 0
            indicatorView.stopAnimating()
            iconView.image = UIImage(named: "StatusOk")
            iconView.tintColor = .green
            iconView.alpha = 1
            titleLabel.textColor = Self.color
            titleLabel.text = title
        case .error(let message):
            indicatorView.alpha = 0
            indicatorView.stopAnimating()
            iconView.image = UIImage(named: "StatusError")
            iconView.tintColor = .red
            iconView.alpha = 1
            titleLabel.textColor = .red
            let title = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : Self.font, NSAttributedString.Key.foregroundColor: Self.color])
            title.append(NSMutableAttributedString(string: "\n\(message)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11), NSAttributedString.Key.foregroundColor: UIColor.red]))
            titleLabel.attributedText = title
        }
    }
}
