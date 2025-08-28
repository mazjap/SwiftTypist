import SwiftUI

struct TypingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isFocused: Bool
    
    private let model: TypingViewModel
    private let precedingCount: Int
    private let succeedingCount: Int
    
    init(precedingCount: Int = 10, succeedingCount: Int = 24, model: TypingViewModel) {
        self.model = model
        self.precedingCount = precedingCount
        self.succeedingCount = succeedingCount
    }
    
    var body: some View {
        TypingRenderer(
            workingText: model.workingText,
            workingIndex: model.currentWorkingTextIndex,
            targetIndex: model.indexIntoRollingText,
            asciiString: model.asciiString,
            errorIndices: model.errorPositions,
            precedingCount: precedingCount,
            succeedingCount: succeedingCount
        )
        .onKeyPress { keyPress in
            guard keyPress.phase != .up, keyPress.key != .return else { return .ignored }
            
            if [KeyEquivalent("\u{7F}"), .delete].contains(keyPress.key) {
                model.handleDeletion()
            } else {
                model.handleCharacterInput(keyPress.characters)
            }
            
            return .handled
        }
        .focusEffectDisabled()
        .focused($isFocused)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                isFocused = true
            }
        }
    }
}

#Preview {
    @Previewable @State var model = TypingViewModel(asciiString: .circular("Hello, World! "))
    
    TypingView(model: model)
}
