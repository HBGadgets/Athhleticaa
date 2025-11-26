//
//  Untitled.swift
//  Athhleticaa
//
//  Created by Dipanshu Kashyap on 12/11/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var ringManager: QCCentralManager
    @State private var gestureTimer: Timer? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var showPreview = false

    @StateObject private var cameraModel: CameraViewModel

    init(ringManager: QCCentralManager) {
        self.ringManager = ringManager
        _cameraModel = StateObject(wrappedValue: CameraViewModel(ringManager: ringManager))
    }


    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            ringManager.lastCapturedImage = image       // ⭐ Store it for UI
            print("✅ Photo saved to gallery")
        }
    }



    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        cameraModel.flipCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: {
                        cameraModel.toggleFlash()
                    }) {
                        Image(systemName: cameraModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(cameraModel.isFlashOn ? .yellow : .white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        ringManager.stopPhotoUI() {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.backward.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(cameraModel.isFlashOn ? .yellow : .white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                    
                    Button(action: {
                        cameraModel.takePhoto()
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 80, height: 80)
                            .padding(.bottom, 20)
                    }
                    
                    Spacer()
                    
                    if let img = ringManager.lastCapturedImage {
                        Button(action: { showPreview = true }) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                )
                                .padding(.leading, 20)
                        }
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .alert("Camera Access Needed",
               isPresented: $ringManager.showCameraDeniedAlert) {

            Button("Cancel", role: .cancel) {
                dismiss()
            }

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .keyboardShortcut(.defaultAction)

        } message: {
            Text("Please allow camera access in Settings to take pictures using your ring.")
        }
        .onDisappear() {
            ringManager.stopPhotoUI()
        }
        .onAppear {
            cameraModel.configure() { success in
                if success {
                    ringManager.switchToPhotoUI()

                    // Register gesture callback from watch
                    QCSDKManager.shareInstance().takePicture = { [weak cameraModel] in
                        print("📸 Watch gesture detected!")
                        cameraModel?.takePhoto()
                    }
                } else {
                    ringManager.showCameraDeniedAlert = true
                }
            }
            
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let img = ringManager.lastCapturedImage {
                ZStack {
                    Color.black.ignoresSafeArea()

                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()

                    VStack {
                        HStack {
                            Button(action: { showPreview = false }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }

    }

    private func stopCameraAndTimer() {
        cameraModel.stopSession()
        gestureTimer?.invalidate()
        gestureTimer = nil
    }
}


final class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @ObservedObject var ringManager: QCCentralManager
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn = false
    @Published var currentPosition: AVCaptureDevice.Position = .back
    
    private var currentInput: AVCaptureDeviceInput?
    
    init(ringManager: QCCentralManager) {
            self.ringManager = ringManager
            super.init()
        }
    
    func flipCamera() {
        session.beginConfiguration()

        // Remove existing input
        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }

        currentPosition = currentPosition == .back ? .front : .back
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition)

        guard let newDevice = device,
              let newInput = try? AVCaptureDeviceInput(device: newDevice),
              session.canAddInput(newInput) else {
            print("❌ Failed to switch camera")
            session.commitConfiguration()
            return
        }

        session.addInput(newInput)
        currentInput = newInput

        session.commitConfiguration()
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }


    func configure(completion: @escaping (Bool) -> Void) {
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Cannot access camera")
            completion(false)
            return
        }

        session.addInput(input)
        self.currentInput = input   // IMPORTANT

        guard session.canAddOutput(output) else {
            completion(false)
            return
        }

        session.addOutput(output)
        session.commitConfiguration()
        session.startRunning()

        completion(true)
    }

    func stopSession() {
        session.stopRunning()
    }

    func takePhoto() {
        
//        AudioServicesPlaySystemSound(1108)
        let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        let settings = AVCapturePhotoSettings()

        if output.supportedFlashModes.contains(.on),
           output.supportedFlashModes.contains(.off) {

            settings.flashMode = isFlashOn ? .on : .off
        }

        output.capturePhoto(with: settings, delegate: self)
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            ringManager.lastCapturedImage = image
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
