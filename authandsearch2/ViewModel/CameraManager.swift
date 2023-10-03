//
//  CameraManager.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-02.
//
import SwiftUI
import Foundation
import AVFoundation

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    
    var session = AVCaptureSession()
    var output = AVCapturePhotoOutput()
    var preview: AVCaptureVideoPreviewLayer!
    var isTaken = false
    var isFlashOn = false
    var isUsingFrontCamera = false
    var picData = Data(count: 0)
    var alert = false
    var isSaved = false
    // All your AVCapture related methods like setUp, Check, toggleCamera, toggleFlash, etc.
    
    func setUp() {
        // setting up camera
        
        do {
            
            // setting configs..
            self.session.beginConfiguration()
            
            // change for your own
            
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    
                    //checking and adding to session
                    
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                        print("Input has been added")
                    }
                    
                }  catch {
                    print(error.localizedDescription)
                }
                // Same for outputs...
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                    print("Output has been added")
                }
                
                self.session.commitConfiguration()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func Check() {
        //first checking cameras got permission..
        switch AVCaptureDevice.authorizationStatus(for:  .video) {
        case .authorized:
            //setting up session
            setUp()
            print("Setup func has been called")
            return
        case .notDetermined:
            // retesting for permission...
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUp()
                }
            }
            
        case .denied:
            self.alert.toggle()
            return
        default:
            return
            
        }
        
    }
    
    func toggleCamera() {
        session.beginConfiguration()
        // Remove existing input
        guard let currentInput = session.inputs.first else { return }
        session.removeInput(currentInput)
        
        // Configure new input
        let newCameraPosition: AVCaptureDevice.Position = isUsingFrontCamera ? .back : .front
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newCameraPosition) else { return }
        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                isUsingFrontCamera.toggle()
            }
        } catch {
            print(error.localizedDescription)
        }
        session.commitConfiguration()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            let settings = AVCapturePhotoSettings()
            settings.flashMode = self.isFlashOn ? .on : .off  // Set flash mode based on isFlashOn state
            self.output.capturePhoto(with: settings, delegate: self)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    self.session.stopRunning()
                }
            }
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
            }
        }
    }
    
    func reTake() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                // clearing
                self.isSaved = false
            }
        }
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("Inside photoOutput function")
        if error != nil{
            print("\(error!.localizedDescription)")
            return
        }
        
        print("pic taken...")
        // print("Image Data Size: \(imageData.count)")
        
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        self.picData = imageData
        // self.isSaved = false
        
        
        
    }
    
    
    
    // ... (the ones that are in CameraModel right now)

    // You also need the delegates like photoOutput
    
    // ...
}
