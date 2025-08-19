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
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isFocused: Bool
    private var model: TypingViewModel
    private let precedingCount: Int
    private let succeedingCount: Int
    
    private var countOfCharsOnScreen: Int {
        succeedingCount + precedingCount + 1
    }
    
    init(precedingCount: Int = 10, succeedingCount: Int = 24, model: TypingViewModel) {
        self.precedingCount = precedingCount
        self.succeedingCount = succeedingCount
        self.model = model
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                
                Text(attributedText)
            }
            .font(.system(size: (geometry.size.width / Double(countOfCharsOnScreen)) * 1.5, weight: .bold, design: .monospaced))
            .position(geometry.size.midPoint())
        }
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
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
        .onChange(of: scenePhase) { // TODO: - This logic should be owned by the parent, but just testing for now
            if scenePhase == .active {
                isFocused = true
            }
        }
    }
    
    private var attributedText: AttributedString {
        let precedingStr = model.workingText.suffix(precedingCount)
        let currentLetterStr = String(model.rollingText[model.currentIndex])
        let succeedingStr = model.rollingText[(model.currentIndex + 1)...(model.currentIndex + 1 + succeedingCount)]
        
        var attributedStr = AttributedString()
        
        var precedingText = AttributedString(precedingStr)
        precedingText.foregroundColor = .writtenText
        
        attributedStr.append(precedingText)
        
        var currentLetter = AttributedString(currentLetterStr)
        currentLetter.foregroundColor = .currentLetter
        currentLetter.underlineColor = .currentLetter
        currentLetter.underlineStyle = .single
        
        attributedStr.append(currentLetter)
        
        var succeedingText = AttributedString(succeedingStr)
        succeedingText.foregroundColor = .futureText
        
        attributedStr.append(succeedingText)
        
        return attributedStr
    }
}

#Preview {
    @Previewable @State var model = TypingViewModel(rollingText: "The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly, but gets faster each minute after you hear this signal. [beep] A single lap should be completed each time you hear this sound. [ding] Remember to run in a straight line, and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark, get ready, start. ")
    
    TypingView(model: model)
}

extension NSColor {
    static let writtenText = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let currentLetter = NSColor.white
    static let futureText = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
}

extension Color {
    static let writtenText = Color(nsColor: .writtenText)
    static let currentLetter = Color(nsColor: .currentLetter)
    static let futureText = Color(nsColor: .futureText)
}

extension CGSize {
    func midPoint(withOriginOf origin: CGPoint = .zero) -> CGPoint {
        let rect = CGRect(origin: origin, size: self)
        
        return CGPoint(x: rect.midX, y: rect.midY)
    }
}
