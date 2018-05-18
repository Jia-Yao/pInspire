//
//  AppDelegate.swift
//  pInspire
//
//  Created by Jia Yao on 4/28/18.
//  Copyright © 2018 parachute. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import UserNotifications
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        // Facebook required
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // navigation bar customize color
        let navigationBarAppearace = UINavigationBar.appearance()
        
        // Color of Navigation Bar background
        navigationBarAppearace.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.3490196078, blue: 0.4509803922, alpha: 1)
        // Color of Navigation Bar Title
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                      NSAttributedStringKey.font: UIFont(name: "Georgia-Bold", size: 24)!] as [NSAttributedStringKey : Any]
        // Color of Navigation Bar back indicator, button titles, button images
        navigationBarAppearace.tintColor = UIColor.white
        
        // Color of Tab bar items
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        UITabBar.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerForPushNotifications()
        return true
    }
    
    func scheduleNotification(at date: Date) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Tutorial Reminder"
        content.body = "Just a reminder to read your tutorial over at appcoda.com!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    
    /* func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Facebook required (for iOS 9 and below)
        return SDKApplicationDelegate.shared.application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
    */
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        // Facebook required (for iOS 10 and above)
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
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
        // Facebook required
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    var restrictRotation: TypeInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch self.restrictRotation {
        case .all:
            return UIInterfaceOrientationMask.all
        case .portrait:
            return UIInterfaceOrientationMask.portrait
        case .landscape:
            return UIInterfaceOrientationMask.landscape
        }
    }
    
    enum TypeInterfaceOrientationMask {
        case all
        case portrait
        case landscape
    }
}

func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
        (granted, error) in
        print("Permission granted: \(granted)")
        
        guard granted else { return }
        getNotificationSettings()
    }
}

func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        UIApplication.shared.registerForRemoteNotifications()
    }
}
