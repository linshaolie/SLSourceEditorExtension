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
        
        if invocation.buffer.selections.count >= 1 {
            let lines = invocation.buffer.lines;
            let lineRange = invocation.buffer.selections[0] as! XCSourceTextRange
            
            if lineRange.start.line == lineRange.end.line &&
                lineRange.start.column == lineRange.end.column {
                completionHandler(NSError(domain: "have not selections line", code: -1, userInfo: nil))
                return;
            }
            let selectedLine = lines[lineRange.start.line] as! String
            
            let range: Range<String.Index> = selectedLine.index(selectedLine.startIndex, offsetBy: lineRange.start.column) ..< selectedLine.index(selectedLine.startIndex, offsetBy: lineRange.end.column + 1)
            let subString = selectedLine.substring(with: range)
            
            let headerName = subString.trimmingCharacters(in: CharacterSet.whitespaces)
            
            let importLineIndex = self.getLastImportIndex(lines: lines)
            if importLineIndex < invocation.buffer.lines.count {
                var importString: String
                switch self.getLanguageType(invocation.buffer.lines[importLineIndex] as! String) {
                    case "obj-c":
                        importString = "#import " + "\"" + headerName + ".h\"" + "\n"
                    case "swift":
                        importString = "import " + headerName + "\n"
                    default:
                        importString = ""
                }
                
                invocation.buffer.lines.insert(importString as NSString, at: importLineIndex + 1)
            }
            
            completionHandler(nil)
        } else {
            completionHandler(NSError(domain: "have not selections line", code: -1, userInfo: nil))
        }
        
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
