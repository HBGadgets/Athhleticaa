//
//  Untitled.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 12/11/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraModel = CameraViewModel()
    @ObservedObject var ringManager: QCCentralManager
    @State private var gestureTimer: Timer? = nil

    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Button(action: {
                    cameraModel.takePhoto()
                }) {
                    Circle()
                        .stroke(Color.white, lineWidth: 5)
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            cameraModel.configure()
            ringManager.switchToPhotoUI()

            // Register gesture callback from watch
            QCSDKManager.shareInstance().takePicture = { [weak cameraModel] in
                print("📸 Watch gesture detected!")
                cameraModel?.takePhoto()
            }
        }
        .onDisappear {
            ringManager.stopPhotoUI()
        }
    }

    private func stopCameraAndTimer() {
        cameraModel.stopSession()
        gestureTimer?.invalidate()
        gestureTimer = nil
    }
}


final class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func configure() {
        session.beginConfiguration()

        // Input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Cannot access camera")
            return
        }
        session.addInput(input)

        // Output
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        session.commitConfiguration()
        session.startRunning()
    }

    func stopSession() {
        session.stopRunning()
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("✅ Photo saved to gallery")
        }
    }
}

// UIViewRepresentable to show live camera
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
