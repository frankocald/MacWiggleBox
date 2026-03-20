import Cocoa
import SwiftUI

public class ShelfWindow: NSPanel {
    public init(viewModel: ShelfViewModel) {
        // Remove .borderless for .titled to work. 
        // Remove .nonactivatingPanel to allow standard controls to behave normally.
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView, .utilityWindow, .hudWindow]
        super.init(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                   styleMask: styleMask,
                   backing: .buffered,
                   defer: false)
        
        self.isFloatingPanel = true
        self.level = .statusBar 
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.hasShadow = true
        
        // Allow dragging from the background (very important for borderless-look windows)
        self.isMovableByWindowBackground = true
        
        // Hide title bar but keep controls
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        
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
