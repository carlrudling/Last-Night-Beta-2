
import SwiftUI

struct CarouselView: View {
    @Binding var currentImageIndex: Int
    var images: [UIImage]

    var body: some View {
        TabView(selection: $currentImageIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill() // Fill the entire view
                    .tag(index)
                    .clipped() // Clip the overflowing parts
                
            }
            .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen

        }
        .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill all available space
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
       
        
    }
}

