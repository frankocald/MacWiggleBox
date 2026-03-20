import Cocoa
import SwiftUI

public class ShelfWindow: NSPanel {
    public init(viewModel: ShelfViewModel) {
        let styleMask: NSWindow.StyleMask = [.nonactivatingPanel, .fullSizeContentView, .borderless]
        super.init(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                   styleMask: styleMask,
                   backing: .buffered,
                   defer: false)
        
        self.isFloatingPanel = true
        // Use a much higher level to stay on top of other apps during drags
        self.level = .statusBar 
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        
        let contentView = NSHostingView(rootView: ShelfView(viewModel: viewModel))
        self.contentView = contentView
    }
    
    public func show(at point: NSPoint) {
        // Center the window on the cursor
        let width: CGFloat = 300
        let height: CGFloat = 200
        let origin = NSPoint(x: point.x - width / 2, y: point.y - height / 2)
        
        self.setFrameOrigin(origin)
        self.makeKeyAndOrderFront(nil)
        self.orderFrontRegardless()
    }
}
