import Carbon
import Cocoa

class HotKeyManager {
    static let shared = HotKeyManager()
    
    var onTrigger: (() -> Void)?
    private var hotKeyRefs: [EventHotKeyRef] = []
    
    func setup(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger
        
        // 1. Install Event Handler
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                // Dispatch event trigger on the main queue
                DispatchQueue.main.async {
                    HotKeyManager.shared.onTrigger?()
                }
                return noErr
            },
            1,
            &eventType,
            nil as UnsafeMutableRawPointer?,
            nil as UnsafeMutablePointer<EventHandlerRef?>?
        )
        
        if status != noErr {
            print("TinyDict: Failed to install event handler: \(status)")
        }
        
        // 2. Register Hotkey 1: Command + Option + S (virtual key code 1, mod: cmdKey | optionKey)
        registerHotKey(id: 1, keyCode: 1, modifiers: cmdKey | optionKey)
        
        // 3. Register Hotkey 2: Command + Shift + ? (virtual key code 44, which is /, mod: cmdKey | shiftKey)
        registerHotKey(id: 2, keyCode: 44, modifiers: cmdKey | shiftKey)
    }
    
    private func registerHotKey(id: UInt32, keyCode: UInt32, modifiers: Int) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(1416127348), id: id) // 'tdic' signature
        
        let status = RegisterEventHotKey(
            keyCode,
            UInt32(modifiers),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let ref = hotKeyRef {
            hotKeyRefs.append(ref)
        } else {
            print("TinyDict: Failed to register hotkey \(id): \(status)")
        }
    }
    
    deinit {
        for ref in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
    }
}
