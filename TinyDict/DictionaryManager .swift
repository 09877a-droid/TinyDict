import SwiftUI
import Foundation
import CoreServices
import Combine

struct WordEntry: Identifiable, Codable {
    var id = UUID()
    let word: String
    let definition: String
}

class DictionaryManager: ObservableObject {
    static let shared = DictionaryManager()
    @Published var history: [WordEntry] = []
    private let storageKey = "TinyDictHistoryData"

    init() { loadHistory() }

    func lookup(word: String) {
        // 1. 提取单词：去掉空格、换行和非字母符号
        let cleaned = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.letters.inverted).first ?? ""
        
        guard cleaned.count >= 2 else { return }

        // 2. 调用系统词典
        let range = CFRangeMake(0, cleaned.utf16.count)
        guard let definitionRaw = DCSCopyTextDefinition(nil, cleaned as CFString, range) else {
            self.updateEntry(word: cleaned, def: "系统词典无结果")
            return
        }
        
        let rawText = definitionRaw.takeRetainedValue() as String
        
        // 3. 提取释义（使用最稳健的遍历法）
        let simple = extractChinese(rawText)
        self.updateEntry(word: cleaned, def: simple)
    }

    private func updateEntry(word: String, def: String) {
        DispatchQueue.main.async {
            self.history.removeAll { $0.word.lowercased() == word.lowercased() }
            self.history.insert(WordEntry(word: word, definition: def), at: 0)
            if self.history.count > 100 { self.history.removeLast() }
            self.saveHistory()
        }
    }

    // --- 稳健版提取逻辑：直接遍历字符，不使用正则表达式 ---
    private func extractChinese(_ raw: String) -> String {
        var results: [String] = []
        var currentBlock = ""
        
        // 排除掉这些字典干扰词
        let stopWords = ["用法", "例句", "词变", "来自", "常用", "及物", "不及物", "名词", "动词", "形容词", "副词", "缩写"]

        for char in raw {
            // 判断字符是否为汉字 (Unicode 范围)
            if ("\u{4E00}"..."\u{9FFF}").contains(char) {
                currentBlock.append(char)
            } else {
                // 如果遇到非汉字，且之前积累了一段汉字词块
                if currentBlock.count >= 2 {
                    if !stopWords.contains(currentBlock) && !results.contains(currentBlock) {
                        results.append(currentBlock)
                    }
                }
                currentBlock = ""
            }
            // 只要抓到 6 个意思就收手
            if results.count >= 6 { break }
        }

        if results.isEmpty {
            // 保底方案：如果没有词块，抓取前 10 个单字汉字
            let allChinese = raw.filter { ("\u{4E00}"..."\u{9FFF}").contains($0) }
            if allChinese.isEmpty { return "未找到中文释义" }
            return String(allChinese.prefix(10))
        }

        return results.joined(separator: "；")
    }

    func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([WordEntry].self, from: data) {
            DispatchQueue.main.async { self.history = decoded }
        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.history = []
            UserDefaults.standard.removeObject(forKey: self.storageKey)
        }
    }
}
