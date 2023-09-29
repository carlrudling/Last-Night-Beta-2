//
//  AlbumInfoView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-28.
//

import SwiftUI

struct AlbumInfoView: View {
//@EnvironmentObject var album : AlbumViewModel
    var album: Album
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    
    
    var body: some View {
        VStack {
            Text(album.albumName)
            Text(dateFormatter.string(from: album.endDate))
            
            
        }
    }
}

struct AlbumInfoView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy Album instance for preview purposes
        let dummyAlbum = Album(uuid: "dummy", albumName: "dummy", photoLimit: 0, creator: "dummy")
        // Pass the dummy Album instance to AlbumInfoView
        return AlbumInfoView(album: dummyAlbum)
    }
}
