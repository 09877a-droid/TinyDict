import SwiftUI
import AppKit

@main
struct TinyDictApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. 创建右上角图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)
            button.action = #selector(toggleWindow)
            button.target = self
        }

        // 2. 配置窗口
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 320, height: 450),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.level = .floating
        window.title = "TinyDict"
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = NSHostingView(rootView: ContentView())

        // 3. 注册系统服务（用于右键菜单）
        NSApp.servicesProvider = self

        // 4. 启动时显示窗口
        showWindow()

        // 5. 【核心】全局快捷键监听（免系统辅助功能授权）
        HotKeyManager.shared.setup { [weak self] in
            self?.handleHotKey()
        }
    }

    // 快捷键触发时的逻辑
    func handleHotKey() {
        // 第一步：模拟 Command + C 复制选中的文本
        let src = CGEventSource(stateID: .hidSystemState)
        let cDown = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: true)
        cDown?.flags = .maskCommand
        let cUp = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: false)
        cUp?.flags = .maskCommand
        
        cDown?.post(tap: .cghidEventTap)
        cUp?.post(tap: .cghidEventTap)
        
        // 第二步：稍微延迟一点点（等系统剪贴板更新），然后读取翻译
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let str = NSPasteboard.general.string(forType: .string) {
                let cleaned = str.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty {
                    DictionaryManager.shared.lookup(word: cleaned)
                    self.showWindow()
                }
            }
        }
    }

    // 响应右键菜单“服务”点击（补充回来的逻辑）
    @objc func handleService(_ pb: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSDictionary?>) {
        if let str = pb.string(forType: .string) {
            DictionaryManager.shared.lookup(word: str)
            self.showWindow()
        }
    }

    func showWindow() {
        DispatchQueue.main.async {
            self.window.setIsVisible(true)
            self.window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            self.window.orderFrontRegardless()
        }
    }

    @objc func toggleWindow() {
        if window.isVisible && NSApp.isActive {
            window.orderOut(nil)
        } else {
            showWindow()
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        window.orderOut(nil)
        return false
    }
}
