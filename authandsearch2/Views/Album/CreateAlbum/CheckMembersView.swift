//
//  CheckMembersView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-14.
//

import Foundation
import SwiftUI

struct CheckMembersView: View {
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var albumViewModel: AlbumViewModel
    @EnvironmentObject var albumService : AlbumService
    @State private var buttonPressed = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var createAlbumSheet: Bool
    @Binding var isTabBarHidden: Bool
    
    
    
    var body: some View {
        VStack{
            List {
                Section(footer: Text("Swipe left to remove a member")) {
                    ForEach(albumViewModel.fetchedUsers, id: \.id) { user in
                        Text(user.username)
                    }
                    .onDelete(perform: delete)
                }
            }
            .frame(height: 500)
            .scrollContentBackground(.hidden)
            .navigationTitle("Members")
            
            Spacer()
            Button {
                buttonPressed = true
                albumViewModel.members.append(self.userService.uuid!)
                albumService.createAlbum(albumName: albumViewModel.albumName, endDate: albumViewModel.endDate, photoLimit: albumViewModel.photoLimit, members: albumViewModel.members, creator: albumViewModel.creator)
                albumViewModel.resetValues()
                createAlbumSheet = false
                isTabBarHidden = false
                
                
            } label: {
                Text("Create Album")
                    .font(Font.custom("Chillax", size: 20))
                    .frame(maxWidth: .infinity) // Align the button to center horizontally
                    .padding()
                    .background(buttonPressed ? Color.green : Color.white)
                    .foregroundColor(buttonPressed ? .white : Color.black)
                    .clipShape(Capsule())
                
                
            }
            
        }
        .padding(.horizontal, 20)
        .onAppear {
            albumViewModel.fetchAllUsers()
            print("The members: \(albumViewModel.members)")
        }
        .background(
            Rectangle()
                .fill(Color.blue)
                .frame(width: 600, height: 1500)
                .rotationEffect(.degrees(-50))
                .offset(y: 300)
                .cornerRadius(10), alignment: .center
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(12)
            
        }
        )
        .onDisappear{
            isTabBarHidden = false
            
        }
    }
    
    func delete(at offsets: IndexSet) {
        // Remove the user from fetchedUsers
        let idsToDelete = offsets.map { albumViewModel.fetchedUsers[$0].id }
        albumViewModel.fetchedUsers.remove(atOffsets: offsets)
        
        // Also remove the corresponding UUIDs from members
        albumViewModel.members.removeAll { idsToDelete.contains($0) }
        print("The members: \(albumViewModel.members)")
    }
}

/*
 struct CheckMembersView_Previews: PreviewProvider {
 static var previews: some View {
 let sampleUserService = UserService()
 CheckMembersView().environmentObject(AlbumViewModel(userService: sampleUserService))
 }
 }
 */
