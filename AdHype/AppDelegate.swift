//
//  AppDelegate.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/14/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
import Firebase
import pop

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        let navViewController = window!.rootViewController as! HypeNavViewController
        let storyboard = UIStoryboard(name: "Helper Views", bundle: nil)
        let helperViewController = storyboard.instantiateViewControllerWithIdentifier("helperViewPageVC") as! HelperViewPageVC
        navViewController.helpViewController = helperViewController
        
        
//
////        var storyboard = UIStoryboard(name: "Settings Nav View", bundle:nil)
////        let settingsViewController = storyboard.instantiateViewControllerWithIdentifier("settingsNavVC") as! SettingsNavVC
////        
////        navViewController.settingsViewController = settingsViewController
//        
//        var storyboard = UIStoryboard(name: "Main Hype View", bundle:nil)
//        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainHypeView") as! MainViewController
//        mainViewController.delegate = navViewController
//        
//        navViewController.mainViewController = mainViewController
//        
////        storyboard = UIStoryboard(name: "Grid View", bundle:nil)
////        let gridViewController = storyboard.instantiateViewControllerWithIdentifier("gridViewController") as! GridViewController
////        gridViewController.delegate = navViewController
//
//        storyboard = UIStoryboard(name: "AdBrowser", bundle: nil)
//        let gridViewController = storyboard.instantiateViewControllerWithIdentifier("adBrowserVC") as! AdBrowserViewController
////
//        navViewController.gridViewController = gridViewController
//
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

