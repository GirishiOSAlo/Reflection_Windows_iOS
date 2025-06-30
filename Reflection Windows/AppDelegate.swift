//
//  AppDelegate.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/02/24.
//

import UIKit
import SVProgressHUD
import FreshchatSDK
import Firebase
import IQKeyboardManagerSwift
import SquareInAppPaymentsSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = (UIApplication.shared.delegate as! AppDelegate)
    lazy var netWorker: NetWorker = { NetWorker { UIAlertController.showAlert(titleString: $0){ _ in
        NetWorker.isShowNoInternet = true
    } } }()


    var window: UIWindow?
    let gcmMessageIDKey = "gcmMessageIDKey"
    
    //iPad screen orietation fixed....
    var orientationLock: UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SVProgressHUD.setDefaultMaskType(.clear)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        FirebaseApp.configure()
        
        let freshchatConfig:FreshchatConfig = FreshchatConfig.init(appID: Constants.freshChatAppID, andAppKey: Constants.freshChatAppKey)
        freshchatConfig.gallerySelectionEnabled = true;
        // set FALSE to disable picture selection for messaging via gallery
        freshchatConfig.cameraCaptureEnabled = true;
        // set FALSE to disable picture selection for messaging via camera
        freshchatConfig.teamMemberInfoVisible = true;
        // set to FALSE to turn off showing
        freshchatConfig.showNotificationBanner = true;
        // set to FALSE if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        //            freshchatConfig.responseExpectations = true;
        //set to FALSE if you want to hide the response expectations for the Topics
        
        freshchatConfig.domain = Constants.freshChatDomain
        Freshchat.sharedInstance().initWith(freshchatConfig)
        
        // Set your Square Application ID
//        SQIPInAppPaymentsSDK.squareApplicationID = Constants.Square.SAND_APPLICATION_ID //UAT
        SQIPInAppPaymentsSDK.squareApplicationID = Constants.Square.PRODUCTION_APPLICATION_ID //Live
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Yay! Got a device token 🥳 \(deviceToken)")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")

//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FCMToken"), object: nil)

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        return [[.alert, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
}
