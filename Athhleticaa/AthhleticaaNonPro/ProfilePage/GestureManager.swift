//
//  GestureManager.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 21/11/25.
//

//class GestureManager: ObservableObject {
//    func getTouchControl() {
//        QCSDKCmdCreator.setTime(Date(), success: { featureList in
//            
//            guard let supported = featureList[QCBandFeatureTouchControl] as? Bool, supported else {
//                return
//            }
//
//            var supportedTypes: [NSNumber] = [NSNumber(value: QCDFU_Utils.self.)]
//
//            if (featureList[QCBandFeatureGestureControlMusic] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeMusic.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlVideo] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeVideo.rawValue))
//            }
//            if (featureList[QCBandFeatureMSLPraise] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeMSLPraise.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlEBook] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeEBook.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlTakePhoto] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeTakePhoto.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlPhoneCall] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypePhoneCall.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlGame] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeGame.rawValue))
//            }
//            if (featureList[QCBandFeatureGestureControlHRMeasure] as? Bool) == true {
//                supportedTypes.append(NSNumber(value: QCTouchGestureControlTypeHRMeasure.rawValue))
//            }
//
//            let controlType = QCTouchGestureControlTypeOff
//
//            QCSDKCmdCreator.setTouchControl(controlType, strength: 1, duration: 3) { error in
//                print("TouchControl set:", error?.localizedDescription ?? "OK")
//            }
//            
//        }, failed: {
//            print("❌ setTime failed")
//        })
//    }
//
//}
