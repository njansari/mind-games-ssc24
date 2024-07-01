import SwiftUI

struct BrainItem<Content: View>: View {
    let animationState: AnimationState

    let xOffset: Double
    let yOffset: Double
    let content: () -> Content

    var body: some View {
        content()
            .phaseAnimator([false, true]) { content, value in
                content
            } animation: { _ in
                nil
            }
            .keyframeAnimator(initialValue: AnimationValues(), trigger: animationState != .notStarted) { content, value in
                content
                    .opacity(value.opacity)
                    .offset(x: value.xOffset, y: value.yOffset)
            } keyframes: { value in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(0, duration: 0.8)
                    CubicKeyframe(1, duration: 0.5)
                }

                KeyframeTrack(\.xOffset) {
                    CubicKeyframe(0, duration: 1)
                    SpringKeyframe(xOffset, duration: 2, spring: .bouncy(extraBounce: 0.1))
                }

                KeyframeTrack(\.yOffset) {
                    CubicKeyframe(0, duration: 1)
                    SpringKeyframe(yOffset, duration: 2, spring: .bouncy(extraBounce: 0.1))
                }
            }
    }
}

#Preview {
    BrainItem(animationState: .notStarted, xOffset: 0, yOffset: 0) {
        Text("Hello, World!")
    }
}
