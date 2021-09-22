//
//  AppDelegate.swift
//  DemoLivePhoto
//
//  Created by Manh Nguyen Ngoc on 22/09/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func cleanupDocumentsDirectory() {
        
        var documentsURL: URL?
        
        do {
            documentsURL = try FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        catch {
            print(error)
            return
        }
        
        if let documentsPath = documentsURL?.path {
            
            guard let en = FileManager.default.enumerator(atPath: documentsPath) else {
                return
            }
            
            while let file = en.nextObject() {
                guard let fileURLToDelete = documentsURL?.appendingPathComponent(file as! String) else {
                    continue
                }
                if FileManager.default.fileExists(atPath: fileURLToDelete.path) {
                    do {
                        
                        try FileManager.default.removeItem(atPath: fileURLToDelete.path)
                        
                    } catch _ as NSError {
                    }
                }
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        cleanupDocumentsDirectory()
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


}

