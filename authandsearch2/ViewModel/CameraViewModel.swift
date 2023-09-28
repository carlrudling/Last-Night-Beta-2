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


class CameraModel: NSObject, ObservableObject,  AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    
    @Published var uuidGlobal : String = ""
  /*
    let post: PostViewModel
    let album: AlbumViewModel
    let user: UserViewModel
 
    init(post: PostViewModel, album: AlbumViewModel, user: UserViewModel) {
        self.post = post
        self.album = album
        self.user = user
    }
   */
    
    // Since wew going to read pic data...
    @Published var output = AVCapturePhotoOutput()
    
    // preview
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    
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

   
        // take and retake functions...
        
        func takePic(){
            DispatchQueue.global(qos: .background).async {
                print("Attempting to capture photo...")
                self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
                DispatchQueue.main.async {
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                                self.session.stopRunning()
                               
                                
                            }
                        }
               // DispatchQueue.main.async {
                 //   withAnimation{self.isTaken.toggle()}
                    
              //  }
            }
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
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
        
   
    
    func savePost() {
        print(" \(picData.count)")
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
            uuidGlobal = uuid
            
            
            
            if let imageData = imageData {
                imageRef.putData(imageData, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Error uploading image: \(error)")
                    }
                    
                    if let metadata = metadata {
                        print("Metadata: \(metadata)")
                    }
                    
                    // Step 2: Once the image is uploaded, get the download URL
                    
                }
              
            }
        self.isSaved = true
        
      //  post.createPost(albumID: albumUuid, imageURL: uuid)
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
    
