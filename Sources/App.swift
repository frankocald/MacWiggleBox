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
            print("WARNING: Accessibility permissions are not enabled. Please enable them in System Settings > Privacy & Security > Accessibility.")
            Task { @MainActor in
                let alert = NSAlert()
                alert.messageText = "Accessibility Permissions Required"
                alert.informativeText = "MacWiggleBox requires Accessibility permissions to detect mouse shakes while dragging files. Please grant permission in System Settings."
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
        
        // Start CGEvent tap for reliable mouse tracking during drag operations
        let eventMask = (1 << CGEventType.leftMouseDragged.rawValue) | (1 << CGEventType.rightMouseDragged.rawValue) | (1 << CGEventType.mouseMoved.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                if let refcon = refcon {
                    let detector = Unmanaged<ShakeDetector>.fromOpaque(refcon).takeUnretainedValue()
                    let loc = event.location
                    detector.update(with: loc)
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(detector).toOpaque())
        ) else {
            print("Failed to create event tap. Make sure the app has Accessibility permissions.")
            return
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
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
