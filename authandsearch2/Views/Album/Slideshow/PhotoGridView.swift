//
//  PhotogridView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI
import Kingfisher

struct PhotoGridView: View {
    @EnvironmentObject var post: PostViewModel
    @EnvironmentObject var imageModel: ImageViewModel
    @Binding var selectedDetent: PresentationDetent
    @EnvironmentObject var fetchAlbum: FetchAlbums
    var posts: [Post]
    let spacing: CGFloat = 1  // Change this to the spacing you want
    @State private var isSaved: Bool = false
    @State private var selectButtonPressed: Bool = false
    @State private var selectedImageUrls: [String] = []
    @State private var progress: CGFloat = 0
    @State var showingPopup = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                Button {
                    withAnimation(.default) {
                        selectButtonPressed.toggle()
                    }
                    //Select images for new slideshow or for download
                } label: {
                    HStack {
                        Spacer() // This will push the button to the right
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                            .foregroundColor(selectButtonPressed ? .white : .black)
                            .rotationEffect(.degrees(selectButtonPressed ? -45 : 0))
                            .frame(width: 40, height: 40) // Giving a frame to the button itself
                    }
                    .background(selectButtonPressed ? Color.purple : Color.white) // Applying background color here
                }
                .frame(width: .infinity) // Making sure the Button covers the full width
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 2) {
                        ForEach(posts, id: \.Postuuid) { post in
                            ZStack(alignment: .bottomTrailing) {
                                if selectButtonPressed {
                                    Button(action: {
                                        if let index = selectedImageUrls.firstIndex(of: post.imageURL) {
                                            selectedImageUrls.remove(at: index)
                                            print("The array: \(selectedImageUrls)")
                                        } else {
                                            selectedImageUrls.append(post.imageURL)
                                            print("The array: \(selectedImageUrls)")
                                        }
                                    }) {
                                        image(for: post)
                                    }
                                    
                                    if selectButtonPressed && selectedImageUrls.contains(post.imageURL) {
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.purple)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                
                                            )
                                            .padding(4)
                                    }
                                } else {
                                    NavigationLink(destination: ImageDetailView(post: post)) {
                                        KFImage(URL(string: post.imageURL))
                                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300)))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width - spacing * 2) / 3)
                                            .clipped()
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, -7)
            }
            
            //End of Nav
            if selectButtonPressed {
                ZStack {
                    VStack {
                        Spacer()
                        Button(action: {
                            
                            imageModel.requestPhotoLibraryPermission { granted in
                                if granted {
                                    imageModel.saveImagesToLibrary(urls: selectedImageUrls)
                                    isSaved = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        withAnimation {
                                            isSaved = false
                                        }
                                    }} else {
                                        showingPopup = true
                                        isSaved = false
                                        
                                        // Handle error: permission not granted
                                        // CREATE POPUP HERE
                                        print("Didn't have permission, needs to accept. Create prompt")
                                    }
                            }
                            
                            
                            
                            
                        }) {
                            
                            HStack {
                                Text("Download Images")
                                    .foregroundColor(.white)
                                
                        Spacer()
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        
                                
                            }
                            .padding(.bottom, 10)
                            .padding(.horizontal, 10)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width, alignment: .center)
                            .background(Color.purple)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .popup(isPresented: $showingPopup) {
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
                                    
                                    Text("To save images you need to allow access to images in settings.")
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
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                            )
                            
                            
                        }
                        .frame(width: 300, height: 300, alignment: .center)
                        //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                        .background(.clear)
                       
                
               
                }
                .popup(isPresented: $isSaved) {
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
                                    Image(systemName: "arrow.down.circle") // SF Symbol for checkmark
                                        .font(.system(size: 80))
                                        .foregroundColor(.white)
                                    
                                        .zIndex(1) // Ensure it's above the background
                                    Image(systemName: "arrow.down.circle.fill") // SF Symbol for checkmark
                                        .font(.system(size: 80))
                                        .foregroundColor(.blue)
                                    
                                        .zIndex(1) // Ensure it's above the background
                                    
                                }
                                
                                Text("Images saved")
                                    .font(.system(size: 22))
                                    .bold()
                                    .padding(.bottom, 5)
                                    .padding(.top, 2)
                                
                                Text("The images you selected have successfully been downloaded.")
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
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        )
                        
                        
                    }
                    .frame(width: 300, height: 300, alignment: .center)
                    //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                    .background(.clear)
                   
                
               
                }

                }
            }
        }
        .onAppear {
            selectedDetent = .large
        }
    }
    
    func image(for post: Post) -> some View {
        KFImage(URL(string: post.imageURL))
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 300)))
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width - spacing * 2) / 3)
            .clipped()
    }
    
    
}
