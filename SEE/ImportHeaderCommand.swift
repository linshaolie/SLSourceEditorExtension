//
//  ImportHeaderCommand.swift
//  MyXCExtension
//
//  Created by shaolie on 16/9/22.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Cocoa
import XcodeKit

enum LanguageType : String {
    case swift = "swift"
    case objc = "obj-c"
}


class ImportHeaderCommand: NSObject, XCSourceEditorCommand {
    var languageType: LanguageType = .swift
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        self.languageType = self.getLanguageType(invocation)
        
        //获取选择行区间
        let lineRange = invocation.buffer.selections.firstObject as! XCSourceTextRange
        
        // 异常判断（是否有选中）
        if lineRange.start.line == lineRange.end.line &&
            lineRange.start.column == lineRange.end.column {
            completionHandler(NSError(domain: "have not selections line", code: -1, userInfo: nil))
            return;
        }
        
        let lines = invocation.buffer.lines
        // 获取选择的字符串
        let selectionString = self.getSelectionString(lines: lines, lineRange: lineRange)
        
        // 获取插入位置
        let headerName = self.getHeaderName(key: selectionString)
        self.importHeader(lines: lines, headerName: headerName)
        
        completionHandler(nil)
    }
    
    private func importHeader(lines: NSMutableArray, headerName: String) {
        let importLineIndex = self.getLastImportIndex(lines: lines)
        var importString: String
        switch self.languageType {
            case .objc:
                importString = "#import " + headerName + "\n"
            default:
                importString = "import " + headerName + "\n"
        }
        
        // 插入头文件引入
        lines.insert(importString, at: importLineIndex)
    }
    
    private func getSelectionString(lines: NSArray, lineRange: XCSourceTextRange) -> String {
        let selectedLine = lines[lineRange.start.line] as! String
        let endOffset = min(max(lineRange.start.column, lineRange.end.column), selectedLine.count - 1)
        let range: Range<String.Index> = selectedLine.index(selectedLine.startIndex, offsetBy: lineRange.start.column) ..< selectedLine.index(selectedLine.startIndex, offsetBy:  endOffset)
        return String(selectedLine[range])
    }
    
    private func getLastImportIndex(lines: NSArray) -> Int {
        for (index, line) in lines.enumerated() {
            if isImportLine(line: line as! String) {
                return index
            }
        }
        return 0
    }
    
    private func isImportLine(line: String) -> Bool {
        return line.hasPrefix("#import") || line.hasPrefix("import")
    }
    
    private func getLanguageType(_ invocation: XCSourceEditorCommandInvocation) -> LanguageType {
        let buffer = invocation.buffer.completeBuffer
        if buffer.contains("#import") || buffer.contains("@interface") || buffer.contains("@implementation") {
            return .objc
        }
        return .swift
    }

    private func getHeaderName(key: String) -> String {
        let heaerName = key.trimmingCharacters(in: CharacterSet.whitespaces)
        switch self.languageType {
        case .objc:
            if key.hasPrefix("UI") {
                return "<UIKit/UIKit.h>"
            } else if key.hasPrefix("NS") {
                return "<Foundation/Foundation.h>"
            }
            return "\"\(heaerName).h\""
        default:
            if key.hasPrefix("UI") {
                return "UIKit"
            } else if key.hasPrefix("NS") {
                return "Foundation"
            }
            return heaerName
        }
    }
}
