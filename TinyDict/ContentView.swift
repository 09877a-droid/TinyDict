import SwiftUI

struct ContentView: View {
    @ObservedObject var mgr = DictionaryManager.shared
    @State private var searchField: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("输入或拷贝单词...", text: $searchField, onCommit: {
                    mgr.lookup(word: searchField)
                    searchField = ""
                })
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(6)
                
                Button(action: { mgr.clear() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.secondary)
                }.buttonStyle(.plain)
            }
            .padding(12)
            
            Divider()
            
            List(mgr.history) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 12) {
                        Text(entry.word)
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.primary)
                        
                        Text(entry.definition)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        Spacer()
                    }
                    
                    if let suggestion = entry.suggestion {
                        Button(action: {
                            searchField = suggestion
                            mgr.lookup(word: suggestion)
                        }) {
                            Text("您是不是想找: \(suggestion) ?")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 92)
                    }
                }
                .padding(.vertical, 6)
            }
            .listStyle(.plain)
            
            Divider()
            
            Text("提示：若仅显示英文释义，请在系统“词典.app”的设置中勾选“简体中文-英文”词典")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.vertical, 6)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 320, minHeight: 450)
    }
}
