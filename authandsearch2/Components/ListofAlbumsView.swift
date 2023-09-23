//
//  ListofAlbumsView.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-08.
//
/*
import SwiftUI

struct ListofAlbumsView: View {
@ObservedObject var fetchAlbums: FetchAlbums
@Binding var selectedAlbumID: String?

    var body: some View {
            Picker("Select an Album", selection: $selectedAlbumID) {
                ForEach(fetchAlbums.queryResultAlbums, id: \.self.uuid) { album in
                    Text(album.albumName).tag(album.uuid)
                }
            }
            .pickerStyle(.menu) // Use .wheel for a wheel-style picker
            .onChange(of: selectedAlbumID) { newSelectedAlbumID in
                // Handle the selection change if needed
            }
        }
    }

*/
