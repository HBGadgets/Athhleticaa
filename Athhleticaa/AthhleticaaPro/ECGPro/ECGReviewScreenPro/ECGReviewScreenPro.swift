//
//  ECGReviewScreenPro.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 28/03/26.
//

import SwiftUI

struct ECGReviewScreenPro: View {
    var vpECGTestDataModel: VPECGTestDataModel
    
    var body: some View {
        VStack {
            ECGHeartRateInfoCard(vpECGTestDataModel: vpECGTestDataModel)
            Text(vpECGTestDataModel.result1)
            Text(vpECGTestDataModel.result2)
            Text(vpECGTestDataModel.result3)
            Text(vpECGTestDataModel.result4)
            Text(vpECGTestDataModel.result5)
            Text(vpECGTestDataModel.result6)
            Text(vpECGTestDataModel.result7)
            Text(vpECGTestDataModel.result8)
            Text(vpECGTestDataModel.multipleDiagnosisTempStr)
        }
        .onAppear() {
            for heartrate in vpECGTestDataModel.muHearts {
                print(type(of: heartrate))
            }
            print("Heart rates: \(vpECGTestDataModel.muHearts)")
            let reportModel = VPECGTestResutHandle.resultReport(with: vpECGTestDataModel)
            print("Disease Risk: \(reportModel.diseaseRisk)")
            print("Pressure Index: \(reportModel.pressureIndex)")
            print("Fatigue Index: \(reportModel.fatigueIndex)")
            print("Myocarditis Risk: \(reportModel.myocarditisRisk)")
            print("Coronary Heart Disease Risk: \(reportModel.chdRisk)")
        }
    }
}
