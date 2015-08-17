//
//  CircularView.swift
//  YUI
//
//  Created by 晏亚博 on 15/8/16.
//  Copyright © 2015年 晏亚博. All rights reserved.
//

import UIKit
import Darwin

// 用先进后出的队列实现循环滚动，队列中最多只维持 3 个 UIView

class CircularView: UIView {

    var visiableViews: [UIView] = []  // 队列保存的位置
    
    var pageCount:  Int = 0
    var firstIndex: Int = -1
    var lastIndex:  Int = -1
    var generateContentView: (atIndex: Int) -> UIView
    var leftEdgeConstraint: NSLayoutConstraint = NSLayoutConstraint()   // 当前显示 UIView 的 constraint，用于实现手势动画
    var edgeConstraints: [NSLayoutConstraint] = []   // 用于确定队列中 UIView 水平位置的 contraint
    
    var gestureRecognizer: UIGestureRecognizer?
    var maxX: Float = 0.0   // 手势水平方向上移动的最大距离，用于确定手势是否触发翻页
    
    var animateDuration: NSTimeInterval = 0.5   // 定时滚动的动画时间
    var hasTimerFired: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
        public API
    */
    init(pageCount: Int, generateContentView: (atIndex: Int) -> UIView) {
        self.pageCount = pageCount
        self.generateContentView = generateContentView
        self.firstIndex = pageCount - 1
        
        super.init(frame: CGRectZero)
        
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.addGestureRecognizer(self.gestureRecognizer!)
        
        self.rebuildVisibleViews(true)
    }
    
    /*
        public API
    */
    func schedule(ti: NSTimeInterval, animateDuration: NSTimeInterval) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: "timerFireMethod:", userInfo: nil, repeats:true);
        self.animateDuration = animateDuration
        timer.fire()
    }
    
    func timerFireMethod(timer: NSTimer) {
        if self.hasTimerFired {
            self.leftEdgeConstraint.constant -= self.frame.width
            
            UIView.animateWithDuration(self.animateDuration, animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    self.rebuildVisibleViews(true)
            })
        } else {
            self.hasTimerFired = true
        }
    }
    
    // UIView 进出队列相关的操作
    
    private func shiftVisibleView() {
        self.firstIndex++;
        self.firstIndex = self.firstIndex == self.pageCount ? 0 : self.firstIndex
        
        self.visiableViews.first!.removeFromSuperview()
        self.visiableViews.removeFirst()
    }
    
    private func unshiftVisibleView() {
        self.firstIndex--;
        self.firstIndex = self.firstIndex == -1 ? self.pageCount - 1 : self.firstIndex
        
        self.visiableViews.insert(self.generateView(self.firstIndex), atIndex: 0)
    }
    
    private func popVisibleView() {
        self.lastIndex--;
        self.lastIndex = self.lastIndex == -1 ? self.pageCount - 1 : self.lastIndex
        
        self.visiableViews.last!.removeFromSuperview()
        self.visiableViews.removeLast()
    }
    
    private func pushVisibleView() {
        if self.lastIndex == -1 {
            self.lastIndex = self.pageCount - 1
        } else {
            self.lastIndex++;
            self.lastIndex = self.lastIndex == self.pageCount ? 0 : self.lastIndex
        }
        
        self.visiableViews.append(self.generateView(self.lastIndex))
    }
    
    private func generateView(atIndex: Int) -> UIView {
        let currentContentView: UIView = self.generateContentView(atIndex: atIndex)
        currentContentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(currentContentView)
        
        self => currentContentView.top == self.top
            => currentContentView.bottom == self.bottom
            => currentContentView.width == self.width
        
        return currentContentView
    }
    
    private func rebuildVisibleViews(swipeLeft: Bool) {
        if self.visiableViews.count == 0 {
            if self.pageCount == 1 {
                self.pushVisibleView()
            } else {
                for _ in 0...2 {
                    self.pushVisibleView()
                }
            }
        } else {
            if self.pageCount > 1 {
                if (swipeLeft) {
                    self.shiftVisibleView()
                    self.pushVisibleView()
                } else {
                    self.unshiftVisibleView()
                    self.popVisibleView()
                }
            }
        }
        
        self.rebulidEdgeConstraints(swipeLeft)
    }
    
    private func rebulidEdgeConstraints(swipeLeft: Bool) {
        if self.pageCount == 1 {
            return
        }
        
        self.removeConstraints(self.edgeConstraints)
        
        let view0 = self.visiableViews[0]
        let view1 = self.visiableViews[1]
        let view2 = self.visiableViews[2]
        
        let edgeContraint0: NSLayoutConstraint = view0.right == view1.left
        let edgeContraint1: NSLayoutConstraint = view1.left == self.left
        let edgeContraint2: NSLayoutConstraint = view2.left == view1.right
        
        self.leftEdgeConstraint = edgeContraint1
        self.edgeConstraints    = [edgeContraint0, edgeContraint1, edgeContraint2]
        
        self => edgeContraint0
            => edgeContraint1
            => edgeContraint2
    }

    // 水平滚动的手势
    // TODO: 改成 Dynamic 做动画
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = gestureRecognizer.translationInView(self)
        let fabsX: Float = Float(fabs(translation.x))
        let width: CGFloat = CGFloat(self.frame.width)
        
        if (fabsX > self.maxX) {
            self.maxX = fabsX
        }
        
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began:
            self.maxX = 0.0
        case UIGestureRecognizerState.Changed:
            self.leftEdgeConstraint.constant = translation.x
        default :
            if ((fabsX < self.maxX - 10) || fabsX < 70 || self.visiableViews.count == 1) {
                self.leftEdgeConstraint.constant = CGFloat(0)
                
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.layoutIfNeeded()
                })
            } else {
                self.leftEdgeConstraint.constant = translation.x < 0 ? -width : width
                
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.layoutIfNeeded()
                    }, completion: { (completion: Bool) -> Void in
                        if completion {
                            self.rebuildVisibleViews(translation.x < 0)
                        }
                })
            }
        }
    }
}
