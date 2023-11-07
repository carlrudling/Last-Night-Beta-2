//
//  CameraView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-07.
//

import SwiftUI
import AVFoundation
import FirebaseFirestoreSwift

struct CameraView: View {
    @State var albumuuid: String
    @State private var selectedAlbumID: String = ""
    @State private var checkCorrectAlbumID = false  // Checks and gives alert if albumID in't pointing to existing album
    @State private var addToAlbumSuccess = false
    @State private var addToAlbumError = false
    
    @StateObject var camera = CameraModel()
    @EnvironmentObject var post: PostViewModel
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var album: AlbumViewModel
    
  
    
    
    func handleQRCode(_ qrCode: String) {
        album.addMembers(documentID: qrCode, member: user.uuid!) { success in
            if success {
                // Update UI to show success message
                print("The user was successfully added to the album.")
                addToAlbumSuccess = true
            } else {
                // Update UI to show error message
                print("There was an error adding the user to the album.")
                addToAlbumError = true
               
            }
        }
    }
    
    var body: some View{
        
        ZStack {
            ZStack{
                
                
                //Going to be the camera preview...
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture(count: 2, perform: {
                        camera.toggleCamera()
                        print("Double tapped!")
                    })
                VStack{
                    AlbumPickerView(selectedAlbumID: $selectedAlbumID)
                 
                        Text("You need to select an album!")
                            .bold()
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .offset(y: checkCorrectAlbumID ? 0 : -30)
                            .opacity(checkCorrectAlbumID ? 1.0 : 0.0)
                            .scaleEffect(checkCorrectAlbumID ? 1.0 : 0.7)
                           
                    
                    
                    Spacer()
                    
                    HStack {
                        
                        
                        // if taken showing save and again take button
                        
                        if camera.isTaken {
                            
                            
                            
                            Button(action: {
                                
                                if selectedAlbumID == "" || selectedAlbumID == "Select album" {
                                    withAnimation(){
                                        checkCorrectAlbumID = true
                                    }
                                    // Setting a timer to revert checkCorrectAlbumID after 3 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation(){
                                                checkCorrectAlbumID = false
                                            }
                                        }
                                        return
                                    
                                }
                                
                                      camera.isSaving = true
                                
                                  
                                DispatchQueue.global(qos: .userInteractive).async {
                                    camera.savePost { success, imageURL in
                                        if success, let imageURL = imageURL {
                                            DispatchQueue.main.async {
                                                camera.reTake() // UI-related task, should be on the main thread
                                            }
                                            
                                            post.createPost(albumId: selectedAlbumID, imagePath: camera.uuidGlobal, imageURL: imageURL, userUUID: user.uuid!)
                                        }
                                        camera.isSaving = false
                                    }
                                }
                            }

                                   , label: {
                                
                                if camera.isSaving {
                                    RotatingDotAnimation()
                                    
                                } else if camera.isSaved {
                                    ZStack {
                                                // Drawing the circle
                                                Circle()
                                                    .fill(Color.green) // Fill circle with green color
                                                    .frame(width: 65, height: 65) // Change this value to resize your circle
                                                
                                                // Placing the checkmark inside the circle
                                                Image(systemName: "checkmark") // SF Symbol for checkmark
                                                    .resizable()
                                                    .foregroundColor(.white) // Making checkmark white
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30) // Change this value to resize your checkmark
                                            }
                                } else if !camera.isSaving && !camera.isSaved {
                                    Text("Save")
                                        .foregroundColor(.black)
                                        .fontWeight(.semibold)
                                        .padding(.vertical,20)
                                        .padding(.horizontal,20)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                    
                                }
                            })
                            .frame(alignment: .center)
                            .padding(.bottom, 60)
                            
                            
                        } else {
                            // Button to take picture
                            Button(action: {camera.takePic()}, label: {
                                
                                ZStack{
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 65, height: 65)
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 75, height: 75)
                                }
                                
                            })
                            .padding(.bottom, 60)
                        }
                    }
                    .frame(height: 75)
                    
                    
                }
                
                VStack {
                    // Buttons
                    HStack{
                        Spacer()
                        VStack {
                            
                            
                            if camera.isTaken {
                                
                                HStack{
                                    // Retake photo Button
                                    Button(action: {camera.reTake()
                                        withAnimation(){
                                            checkCorrectAlbumID = false
                                        }}, label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    })
                                }
                            }
                            // Toggle to frontCamera
                            Button(action: { camera.toggleCamera() }, label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            })
                            
                            // Toggle Flash
                            Button(action: { camera.toggleFlash() }, label: {
                                Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            })
                        }
                        
                        
                    }
                    
                    Spacer()
                }
                
                
                
            }
            
            .popup(isPresented: $camera.alert) {
                VStack{
                    ZStack { // 4
                        
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            Spacer()
                        }
                        
                        VStack {
                            ZStack{
                                Image(systemName: "exclamationmark.circle") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                
                                    .zIndex(1) // Ensure it's above the background
                                Image(systemName: "exclamationmark.circle.fill") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.red)
                                
                                    .zIndex(1) // Ensure it's above the background
                                
                            }
                            
                            Text("Permissions not granted")
                                .font(.system(size: 22))
                                .bold()
                                .padding(.bottom, 5)
                                .padding(.top, 2)
                            
                            Text("To use the camera, you need to allow camera usage in settings.")
                                .font(.system(size: 16))
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            Spacer()
                            
                        }
                        .padding(.top, -40) // Make space for the checkmark at the top
                        
                    }
                    .frame(width: 300, height: 200, alignment: .center)
                    //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                    
                    .background(
                        // Clipped background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 6, x: 0, y: 3)
                    )
                    
                    
                }
                .frame(width: 300, height: 300, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                .background(.clear)
               
       
        
       
        }
            .popup(isPresented: $addToAlbumSuccess) {
                VStack{
                    ZStack { // 4
                        
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            Spacer()
                        }
                        
                        VStack {
                            ZStack{
                                Image(systemName: "checkmark.seal") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                
                                    .zIndex(1) // Ensure it's above the background
                                Image(systemName: "checkmark.seal.fill") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                                
                                    .zIndex(1) // Ensure it's above the background
                                
                            }
                            
                            Text("Success")
                                .font(.system(size: 25))
                                .bold()
                                .padding(.bottom, 5)
                                .padding(.top, 2)
                            
                            Text("You've just joined a new album")
                                .font(.system(size: 18))
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            Spacer()
                            
                        }
                        .padding(.top, -40) // Make space for the checkmark at the top
                        
                    }
                    .frame(width: 300, height: 200, alignment: .center)
                    //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                    
                    .background(
                        // Clipped background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 6, x: 0, y: 3)
                    )
                    
                    
                }
                .frame(width: 300, height: 300, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                .background(.clear)
               
       
        
       
        }
            .popup(isPresented: $addToAlbumError) {
                VStack{
                    ZStack { // 4
                        
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            Spacer()
                        }
                        
                        VStack {
                            ZStack{
                                Image(systemName: "exclamationmark.circle") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                
                                    .zIndex(1) // Ensure it's above the background
                                Image(systemName: "exclamationmark.circle.fill") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.red)
                                
                                    .zIndex(1) // Ensure it's above the background
                                
                            }
                            
                            Text("Error")
                                .font(.system(size: 25))
                                .bold()
                                .padding(.bottom, 5)
                                .padding(.top, 2)
                            
                            Text("Something went wrong.")
                                .font(.system(size: 18))
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            Spacer()
                            
                        }
                        .padding(.top, -40) // Make space for the checkmark at the top
                        
                    }
                    .frame(width: 300, height: 200, alignment: .center)
                    //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                    
                    .background(
                        // Clipped background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    )
                    
                    
                }
                .frame(width: 300, height: 300, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                .background(.clear)
               
       
            }
        }
        .onAppear(perform: {
            camera.Check()
            camera.qrCodeFoundHandler = handleQRCode // Setting the handler when the view appears
    })
        
    }
}
                               
struct RotatingDotAnimation: View {
    
    @State private var startAnimation = false
    @State private var duration = 1.0 // Works as speed, since it repeats forever
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 65, height: 65, alignment: .center)

            Circle()
                .fill(.white)
                .frame(width: 16, height: 16, alignment: .center)
                .offset(x: -23)
                .rotationEffect(.degrees(startAnimation ? 360 : 0))
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false),
                           value: startAnimation
                )
        }
        .onAppear {
            self.startAnimation.toggle()
        }
    }
}



struct AlbumPickerView: View {
   // @StateObject var fetchAlbums = FetchAlbums()
    @EnvironmentObject var album: AlbumViewModel
    @EnvironmentObject var user: UserViewModel
    @State var albumName: String = ""
    @Binding var selectedAlbumID: String
    
    @State private var showList = false  // State variable to control visibility of list
    
    var body: some View {
        VStack {
            // Button to toggle list visibility
            Button(action: {
                withAnimation {  // Animates the transition
                    self.showList.toggle()  // Toggle showList value between true and false
                }
            }) {
                
                Text(albumName == "" ? "Select album" : albumName)
                    .foregroundColor(Color.white)
                
            }
            .frame(width: 180)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
            .contentShape(Rectangle())
            
            
            if showList {
                HStack {
                    ScrollView {
                        VStack {
                            ForEach(album.queryResultAlbums, id: \.uuid) { album in
                                if album.isActive {
                                    Text(album.albumName)
                                        .frame(width: 180)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                                        .contentShape(Rectangle())
                                    
                                        .onTapGesture {
                                            albumName = album.albumName
                                            selectedAlbumID = album.uuid
                                            print(albumName)
                                            print(selectedAlbumID)
                                            self.showList.toggle()
                                        }
                                }
                            }
                        }
                    }
                    .frame(width: 200, height: 300)
                    .offset(y: showList ? 0 : -400)  // Offset modifier to control position of list
                }
            }
            
        }
        .onAppear {
            // Make safe, creates Fatal error: Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            // This happens when pressing SignOut button from profileView
            guard let uuid = user.uuid else {return}
            album.fetchAlbums(forUserWithID: user.uuid ?? "")
        }
    }
}

