
import SwiftUI

struct EditProfileView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var uploadError: Error?

    var body: some View {
        ZStack {
           
            if selectedImage != nil {
                Button(action: {
                    print("Upload Image button tapped")
                    // Ensure selectedImage is unwrapped before passing it to uploadImage
                    if let selectedImage = selectedImage {
                        userViewModel.uploadProfileImage(selectedImage) { error in
                            self.uploadError = error
                            print(error ?? "Image uploaded successfully")
                        }
                    }
                }) {
                    Text("Upload Image")
                }
                .padding(.top, 300)
            }
                

            if let uploadError = uploadError {
                Text("Error uploading image: \(uploadError.localizedDescription)")
            }
            
            Image(uiImage: selectedImage ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding()
            
            Button(action: {
                isImagePickerPresented.toggle()
            }) {
                Image(systemName: "camera")
                    .resizable()
                    .frame(width: 40, height: 30)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }  // This is where your VStack should close
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
