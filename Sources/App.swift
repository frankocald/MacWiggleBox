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
        checkPermissions()
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
    
    nonisolated func checkPermissions() {
        let options: NSDictionary = ["AXTrustedCheckOptionPrompt": true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            Task { @MainActor in
                let alert = NSAlert()
                alert.messageText = "Accessibility Permissions Required"
                alert.informativeText = "MacWiggleBox requires Accessibility permissions to detect mouse shakes while dragging files."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Quit")
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                } else {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
    
    func setupShakeDetector() {
        detector.onShakeDetected = { [weak self] in
            DispatchQueue.main.async {
                self?.showShelf()
            }
        }
        
        let mask: NSEvent.EventTypeMask = [.leftMouseDragged, .mouseMoved]
        
        NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            // Only update if a mouse button is pressed (dragging)
            if NSEvent.pressedMouseButtons != 0 {
                self?.detector.update(with: NSEvent.mouseLocation)
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            if NSEvent.pressedMouseButtons != 0 {
                self?.detector.update(with: NSEvent.mouseLocation)
            }
            return event
        }
    }

    @MainActor
    func showShelf() {
        if shelfWindow == nil {
            shelfWindow = ShelfWindow(viewModel: viewModel)
        }
        
        let mouseLocation = NSEvent.mouseLocation
        shelfWindow?.show(at: mouseLocation)
        
        // Ensure the app becomes active to show the window on top
        NSApp.activate(ignoringOtherApps: true)
    }
}
