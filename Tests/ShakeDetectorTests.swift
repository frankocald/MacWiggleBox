import XCTest
@testable import MacWiggleBox

final class ShakeDetectorTests: XCTestCase {
    func testShakeDetection() {
        let detector = ShakeDetector()
        var shakeDetected = false
        detector.onShakeDetected = {
            shakeDetected = true
        }
        
        // Simulate a rapid left-right shake
        let points: [CGPoint] = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 150, y: 100), // Move right
            CGPoint(x: 100, y: 100), // Move left
            CGPoint(x: 150, y: 100), // Move right
            CGPoint(x: 100, y: 100), // Move left
            CGPoint(x: 150, y: 100), // Move right
            CGPoint(x: 100, y: 100)  // Move left
        ]
        
        for point in points {
            detector.update(with: point)
        }
        
        XCTAssertTrue(shakeDetected, "Shake should be detected for rapid left-right movement")
    }
    
    func testNoShakeDetectionForSlowMovement() {
        let detector = ShakeDetector()
        var shakeDetected = false
        detector.onShakeDetected = {
            shakeDetected = true
        }
        
        // Simulate a slow movement
        let points: [CGPoint] = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: 105, y: 100),
            CGPoint(x: 110, y: 100),
            CGPoint(x: 115, y: 100)
        ]
        
        for point in points {
            detector.update(with: point)
        }
        
        XCTAssertFalse(shakeDetected, "Shake should not be detected for slow unidirectional movement")
    }
}
