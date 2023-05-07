//
//  AppDelegate.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 20.12.2020.
//

import UIKit
import CircularSpinner
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        UIView.appearance().tintColor = Settings.Color.brand
        CircularSpinner.trackPgColor = Settings.Color.brand
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Settings.Color.brand]
        
        print(DatabaseManager.documentDirectoryURL.path)
        let _ = DatabaseManager.shared
        
        window?.makeKey()
        
        return true
    }


}

