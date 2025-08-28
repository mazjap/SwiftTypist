import Foundation

enum TypingMode {
//    case progressive(level: Int)
//    case weakSpot
    case realWorld(ContentType)
//    case adaptive
//    case endurance(duration: TimeInterval)
    
    enum ContentType {
        case programming(language: ProgrammingLanguage)
        case academic
        case business
        case numbers
        case punctuation
    }
    
    enum ProgrammingLanguage {
        case swift, python, javascript, c
    }
}
