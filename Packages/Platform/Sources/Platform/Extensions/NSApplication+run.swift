//
//  Copyright © Marc Rollin.
//

import Cocoa
import SwiftUI

extension NSApplication {

    public func run(@ViewBuilder view: () -> some View) {
        let appDelegate = AppDelegate(view())
        NSApp.setActivationPolicy(.regular)
        mainMenu = customMenu
        delegate = appDelegate
        run()
    }
}

extension NSApplication {

    private var customMenu: NSMenu {
        .init(title: "Main Menu")..{ mainMenu in
            mainMenu.addItem(.init()..{ appMenu in
                appMenu.submenu = .init()..{ submenu in
                    let appName = ProcessInfo.processInfo.processName
                    submenu.addItem(.init(
                        title: "About \(appName)",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: ""
                    ))
                    submenu.addItem(.separator())
                    submenu.addItem(.init(title: "Services", action: nil, keyEquivalent: "")..{ services in
                        self.servicesMenu = NSMenu()
                        services.submenu = self.servicesMenu
                    })
                    submenu.addItem(.separator())
                    submenu.addItem(.init(title: "Hide \(appName)", action: #selector(NSApplication.hide), keyEquivalent: "h"))
                    submenu.addItem(.init(
                        title: "Hide Others",
                        action: #selector(NSApplication.hideOtherApplications),
                        keyEquivalent: "h"
                    )..{
                        $0.keyEquivalentModifierMask = [.command, .option]
                    })
                    submenu.addItem(.init(
                        title: "Show All",
                        action: #selector(NSApplication.unhideAllApplications),
                        keyEquivalent: ""
                    ))
                    submenu.addItem(.separator())
                    submenu.addItem(.init(
                        title: "Quit \(appName)",
                        action: #selector(NSApplication.terminate),
                        keyEquivalent: "q"
                    ))
                }
            })
            mainMenu.addItem(.init()..{ windowMenu in
                windowMenu.submenu = NSMenu(title: "Window")..{ submenu in
                    submenu.addItem(NSMenuItem(title: "Minmize", action: #selector(NSWindow.miniaturize), keyEquivalent: "m"))
                    submenu.addItem(NSMenuItem(title: "Zoom", action: #selector(NSWindow.performZoom), keyEquivalent: ""))
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(NSMenuItem(
                        title: "Show All",
                        action: #selector(NSApplication.arrangeInFront),
                        keyEquivalent: "m"
                    ))
                }
            })
        }
    }
}

// MARK: - AppDelegate

private final class AppDelegate<ContentView: View>: NSObject, NSApplicationDelegate, NSWindowDelegate {

    // MARK: Lifecycle

    init(_ contentView: ContentView) {
        self.contentView = contentView
    }

    // MARK: Internal

    var window: NSWindow!
    var hostingView: NSView?
    var contentView: ContentView

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView, .unifiedTitleAndToolbar],
            backing: .buffered,
            defer: false
        )
        window.collectionBehavior = [.fullScreenNone, .moveToActiveSpace, .participatesInCycle, .managed]
        window.center()
        window.setFrameAutosaveName("Main Window")
        hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        NSApp.activate(ignoringOtherApps: true)
    }

    // Terminate application when window closes
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }

    func windowWillUseStandardFrame(_ window: NSWindow, defaultFrame newFrame: NSRect) -> NSRect {
        guard let screen = window.screen else {
            return newFrame
        }

        let screenRect = screen.visibleFrame
        let newWidth = screenRect.width * 0.8
        let newHeight = screenRect.height * 0.8
        let newOriginX = (screenRect.width - newWidth) / 2
        let newOriginY = (screenRect.height - newHeight) / 2

        return NSRect(x: newOriginX, y: newOriginY, width: newWidth, height: newHeight)
    }
}
