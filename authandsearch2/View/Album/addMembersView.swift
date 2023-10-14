//
//  addMembersView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-30.
//

import SwiftUI

struct AddMembersView: View {
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var album : AlbumViewModel
    @StateObject var usersLookup = UsersLookupViewModel()
    @State var keyword = ""
    @State private  var members : [String] = []
    @Binding private var albumName : String
    @Binding private var  endDate : Date
    @Binding private var photoLimit : Int
    @Binding private var creator : String
    @Binding var isTabBarHidden: Bool
    @State private var buttonPressed = false
    @State private var isActive: Bool = false
    @Binding var shouldPopToRootView : Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    
    init(albumName: Binding<String>, endDate: Binding<Date>, photoLimit: Binding<Int>, creator: Binding<String>, isTabBarHidden: Binding<Bool>, shouldPopToRootView : Binding<Bool>) {
        _albumName = albumName
        _endDate = endDate
        _photoLimit = photoLimit
        _creator = creator
        _isTabBarHidden = isTabBarHidden
        _shouldPopToRootView = shouldPopToRootView
        
    }
    
    
    var body: some View {
        let keywordBinding = Binding<String>(
            get: {
                keyword
            },
            set: {
                keyword = $0
                usersLookup.fetchUsers(with: keyword)
            }
        )
        VStack {
            
            
            SearchBarView2(keyword: keywordBinding)
            ScrollView {
                ForEach(usersLookup.queryResultUsers, id: \.uuid) { user in
                    ProfileBarView2(user: user, members: $members)
                    
                }
            }
            
       
                Button {
                    buttonPressed = true
                    album.createAlbum(albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members, creator: creator)
                    self.shouldPopToRootView = false
                    
                } label: {
                    Text("Create Album")
                        .font(Font.custom("Chillax", size: 20))
                        .frame(maxWidth: .infinity) // Align the button to center horizontally
                        .padding()
                        .background(buttonPressed ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    

                }
                
              
                
                
            
            
            
            
            
        }
        .padding(.horizontal, 20)
      
        .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading:
                        Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                            Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                            .padding(12)
                           
                          
                        }
                )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear{
            members.append(self.user.uuid!)
            isTabBarHidden = true
            
        }
        .onDisappear{
            isTabBarHidden = false
        }
    }
    
}

struct SearchBarView2: View {
    @Binding var keyword: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.5))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Searching for...", text: $keyword)
                    .autocapitalization(.none)
            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}


// Propably you need to create another struct and call it when onTapgesture that displays the member (as selected)


struct ProfileBarView2: View {
    var user: User
    @Binding var members : [String]
    @State private var isTapped: Bool = false
    
    init(user: User, members: Binding<[String]>) {
        self.user = user
        _members = members
    }
    
    
    var body: some View {
        
        ZStack {
        
            Rectangle()
                .foregroundColor(isTapped ? Color.green : Color.gray.opacity(0.2))
                .onTapGesture {
                    if members.contains( user.uuid) {
                        // Member is already in the array, so remove them
                        //  members.remove(user.uuid)
                        isTapped = false
                    } else {
                        // Member is not in the array, so add them
                        members.append(user.uuid)
                        isTapped = true
                    }
                }
            HStack {
                Text("\(user.username)")
                Spacer()
                Text("\(user.firstName) \(user.lastName)")
            }
            .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .cornerRadius(13)
        .padding()
        
        
        
    }
}


struct addMembersView_Previews: PreviewProvider {
    static var previews: some View {
        let albumName = Binding<String>(get: { "Sample Album" }, set: { _ in })
        let endDate = Binding<Date>(get: { Date() }, set: { _ in })
        let photoLimit = Binding<Int>(get: { 10 }, set: { _ in })
        let creator = Binding<String>(get: {"Sample creator"}, set: { _ in})
        let isTabBarHidden = Binding<Bool>(get: { true }, set: { _ in })
        let shouldPopToRootView = Binding<Bool>(get: { true }, set: { _ in })
        
        return AddMembersView(albumName: albumName, endDate: endDate, photoLimit: photoLimit, creator: creator, isTabBarHidden: isTabBarHidden, shouldPopToRootView: shouldPopToRootView)
    }
}
