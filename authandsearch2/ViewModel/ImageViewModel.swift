//
//  ImageViewModel.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-09-29.
//
/*
import Foundation
import UIKit
import FirebaseStorage



class ImageViewModel: ObservableObject {
    @Published var image: UIImage?
    
    private var storageRef: StorageReference
    
    init(imagePath: String) {
        storageRef = Storage.storage().reference(withPath: imagePath)
        loadImage()
    }
    
    func loadImage() {
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in  // 1 MB limit
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                self.image = UIImage(data: data)
            }
        }
    }
}

*/
 import Foundation
 import UIKit
 import FirebaseStorage

 class ImageViewModel: ObservableObject {
     @Published var image: UIImage?
     @Published var error: Error?
     
     private var storageRef: StorageReference
     
     init(imagePath: String) {
         print("Loading image from path: \(imagePath)")  // Log the image path
         storageRef = Storage.storage().reference(withPath: imagePath)
         loadImage()
     }
     
     func loadImage() {
         storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in  // 1 MB limit
             guard let self = self else { return }
             
             if let error = error {
                 print("Error loading image from path \(self.storageRef.fullPath): \(error.localizedDescription)")
                 DispatchQueue.main.async {
                     self.error = error
                 }
             } else if let data = data, let image = UIImage(data: data) {
                 DispatchQueue.main.async {
                     self.image = image
                 }
             } else {
                 print("Unexpected error: No error, no data or failed to decode image data from path \(self.storageRef.fullPath)")
                 DispatchQueue.main.async {
                     self.error = NSError(domain: "ImageViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
                 }
             }
         }
     }
 }


/*
 // BluePrint for deleting Images
 func deleteItem(item: StorageReference) {
         item.delete { error in
             if let error = error {
                     print("Error deleting item", error)
             }
         }
 }
 */
