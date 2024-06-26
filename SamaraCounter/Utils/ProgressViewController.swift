//
//  ProgressViewController.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 24.06.2024.
//

import Foundation
import UIKit

enum ProgressState {
    case inProgress
    case allDone
    case partlyDone
    case allError
}

class ProgressViewController: UIViewController {

    private var isProgress: Bool {
        status == .inProgress
    }

    static let spinnerSize = 200.0
    static let shiftHeight = 20.0

    private let spinnerView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize))
    private let titleLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320.0, height: spinnerSize / 2.0))

    let items: [ProgressItemView]
    var okHandle: (() -> Void)? = nil
    var cancelHandle: (() -> Void)? = nil
    var status: ProgressState = .inProgress {
        didSet {
            update(animated: true)
        }
    }

    private let okHeader: UIView = UIButton.createOnView(title: "Отлично!", target: self, action: #selector(okClick))
    private let okCancelHeader: UIView = UIButton.createOnView(title1: "Сойдёт", target1: self, action1: #selector(okClick), title2: "Поправить", target2: self, action2: #selector(cancelClick))
    private let cancelHeader: UIView = UIButton.createOnView(title: "OK", target: self, action: #selector(cancelClick))

    init(items: [ProgressItemView]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.items = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let toolBar = UIToolbar(frame: view.bounds)
        toolBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(toolBar)

        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: ProgressItemView.width, height: spinnerView.frame.size.height + Self.shiftHeight + Double(items.count) * ProgressItemView.height))
        spinnerView.center = CGPointMake(contentView.frame.size.width / 2.0, spinnerView.frame.size.height / 2.0)
        contentView.addSubview(spinnerView)
        contentView.center = CGPointMake(view.frame.size.width / 2.0, view.frame.size.height / 2.0)
        contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.addSubview(contentView)

        update(animated: false)

        for itemView in items {
            contentView.addSubview(itemView)
        }

        titleLabel.frame = CGRect(x: 20.0, y: Self.shiftHeight + Double(items.count) * ProgressItemView.height, width: contentView.frame.size.width - 40.0, height: Self.spinnerSize / 2.0)
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.alpha = 0

        okHeader.alpha = 0
        okHeader.autoresizingMask =  [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        okHeader.frame = CGRect(x: 0.0, y: contentView.frame.size.height - okHeader.frame.size.height, width: contentView.frame.size.width, height: okHeader.frame.size.height)
        contentView.addSubview(okHeader)
        okCancelHeader.alpha = 0
        okCancelHeader.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        okCancelHeader.frame = okHeader.frame
        contentView.addSubview(okCancelHeader)
        cancelHeader.alpha = 0
        cancelHeader.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        cancelHeader.frame = okHeader.frame
        contentView.addSubview(cancelHeader)
    }

    private func updateContent() {
        for (index, itemView) in items.enumerated() {
            let y = (isProgress ? spinnerView.frame.size.height + Self.shiftHeight : 0.0) + Double(index) * ProgressItemView.height
            itemView.frame = CGRect(x: 0, y: y, width: ProgressItemView.width, height: ProgressItemView.height)
        }

        titleLabel.alpha = isProgress ? 0 : 1
        spinnerView.alpha = isProgress ? 1 : 0

        switch status {
        case .inProgress:
            titleLabel.text = ""
            okHeader.alpha = 0
            okCancelHeader.alpha = 0
            cancelHeader.alpha = 0
        case .allDone:
            titleLabel.text = "Ваши показания успешно отправлены."
            okHeader.alpha = 1
            okCancelHeader.alpha = 0
            cancelHeader.alpha = 0
        case .partlyDone:
            titleLabel.text = "Некоторые провайдеры не приняли показания. Хотите изменить данные?"
            okHeader.alpha = 0
            okCancelHeader.alpha = 1
            cancelHeader.alpha = 0
        case .allError:
            titleLabel.text = "Ни один провайдер не принял показания. Попробуйте поправить данные."
            okHeader.alpha = 0
            okCancelHeader.alpha = 0
            cancelHeader.alpha = 1
        }
    }

    func update(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.35) {[weak self] in
                self?.updateContent()
            }
        } else {
            updateContent()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinnerView.startAnimation()
    }

    @objc func okClick(){
        okHandle?()
    }

    @objc func cancelClick(){
        cancelHandle?()
    }

}
