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
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        
        let contentView = NSHostingView(rootView: ShelfView(viewModel: viewModel))
        self.contentView = contentView
    }
    
    public func show(at point: NSPoint) {
        self.setFrameOrigin(point)
        self.makeKeyAndOrderFront(nil)
    }
}
