//
//  CameraView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-07.
//

import SwiftUI
import AVFoundation
import FirebaseFirestoreSwift

struct CameraView2: View {
    @EnvironmentObject var album : AlbumViewModel
    @State var albumuuid : String
    @StateObject var fetchAlbums = FetchAlbums()
    @State private var selectedAlbumID: String? = "LUjUOcK9ByPlcyjYYrda"
    @EnvironmentObject var post: PostViewModel
    @EnvironmentObject var user: UserViewModel
    @StateObject var camera = cameraModel()
    
   
    
    
    var body: some View{
        ZStack{
            
            //Going to be the camera preview...
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                        
                        if camera.isTaken {
                            
                            HStack{
                                Spacer()
                                Button(action: camera.reTake, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                })
                                .padding(.trailing,10)
                                
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            
                            
                            // if taken showing save and again take button
                            
                            if camera.isTaken {
                                
                                
                                Button(action: {if !camera.isSaved{camera.savePost(albumUuid: selectedAlbumID ?? "")}}, label: {
                                    Text(camera.isSaved ? "Saved" : "Save")
                                        .foregroundColor(.black)
                                        .fontWeight(.semibold)
                                        .padding(.vertical,10)
                                        .padding(.horizontal,20)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                    
                                })
                                .padding(.leading)
                                Spacer()
                                
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
                            }
                        }
                        .frame(height: 75)
                        AlbumPickerView(fetchAlbums: fetchAlbums, selectedAlbumID: $selectedAlbumID)
                    }
            }
            .onAppear(perform: {
                camera.Check()
            })
        }
    }



struct AlbumPickerView: View {
    @ObservedObject var fetchAlbums: FetchAlbums
    @Binding var selectedAlbumID: String?

        var body: some View {
                Picker("Select an Album", selection: $selectedAlbumID) {
                    ForEach(fetchAlbums.queryResultAlbums, id: \.self.uuid) { album in
                        Text(album.albumName).tag(album.uuid)
                    }
                }
                .pickerStyle(.menu) // Use .wheel for a wheel-style picker
                .onChange(of: selectedAlbumID) { newSelectedAlbumID in
                    // Handle the selection change if needed
                }
            }
        }

