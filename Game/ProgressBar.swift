import SwiftUI

struct ProgressBar: View {
    struct CurrentProgressBar: Animatable, View {
        var progress: Double
        let color: Color

        var animatableData: Double {
            get { progress }
            set { progress = newValue }
        }

        var body: some View {
            LinearGradient(stops: [
                .init(color: color, location: progress),
                .init(color: .primary.opacity(0.2), location: progress)
            ], startPoint: .leading, endPoint: .trailing)
        }
    }

    let progress: Double
    let numSegments: Int
    let currentSegment: Int
    let numIncorrect: Int
    let colorForSegment: (Int) -> Color

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numSegments, id: \.self) { i in
                let progress = currentSegment == i ? progress : currentSegment < i ? 0 : 1

                ZStack(alignment: .leading) {
                    CurrentProgressBar(progress: progress, color: colorForSegment(i))
                        .animation(.easeOut, value: progress)

                    if currentSegment == i {
                        HStack(spacing: 5) {
                            ForEach(0..<numIncorrect, id: \.self) { _ in
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundStyle(.bar)
                                    .transition(.scale)
                            }
                        }
                        .animation(.bouncy, value: numIncorrect)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .frame(height: 40)
        .clipShape(.capsule)
    }
}

#Preview {
    ProgressBar(progress: 0.5, numSegments: 3, currentSegment: 0, numIncorrect: 1, colorForSegment: { _ in .accentColor})
}
