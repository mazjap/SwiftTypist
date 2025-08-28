import Foundation

extension CGSize {
    func midPoint(withOriginOf origin: CGPoint = .zero) -> CGPoint {
        let rect = CGRect(origin: origin, size: self)
        
        return CGPoint(x: rect.midX, y: rect.midY)
    }
}
