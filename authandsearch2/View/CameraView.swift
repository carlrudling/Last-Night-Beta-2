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
            
            VStack{
                AlbumPickerView(selectedAlbumID: $selectedAlbumID)
           //     Spacer()
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
                        
                        
                        
                        Button(action: {if !camera.isSaved{camera.savePost(); if camera.uuidGlobal != "" { post.createPost(albumId: selectedAlbumID, imageURL: camera.uuidGlobal, userUUID: user.uuid!)}}}, label: {
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
               
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}



struct AlbumPickerView: View {
    @StateObject var fetchAlbums = FetchAlbums()
    // @ObservedObject var fetchAlbums = FetchAlbums()
    // @Binding var selectedAlbumID: String = ""
    @State private var albumsOptions : [String] = []
    @EnvironmentObject var user : UserViewModel
    @State var albumName : String = ""
    @Binding var selectedAlbumID : String
    
    var body: some View {
        
        
        /*
         Picker("Select an Album", selection: $selectedAlbumID) {
         ForEach(fetchAlbums.queryResultAlbums, id: \.self.uuid) { album in
         Text(album.albumName).tag(album.uuid)
         
         }
         }
         
         .pickerStyle(.menu) // Use .wheel for a wheel-style picker
         .onChange(of: selectedAlbumID) { newSelectedAlbumID in
         // Handle the selection change if needed                }
         
         }
         */
        VStack {
            
            
            //   Image(systemName: "control")
            //     .foregroundColor(.black)
            //   .padding()
            
            HStack {
                
                //Text("\(albumName)")
                //    .onTapGesture {
                        
                        List(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                            HStack {
                                Text(album.albumName)
                                Spacer()
                            }.contentShape(Rectangle())
                                .onTapGesture {
                                    albumName = album.albumName
                                    selectedAlbumID = album.uuid
                                    print(albumName)
                                    print(selectedAlbumID)
                                
                                    
                                }
                        }
                        
                        
                    }
            
            .frame(width: 200, height: 300, alignment: .center) // Set frame to the text
            .background(Color.clear)
            .onAppear {
               fetchAlbums.fetchAlbums(with: user.uuid!)
             }
            
        }
        .background(Color.clear)
        
    }
    
}

