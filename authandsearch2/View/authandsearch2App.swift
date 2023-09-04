//
//  authandsearch2App.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-08-28.
//

import SwiftUI
import UIKit
import FirebaseCore

@main
struct authandsearch2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            let user = UserViewModel()
            let album = AlbumViewModel()
            ContentView()
                .environmentObject(user)
                .environmentObject(album)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
