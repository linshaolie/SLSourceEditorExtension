//
//  ImportHeaderCommand.swift
//  MyXCExtension
//
//  Created by shaolie on 16/9/22.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Cocoa
import XcodeKit

class ImportHeaderCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        
        //获取行
        let lines = invocation.buffer.lines;
        let lineRange = invocation.buffer.selections[0] as! XCSourceTextRange
        
        // 1. 异常判断（是否有选中）
        if lineRange.start.line == lineRange.end.line &&
            lineRange.start.column == lineRange.end.column {
            completionHandler(NSError(domain: "have not selections line", code: -1, userInfo: nil))
            return;
        }
        
        // 2. 拿到选择的字符串
        let selectedLine = lines[lineRange.start.line] as! String
        let endOffset = min(max(lineRange.start.column, lineRange.end.column), (selectedLine as NSString).length - 1)
        let range: Range<String.Index> = selectedLine.index(selectedLine.startIndex, offsetBy: lineRange.start.column) ..< selectedLine.index(selectedLine.startIndex, offsetBy:  endOffset)
        let subString = selectedLine.substring(with: range)
        
        let headerName = subString.trimmingCharacters(in: CharacterSet.whitespaces)
        
        // 3. 获取插入位置
        let importLineIndex = self.getLastImportIndex(lines: lines)
        if importLineIndex < invocation.buffer.lines.count {
            var importString: String
            // 4. 开发语言类型判断
            switch self.getLanguageType(invocation.buffer.lines[importLineIndex] as! String) {
                case "obj-c":
                    importString = "#import " + "\"" + headerName + ".h\"" + "\n"
                case "swift":
                    importString = "import " + headerName + "\n"
                default:
                    importString = ""
            }
            
            // 5. 插入头文件引入
            invocation.buffer.lines.insert(importString as NSString, at: importLineIndex + 1)
        }
        
        // 6. 回调
        completionHandler(nil)
        
    }
    
    private func getLastImportIndex(lines: NSArray) -> Int {
        for i in 0 ..< lines.count {
            let line = lines[lines.count - 1 - i] as! String
            if isImportType(line: line) {
                return lines.count - 1 - i
            }
        }
        return 0;
    }
    
    private func isImportType(line: String) -> Bool {
        return line.hasPrefix("#import") || line.hasPrefix("import")
    }
    
    private func getLanguageType(_ line: String) -> String {
        if line.hasPrefix("#") {
            return "obj-c"
        }
        return "swift"
    }
}
