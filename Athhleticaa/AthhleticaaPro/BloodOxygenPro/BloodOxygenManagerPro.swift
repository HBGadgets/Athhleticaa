//
//  BloodOxygenManagerPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 16/03/26.
//

import Foundation
import Combine

class BloodOxygenManagerPro: ObservableObject {
    @Published var bloodOxygenDict: [String: [String: String]] = [:]

    /// Reads blood oxygen data for a given day and returns whether parsing succeeded.
    func readBloodOxygenData(day: Int, completion: @escaping () -> Void) {
        let raw = VPDataBaseOperation.veepooSDKGetDeviceOxygenData(
            withDate: day.getOneDayDateString(),
            andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress
        )
        
//        print("raw blood oxygen data for date: \(day.getOneDayDateString()) ======>>>>> \(raw)")

        // Reset first
        bloodOxygenDict.removeAll()

        guard let anyArray = raw as? [Any] else {
            // If SDK returns nil or unexpected type, report failure gracefully
            completion()
            return
        }

        // Try to coerce the returned structure into [String: [String: String]]
        var result: [String: [String: String]] = [:]

        for element in anyArray {
            if let dict = element as? [String: Any] {
                // Determine a key to index by. Prefer a timestamp/date key if present, otherwise use an incrementing index.
                let key: String
                if let ts = dict["time"] as? String { // common pattern from Veepoo SDK samples
                    key = ts
                } else if let date = dict["date"] as? String {
                    key = date
                } else if let id = dict["id"] as? CustomStringConvertible {
                    key = String(describing: id)
                } else {
                    key = UUID().uuidString
                }

                // Map values to String: String
                var inner: [String: String] = [:]
                for (k, v) in dict {
                    switch v {
                    case let s as String:
                        inner[k] = s
                    case let n as NSNumber:
                        inner[k] = n.stringValue
                    case let i as Int:
                        inner[k] = String(i)
                    case let d as Double:
                        inner[k] = String(d)
                    case let b as Bool:
                        inner[k] = String(b)
                    default:
                        // Skip unsupported nested structures
                        continue
                    }
                }
                result[key] = inner
            } else if let strDict = element as? [String: String] {
                // If already string-to-string, store with a generated key
                result[UUID().uuidString] = strDict
            }
        }

        self.bloodOxygenDict = result
        completion()
    }
}
