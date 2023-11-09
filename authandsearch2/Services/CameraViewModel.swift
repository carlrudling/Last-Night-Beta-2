//
//  CameraViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-07.
//

//import Foundation




/*
 
 struct CamerVIEW2Kavsoft: View {
 var body: some View {
 CameraView2()
 }
 }
 
 struct CamerVIEW2Kavsoft_Previews: PreviewProvider {
 static var previews: some View {
 CameraView2()
 }
 }
 */

//Camera Model...

import SwiftUI
import AVFoundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class CameraModel: NSObject, ObservableObject,  AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    
    @Published var uuidGlobal : String = ""
    @Published var isFlashOn: Bool = false
    @Published var isUsingFrontCamera: Bool = false
    
    // Since wew going to read pic data...
    @Published var output = AVCapturePhotoOutput()
    @Published var metadataOutput = AVCaptureMetadataOutput()
    // preview
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    @Published var isSaved = false
    @Published var isSaving = false
    @Published var picData = Data(count: 0)
    var qrCodeFoundHandler: ((String) -> Void)?
    
    
    func Check() {
        let startDate = Date()
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
        print("Setup: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")

        
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
    
    
    func setUp() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            let startDate = Date()
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
                    
                    if self.session.canAddOutput(self.metadataOutput) {
                                    self.session.addOutput(self.metadataOutput)
                                    
                                    self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                                    self.metadataOutput.metadataObjectTypes = [.qr] // you can add other types you need like: .ean13, .ean8
                            }
                    
                    self.session.commitConfiguration()
                    print("Setup: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    // take and retake functions...
    
    func takePic() {
   
        DispatchQueue.global(qos: .userInitiated).async {
            let startDate = Date()
            let settings = AVCapturePhotoSettings()
            settings.flashMode = self.isFlashOn ? .on : .off  // Set flash mode based on isFlashOn state
            self.output.capturePhoto(with: settings, delegate: self)
            DispatchQueue.main.async {
                let startDates = Date()
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    self.session.stopRunning()
                    print("TakePic, main Queue: \(Date().timeIntervalSince1970 - startDates.timeIntervalSince1970)")

                }
            }
            DispatchQueue.main.async {
                withAnimation { self.isTaken.toggle() }
            }
            print("TakePic, when finished: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")

        }
    }
    
    func reTake() {
        let startDate = Date()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            print("Retake, after starting session again: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")

            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                // clearing
                self.isSaved = false
            }
            
        }
        print("Retake, when finished: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")

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
    
    
    
    func savePost(completion: @escaping (Bool, String?) -> Void) {
        let startDate = Date()
        DispatchQueue.global().async {
            
         
            print(" \(self.picData.count)")
            guard let image = UIImage(data: self.picData) else {
                print("Failed to create UIImage from picData.")
                return
            }
            let uuid = UUID().uuidString
            
            // Step 1: Upload the image to Firebase Storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("\(uuid).jpg") // Unique name for the image
            let imageData = image.jpegData(compressionQuality: 0.8)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            self.uuidGlobal = uuid
            
            print("The uuidGlobal is \(self.uuidGlobal)")
            
            if let imageData = imageData {
                imageRef.putData(imageData, metadata: metadata) { metadata, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error uploading image: \(error)")
                            completion(false, nil)
                            print("SavePost: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")

                        } else {
                            // Fetch the download URL
                            imageRef.downloadURL { (url, error) in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        print("Error fetching download URL: \(error)")
                                        completion(false, nil)
                                        
                                    } else if let downloadURL = url {
                                        print("Image uploaded and download URL fetched!")
                                        completion(true, downloadURL.absoluteString) // Pass the URL string to the completion handler
                                        print("SavePost: \(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)")
                                        withAnimation(.default) {
                                            self.isSaved = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
            
        
            
        }

    }
    
    
    
    
    // FOR QR-Codes, and Metadata

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                found(code: readableObject.stringValue!)
            }
        }
    
    
    func found(code: String) {
           print("QR Code Detected: \(code)")
            qrCodeFoundHandler?(code)
           // You can add further actions that you want to perform when a QR code is found
       }
    
    
}



//Setting view for preview...


struct CameraPreview: UIViewRepresentable {
    @EnvironmentObject var post: PostViewModel
    @ObservedObject var camera : CameraModel
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your own properties...
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        //starting session
        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

