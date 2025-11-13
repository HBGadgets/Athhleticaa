//
//  HealthManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 12/11/25.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    // MARK: - Request permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let writeTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]

        let readTypes = writeTypes

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            completion(success && error == nil)
        }
    }

    // MARK: - Save Steps
    func saveSteps(count: Int, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let quantity = HKQuantity(unit: .count(), doubleValue: Double(count))
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)

        healthStore.save(sample) { success, error in
            print(success ? "✅ Saved steps to HealthKit" : "❌ Failed to save steps: \(error?.localizedDescription ?? "")")
        }
    }

    // MARK: - Save Calories
    func saveCalories(_ kcal: Double, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: kcal)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)
        healthStore.save(sample) { success, _ in
            print(success ? "✅ Calories saved" : "❌ Failed to save calories")
        }
    }

    // MARK: - Save Distance
    func saveDistance(_ meters: Double, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let quantity = HKQuantity(unit: .meter(), doubleValue: meters)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)
        healthStore.save(sample) { success, _ in
            print(success ? "✅ Distance saved" : "❌ Failed to save distance")
        }
    }

    // MARK: - Save Sleep
    func saveSleep(start: Date, end: Date, asleep: Bool) {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let value = asleep ? HKCategoryValueSleepAnalysis.asleep.rawValue : HKCategoryValueSleepAnalysis.inBed.rawValue
        let sample = HKCategorySample(type: type, value: value, start: start, end: end)
        healthStore.save(sample) { success, _ in
            print(success ? "✅ Sleep saved" : "❌ Failed to save sleep")
        }
    }

    // MARK: - Save Heart Rate
    func saveHeartRate(bpm: Int, date: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let quantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(bpm))
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        healthStore.save(sample) { success, _ in
            print(success ? "✅ Heart rate saved" : "❌ Failed to save heart rate")
        }
    }

    // MARK: - Read Today's Steps
    func readTodaySteps(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            completion(value)
        }

        healthStore.execute(query)
    }
}
