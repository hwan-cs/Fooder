//
//  AppDelegate.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/19.
//

import UIKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        GMSPlacesClient.provideAPIKey(K.placesAPIKey)
        return true
    }
}

