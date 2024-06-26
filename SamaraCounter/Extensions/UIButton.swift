//
//  UIButton.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.10.2021.
//

import UIKit


extension UIButton {
    
    static func createOnView(title: String, target: Any?, action: Selector) -> UIView
    {
        let foother = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        foother.backgroundColor = .clear
        
        let btSend = UIButton(frame: CGRect(x: 20, y: 10, width: 60, height: 40))
        btSend.layer.cornerRadius = 8
        btSend.backgroundColor = Settings.Color.brand
        btSend.setTitleColor(.white, for: .normal)
        btSend.setTitleColor(.yellow, for: .highlighted)
        btSend.setTitle(title, for: .normal)
        btSend.addTarget(target, action: action, for: .touchUpInside)
        
        foother.addSubview(btSend)
        btSend.translatesAutoresizingMaskIntoConstraints = false
        btSend.leadingAnchor.constraint(equalTo: foother.leadingAnchor, constant: 20).isActive = true
        btSend.trailingAnchor.constraint(equalTo: foother.trailingAnchor, constant: -20).isActive = true
        btSend.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        btSend.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        btSend.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btSend.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return foother
    }

    static func createOnView(title1: String, target1: Any?, action1: Selector, title2: String, target2: Any?, action2: Selector) -> UIView
    {
        let foother = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        foother.backgroundColor = .clear

        let bt1 = UIButton(frame: CGRect(x: 20, y: 10, width: 60, height: 40))
        bt1.layer.cornerRadius = 8
        bt1.backgroundColor = Settings.Color.brand
        bt1.setTitleColor(.white, for: .normal)
        bt1.setTitleColor(.yellow, for: .highlighted)
        bt1.setTitle(title1, for: .normal)
        bt1.addTarget(target1, action: action1, for: .touchUpInside)
        
        let bt2 = UIButton(frame: CGRect(x: 120, y: 10, width: 60, height: 40))
        bt2.layer.cornerRadius = 8
        bt2.backgroundColor = Settings.Color.brand
        bt2.setTitleColor(.white, for: .normal)
        bt2.setTitleColor(.yellow, for: .highlighted)
        bt2.setTitle(title2, for: .normal)
        bt2.addTarget(target2, action: action2, for: .touchUpInside)

        foother.addSubview(bt1)
        foother.addSubview(bt2)

        bt1.translatesAutoresizingMaskIntoConstraints = false
        bt1.leadingAnchor.constraint(equalTo: foother.leadingAnchor, constant: 20).isActive = true
        bt1.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        bt1.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        bt1.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bt1.heightAnchor.constraint(equalToConstant: 40).isActive = true

        bt2.translatesAutoresizingMaskIntoConstraints = false
        bt2.trailingAnchor.constraint(equalTo: foother.trailingAnchor, constant: -20).isActive = true
        bt2.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        bt2.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        bt2.widthAnchor.constraint(equalToConstant: 60).isActive = true
        bt2.heightAnchor.constraint(equalToConstant: 40).isActive = true


        bt1.trailingAnchor.constraint(equalTo: bt2.leadingAnchor, constant: -20).isActive = true
        bt1.widthAnchor.constraint(equalTo: bt2.widthAnchor, constant: 0).isActive = true

        return foother
    }

}
