//
//  AppDelegate.swift
//  AVPlayerPOC
//
//  Created by Kumari Rajan on 17/03/23.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        handleAudioSessionCategorySetting()
        // Override point for customization after application launch.
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
    }
    
    func handleAudioSessionCategorySetting() {
            let audioSession = AVAudioSession.sharedInstance()
            // When AVAudioSessionCategoryPlayback is already active, we have nothing to do here
            guard audioSession.category.rawValue != AVAudioSession.Category.playback.rawValue else { return }

            do {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback)
            } catch {
                print("Setting category to AVAudioSessionCategoryPlayback failed.")
            }
        }


}

