import Foundation
import SwiftUI

extension Color {
    
    static let background: Color = Color(UIColor.systemBackground)
    static let label: Color = Color(UIColor.label)
    
    //Theme Colors
    
    static let lightPurple: Color = Color(r: 209, g: 123, b: 234)
    static let darkPurple: Color = Color(r: 65, g: 24, b: 120)
    // And regular black
    
    
    static let backgroundWhite: Color = Color(r: 253, g: 252, b: 252)
    
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
}


