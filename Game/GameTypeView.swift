 import SwiftUI

protocol GameTypeView: View {
    associatedtype SomeGameType: GameType
    associatedtype Content: View

    var controller: SomeGameType { get }
    @ViewBuilder var content: Content { get }

    init(controller: SomeGameType)

    func start() async
}

extension GameTypeView {
    init(_ controller: GameType, isGameStarted: Bool = false) {
        self.init(controller: controller as! SomeGameType)
        controller.isGameStarted = isGameStarted
    }

    var body: some View {
        content
            .allowsHitTesting(controller.isAcceptingInput)
            .task(id: controller.isGameStarted) {
                if controller.isGameStarted {
                    await start()
                }
            }
    }
}

protocol GameTypeHeader: GameTypeView {}

extension GameTypeHeader {
    func start() async {}
}
