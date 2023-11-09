//
//  BackButtonModifier.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-10.
//
/*
import Foundation
import SwiftUI

struct BackButtonModifier: ViewModifier {
    @EnvironmentObject private var navigationState: NavigationState
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton {
                        navigationState.routes.removeLast()
                    }
                }
            }
    }
}

extension View {
    func withCustomBackButton() -> some View {
        modifier(BackButtonModifier())
    }
}
*/
