//
//  NextToDoCommand.swift
//  MyXCExtension
//
//  Created by shaolie on 16/9/21.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Foundation
import XcodeKit

class NextToDoCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let lineSelection: XCSourceTextRange? = self.getTodoLineRange(with: invocation)
        
        if lineSelection != nil {
            invocation.buffer.selections.setArray([lineSelection!])
            completionHandler(nil)
        } else {
            completionHandler(NSError(domain: "there have not TODO in file", code: 0, userInfo: nil))
        }
        
    }
    
    func getTodoRange(with invocation: XCSourceEditorCommandInvocation,
                      start: Int, end: Int) -> XCSourceTextRange? {
        for lineIndex in start ..< end {
            let line = invocation.buffer.lines[lineIndex] as! String
            let upperLine = line.trimmingCharacters(in: CharacterSet.whitespaces).uppercased()
            if(upperLine.hasPrefix("//TODO") || upperLine.hasPrefix("// TODO")) {
                let lineSelection = XCSourceTextRange()
                lineSelection.start = XCSourceTextPosition(line: lineIndex, column: 0)
                lineSelection.end = XCSourceTextPosition(line: lineIndex + 1, column: 0)
                
                return lineSelection
            }
        }
        return nil
    }
    
    func getTodoLineRange(with invocation: XCSourceEditorCommandInvocation) -> XCSourceTextRange? {
        let curCursor = invocation.buffer.selections.lastObject as! XCSourceTextRange
        var lineSelection = self.getTodoRange(with: invocation, start: curCursor.end.line + 1, end: invocation.buffer.lines.count)

        if lineSelection == nil {
            lineSelection = self.getTodoRange(with: invocation, start: 0, end: invocation.buffer.lines.count)
        }
        return lineSelection
    }
}
