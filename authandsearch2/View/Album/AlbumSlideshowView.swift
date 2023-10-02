//
//  AlbumSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-01.
//

import SwiftUI

struct AlbumSlideshowView: View {
    @EnvironmentObject var imageModel : ImageViewModel
    @Binding var isTabBarHidden: Bool
    var album: Album
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    
    func formattedImagePath(from imageURL: String) -> String {
        let imagePath = "\(imageURL).jpg"
        print(imagePath)
        return imagePath
    }
    
    func startSlideshow() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if currentImageIndex < album.posts.count - 1 {
                currentImageIndex += 1
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func stopSlideshow() {
        timer?.invalidate()
        timer = nil
    }
    
    var body: some View {
        
        
        ZStack {
            if album.posts.indices.contains(currentImageIndex) {
                FirebaseImageView(imagePath: formattedImagePath(from: album.posts[currentImageIndex].imageURL))
                    .edgesIgnoringSafeArea(.all)
            }
            VStack {
                Button {
                    if timer == nil {
                        startSlideshow()
                    } else {
                        stopSlideshow()
                    }
                } label: {
                    Image(systemName: timer == nil ? "play.circle" : "pause.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                }
           
                
                
                
            }
        }
        .onAppear{
            isTabBarHidden = true
        }
        .onDisappear {
            stopSlideshow()
        }
    }
}

struct AlbumSlideshowView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        AlbumSlideshowView(isTabBarHidden: isTabBarHidden, album: dummyAlbum)
    }
}
