//
//  ViewController.swift
//  YUI
//
//  Created by 晏亚博 on 15/8/15.
//  Copyright © 2015年 晏亚博. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let generateContentView = { (atIndex: Int) -> UIView in
            let containerView = UIView(frame: CGRectZero)
            let contentView = UIView(frame: CGRectZero)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(contentView)
            containerView => contentView.left == containerView.left + 10
                        => contentView.right == containerView.right - 10
                        => contentView.top == containerView.top + 10
                        => contentView.bottom == containerView.bottom - 10
            
            contentView.alpha = 0.3
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
            
            switch (atIndex) {
            case 0:
                contentView.backgroundColor = UIColor.blackColor()
            case 1:
                contentView.backgroundColor = UIColor.blueColor()
            case 2:
                contentView.backgroundColor = UIColor.redColor()
            case 3:
                contentView.backgroundColor = UIColor.purpleColor()
            case 4:
                contentView.backgroundColor = UIColor.brownColor()
            default :
                contentView.backgroundColor = UIColor.yellowColor()
            }
            
//            let label = UILabel(frame: CGRectZero)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            label.textColor = UIColor.whiteColor()
//            label.text = String(atIndex)
//            label.font = UIFont.systemFontOfSize(50)
//            
//            containerView.addSubview(label)
//            
//            containerView => containerView.centerX == label.centerX
//                        => containerView.centerY == label.centerY
            
            return containerView
        }
        
        let circularView = CircularView(pageCount: 5, generateContentView: generateContentView)
        circularView.schedule(4, animateDuration: 0.4)
        
        self.view.addSubview(circularView)
        
        circularView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view => circularView.top == self.view.top + 50
                      => circularView.left == self.view.left
                      => circularView.right == self.view.right
                      => circularView.height == (self.view.frame.height - 80) / 2
    }

}
