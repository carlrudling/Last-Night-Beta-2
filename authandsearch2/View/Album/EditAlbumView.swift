//
//  EditAlbumView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-06.
//

import SwiftUI



struct EditAlbumView: View {
    @EnvironmentObject var albumViewModel : AlbumViewModel
    @EnvironmentObject var userViewModel : UserViewModel
    @State private var albumName = ""
    @State private var  endDate = Date()
    @State private var photoLimit = 0
    @State private var members : [String] = []
    @State private var creator : String = ""
    @State private var users: [User] = []
    @State var confirmationPopup = false
    
    @Binding var isTabBarHidden: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var album: Album
    

    func handleUpdate() {
           var updatedAlbum = album
           updatedAlbum.albumName = self.albumName
           updatedAlbum.endDate = self.endDate
           updatedAlbum.photoLimit = self.photoLimit
           
           // Now call the editAlbum function
           albumViewModel.editAlbum(album: updatedAlbum)
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
                photoLimitSelector2(photoLimit: $photoLimit)
                Text("Current enddate: \(dateFormatter.string(from: album.endDate))")
                    .font(Font.custom("Chillax", size: 18))
                datePicker2(endDate: $endDate)
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
                                .bold()
                                .padding(.bottom, 5)
                                .padding(.top, 2)
                                .foregroundColor(.black)
                            
                            Text("If you press 'yes', the settings you've set here will become the new default.")
                                .font(.system(size: 16))
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
                creator = self.userViewModel.uuid ?? ""
                isTabBarHidden = true
                albumViewModel.fetchUsersFromAlbum(album: album, userViewModel: userViewModel) { fetchedUsers in
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




struct photoLimitSelector2: View {
    @Binding var photoLimit: Int
    @State private var selectedOption: photoLimity = .None
    
    
    
    var body: some View {
        Picker("PhotoLimit per user per 24h", selection: $selectedOption) {
            // 1
            ForEach(photoLimity.allCases) { option in
                
                // 2
                Text(String(describing: option))
                    .tag(option.intValue)
                
            }
        }
        .pickerStyle(.wheel)
        .frame(maxHeight: 120)
        .onChange(of: selectedOption) { newValue in
            photoLimit = newValue.intValue // Update photoLimit with the selected intValue
        }
        
        
    }
}


struct datePicker2: View {
    @Binding var endDate: Date
    
    var body: some View {
        VStack {
            DatePicker("Select new date", selection: $endDate, in: Date.now...)
                .font(Font.custom("Chillax", size: 16))
            
        }
    }
}

/*
struct EditAlbumView_PreviewProvider {
    @State static private var isTabBarHidden = false
    @State static private var rootIsActive = false
    static var previews: some View {
        EditAlbumView(isTabBarHidden: $isTabBarHidden, rootIsActive: $rootIsActive, album: album)
    }
}

*/
