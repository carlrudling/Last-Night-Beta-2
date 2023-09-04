//
//  ProfileView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//
/*
import SwiftUI

struct ProfileSearchView: View {
    @EnvironmentObject var user: UserViewModel
    @StateObject var userLookup = UsersLookupViewModel()
    @State var keyword: String = ""
    
    var body: some View {
        let keywordBinding = Binding<String>(
            get: {
            keyword
            },
            set: {
                keyword = $0
                userLookup.fetchUsers(from: keyword)
            }
        )
        
        VStack {
            HStack {
                Button(action: {
                    user.signOut()
                }) {
                    Text("Sign Out")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            SearchBarView(keyword: keywordBinding)
            ScrollView {
                ForEach(userLookup.queriedUsers, id: \.uuid) {
                    user in ProfileBarView(user : user)
                }
            }
            
        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
 
struct SearchBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.5))
            HStack {
                TextField("Searching for...", text: $keyword)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
        
        
    }
}

struct ProfileBarView: View {
    var user: User
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.2))
            
            HStack {
                Text("\(user.username)")
                Spacer()
                Text("\(user.firstName) \(user.lastName)")
            }
            .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .cornerRadius(13)
            .padding()
        
    }
}

 */
import SwiftUI

struct ProfileSearchView: View {
    @EnvironmentObject var user: UserViewModel
    @StateObject var usersLookup = UsersLookupViewModel()
    @State var keyword = ""
    
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
            HStack {
                Button(action: {
                    user.signOut()
                }) {
                    Text("Sign out")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .padding(.leading, 13)
                Spacer()
            }
            SearchBarView(keyword: keywordBinding)
            ScrollView {
                ForEach(usersLookup.queryResultUsers, id: \.uuid) { user in
                    ProfileBarView(user: user)
                        
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchBarView: View {
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

struct ProfileBarView: View {
    var user: User
    
    var body: some View {
        ZStack {
            Rectangle()
            .foregroundColor(Color.gray.opacity(0.2))
            .onTapGesture {
                print("You pressed \(user.firstName)")
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



/*
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
*/
