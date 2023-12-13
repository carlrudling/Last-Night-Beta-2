import SwiftUI

struct QRCodeView: View {
    var data: String
    
    var body: some View {
        Image(uiImage: generateQRCode(from: data))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        // Get data from the string
        let data = Data(string.utf8)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return UIImage() }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Set the color of the QR code and the background to black and transparent respectively
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage": qrFilter.outputImage!, "inputColor0": CIColor.black, "inputColor1": CIColor.clear])
        // Get the output image
        guard let qrImage = colorFilter?.outputImage else { return UIImage() }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Create a UIImage from the CIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
    
    
    
}
