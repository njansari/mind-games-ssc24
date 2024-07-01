import SwiftUI

enum AnimationState {
    case notStarted
    case starting
    case finished
}

struct IntroView: View {
    @Environment(\.gameState) private var gameState

    @State private var animationState: AnimationState = .notStarted
    @State private var anchorPointY = 0.0

    var mindGamesText: some View {
        Text("Mind Games")
            .font(.system(size: 72, weight: .heavy, design: .rounded))
            .foregroundStyle(.black)
            .phaseAnimator([false, true]) { content, value in
                content
                    .scaleEffect(
                        x: animationState == .finished && value ? 1.02 : 1,
                        y: animationState == .finished && value ? 1.05 : 1,
                        anchor: .bottom
                    )
            } animation: { value in
                value ? .easeIn(duration: 1).delay(0.75) : .easeOut(duration: 0.75)
            }
            .keyframeAnimator(initialValue: AnimationValues(scale: 0), trigger: animationState != .notStarted) { content, value in
                content
                    .scaleEffect(
                        x: value.horizontalStretch,
                        y: value.verticalStretch,
                        anchor: .bottom
                    )
                    .scaleEffect(value.scale, anchor: .top)
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    CubicKeyframe(0, duration: 0.2)
                    SpringKeyframe(1, duration: 2, spring: .bouncy)
                }

                KeyframeTrack(\.horizontalStretch) {
                    CubicKeyframe(1, duration: 0.4)
                    CubicKeyframe(1.2, duration: 0.2)
                    CubicKeyframe(1, duration: 0.5)
                }

                KeyframeTrack(\.verticalStretch) {
                    CubicKeyframe(1, duration: 0.4)
                    CubicKeyframe(0.9, duration: 0.2)
                    CubicKeyframe(1, duration: 0.5)
                }

                KeyframeTrack(\.opacity) {
                    CubicKeyframe(1, duration: 0.75)
                }
            }
    }

    var startButton: some View {
        Button("Get Started") {
            withAnimation(.timingCurve(0.75, 0, 0, 0, duration: 5)) {
                gameState.wrappedValue = .select
            }
        }
        .font(.largeTitle.bold())
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 20))
        .controlSize(.large)
        .transition(.blurReplace)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [.accentColor, .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    AppIcon(animationState: animationState, isStarting: gameState.wrappedValue == .select) { localPointY in
                        anchorPointY = localPointY / geometry.size.height
                    }

                    mindGamesText

                    if case .finished = animationState {
                        startButton
                    }
                }
            }
        }
        .transition(.asymmetric(
            insertion: .opacity,
            removal: .scale(scale: 20, anchor: .init(x: 0.5, y: anchorPointY))
        ))
        .task {
            await startAnimations()
            Sounds.glass.play()
        }
    }

    func startAnimations() async {
        try? await Task.sleep(for: .seconds(1))

        withAnimation {
            animationState = .starting
        }

        try? await Task.sleep(for: .seconds(2))

        withAnimation {
            animationState = .finished
        }
    }
}

#Preview {
    IntroView()
}
