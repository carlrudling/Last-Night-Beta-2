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
    
    init(albumName: Binding<String>, endDate: Binding<Date>, photoLimit: Binding<Int>) {
            _albumName = albumName
            _endDate = endDate
            _photoLimit = photoLimit
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
                album.createAlbum(albumName: albumName, endDate: endDate, photoLimit: photoLimit, members: members)
            } label: {
                Text("Create Album")
            }

        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct ProfileBarView2: View {
    var user: User
    @Binding var members : [String]
    
    init(user: User, members: Binding<[String]>) {
            self.user = user
            _members = members
        }
    
    var body: some View {
        ZStack {
            Rectangle()
            .foregroundColor(Color.gray.opacity(0.2))
            .onTapGesture {
                members.append(user.uuid)
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
        
        return AddMembersView(albumName: albumName, endDate: endDate, photoLimit: photoLimit)
    }
}
