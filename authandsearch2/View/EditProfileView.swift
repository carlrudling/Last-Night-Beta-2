
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var user: UserViewModel
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var uploadError: Error?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSaving: Bool = false
    
    
    // MARK: FUNCTIONS
    private func updateUserProfile() {
        user.updateUserProfile(firstName: firstName, lastName: lastName, username: "@\(username)") { error in
            if let error = error {
                print("Failed to update user: \(error.localizedDescription)")
            } else {
                print("User updated successfully")
                // Perform any UI updates or pop view controller if needed
            }
            isSaving = false
        }
    }
    
    var body: some View {
        
        VStack{
            
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
            .padding(.bottom, 30)
            
            
            // Maybe create the ability to change email aswell
            Text(user.user? ? "Current Firstname: \(user.user?.firstName)" : "")
                .font(Font.custom("Chillax", size: 18))
            TextField("New Firstname", text: $firstName)
                .disableAutocorrection(true)
                .font(Font.custom("Chillax", size: 16))
                .padding(.bottom, 25)
            Text(user.user? ? "Current Lastname: \(user.user!.lastName)" : "")
                .font(Font.custom("Chillax", size: 18))
            TextField("New Lastname", text: $lastName)
                .disableAutocorrection(true)
                .font(Font.custom("Chillax", size: 16))
                .padding(.bottom, 25)
            Text(user.user? ? "Current username: \(user.user!.username)" : "")
                .font(Font.custom("Chillax", size: 18))
            TextField("New username", text: $username)
                .disableAutocorrection(true)
                .font(Font.custom("Chillax", size: 16))
                .padding(.bottom, 25)
            
            VStack{
                
                Button {
                    isSaving = true
                    if let selectedImage = selectedImage {
                        user.uploadProfileImage(selectedImage) { error in
                            if let error = error {
                                self.uploadError = error
                                print("Error uploading image: \(error.localizedDescription)")
                                isSaving = false
                            } else {
                                print("Image uploaded successfully")
                                updateUserProfile()
                            }
                        }
                    } else {
                        // If no image is selected, just update the profile
                        updateUserProfile()
                    }
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 20))
                    // Rest of your button styling
                }
                .disabled(isSaving) // Disable button while saving
                
                Spacer()
                
                
                Button {
                    user.signOut()
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 25))
                        .frame(width: 150)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 80)
                }
            }

        }
    }
    
    
}


/*
 struct EditProfileView_Previews: PreviewProvider {
 static var previews: some View {
 EditProfileView(user: user)
 }
 }
 */
