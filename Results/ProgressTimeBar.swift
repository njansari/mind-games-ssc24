import SwiftUI

struct ProgressTimeBar: View {
    let value: Double
    let average: Double?

    let maxValue: Double

    init(averageTime: Double, average: Double?, isAppearing: Bool) {
        self.average = average
        value = isAppearing ? averageTime : 0
        maxValue = max(averageTime, average ?? 0).rounded(.awayFromZero)
    }

    var progressText: some View {
        AnimatingText(value: value) { updatedValue in
            VStack {
                Text(.seconds(updatedValue), format: .units(allowed: [.seconds], width: .wide, fractionalPart: .show(length: 3)))
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                Text("Average Time")
                    .font(.title3.weight(.semibold))

                if let average {
                    Group {
                        if value < average {
                            Text("Above average")
                        } else if value > average {
                            Text("Below average")
                        } else {
                            Text("On average")
                        }
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.accentColor.secondary)
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            ZStack(alignment: .bottomLeading) {
                UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                    .fill(.tint)
                    .frame(width: value * (300 / maxValue), height: 200, alignment: .leading)
                    .frame(width: 300, height: 250, alignment: .leading)

                Rectangle()
                    .frame(width: 2)

                Rectangle()
                    .frame(height: 2)
                    .overlay(alignment: .bottom) {
                        HStack {
                            Text(.seconds(0), format: .units(allowed: [.seconds], width: .narrow))
                            Spacer()
                            Text(.seconds(maxValue), format: .units(allowed: [.seconds], width: .narrow))
                        }
                        .offset(y: 25)
                    }

                if let average {
                    let avgValue = average * (300 / maxValue)

                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 2)
                        .offset(x: avgValue)
                        .shadow(radius: 1)
                }
            }
            .frame(width: 300, height: 250)

            progressText
        }
        .animation(.timingCurve(0.25, 0.75, 0.5, 1, duration: 1.5), value: value)
    }
}

#Preview {
    ProgressTimeBar(averageTime: 0.345, average: 0.25, isAppearing: true)
}
