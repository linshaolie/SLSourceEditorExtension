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
    
    func getTodoLineRange(with invocation: XCSourceEditorCommandInvocation) -> XCSourceTextRange? {
        let curCursor = invocation.buffer.selections.lastObject as! XCSourceTextRange
        for lineIndex in curCursor.end.line + 1 ..< invocation.buffer.lines.count {
            let line = invocation.buffer.lines[lineIndex] as! String
            if(line.trimmingCharacters(in: CharacterSet.whitespaces).uppercased().hasPrefix("//TODO")) {
                let lineSelection = XCSourceTextRange()
                lineSelection.start = XCSourceTextPosition(line: lineIndex, column: 0)
                lineSelection.end = XCSourceTextPosition(line: lineIndex + 1, column: 0)
                
                return lineSelection
            }
        }
        
        for lineIndex in 0 ..< invocation.buffer.lines.count {
            let line = invocation.buffer.lines[lineIndex] as! String
            if(line.trimmingCharacters(in: CharacterSet.whitespaces).uppercased().hasPrefix("//TODO")) {
                let lineSelection = XCSourceTextRange()
                lineSelection.start = XCSourceTextPosition(line: lineIndex, column: 0)
                lineSelection.end = XCSourceTextPosition(line: lineIndex + 1, column: 0)
                
                return lineSelection
            }
        }
        
        return nil
    }
}
