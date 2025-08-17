import SwiftUI

@Observable
class TypingViewModel {
    var workingText = ""
    var currentIndex = 0
    var rollingText: CircularString
    
    init(rollingText: CircularString) {
        self.rollingText = rollingText
    }
}

struct TypingView: View {
    private var model: TypingViewModel
    private let backwardScope = 8
    private let forwardScope = 12
    
    private var countOfCharsOnScreen: Int {
        forwardScope + backwardScope + 1
    }
    
    init(model: TypingViewModel) {
        self.model = model
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                let beforeCurrentLetter = model.workingText.suffix(backwardScope)
                let currentCharacter = String(model.rollingText[model.currentIndex])
                let afterCurrentLetter = model.rollingText[(model.currentIndex + 1)...(model.currentIndex + 1 + forwardScope)]
                
                Spacer(minLength: 0)
                
                Text(beforeCurrentLetter)
                    .foregroundStyle(Color.writtenText)
                
                Group {
                    if currentCharacter == " " {
                        Text("_")
                    } else {
                        Text(currentCharacter)
                    }
                }
                .foregroundStyle(Color.currentLetter)
                
                Text(afterCurrentLetter)
                    .foregroundStyle(Color.futureText)
            }
            .font(.system(size: (geometry.size.width / Double(countOfCharsOnScreen)) * 1.5, weight: .bold, design: .monospaced))
            .position(geometry.size.midPoint())
        }
        .focusable()
        .focusEffectDisabled()
        .lineLimit(1)
        .onKeyPress { keyPress in
            guard keyPress.phase != .up, keyPress.key != .return else { return .ignored }
            
            if [KeyEquivalent("\u{7F}"), .delete].contains(keyPress.key) {
                if model.currentIndex != 0 {
                    model.workingText.removeLast()
                    model.currentIndex -= 1
                }
            } else {
                model.workingText += keyPress.characters
                model.currentIndex += keyPress.characters.count
            }
            
            return .handled
        }
    }
}

#Preview {
    @Previewable @State var model = TypingViewModel(rollingText: "The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. [beep] A single lap should be completed each time you hear this sound. [ding] Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, start. ")
    
    TypingView(model: model)
}


extension Color {
    static let writtenText = Color(red: 0.4, green: 0.4, blue: 0.4, opacity: 1)
    static let currentLetter = Color.white
    static let futureText = Color(red: 0.7, green: 0.7, blue: 0.7, opacity: 1)
}

extension CGSize {
    func midPoint(withOriginOf origin: CGPoint = .zero) -> CGPoint {
        let rect = CGRect(origin: origin, size: self)
        
        return CGPoint(x: rect.midX, y: rect.midY)
    }
}
