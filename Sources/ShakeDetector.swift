import Foundation

public class ShakeDetector {
    public var onShakeDetected: (() -> Void)?
    
    private var points: [(point: CGPoint, time: Date)] = []
    private let maxPoints = 10
    private let shakeThreshold = 3 // Number of direction reversals
    private let timeWindow: TimeInterval = 0.5 // Window to consider for a shake
    
    public init() {}
    
    public func update(with point: CGPoint) {
        let now = Date()
        points.append((point, now))
        
        // Remove old points
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
        var lastDirection: CGFloat = 0 // 1 for right, -1 for left
        
        for i in 1..<points.count {
            let dx = points[i].point.x - points[i-1].point.x
            if abs(dx) > 5 { // Minimum movement threshold
                let currentDirection = dx > 0 ? 1.0 : -1.0
                if lastDirection != 0 && currentDirection != lastDirection {
                    directionChanges += 1
                }
                lastDirection = currentDirection
            }
        }
        
        return directionChanges >= shakeThreshold
    }
}
