//
//  AppDelegate.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/24/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Override point for customization after application launch.
        
        // creates a connection to the server
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                let api = API();
                configuration.applicationId = api.applicationId
                configuration.server = api.server
                
            })
        )
        print("hello")
        // Makes the auto generated navigation elements match the reset of the app
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "MarkerFelt-Wide", size: 23)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 1, blue: 0.5923928618, alpha: 1)], for: UIControl.State.normal)
        
        // Checks to see if there is a user connected with this phone
        if PFUser.current() == nil{
            PFUser.enableAutomaticUser() // if there is no user one is created
            
            // the users location and karma is set
            PFGeoPoint.geoPointForCurrentLocation { (point, error) in
                if let point = point{
                    PFUser.current()?.userLocation = point
                    PFUser.current()?.experiencePoints = 0
                }else{
                    print(error!.localizedDescription)
                }
            }
            
            
            // The user data is sent to the server
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if let error = error{
                    print(error.localizedDescription)
                } else{
                    print("Automatic User Created. 😁")
                    print("CREATED: 🦄 Username: \(PFUser.current()?.username ?? "No username") 🦄")
                }
            })
        }else {
            // debug print if the users an account
            print("🦄 Username: \(PFUser.current()?.username ?? "No username") 🦄")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

