import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var clipboardHistory: [String] = []
    let pasteboard = NSPasteboard.general
    var lastChangeCount = 0
    let maxHistoryLimit = 10

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        NSApplication.shared.setActivationPolicy(.accessory)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(showMenu)
        }

        startClipboardMonitoring()
    }

    @objc func showMenu() {
        let menu = NSMenu()

        if !clipboardHistory.isEmpty {
            for (index, item) in clipboardHistory.prefix(10).enumerated() {
                let preview = item.count > 30 ? String(item.prefix(30)) + "..." : item  // Truncate long items
                let menuItem = NSMenuItem(title: preview, action: #selector(pasteClipboardItem(_:)), keyEquivalent: "")
                menuItem.target = self
                menuItem.tag = index
                menu.addItem(menuItem)
            }
        } else {
            menu.addItem(NSMenuItem(title: "No clipboard items", action: nil, keyEquivalent: ""))
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))

        statusItem?.menu = menu
    }

    @objc func pasteClipboardItem(_ sender: NSMenuItem) {
        let selectedItemIndex = sender.tag
        if selectedItemIndex < clipboardHistory.count {
            let itemToPaste = clipboardHistory[selectedItemIndex]
            pasteboard.clearContents()
            pasteboard.setString(itemToPaste, forType: .string)
            print("Pasted clipboard item: \(itemToPaste)")

            simulatePaste()

            moveItemToTop(at: selectedItemIndex)
        }
    }

    func moveItemToTop(at index: Int) {
        let item = clipboardHistory[index]
        clipboardHistory.remove(at: index)
        clipboardHistory.insert(item, at: 0)
        print("Moved item to top: \(item)")

        showMenu()
    }

    func simulatePaste() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
        keyVDown?.flags = .maskCommand
        let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)

        keyVDown?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }

    func startClipboardMonitoring() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPasteboard), userInfo: nil, repeats: true)
    }

    @objc func checkPasteboard() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let newContent = pasteboard.string(forType: .string), !newContent.isEmpty {
                if clipboardHistory.isEmpty || clipboardHistory.first != newContent {
                    clipboardHistory.insert(newContent, at: 0)
                    if clipboardHistory.count > maxHistoryLimit {
                        clipboardHistory.removeLast()
                    }
                    print("New clipboard content added: \(newContent)")
                    showMenu()
                }
            }
        }
    }
}
