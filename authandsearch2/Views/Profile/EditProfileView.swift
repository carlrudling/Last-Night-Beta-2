
import SwiftUI
struct EditProfileView: View {
    @EnvironmentObject var userService: UserService
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var uploadError: Error?
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSaving: Bool = false
    @Binding var editProfileSheet: Bool
    
    // New State property for current profile image
    @State private var currentProfileImage: UIImage?
    
    // MARK: FUNCTIONS
    private func updateUserProfile() {
        userService.updateUserProfile(firstName: firstName, lastName: lastName, username: "@\(username)") { error in
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
            ZStack{
                // Display current or selected profile image
                Image(uiImage: selectedImage ?? currentProfileImage ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                    .frame(width: 100, height: 100)
                    .padding()
                    .onAppear {
                        if let userProfile = userService.user,
                           let profileImageURL = userProfile.profileImageURL,
                           let url = URL(string: profileImageURL) {
                            // Load current profile image
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.currentProfileImage = UIImage(data: data)
                                    }
                                }
                            }.resume()
                        }
                    }
                
                // Button to open image picker
                Button(action: {
                    isImagePickerPresented.toggle()
                }) {
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 40, height: 30)
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
            }
            
            Form {
                // Maybe create the ability to change email aswell
                Text("Current Firstname: \(userService.user?.firstName ?? "Unknown")")
                    .font(Font.custom("Chillax", size: 18))
                TextField("New Firstname", text: $firstName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                Text("Current Lastname: \(userService.user?.lastName ?? "Unknown")")
                    .font(Font.custom("Chillax", size: 18))
                TextField("New Lastname", text: $lastName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                Text("Current Username: \(userService.user?.username ?? "Unknown")")
                    .font(Font.custom("Chillax", size: 18))
                TextField("New username", text: $username)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                
            }
            .frame(height: 300)
            .scrollContentBackground(.hidden)
            Spacer()
            VStack{
                
                Button {
                    isSaving = true
                    if let selectedImage = selectedImage {
                        userService.uploadProfileImage(selectedImage) { error in
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
                        editProfileSheet = false
                    }
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 14))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10)
                    
                    // Rest of your button styling
                }
                .disabled(isSaving) // Disable button while saving
                
                Spacer()
                Button {
                    userService.signOut()
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 18))
                        .frame(width: 100)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 30)
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.white)
                .padding(12)
            
            
        }
        )
        
        
    }
}

