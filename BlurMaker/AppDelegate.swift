//
//  AppDelegate.swift
//  BlurMaker
//
//  Created by 许浩渊 on 2022/5/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        window = UIWindow()
        let vc = IntroViewController()

        window?.rootViewController = vc

        window?.makeKeyAndVisible()

        return true
    }


}

