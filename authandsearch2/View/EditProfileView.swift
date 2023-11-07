
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var uploadError: Error?

    var body: some View {
        ZStack {
           
            if selectedImage != nil {
                Button(action: {
                    print("Upload Image button tapped")
                    if let selectedImage = selectedImage {
                        user.uploadProfileImage(selectedImage) { error in
                            if let error = error {
                                self.uploadError = error
                                print("Error uploading image: \(error.localizedDescription)")
                            } else {
                                print("Image uploaded successfully")
                            }
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
