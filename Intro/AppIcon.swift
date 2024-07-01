import SwiftUI

struct AppIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    let animationState: AnimationState
    let isStarting: Bool
    let calculateAnchorPoint: (Double) -> Void

    var iconBackground: some View {
        RoundedRectangle(cornerRadius: 50)
            .frame(width: 250, height: 250)
            .phaseAnimator([0, 1, 2, 3], trigger: isStarting) { content, value in
                let colors: [Color] = switch value {
                case 0:
                    [.black]
                case 1:
                    [.init(red: 239 / 255, green: 142 / 255, blue: 119 / 255),
                     .init(red: 244 / 255, green: 182 / 255, blue: 164 / 255)]
                default:
                    colorScheme == .dark ? [.black] : [.white]
                }

                content
                    .foregroundStyle(.linearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                    .shadow(radius: value > 0 ? 0 : 10)
            } animation: { value in
                switch value {
                case 1:
                    .easeIn(duration: 2)
                case 2:
                    .easeIn(duration: 1.5)
                case 3:
                    .easeIn(duration: 1.5)
                default:
                    .default
                }
            }
            .keyframeAnimator(initialValue: AnimationValues(scale: 0), trigger: animationState != .notStarted) { content, value in
                content
                    .scaleEffect(value.scale)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1, duration: 4, spring: .bouncy)
                }
            }
    }

    var anchorPointCalculator: some View {
        GeometryReader { geometry in
            Color.clear
                .onChange(of: animationState) { _, value in
                    guard case .finished = value else { return }

                    let localFrame = geometry.frame(in: .global)
                    let localPointY = localFrame.minY + geometry.size.height / 10

                    calculateAnchorPoint(localPointY)
                }
        }
    }

    var mainBrain: some View {
        Image(systemName: "brain.head.profile.fill")
            .font(.system(size: 132))
            .foregroundStyle(
                .white,
                .linearGradient(
                    stops: [
                        .init(color: .init(red: 1, green: 29 / 255.0, blue: 0), location: 0.35),
                        .init(color: .init(red: 1, green: 80 / 255.0, blue: 51 / 255.0), location: 0.65),
                        .init(color: .init(red: 1, green: 166 / 255.0, blue: 126 / 255.0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .offset(y: 30)
            .phaseAnimator([false, true]) { content, value in
                content
                    .shadow(color: animationState == .finished && value ? .white : .clear, radius: 10, y: -2)
            } animation: { value in
                value ? .easeOut(duration: 1.5) : .easeIn(duration: 1)
            }
            .keyframeAnimator(initialValue: AnimationValues()) { content, value in
                content
                    .scaleEffect(
                        x: animationState == .finished ? value.horizontalStretch : 1,
                        y: animationState == .finished ? value.verticalStretch : 1,
                        anchor: .bottom
                    )
            } keyframes: { value in
                KeyframeTrack(\.verticalStretch) {
                    CubicKeyframe(1, duration: 0.5)
                    CubicKeyframe(0.9, duration: 1)
                    CubicKeyframe(1.05, duration: 0.5)
                    CubicKeyframe(1, duration: 0.6)
                }

                KeyframeTrack(\.horizontalStretch) {
                    CubicKeyframe(0.95, duration: 1)
                    CubicKeyframe(1, duration: 1.5)
                }
            }
            .keyframeAnimator(initialValue: AnimationValues(scale: 0), trigger: animationState != .notStarted) { content, value in
                content
                    .scaleEffect(value.scale, anchor: .bottom)
                    .scaleEffect(y: value.verticalStretch)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    CubicKeyframe(0, duration: 0.2)
                    SpringKeyframe(1, duration: 2, spring: .bouncy)
                }
            }
    }

    var brainItem1: some View {
        BrainItem(animationState: animationState, xOffset: -85, yOffset: -32) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 36))
                .phaseAnimator([false, true]) { content, value in
                    content
                        .foregroundStyle(
                            .linearGradient(stops: [
                                .init(color: .white, location: animationState == .finished && value ? 0.4 : 1),
                                .init(color: .accentColor, location: 1)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                } animation: { value in
                    value ? .easeOut(duration: 0.5).delay(1) : .easeIn(duration: 0.5).delay(0.5)
                }
                .rotationEffect(.degrees(-45))
        }
    }

    var brainItem2: some View {
        BrainItem(animationState: animationState, xOffset: -52, yOffset: -75) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 36))
                .phaseAnimator([false, true]) { content, value in
                    content
                        .foregroundStyle(
                            .linearGradient(stops: [
                                .init(color: .white, location: animationState == .finished && value ? 0.4 : 1),
                                .init(color: .accentColor, location: 1)
                            ], startPoint: .top, endPoint: .init(x: 0.8, y: 1))
                        )
                } animation: { value in
                    value ? .easeOut(duration: 0.5).delay(1) : .easeIn(duration: 0.5).delay(0.5)
                }
                .rotationEffect(.degrees(20))
        }
    }

    var brainItem3: some View {
        BrainItem(animationState: animationState, xOffset: -4, yOffset: -88) {
            Image(systemName: "questionmark")
                .font(.system(size: 45, weight: .bold))
                .phaseAnimator([false, true]) { content, value in
                    content
                        .foregroundStyle(
                            .linearGradient(stops: [
                                .init(color: .white, location: animationState == .finished && value ? 0.3 : 1),
                                .init(color: .accentColor, location: 1)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                } animation: { value in
                    value ? .easeOut(duration: 0.5).delay(1) : .easeIn(duration: 0.5).delay(0.5)
                }
                .rotationEffect(.degrees(-5))
        }
    }

    var brainItem4: some View {
        BrainItem(animationState: animationState, xOffset: 45, yOffset: -85) {
            Image(systemName: "lightbulb.max.fill")
                .font(.system(size: 36))
                .phaseAnimator([false, true]) { content, value in
                    content
                        .foregroundStyle(
                            .linearGradient(stops: [
                                .init(color: .white, location: animationState == .finished && value ? 0.4 : 1),
                                .init(color: .accentColor, location: 1)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                } animation: { value in
                    value ? .easeOut(duration: 0.5).delay(1) : .easeIn(duration: 0.5).delay(0.5)
                }
                .rotationEffect(.degrees(20))
        }
    }

    var brainItem5: some View {
        BrainItem(animationState: animationState, xOffset: 85, yOffset: -45) {
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 36))
                .phaseAnimator([false, true]) { content, value in
                    content
                        .foregroundStyle(
                            .linearGradient(stops: [
                                .init(color: .white, location: animationState == .finished && value ? 0.4 : 1),
                                .init(color: .accentColor, location: 1)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                } animation: { value in
                    value ? .easeOut(duration: 0.5).delay(1) : .easeIn(duration: 0.5).delay(0.5)
                }
                .rotationEffect(.degrees(45))
        }
    }

    var body: some View {
        ZStack {
            iconBackground

            ZStack {
                mainBrain
                    .background {
                        anchorPointCalculator
                    }

                brainItem1
                brainItem2
                brainItem3
                brainItem4
                brainItem5
            }
            .keyframeAnimator(initialValue: AnimationValues(opacity: 1), trigger: isStarting) { content, value in
                content
                    .opacity(value.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.opacity) {
                    CubicKeyframe(0, duration: 1)
                }
            }
            .keyframeAnimator(initialValue: AnimationValues(scale: 0), trigger: animationState != .notStarted) { content, value in
                content
                    .scaleEffect(value.scale)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1, duration: 2, spring: .bouncy)
                }
            }
        }
    }
}

#Preview {
    GeometryReader { geometry in
        AppIcon(animationState: .notStarted, isStarting: false) { _ in }
    }
}
