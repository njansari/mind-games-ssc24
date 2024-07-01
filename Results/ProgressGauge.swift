import SwiftUI

struct ProgressGauge: View {
    struct AnimatingPercentageText: Animatable, View {
        var value: Double

        var animatableData: Double {
            get { value }
            set { value = newValue }
        }

        var body: some View {
            Text(value, format: .percent.precision(.significantDigits(3)))
                .font(.system(size: 64, weight: .bold, design: .rounded))
        }
    }

    let value: Double
    let average: Double?

    init(percentageCorrect: Double, average: Double?, isAppearing: Bool) {
        self.average = average
        value = isAppearing ? percentageCorrect : 0
    }

    var progressText: some View {
        AnimatingText(value: value) { updatedValue in
            VStack {
                Text(updatedValue, format: .percent.precision(.significantDigits(3)))
                    .font(.system(size: 64, weight: .bold, design: .rounded))

                Text("Percentage Correct")
                    .font(.title3.weight(.semibold))

                if let average {
                    Group {
                        if value < average {
                            Text("Below average")
                        } else if value > average {
                            Text("Above average")
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
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.1, to: 0.9)
                    .stroke(.fill, style: .init(lineWidth: 30, lineCap: .round))

                Circle()
                    .trim(from: 0.1, to: 0.1 + value * 0.8)
                    .stroke(.tint, style: .init(lineWidth: 30, lineCap: .round))

                if let average {
                    let avgValue = (0.1 + average * 0.8) * 360

                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: 50, height: 10)
                        .rotationEffect(.degrees(avgValue))
                        .offset(
                            x: 150 * cos(avgValue * .pi / 180),
                            y: 150 * sin(avgValue * .pi / 180)
                        )
                        .shadow(radius: 1)
                }
            }
            .rotationEffect(.degrees(90))
            .frame(width: 300, height: 300)

            progressText
        }
        .animation(.timingCurve(0.25, 0.75, 0.5, 1, duration: 1.5), value: value)
    }
}

#Preview {
    ProgressGauge(percentageCorrect: 0.5, average: 0.8, isAppearing: true)
}
