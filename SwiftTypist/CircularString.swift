import Foundation

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
