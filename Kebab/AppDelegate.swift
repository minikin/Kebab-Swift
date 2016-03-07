//
//  AppDelegate.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/18/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit
import GSMessages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    // Override point for customization after application launch.
    
    // Customise switch in setting menu
    
    UISwitch.appearance().onTintColor = Theme.Labels.mainColor.colorWithAlphaComponent(0.7)
    UISwitch.appearance().tintColor = Theme.Labels.mainColor.colorWithAlphaComponent(0.2)
    UISwitch.appearance().thumbTintColor = Theme.Text.mainColor
  
    // User defaults on the first launch
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.registerDefaults([ "Junkfood categories" : JunkFoodType.Kebab.rawValue,
                                "Search radius" : SearchRadius.four.rawValue,
                                "SwitchState" : true])
    
    // Set GSMessage background colors
    
    GSMessage.warningBackgroundColor = Theme.SPMessageWarningBackground.SPMessageStyle
    GSMessage.errorBackgroundColor = Theme.SPMessageErrorBackground.SPMessageStyle
    GSMessage.infoBackgroundColor = Theme.SPMessageInfoBackground.SPMessageStyle
    
    
    // This is helpful when developing the app.
    
    let key = "MGLMapboxAccessToken"
    assert(NSBundle.mainBundle().objectForInfoDictionaryKey(key) != nil, "An access token is necessary to use Mapbox services and APIs, such as maps, directions, and telemetry the \(key) key in your Info.plist. Please, read more here: https://www.mapbox.com/ios-sdk/")
    
    return true
    
  }
  
//  // Application state saving and restoring
//  
//  func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//    return true
//  }
//  
//  func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
//    return true
//  }
  
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

