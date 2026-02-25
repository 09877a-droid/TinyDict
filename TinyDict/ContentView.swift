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
                .padding(.vertical, 6)
            }
            .listStyle(.plain)
        }
        .frame(minWidth: 320, minHeight: 450)
    }
}
