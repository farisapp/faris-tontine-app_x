import UIKit
import Flutter
import GoogleMaps
import Firebase
import flutter_foreground_task
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 🗺️ Clé API Google Maps
    GMSServices.provideAPIKey("AIzaSyB8awCcyz8lQoHizYM2mfew1fUUiMyLK50")

    // 🚀 Configuration de Firebase
    FirebaseApp.configure()

    // 🔔 Notifications iOS (10+)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()

    // 📩 Firebase Messaging
    Messaging.messaging().delegate = self

    // 🟢 Callback Foreground Task Flutter
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // 📦 Plugins Flutter
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 🔁 Gestion des tokens FCM
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔐 FCM Token: \(fcmToken ?? "")")
    // ➕ Tu peux ici envoyer le token à ton serveur via HTTP si besoin
  }

  // 🔔 Réception de notifications en foreground (iOS 10+)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }

  // 📥 Gestion de la réponse à une notification
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}
