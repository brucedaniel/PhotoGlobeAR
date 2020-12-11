//
//  AppDelegate.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/9/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIFont.familyNames.forEach({ familyName in
                    let fontNames = UIFont.fontNames(forFamilyName: familyName)
                    print(familyName, fontNames)
                })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

}

