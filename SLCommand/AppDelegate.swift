//
//  AppDelegate.swift
//  SLCommand
//
//  Created by shaolie on 16/9/24.
//  Copyright © 2016年 shaolie. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var authorBtn: NSButton!

    @IBOutlet weak var logoBtn: NSButton!
    @IBOutlet weak var btn: NSButton!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let color = NSColor(red: 9 / 255.0, green: 80 / 255.0, blue: 208 / 255.0, alpha: 1)
        let colorTitle = NSMutableAttributedString(string: authorBtn.title, attributes: [NSForegroundColorAttributeName:color])
        authorBtn.attributedTitle = colorTitle
        
        let a = CABasicAnimation.init(keyPath: "transform.rotation.z")
        a.fromValue = 0
        a.toValue = -M_PI * 2
        logoBtn.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        a.duration = 6;
        a.repeatCount = HUGE;
        
        logoBtn.layer?.add(a, forKey: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Insert code here to tear down your application
    }


    @IBAction func clickShaolie(_ sender: Any) {
        let url = URL(string: "https://github.com/linshaolie/SLSourceEditorExtension")
        NSWorkspace.shared().open(url!)
    }
}

