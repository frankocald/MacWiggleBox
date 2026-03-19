import SwiftUI
import Cocoa

@main
struct MacWiggleBoxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var shelfWindow: ShelfWindow?
    let viewModel = ShelfViewModel()
    let detector = ShakeDetector()
    var monitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupShakeDetector()
        
        // Show dock icon
        NSApp.setActivationPolicy(.regular)
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hand.raised.fill", accessibilityDescription: "MacWiggleBox")
            button.action = #selector(statusItemClicked)
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit MacWiggleBox", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    @objc func statusItemClicked() {
        // Handle click if needed
    }
    
    func setupShakeDetector() {
        detector.onShakeDetected = { [weak self] in
            DispatchQueue.main.async {
                self?.showShelf()
            }
        }
        
        // Start a high-frequency timer to poll mouse location.
        // This is necessary because both NSEvent monitors and CGEvents 
        // can be blocked or require strict permissions during drag operations.
        // NSEvent.mouseLocation always works.
        let timer = Timer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(pollMouseLocation), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func pollMouseLocation() {
        let loc = NSEvent.mouseLocation
        detector.update(with: loc)
    }
        
    
    @MainActor
    func showShelf() {
        if shelfWindow == nil {
            shelfWindow = ShelfWindow(viewModel: viewModel)
        }
        
        let mouseLocation = NSEvent.mouseLocation
        shelfWindow?.show(at: mouseLocation)
        
        // Give it focus for a moment to ensure it's on top
        shelfWindow?.makeKey()
    }
}
