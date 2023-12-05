
import SwiftUI

struct RotatingDotAnimationView: View {
    
    @State private var startAnimation = false
    @State private var duration = 1.0 // Works as speed, since it repeats forever
    
    var outerCircleSize: CGFloat
    var innerCircleSize: CGFloat
    var offset: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: outerCircleSize, height: outerCircleSize, alignment: .center)
            
            Circle()
                .fill(.white)
                .frame(width: innerCircleSize, height: innerCircleSize, alignment: .center)
                .offset(x: offset)
                .rotationEffect(.degrees(startAnimation ? 360 : 0))
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false),
                           value: startAnimation
                )
        }
        .onAppear {
            self.startAnimation.toggle()
        }
    }
}
