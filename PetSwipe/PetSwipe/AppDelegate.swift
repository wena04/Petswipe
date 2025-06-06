//
//  AppDelegate.swift
//  PetSwipe
//
//  Created by George Lee on 5/19/25.
//

import UIKit
import Firebase
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // jess - reset profile variables
        let keysToRemove = ["savedName", "savedEmail", "savedPhone"]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }

        // Init Firebase
        FirebaseApp.configure()
        testFetchPetsFromFirestore()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
        // Check firebase config
//        print("Firebase configured: \(FirebaseApp.app() != nil)")
    }

}

