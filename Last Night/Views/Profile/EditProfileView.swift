
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
    @State var signOutConfirmation = false

    // New State property for current profile image
    @State private var currentProfileImage: UIImage?
    
    // MARK: FUNCTIONS
    private func updateUserProfile() {
        // Use existing values if fields are empty
        let newFirstName = firstName.isEmpty ? userService.user?.firstName : firstName
        let newLastName = lastName.isEmpty ? userService.user?.lastName : lastName
        let newUsername = username.isEmpty ? userService.user?.username : "@\(username)"
        
        userService.updateUserProfile(firstName: newFirstName ?? "", lastName: newLastName ?? "", username: newUsername ?? "") { error in
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
            ZStack {
                // Check if any image is selected or exists
                if let uiImage = selectedImage ?? currentProfileImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                        .frame(width: 100, height: 100)
                        .padding()
                } else {
                    // Display a default system image when no image is available
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray) // You can set any color you like
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))  // Optional: Adds a border
                        .shadow(radius: 10)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white) // You can set the icon color
                                .opacity(0.3)
                        )
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
                    .font(Font.custom("Chillax-Regular", size: 12))
                TextField("New Firstname", text: $firstName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax-Regular", size: 16))
                Text("Current Lastname: \(userService.user?.lastName ?? "Unknown")")
                    .font(Font.custom("Chillax-Regular", size: 12))
                TextField("New Lastname", text: $lastName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax-Regular", size: 16))
                Text("Current Username: \(userService.user?.username ?? "Unknown")")
                    .font(Font.custom("Chillax-Regular", size: 12))
                TextField("New username", text: $username)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax-Regular", size: 16))
                
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
                                editProfileSheet = false
                            }
                        }
                    } else {
                        // If no image is selected, just update the profile
                        updateUserProfile()
                        editProfileSheet = false
                    }
                } label: {
                    Text("Save Changes")
                        .font(Font.custom("Chillax-Regular", size: 14))
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
                    signOutConfirmation.toggle()
                    
                } label: {
                    Text("Sign Out")
                        .font(Font.custom("Chillax-Regular", size: 18))
                        .frame(width: 100)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 30)
                }
            }
        }
        
        
        .popup(isPresented: $signOutConfirmation) {
            VStack{
                ZStack { // 4
                    
                    VStack{
                        HStack{
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        ZStack{
                            Image(systemName: "power.circle") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                                .zIndex(1) // Ensure it's above the background
                            Image(systemName: "power.circle.fill") // SF Symbol for checkmark
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .zIndex(1) // Ensure it's above the background
                        }
                        
                        Text("Sure you want to sign out?")
                            .font(Font.custom("Chillax-Medium", size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 5)
                            .padding(.top, 2)
                        
                        Text("By pressing yes you will have signed out of your account.")
                            .font(Font.custom("Chillax-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        HStack(spacing: 0) {
                            Button {
                                signOutConfirmation = false
                            } label: {
                                Text("No")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            //.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 10)
                            }
                            
                            Button {
                                
                            
                               //REPORT POST
                                userService.signOut()
                                signOutConfirmation = false
                                
                            } label: {
                                Text("Yes")
                                    .font(Font.custom("Chillax-Regular", size: 18))
                                    .frame(width: 80)
                                    .padding(10)
                                    .background(
                                        // Clipped background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    )
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 10)
                                
                            }
                            
                        }
                        
                    }
                    .padding(.top, -40) // Make space for the checkmark at the top
                    
                }
                .frame(width: 300, height: 240, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out¨
                
                .background(
                    // Clipped background
                    RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .lightPurple, location: 0.001),
                                    .init(color: .darkPurple, location: 0.99)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
)
            }
            .frame(width: 300, height: 300, alignment: .center)
            //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
            .background(.clear)
            
        }
        .background(
            ZStack{
                Color.backgroundWhite.edgesIgnoringSafeArea(.all)
                
                // First Layer: Custom Background View
                BackgroundView()
                    .frame(width: 600, height: 1500)
                    .rotationEffect(.degrees(-50))
                    .offset(y: 300)
            }
            )        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.white)
                .padding(12)
            
            
        }
        )
        
        
    }
}

