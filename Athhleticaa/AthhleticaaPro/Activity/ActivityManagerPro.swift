//
//  ActivityManagerPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 12/03/26.
//

struct StepsDataString {
    let totalSteps: String
    let calories: String
    let distance: String
}

class ActivityManagerPro: ObservableObject {
    @Published var stepsData: StepsDataString?
    @Published var stepsDataDetails: StepsDataString?
    
    func readOneDayActivityData(completion: @escaping (StepsDataString?) -> Void) {
        VPDataBaseOperation.veepooSDKGetStepData(
            withDate: 0.getOneDayDateString(),
            andTableID: VPBleCentralManage.sharedBleManager().peripheralModel.deviceAddress,
            changeUserStature: VPBleCentralManage.sharedBleManager().peripheralModel.deviceStature
        ) { stepDataBaseDict in

            guard let stepDict = stepDataBaseDict as? [String: String] else {
                print("couldn't get steps data")
                completion(nil)
                return
            }

            let data = StepsDataString(
                totalSteps: stepDict["Step"] ?? "0",
                calories: stepDict["Cal"] ?? "0",
                distance: stepDict["Dis"] ?? "0"
            )

            DispatchQueue.main.async {
                self.stepsData = data
                completion(data)
            }

            print("\(data.totalSteps) total steps taken")
        }
    }
}

extension Int {
    func getOneDayDateString() -> String {//通过数值得到于今天差距的日期字符串
        let todayDate = Date(timeIntervalSinceNow: 0)
        
        let currentCalendar = Calendar.current
        
        let date = currentCalendar.date(byAdding: .day, value: self, to: todayDate)
        
        let year = currentCalendar.component(.year, from: date!)
        
        let month = currentCalendar.component(.month, from: date!)
        
        let day = currentCalendar.component(.day, from: date!)
        
        return String(year) + "-" + String(format: "%02d", month) + "-" + String(format: "%02d", day)
    }
}
