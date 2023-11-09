//
//  ProfileBarView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-11-08.
//

import SwiftUI

struct ProfileDisplayView: View {
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
