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
    @State var albumuuid : String
    @State private var selectedAlbumID: String = ""
    
    @StateObject var camera = CameraModel()
    @EnvironmentObject var post : PostViewModel
    @EnvironmentObject var user : UserViewModel
    // let camera: CameraModel
    
    
    
    
    var body: some View{
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
                
                
                    
        Spacer()
                
                HStack {
                    
                    
                    // if taken showing save and again take button
                    
                    if camera.isTaken {
                        
                        
                        
                        Button(action:
                                {if !camera.isSaved{camera.savePost();
                                    if camera.uuidGlobal != "" { post.createPost(albumId: selectedAlbumID, imageURL: camera.uuidGlobal, userUUID: user.uuid!)
                                        
                                    }
                                    
                                }
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) {
                                DispatchQueue.main.async {
                                    camera.reTake()
                                }
                            }
                        }
                               
                               , label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical,20)
                                .padding(.horizontal,20)
                                .background(camera.isSaved ? Color.green : Color.white)
                                .clipShape(Capsule())
                            
                        })
                        .frame(alignment: .center)
                        .padding(.bottom, 60)
                        
                        
                    } else {
                        
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
                                Button(action: camera.reTake, label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                })
                            }
                        }
                        // Toggle Camera Button
                        Button(action: { camera.toggleCamera() }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        })
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
        
        .onAppear(perform: {
            camera.Check()
        })
        
    }
}



struct AlbumPickerView: View {
    @StateObject var fetchAlbums = FetchAlbums()
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
                            ForEach(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                                
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
                    .frame(width: 200, height: 300)
                    .offset(y: showList ? 0 : -400)  // Offset modifier to control position of list
                }
            }
            
        }
        .onAppear {
            fetchAlbums.fetchAlbums(with: user.uuid!)
        }
    }
}

