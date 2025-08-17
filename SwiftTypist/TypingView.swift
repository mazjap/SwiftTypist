import SwiftUI

struct CircularString: ExpressibleByStringLiteral {
    private let strBuffer: Array<UInt8>
    
    init?(_ strBuffer: String) {
        guard let data = strBuffer.data(using: .ascii) else { return nil }
        self.strBuffer = Array(data)
        
    }
    
    init(stringLiteral value: String) {
        self.init(value)!
    }
    
    private func wrappedIndex(for index: Int) -> Int {
        // Double modulo to handle negative values
        // ABCDEFGHIJ - 10 count
        // i = -12: ((-12 % 10) + 10) % 10 = (-2 + 10) % 10 = 8 (I)
        // i =  12: (( 12 % 10) + 10) % 10 = ( 2 + 10) % 10 = 2 (C)
        
        ((index % strBuffer.count) + strBuffer.count) % strBuffer.count
    }
    
    subscript(index: Int) -> Character {
        Character(UnicodeScalar(strBuffer[wrappedIndex(for: index)]))
    }
    
    subscript<R>(range: R) -> String where R: RangeExpression, R.Bound == Int {
        let concreteRange = range.relative(to: Int.min..<Int.max)
        
        var result: [UInt8] = []
        result.reserveCapacity(concreteRange.count)
        
        for i in concreteRange {
            result.append(strBuffer[wrappedIndex(for: i)])
        }
        
        return String(bytes: result, encoding: .ascii)!
    }
}

struct TypingView: View {
    private let rollingText: CircularString = "As a child, I watched superhero movies and wanted to be one myself. After coming across a vile of gold flakes in my dad's office and knowing that powers came from interesting circumstances, I popped open the vile and dumped its contents down my throat. "
    @State private var workingText = ""
    @State private var currentIndex = 0
    
    private let scope = 30
    
    private var countOfCharsOnScreen: Int {
        scope * 2 + 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                let beforeCurrentLetter = workingText.suffix(scope)
                let currentCharacter = String(rollingText[currentIndex])
                let afterCurrentLetter = rollingText[(currentIndex + 1)...(currentIndex + 1 + scope)]
                
                Text(beforeCurrentLetter)
                    .foregroundStyle(Color.writtenText)
                
                
                if currentCharacter == " " {
                    Text("_")
                        .foregroundStyle(Color.currentLetter)
                } else {
                    Text(currentCharacter)
                        .foregroundStyle(Color.currentLetter)
                }
                
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
                if currentIndex != 0 {
                    workingText.removeLast()
                    currentIndex -= 1
                }
            } else {
                workingText += keyPress.characters
                currentIndex += keyPress.characters.count
            }
            
            return .handled
        }
    }
}

#Preview {
    TypingView()
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
