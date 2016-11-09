//
//  CommentSelectionCommand.swift
//  MyXCExtension
//
//  Created by shaolie on 2016/11/1.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Cocoa
import XcodeKit

class CommentSelectionCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        if invocation.buffer.selections.count >= 1 {
            let lines = invocation.buffer.lines;
            let lineRange = invocation.buffer.selections[0] as! XCSourceTextRange
            let firstLine = lines[lineRange.start.line] as! String
            if(firstLine.trimmingCharacters(in: CharacterSet.whitespaces).hasPrefix("//")) {
                // uncomment
                let range = firstLine.range(of: "//");
                for lineIndex in lineRange.start.line ... lineRange.end.line {
                    let line = lines[lineIndex] as! String
                    
                    invocation.buffer.lines[lineIndex] = line.replacingOccurrences(of: "//", with: "", options: String.CompareOptions.caseInsensitive, range: range)
                }
                
            } else {
                // comment
                for lineIndex in lineRange.start.line ... lineRange.end.line {
                    let line = lines[lineIndex] as! String
                    var slash = "//";
                    slash.append(line);
                    invocation.buffer.lines[lineIndex] = slash;
                }

                
            }
            completionHandler(nil)
        }
    }
}
