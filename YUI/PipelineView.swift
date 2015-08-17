//
//  PipelineView.swift
//  YUI
//
//  Created by 晏亚博 on 15/8/16.
//  Copyright © 2015年 晏亚博. All rights reserved.
//

import UIKit

// 用 UIScrollView 的 contentOffset 来让界面看起来像循环的

class PipelineView: UIScrollView, UIScrollViewDelegate {

    var containerViews: [UIView] = [] // 占位符，没有滚到附近的 View 不会生成具体的内容
    var filledIndexes: [Int] = []     // 已经生成了内容的部分
    var currentIndex: Int = 1
    
    var pageCount:  Int = 0
    var generateContentView: (atIndex: Int) -> UIView
    
    var hasInitContainerView: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
        public API
    */
    init(pageCount: Int, generateContentView: (atIndex: Int) -> UIView) {
        self.pageCount = pageCount
        self.generateContentView = generateContentView
        
        super.init(frame: CGRectZero)
        
        self.delegate = self
        self.scrollEnabled = true
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        
        self.initContainerView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.hasInitContainerView {
            self.scrollRectToVisible(CGRectMake(self.frame.width, 0, self.frame.width, self.frame.height), animated: false)
            self.hasInitContainerView = true
        }
    }
    
    private func initContainerView() {
        let view: UIView = UIView(frame: CGRectZero);
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        self => view.top == self.top
            => view.bottom == self.bottom
            => view.left == self.left
            => view.right == self.right
            => view.height == self.height
            ~~~> view.width == self.width
        
        var lastContainerView: UIView?
        
        for i in 0...self.pageCount + 1 {
            let containerView: UIView = UIView(frame: CGRectZero)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(containerView)
            
            if lastContainerView == nil {
                view => containerView.left == view.left
            } else {
                view => containerView.left == lastContainerView!.right
            }
            
            if i == self.pageCount + 1 {
                view => containerView.right == view.right
            }
            
            view => containerView.top == view.top
                => containerView.bottom == view.bottom
            
            self => containerView.width == self.width
            
            lastContainerView = containerView
            self.containerViews.append(containerView)
        }
        
        self.fillContainerView(0)
        self.fillContainerView(1)
        self.fillContainerView(2)
        self.fillContainerView(self.pageCount + 1)
    }
    
    private func fillContainerView(atIndex: Int) {
        for filledIndex in self.filledIndexes {
            if filledIndex == atIndex {
                return
            }
        }
        
        let contentIndex : Int?
        
        switch (atIndex) {
        case 0:
            contentIndex = self.pageCount - 1
        case self.containerViews.count - 1:
            contentIndex = 0
        default:
            contentIndex = atIndex - 1
        }
        
        let contentView: UIView = self.generateContentView(atIndex: contentIndex!)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView: UIView = self.containerViews[atIndex]
        containerView.addSubview(contentView)
        
        containerView => contentView.top == containerView.top
            => contentView.bottom == containerView.bottom
            => contentView.left == containerView.left
            => contentView.right == containerView.right
        
        self.filledIndexes.append(atIndex)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (self.contentOffset.x / self.frame.width != CGFloat(self.currentIndex)) {
            if scrollView.panGestureRecognizer.translationInView(self).x < 0 {
                self.currentIndex++
                self.currentIndex = self.currentIndex >= self.containerViews.count - 1 ? 0 : self.currentIndex
                
                self.fillContainerView(self.currentIndex + 1)
            } else {
                self.currentIndex--
                self.currentIndex = self.currentIndex <= 0 ? self.containerViews.count - 1 : self.currentIndex
                
                self.fillContainerView(self.currentIndex - 1)
            }
            
            if self.contentOffset.x == 0 {
                self.scrollRectToVisible(CGRectMake(self.frame.width * CGFloat(self.pageCount), 0, self.frame.width, self.frame.height), animated: false)
            } else if self.contentOffset.x == self.frame.width * CGFloat(self.pageCount) {
                self.scrollRectToVisible(CGRectMake(0, 0, self.frame.width, self.frame.height), animated: false)
            }
        }
    }
}
