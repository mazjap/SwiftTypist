import SwiftUI

struct TypingRenderer: View {
    private let workingText: String
    private let workingIndex: Int
    private let targetIndex: Int
    private let asciiString: AsciiString
    private let errorIndices: Set<Int>
    
    private let precedingCount: Int
    private let succeedingCount: Int
    
    private var countOfCharsOnScreen: Int {
        succeedingCount + precedingCount + 1
    }
    
    init(workingText: String, workingIndex: Int, targetIndex: Int, asciiString: AsciiString, errorIndices: Set<Int>, precedingCount: Int, succeedingCount: Int) {
        self.workingText = workingText
        self.workingIndex = workingIndex
        self.targetIndex = targetIndex
        self.asciiString = asciiString
        self.errorIndices = errorIndices
        self.precedingCount = precedingCount
        self.succeedingCount = succeedingCount
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
        .lineLimit(1)
    }
    
    private var attributedText: AttributedString {
        let succeedingStr = asciiString[(targetIndex + 1)...(targetIndex + 1 + succeedingCount)]
        
        let precedingCount = countOfCharsOnScreen - 1 - succeedingStr.count
        
        let precedingStr = workingText.suffix(precedingCount)
        let currentLetterStr = asciiString[targetIndex].map { String($0) }
        
        var attributedStr = AttributedString()
        
        // Apply colors to individual characters in preceding text based on errors
        let precedingStartIndex = workingIndex - precedingStr.count
        for (offset, char) in precedingStr.enumerated() {
            let absoluteIndex = precedingStartIndex + offset
            var charAttributedStr = AttributedString(String(char))
            
            if errorIndices.contains(absoluteIndex) {
                charAttributedStr.foregroundColor = .red
                charAttributedStr.strikethroughColor = .red
                charAttributedStr.strikethroughStyle = .single
            } else {
                charAttributedStr.foregroundColor = .writtenText
            }
            
            attributedStr.append(charAttributedStr)
        }
        
        if let currentLetterStr {
            var currentLetter = AttributedString(currentLetterStr)
            currentLetter.foregroundColor = .currentLetter
            currentLetter.underlineColor = .currentLetter
            currentLetter.underlineStyle = .single
            
            attributedStr.append(currentLetter)
        }
        
        var succeedingText = AttributedString(succeedingStr)
        succeedingText.foregroundColor = .futureText
        
        attributedStr.append(succeedingText)
        
        return attributedStr
    }
}
