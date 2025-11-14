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

    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let allTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]

        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { success, error in
            completion(success && error == nil)
        }
    }

    // =========================================================
    // MARK: - WRITE DATA
    // =========================================================

    func saveSteps(count: Int, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let quantity = HKQuantity(unit: .count(), doubleValue: Double(count))
        saveSample(type: type, quantity: quantity, start: start, end: end, label: "steps")
    }

    func saveActiveEnergy(_ kcal: Double, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: kcal)
        saveSample(type: type, quantity: quantity, start: start, end: end, label: "active energy")
    }

    func saveDistance(_ meters: Double, start: Date, end: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let quantity = HKQuantity(unit: .meter(), doubleValue: meters)
        saveSample(type: type, quantity: quantity, start: start, end: end, label: "distance")
    }

    func saveHeartRate(_ bpm: Int, date: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let quantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(bpm))
        saveSample(type: type, quantity: quantity, start: date, end: date, label: "heart rate")
    }

    func saveSleep(start: Date, end: Date, asleep: Bool) {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let value = asleep ? HKCategoryValueSleepAnalysis.asleep.rawValue : HKCategoryValueSleepAnalysis.inBed.rawValue
        let sample = HKCategorySample(type: type, value: value, start: start, end: end)
        healthStore.save(sample) { success, error in
            print(success ? "✅ Saved sleep" : "❌ Sleep save failed: \(error?.localizedDescription ?? "")")
        }
    }
    
    func saveHRV(_ ms: Double, date: Date) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        let quantity = HKQuantity(unit: HKUnit.secondUnit(with: .milli), doubleValue: ms)
        
        let sample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            print(success ? "✅ Saved HRV" : "❌ Failed to save HRV: \(error?.localizedDescription ?? "")")
        }
    }

    private func saveSample(type: HKQuantityType, quantity: HKQuantity, start: Date, end: Date, label: String) {
        let sample = HKQuantitySample(type: type, quantity: quantity, start: start, end: end)
        healthStore.save(sample) { success, error in
            print(success ? "✅ Saved \(label)" : "❌ Failed to save \(label): \(error?.localizedDescription ?? "")")
        }
    }

    // =========================================================
    // MARK: - READ DATA
    // =========================================================

    // MARK: Read Steps (Total Today)
    func readTodaySteps(completion: @escaping (Double) -> Void) {
        readCumulativeQuantity(typeIdentifier: .stepCount, unit: .count(), completion: completion)
    }

    // MARK: Read Active Energy Burned (Total Today)
    func readTodayActiveEnergy(completion: @escaping (Double) -> Void) {
        readCumulativeQuantity(typeIdentifier: .activeEnergyBurned, unit: .kilocalorie(), completion: completion)
    }

    // MARK: Read Walking + Running Distance (Total Today)
    func readTodayDistance(completion: @escaping (Double) -> Void) {
        readCumulativeQuantity(typeIdentifier: .distanceWalkingRunning, unit: .meter(), completion: completion)
    }

    // MARK: Read Average Heart Rate (Today)
    func readTodayHeartRateAverage(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            completion(value)
        }
        healthStore.execute(query)
    }

    // MARK: Read Sleep (All Segments in Last 24h)
    func readRecentSleep(completion: @escaping ([HKCategorySample]) -> Void) {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            let sleepSamples = samples as? [HKCategorySample] ?? []
            completion(sleepSamples)
        }
        healthStore.execute(query)
    }

    // MARK: - Generic Helper for Cumulative Queries
    private func readCumulativeQuantity(
        typeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        completion: @escaping (Double) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completion(value)
        }

        healthStore.execute(query)
    }
}
