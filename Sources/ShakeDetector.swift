import Foundation

public class ShakeDetector {
    public var onShakeDetected: (() -> Void)?
    
    private var points: [(point: CGPoint, time: Date)] = []
    private let maxPoints = 50 
    private let shakeThreshold = 3 
    private let timeWindow: TimeInterval = 0.8 
    
    public init() {}
    
    public func update(with point: CGPoint) {
        let now = Date()
        points.append((point, now))
        
        points = points.filter { now.timeIntervalSince($0.time) < timeWindow }
        if points.count > maxPoints {
            points.removeFirst()
        }
        
        if isShake() {
            onShakeDetected?()
            points.removeAll()
        }
    }
    
    private func isShake() -> Bool {
        guard points.count >= 4 else { return false }
        
        var directionChanges = 0
        var lastDirection: CGFloat = 0 
        
        for i in 1..<points.count {
            let dx = points[i].point.x - points[i-1].point.x
            if abs(dx) > 1 { 
                let currentDirection = dx > 0 ? 1.0 : -1.0
                if lastDirection != 0 && currentDirection != lastDirection {
                    directionChanges += 1
                }
                lastDirection = currentDirection
            }
        }
        
        let minX = points.map { $0.point.x }.min() ?? 0
        let maxX = points.map { $0.point.x }.max() ?? 0
        let totalSpan = maxX - minX
        
        return directionChanges >= shakeThreshold && totalSpan > 10
    }
}
