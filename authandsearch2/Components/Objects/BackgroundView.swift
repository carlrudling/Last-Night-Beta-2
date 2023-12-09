//
//  BackgroundView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-12-07.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack{
            LinearGradient(stops: [
                .init(color: .lightPurple, location: 0.15),
                .init(color: .darkPurple, location: 0.60),
            ], startPoint: .top, endPoint: .bottom)
            .frame(width: 600, height: 1500)
            
            LinearGradient(stops: [
                .init(color: .clear, location: 0.5),
                .init(color: .black.opacity(0.2), location: 1.0),
                .init(color: .black, location: 0.60)
            ], startPoint: .top, endPoint: .bottom)
            .frame(width: 600, height: 1500)
            
        }        .frame(width: 600, height: 1500)
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
