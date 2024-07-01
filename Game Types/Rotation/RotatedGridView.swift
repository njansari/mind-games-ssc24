import SwiftUI

struct RotatedGridView: View {
    let grid: Rotation.RotatedGrid
    let size: Double

    let colors: [Color] = [.white, .yellow, .brown, .pink, .blue]

    var borderWidth: Double {
        size / 20
    }

    var body: some View {
        Grid(horizontalSpacing: borderWidth, verticalSpacing: borderWidth) {
            ForEach(0..<grid.count, id: \.self) { i in
                GridRow {
                    ForEach(0..<grid[i].count, id: \.self) { j in
                        Rectangle()
                            .fill(colors[grid[i][j]])
                            .frame(width: size, height: size)
                    }
                }
            }
        }
        .background(.black)
        .border(.black, width: borderWidth)
    }
}

#Preview {
    RotatedGridView(grid: [], size: 40)
}
