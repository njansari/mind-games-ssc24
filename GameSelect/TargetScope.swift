import SwiftUI

struct TargetScope: View {
    @State private var isShooting = false
    @State private var numShots = 0

    let trigger: Date

    let animationValues = AnimationValues(
        rotation: .random(in: -5...5),
        xOffset: .random(in: -40...40),
        yOffset: .random(in: -10...10)
    )

    var body: some View {
        Image(systemName: isShooting ? "dot.scope" : "scope")
            .offset(x: animationValues.xOffset, y: animationValues.yOffset)
            .rotationEffect(.degrees(animationValues.rotation))
            .animation(.smooth(duration: 1), value: trigger)
            .symbolEffect(.bounce, value: numShots)
            .onChange(of: trigger) {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    isShooting = true
                    numShots += 1
                    try await Task.sleep(for: .seconds(0.75))
                    isShooting = false
                }
            }
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 2)) { context in
        TargetScope(trigger: context.date)
            .font(.system(size: 56))
    }
}
