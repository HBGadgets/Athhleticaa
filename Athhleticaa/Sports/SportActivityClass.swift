//
//  SportActivities.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 27/11/25.
//

struct SportActivity: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let sportType: OdmSportPlusExerciseModelType
}
