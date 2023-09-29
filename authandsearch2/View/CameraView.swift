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


/*
struct AlbumPickerView: View {
    @StateObject var fetchAlbums = FetchAlbums()
    // @ObservedObject var fetchAlbums = FetchAlbums()
    // @Binding var selectedAlbumID: String = ""
    @State private var albumsOptions : [String] = []
    @EnvironmentObject var user : UserViewModel
    @State var albumName : String = ""
    @Binding var selectedAlbumID : String
    
    var body: some View {
        
        
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
               
                .frame(width: 200, height: 300)
                
                
                
                
            }
            
            
            .onAppear {
                fetchAlbums.fetchAlbums(with: user.uuid!)
            }
            
        }

        
        
    }
    
}
*/

/*
struct AlbumPickerView: View {
    @StateObject var fetchAlbums = FetchAlbums()
    @EnvironmentObject var user: UserViewModel
    @State var albumName: String = ""
    @Binding var selectedAlbumID: String
    
    var body: some View {
        VStack {
            HStack {
                ScrollView {
                    VStack {
                        ForEach(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                            HStack {
                                Text(album.albumName)
                                
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                albumName = album.albumName
                                selectedAlbumID = album.uuid
                                print(albumName)
                                print(selectedAlbumID)
                            }
                            //.padding()  // optional, for better spacing
                        }
                    }
                }
                .frame(width: 200, height: 300)
            }
            .onAppear {
                fetchAlbums.fetchAlbums(with: user.uuid!)
            }
        }
    }
}
*/

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
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple))
            .contentShape(Rectangle())
            
            
            if showList {
                HStack {
                    ScrollView {
                        VStack {
                            ForEach(fetchAlbums.queryResultAlbums, id: \.uuid) { album in
                                HStack {
                                    Text(album.albumName)
                                    Spacer()
                                }
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

