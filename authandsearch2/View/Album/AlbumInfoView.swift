

import SwiftUI

struct AlbumInfoView: View {
    @EnvironmentObject var imageModel : ImageViewModel
    @Binding var isTabBarHidden: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var album: Album
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    func formattedImagePath(from imagePath: String) -> String {
        let imagePath = "\(imagePath).jpg"
        print(imagePath)
        return imagePath
    }
    
    var body: some View {
        VStack {
            Text(album.albumName)
            Text(dateFormatter.string(from: album.endDate))
            ForEach(album.posts) { post in
                FirebaseImageView(imagePath: formattedImagePath(from: post.imagePath))
            }
        }
        .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading:
                        Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                            Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                            .padding(12)
                        
                        }
                )
        .onAppear{
            isTabBarHidden = false
        }
    }
        
}


struct AlbumInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy Album instance for preview purposes
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        // Pass the dummy Album instance to AlbumInfoView
        return AlbumInfoView(isTabBarHidden: isTabBarHidden, album: dummyAlbum)
    }
}


/*
struct FirebaseImageView: View {
    @ObservedObject private var imageLoader: ImageViewModel
    
    init(imagePath: String) {
        imageLoader = ImageViewModel(imagePath: imagePath)
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            ProgressView()  // or a placeholder image
        }
    }
}
*/
