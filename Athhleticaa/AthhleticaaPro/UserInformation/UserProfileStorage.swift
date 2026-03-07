//
//  UserProfileStorage.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 07/03/26.
//

import Foundation

struct UserProfile: Codable {
    
    var gender: Int        // 0 female, 1 male
    var birthDate: Date
    var height: Int        // cm
    var weight: Int        // kg
    
    var targetSteps: Int = 8000
    var targetSleep: Int = 480
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
}

class UserProfileStorage {

    private static let key = "user_profile"

    static func save(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
}
