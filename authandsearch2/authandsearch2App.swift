//
//  authandsearch2App.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseAuth

@main
struct authandsearch2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


    
    init() {
            FirebaseApp.configure()
           let auth = Auth.auth()
           auth.addStateDidChangeListener { (auth, user) in
               if let user = user {
                   print("User is signed in with uid:", user.uid)
               } else {
                   print("User is signed out")
               }
              
           }
        
        
       }
    
    var body: some Scene {
        WindowGroup {
            let userService = UserService()
            let albumService = AlbumService()
            let postService = PostService()
            let imageViewModel = ImageViewModel(imagePath: "")
            let authViewModel = AuthViewModel()
            let albumViewModel = AlbumViewModel(userService: userService)
            ContentView()
                .environmentObject(userService)
                .environmentObject(albumService)
                .environmentObject(postService)
                .environmentObject(imageViewModel)
                .environmentObject(authViewModel)
                .environmentObject(albumViewModel)
               
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
    //FirebaseApp.configure()

    return true
  }
}
