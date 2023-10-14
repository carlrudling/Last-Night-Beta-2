
 import Foundation
 import UIKit
 import FirebaseStorage
 import Photos


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
         storageRef.getData(maxSize: 10 * 1024 * 1024) { [weak self] data, error in  // 1 MB limit
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
     
     func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
             let photosStatus = PHPhotoLibrary.authorizationStatus()

             switch photosStatus {
             case .authorized:
                 // Permission is already granted
                 completion(true)

             case .notDetermined:
                 // Permission has not been determined yet
                 PHPhotoLibrary.requestAuthorization { newStatus in
                     completion(newStatus == .authorized)
                 }

             default:
                 // Permission is denied or restricted
                 completion(false)
             }
         }

     
     func saveImageToLibrary(image: UIImage) {
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
     }
 }

extension ImageViewModel {
    static func preloadImages(paths: [String], completion: @escaping ([UIImage]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []

        for path in paths {
            dispatchGroup.enter()
            let storageRef = Storage.storage().reference(withPath: path)
            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let data = data, let image = UIImage(data: data) {
                    images.append(image)
                } else {
                    print("Failed to preload image from path \(path): \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(images)
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
