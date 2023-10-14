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
            let user = UserViewModel()
            let album = AlbumViewModel()
            let post = PostViewModel()
            let imageViewModel = ImageViewModel(imagePath: "")
            ContentView()
                .environmentObject(user)
                .environmentObject(album)
                .environmentObject(post)
                .environmentObject(imageViewModel)
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
