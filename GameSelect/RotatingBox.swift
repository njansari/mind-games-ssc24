import SwiftUI

struct RotatingBox: View {
    @State private var arrowOpacity = 0.0
    @State private var boxRotation = 0.0

    let trigger: Date

    let isClockwise = Bool.random()
    let rotationAmount: Double = [90, 180].randomElement()!

    var body: some View {
        Image(systemName: isClockwise ? "rotate.right" : "rotate.left")
            .foregroundStyle(.primary.opacity(arrowOpacity), .primary)
            .rotationEffect(.degrees(boxRotation), anchor: .init(x: 0.5, y: 0.64))
            .offset(y: -7)
            .onChange(of: trigger) {
                rotateBox()
            }
    }

    func rotateBox() {
        withAnimation(.easeInOut(duration: 0.5)) {
            arrowOpacity = 1
        }

        withAnimation(.easeInOut(duration: rotationAmount / 180 + 0.5)) {
            if isClockwise {
                boxRotation += rotationAmount
            } else {
                boxRotation -= rotationAmount
            }
        } completion: {
            withAnimation(.easeInOut(duration: 0.5)) {
                arrowOpacity = 0
            } completion: {
                if isClockwise {
                    boxRotation -= rotationAmount
                } else {
                    boxRotation += rotationAmount
                }
            }
        }
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 2)) { context in
        RotatingBox(trigger: context.date)
            .font(.system(size: 56))
    }
}
