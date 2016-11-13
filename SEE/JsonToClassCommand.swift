//
//  JsonToClassCommand.swift
//  SLCommand
//
//  Created by shaolie on 2016/11/11.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Foundation
import XcodeKit

class JsonToClassCommand: NSObject, XCSourceEditorCommand {
    var classContent = [Array<String>]()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        print(invocation.buffer.lines)
        print(invocation.buffer.completeBuffer)
        do {
            let data = invocation.buffer.completeBuffer.data(using: .utf8)!
            let dic:[String: AnyObject] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            
            self.interateJson(jsonObj: dic as AnyObject, className: "ClassName")
            for arr in classContent.reversed() {
                invocation.buffer.lines.addObjects(from: arr)
            }
        } catch {
//            print(error.localizedDescription)
            completionHandler(error)
        }
        completionHandler(nil)
    }
    
    func interateJson(jsonObj: AnyObject, className: String) -> Void {
        var content = [String]()
        if jsonObj.isKind(of: NSDictionary.self) {
            let dic = jsonObj as! [String: AnyObject]
            for (key, value) in dic {
                if value.isKind(of: NSString.self) {
                    content.append("@property (nonatomic, copy) \tNSString *\(key);")
                } else if value.isKind(of: NSArray.self) {
                    content.append("@property (nonatomic, strong) \tNSArray<<#\(key)OfClass#>> *\(key);")
                    
                    let arr = value as! Array<AnyObject>
                    if arr.count > 0 {
                        if arr.first!.isKind(of: NSDictionary.self) {
                            interateJson(jsonObj: arr.first as AnyObject, className: "\(key)OfClass")
                        }
                    }
                    
                } else if value.isKind(of: NSDictionary.self) {
                    content.append("@property (nonatomic, strong) \t<#\(key)OfClass#> *\(key);")
                    
                    interateJson(jsonObj: value, className: "\(key)OfClass")
                    
                } else if value.isKind(of: NSNumber.self) {
                    content.append("@property (nonatomic, copy) \tNSNumber *\(key);")
                }
            }
        }
        
        content.insert("\n\n@interface <#\(className)#> : NSObject\n\n", at: 0)
        content.append("\n\n@end")
        classContent.append(content)
    }
}
