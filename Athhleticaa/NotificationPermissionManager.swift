//
//  NotificationManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 09/02/26.
//

import UserNotifications

final class NotificationPermissionManager {

    static let shared = NotificationPermissionManager()

    private init() {}

    func requestPermissionIfNeeded(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {

            case .authorized, .provisional:
                completion?(true)

            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        completion?(granted)
                    }
                }

            case .denied:
                completion?(false)

            @unknown default:
                completion?(false)
            }
        }
    }
}
