import SwiftUI

struct TowerPole: Shape {
    let thickness = 7.5

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRoundedRect(
            in: .init(
                x: rect.minX,
                y: rect.maxY - rect.height / thickness,
                width: rect.width,
                height: rect.height / thickness
            ),
            cornerRadii: .init(topLeading: rect.width / 10, bottomLeading: rect.width / 20, bottomTrailing: rect.width / 20, topTrailing: rect.width / 10)
        )

        path.addRoundedRect(
            in: .init(
                x: rect.midX - rect.width / thickness / 2,
                y: rect.minY,
                width: rect.width / thickness,
                height: rect.height
            ),
            cornerRadii: .init(topLeading: rect.height / 10, topTrailing: rect.height / 10)
        )

        return path
    }
}

struct TowerDisks: View {
    let trigger: Date

    let positions: [Double] = [
        [1, 2, 3], [1, 2, 3],
        [2, 3, 0], [2, 3, 0],
        [0, 2, 3], [0, 2, 3],
        [3, 0, 0],
        [0, 3, 0],
        [0, 0, 3]
    ].randomElement()!

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                TowerPole()
                disks(geometry: geometry)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    func disks(geometry: GeometryProxy) -> some View {
        ForEach(0..<3) { i in
            let width = geometry.size.width
            let height = geometry.size.height

            let delay = (3 - positions[i]) * 0.15

            RoundedRectangle(cornerRadius: 20)
                .frame(width: width * [0.4, 0.6, 0.8][i], height: height * 0.15)
                .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
                    content
                        .opacity(value.opacity)
                        .offset(y: value.yOffset)
                } keyframes: { value in
                    KeyframeTrack(\.yOffset) {
                        CubicKeyframe(0, duration: delay)
                        CubicKeyframe(height * 0.22 * positions[i], duration: 0.4)
                    }

                    KeyframeTrack(\.opacity) {
                        CubicKeyframe(0, duration: delay)
                        CubicKeyframe(positions[i], duration: 0.4)
                        CubicKeyframe(positions[i], duration: 0.8 - delay)
                        CubicKeyframe(0, duration: 0.25)
                    }
                }
        }
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 2)) { context in
        TowerDisks(trigger: .now)
            .frame(height: 200)
    }
}
