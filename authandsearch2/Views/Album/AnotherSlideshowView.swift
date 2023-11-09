//
//  AnotherSlideshowView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-30.
//

import SwiftUI

struct AnotherSlideshowView: View {
    public let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var selection = 0
    
    let images: [UIImage] = []
    var body: some View {
        VStack{
            TabView(selection: $selection) {
                ForEach(0..<images.count) { i in
                    Image("images[i]").resizable().ignoresSafeArea()
                }
            }.tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .onReceive(timer, perform: {_ in
                    withAnimation {
                        selection = selection < images.count ? selection + 1 : 0
                    }
                })
        } .ignoresSafeArea()
    }
}

struct AnotherSlideshowView_Previews: PreviewProvider {
    static var previews: some View {
        AnotherSlideshowView()
    }
}
