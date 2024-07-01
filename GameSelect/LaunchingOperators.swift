import SwiftUI

struct LaunchingOperators: View {
    let trigger: Date

    let icons = ["plus", "minus", "multiply", "divide"].shuffled().prefix(3)

    var leftIcon: some View {
        Image(systemName: icons[0])
            .scaleEffect(0.8)
            .keyframeAnimator(initialValue: AnimationValues(yOffset: 20), trigger: trigger) { content, value in
                content
                    .opacity(value.opacity)
                    .rotationEffect(.degrees(value.rotation))
                    .offset(x: value.xOffset, y: value.yOffset)
            } keyframes: { value in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(1, duration: 0.4)
                    CubicKeyframe(1, duration: 0.7)
                    CubicKeyframe(0, duration: 0.4)
                }

                KeyframeTrack(\.rotation) {
                    CubicKeyframe(-10, duration: 0.4)
                }

                KeyframeTrack(\.xOffset) {
                    SpringKeyframe(-60, duration: 1.5, spring: .bouncy(extraBounce: 0.1))
                }

                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(10, duration: 1.5, spring: .bouncy(extraBounce: 0.1))
                }
            }
    }

    var centerIcon: some View {
        Image(systemName: icons[1])
            .fontWeight(.heavy)
            .keyframeAnimator(initialValue: AnimationValues(yOffset: 50), trigger: trigger) { content, value in
                content
                    .opacity(value.opacity)
                    .offset(y: value.yOffset)
            } keyframes: { value in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(1, duration: 0.2)
                    CubicKeyframe(1, duration: 1.2)
                    CubicKeyframe(0, duration: 0.4)
                }

                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(-10, duration: 1.5, spring: .bouncy(extraBounce: 0.1))
                    CubicKeyframe(0, duration: 0.3)
                }
            }
    }

    var rightIcon: some View {
        Image(systemName: icons[2])
            .scaleEffect(0.8)
            .keyframeAnimator(initialValue: AnimationValues(yOffset: 20), trigger: trigger) { content, value in
                content
                    .opacity(value.opacity)
                    .rotationEffect(.degrees(value.rotation))
                    .offset(x: value.xOffset, y: value.yOffset)
            } keyframes: { value in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(1, duration: 0.4)
                    CubicKeyframe(1, duration: 0.7)
                    CubicKeyframe(0, duration: 0.4)
                }

                KeyframeTrack(\.rotation) {
                    CubicKeyframe(10, duration: 0.4)
                }

                KeyframeTrack(\.xOffset) {
                    SpringKeyframe(60, duration: 1.5, spring: .bouncy(extraBounce: 0.1))
                }

                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(10, duration: 1.5, spring: .bouncy(extraBounce: 0.1))
                }
            }
    }

    var body: some View {
        ZStack {
            leftIcon
            centerIcon
            rightIcon
        }
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 2)) { context in
        LaunchingOperators(trigger: context.date)
            .font(.system(size: 56))
    }
}
