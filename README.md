# TinyDict - macOS 轻量级菜单栏词典应用

TinyDict 是一个专为 macOS 设计的轻量级菜单栏/悬浮窗词典应用。它调用 macOS 原生的系统词典接口，支持划词自动复制并查询释义，适合作为桌面端极速查词工具。

## 项目特点与技术栈

- **核心框架**：Swift 5 + SwiftUI + AppKit
- **运行平台**：macOS 10.15+
- **免权限全局快捷键**：采用 Carbon 框架底层的 `RegisterEventHotKey` API 实现，**无需**在系统“辅助功能”中开启授权，开箱即用。
- **启动即可见**：启动时会自动弹出主界面，并在顶部菜单栏显示书本图标。
- **划词快捷查询**：按下快捷键后，应用将自动触发复制选中文本的操作，并自动调起系统词典进行中文释义查询。

---

## 快速上手与运行

1. 用 Xcode 打开项目根目录下的 `TinyDict.xcodeproj`。
2. 选择 Scheme 为 `TinyDict`，运行设备为 `My Mac`。
3. 点击 **Run** (或者按 `Cmd + R`) 编译并运行。
4. 运行后，屏幕上会自动弹出 TinyDict 的查词主窗口，且顶部菜单栏会出现一个 📖 图标。
5. 关闭窗口不会退出应用（仅在后台运行并常驻菜单栏），点击顶部 📖 图标或使用全局快捷键可以再次唤起。

---

## 默认快捷键

应用启动后，您可以使用以下两个默认的全局快捷键（在任意其他应用中均可直接触发）：

- **`Command + Option + S`**
- **`Command + Shift + ?`** (即 `Command + Shift + /`)

### 使用方法：
在浏览器、PDF 阅读器或任何编辑器中选中想要查询的单词，按下上述任意快捷键，TinyDict 将会自动提取选中的词汇并弹出释义窗口。

---

## 如何自定义修改快捷键？

如果您想把默认快捷键修改为其他组合，只需简单修改代码中的按键码（Key Code）与修饰键（Modifiers）：

### 修改步骤：
1. 在 Xcode 中打开 [HotKeyManager.swift](file:///Users/a1/Desktop/all_monthly_csv/TinyDict/TinyDict/HotKeyManager.swift)。
2. 找到 `setup(onTrigger:)` 方法，你会看到如下注册代码：
   ```swift
   // 注册快捷键 1: Command + Option + S
   registerHotKey(id: 1, keyCode: 1, modifiers: cmdKey | optionKey)
   
   // 注册快捷键 2: Command + Shift + ? (即 / 键)
   registerHotKey(id: 2, keyCode: 44, modifiers: cmdKey | shiftKey)
   ```
3. 根据下表，修改您想要的 `keyCode` 以及 `modifiers` 组合，然后重新编译运行即可！

### 常用 macOS 虚拟键码（Key Code）对照表：

| 按键 | 键码 (keyCode) | 按键 | 键码 (keyCode) |
| :--- | :--- | :--- | :--- |
| **A** | `0` | **S** | `1` |
| **D** | `2` | **F** | `3` |
| **E** | `14` | **R** | `15` |
| **Space (空格)** | `49` | **/** (及 **?**) | `44` |
| **Enter (回车)** | `36` | **Escape** | `53` |

> 提示：如果您想查询其他按键的物理键码，可以在网上搜索 “macOS virtual key codes”。

### 常用修饰键（Modifiers）对照表：

| 修饰键 | 代码常量 |
| :--- | :--- |
| **Command (⌘)** | `cmdKey` |
| **Shift (⇧)** | `shiftKey` |
| **Option / Alt (⌥)** | `optionKey` |
| **Control (⌃)** | `controlKey` |

*例如：若想改为 `Command + Control + D`，代码修改为：*
```swift
registerHotKey(id: 1, keyCode: 2, modifiers: cmdKey | controlKey)
```

---

## 许可证
[MIT License](LICENSE.txt)
