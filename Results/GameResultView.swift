import SwiftUI

struct GameResultView: View {
    let offset: Int
    let option: (key: GameOption, value: GameResult.Data)
    let scrollPosition: Int?
    let appearedOptions: [Bool]

    var gameType: GameType.Type {
        option.key.gameType
    }

    var nameHeaderText: some View {
        VStack {
            Text(gameType.formattedName())
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                    content
                        .opacity(abs(phase.value) == 0 ? 1 : abs(phase.value) >= 0.5 ? 0 : abs(phase.value))
                        .scaleEffect(1 - abs(phase.value))
                        .rotationEffect(.degrees(phase.value * 20))
                        .offset(x: phase.value * 50, y: abs(phase.value) * 200)
                }

            Text(gameType.category)
                .font(.system(size: 30, weight: .bold))
                .underline()
                .foregroundStyle(.tint.opacity(0.75))
                .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                    content
                        .opacity(abs(phase.value) == 0 ? 1 : 0)
                        .scaleEffect(1 - abs(phase.value))
                        .rotationEffect(.degrees(phase.value * 20))
                        .offset(x: phase.value * 50, y: abs(phase.value) * 200)
                }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .padding(.vertical, 30)
    }

    var body: some View {
        VStack {
            nameHeaderText

            if let percentageCorrect = option.value.percentageCorrect {
                progressGauge(percentageCorrect: percentageCorrect)

                HStack {
                    if let averageTime = option.value.averageTime, let avgAverageTime = gameType.averageResults.averageTime {
                        averageTimeFooter(averageTime: averageTime, avgAverageTime: avgAverageTime)
                    }

                    if let memoryLength = option.value.memoryLength, let avgMemoryLength = gameType.averageResults.memoryLength {
                        memoryLengthFooter(memoryLength: memoryLength, avgMemoryLength: avgMemoryLength)
                    }
                }
                .padding()
                .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                    content
                        .scaleEffect(1 - abs(phase.value))
                }
                .animation(.smooth) {
                    $0.opacity(scrollPosition == offset ? 1 : 0)
                }
            } else if let averageTime = option.value.averageTime {
                progressTimeBar(averageTime: averageTime)
            }
        }
        .tint(gameType.color)
        .containerRelativeFrame(.horizontal, count: 3, spacing: 0)
        .scrollTransition(.interactive.threshold(.centered)) { content, phase in
            content
                .blur(radius: abs(phase.value) * 20)
                .opacity(1 - abs(phase.value))
                .scaleEffect(1 - abs(phase.value))
                .offset(y: abs(phase.value) * 100)
        }
    }

    func progressGauge(percentageCorrect: Double) -> some View {
        ProgressGauge(percentageCorrect: percentageCorrect, average: gameType.averageResults.percentageCorrect, isAppearing: appearedOptions[offset])
            .padding()
            .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                content
                    .scaleEffect(1 - abs(phase.value))
            }
    }

    func progressTimeBar(averageTime: Double) -> some View {
        ProgressTimeBar(averageTime: averageTime, average: gameType.averageResults.averageTime, isAppearing: appearedOptions[offset])
            .padding()
            .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                content
                    .scaleEffect(1 - abs(phase.value))
            }
    }

    func averageTimeFooter(averageTime: Double, avgAverageTime: Double) -> some View {
        VStack {
            Text("Average Time")
                .font(.title3.bold())

            Text(.seconds(averageTime), format: .units(allowed: [.seconds], width: .wide, fractionalPart: .show(length: 3)))
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Group {
                if averageTime < avgAverageTime {
                    Text("Above average")
                } else if averageTime > avgAverageTime {
                    Text("Below average")
                } else {
                    Text("On average")
                }
            }
            .font(.subheadline.bold())
            .foregroundStyle(Color.accentColor.secondary)
        }
    }

    func memoryLengthFooter(memoryLength: Int, avgMemoryLength: Int) -> some View {
        VStack {
            Text("Maximum elements memorised")
                .font(.title3.bold())

            Text(memoryLength, format: .number)
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Group {
                if memoryLength < avgMemoryLength {
                    Text("Below average")
                } else if memoryLength > avgMemoryLength {
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

#Preview {
    GameResultView(
        offset: 0,
        option: (.reactions, .init(averageTime: 0.4)),
        scrollPosition: 0,
        appearedOptions: []
    )
}
