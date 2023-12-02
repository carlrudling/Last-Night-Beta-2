//
//  EditAlbumView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-06.
//

import SwiftUI



struct EditAlbumView: View {
    @EnvironmentObject var albumService : AlbumService
    @EnvironmentObject var userService : UserService
    @State private var albumName = ""
    @State private var endDate = Date()
    @State private var photoLimit = 0
    @State private var members : [String] = []
    @State private var creator : String = ""
    @State private var users: [User] = []
    @State var confirmationPopup = false
    
    @Binding var isTabBarHidden: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var album: Album
    
    
    var isAlbumNameValid: Bool {
            !albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

    func handleUpdate() {
           var updatedAlbum = album
           updatedAlbum.albumName = self.albumName
           updatedAlbum.endDate = self.endDate
           updatedAlbum.photoLimit = self.photoLimit
           
           // Now call the editAlbum function
        albumService.editAlbum(album: updatedAlbum)
           // Dismiss the view or show a confirmation of the update
           self.presentationMode.wrappedValue.dismiss()
       }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    // add creator to members array
    var body: some View {
        
      
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("Current albumname: \(album.albumName)")
                    .font(Font.custom("Chillax", size: 18))
                TextField("New album name", text: $albumName)
                    .disableAutocorrection(true)
                    .font(Font.custom("Chillax", size: 16))
                    .padding(.bottom, 25)
                Text("Current photolimit: \(album.photoLimit)")
                    .font(Font.custom("Chillax", size: 18))
                    .padding(.bottom, -25)
                PhotoLimitSelector(photoLimit: $photoLimit, pickerText: "New photolimit")
                Text("Current enddate: \(dateFormatter.string(from: album.endDate))")
                    .font(Font.custom("Chillax", size: 18))
                DatepickerView(endDate: $endDate, pickerText: "New enddate")
                Spacer()
                
                
                Button {
                    confirmationPopup = true
                } label: {
                    Text("Save changes")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(!isAlbumNameValid) // Disable the button if album name is not valid
                
            }
        
        
            .padding(.horizontal, 20)
            .popup(isPresented: $confirmationPopup) {
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
                                Image(systemName: "questionmark.circle") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                
                                    .zIndex(1) // Ensure it's above the background
                                Image(systemName: "questionmark.circle.fill") // SF Symbol for checkmark
                                    .font(.system(size: 80))
                                    .foregroundColor(.yellow)
                                
                                    .zIndex(1) // Ensure it's above the background
                                
                            }
                            
                            Text("Sure you want to change?")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .bold()
                                .padding(.bottom, 5)
                                .padding(.top, 2)
                                .foregroundColor(.black)
                            
                            Text("If you press 'yes', the settings you've set here will become the new default.")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.top, 5)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                
                            Spacer()
                            HStack(spacing: 0) {
                                Button {
                                    confirmationPopup = false
                                } label: {
                                    Text("No")
                                        .font(.system(size: 20))
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(
                                            // Clipped background
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                                        )
                                        .foregroundColor(.black)
                                        .padding(.bottom, 20)
                                        .padding(.horizontal, 10)
                                       
                                    
                                }
                                
                                Button {
                                    handleUpdate()
                                } label: {
                                    Text("Yes")
                                        .font(.system(size: 20))
                                        .frame(width: 80)
                                        .padding(10)
                                        .background(
                                            // Clipped background
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.red)
                                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
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
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 6, x: 0, y: 3)
                    )
                    
                    
                }
                .frame(width: 300, height: 300, alignment: .center)
                //.padding(.top, 40) // Padding to push everything down so checkmark appears half out
                .background(.clear)
               
        
               
       
        }
            .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading:
                            Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                                Image(systemName: "chevron.backward")
                                .foregroundColor(.black)
                                .padding(12)
                                
                            }
                    )
            .onAppear {
                creator = self.userService.uuid ?? ""
                isTabBarHidden = true
                albumService.fetchUsersFromAlbum(album: album, userService: userService) { fetchedUsers in
                    users = fetchedUsers // Updating the state with fetched users
                }
            }
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.endEditing()
                }
            )
        
        
        }
    }

