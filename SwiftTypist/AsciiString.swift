import Foundation

struct CircularAsciiString: ExpressibleByStringLiteral {
    private let strBuffer: Array<UInt8>
    
    init?(_ strBuffer: String) {
        guard let data = strBuffer.data(using: .ascii) else { return nil }
        self.strBuffer = Array(data)
    }
    
    /// Will crash if non-ascii characters are used
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

/// Same as CircularString, but no wrappedIndex so character subscript returns nil if out of range, and range subscript can return an empty string
struct LinearAsciiString: ExpressibleByStringLiteral {
    private let strBuffer: Array<UInt8>
    
    init?(_ strBuffer: String) {
        guard let data = strBuffer.data(using: .ascii) else { return nil }
        self.strBuffer = Array(data)
    }
    
    /// Will crash if non-ascii characters are used
    init(stringLiteral value: String) {
        self.init(value)!
    }
    
    subscript(index: Int) -> Character? {
        guard index < strBuffer.count && index >= 0 else { return nil }
        
        return Character(UnicodeScalar(strBuffer[index]))
    }
    
    subscript<R>(range: R) -> String where R: RangeExpression, R.Bound == Int {
        let bufferRange = strBuffer.indices
        let concreteRange = range.relative(to: Int.min..<Int.max)
        
        var result: [UInt8] = []
        result.reserveCapacity(concreteRange.count)
        
        for i in concreteRange where bufferRange.contains(i) {
            result.append(strBuffer[i])
        }
        
        return String(bytes: result, encoding: .ascii)!
    }
}

enum AsciiString {
    case circular(CircularAsciiString)
    case linear(LinearAsciiString)
    
    subscript(index: Int) -> Character? {
        switch self {
        case let .circular(str):
            return str[index]
        case let .linear(str):
            return str[index]
        }
    }
    
    subscript<R>(range: R) -> String where R: RangeExpression, R.Bound == Int {
        switch self {
        case let .circular(str):
            return str[range]
        case let .linear(str):
            return str[range]
        }
    }
}
