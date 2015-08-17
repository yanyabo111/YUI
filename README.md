# YUI

### 用 Swift 写的循环滚动视图，包含两种实现

- 用先进后出的队列实现循环滚动，队列中最多只维持 3 个 UIView
- 用特定顺序的 UIScrollView 来让其看起来是循环滚动的，没有滚动到的 View，不加载具体内容

#### 说明
- 语言：Swift
- 编译环境： Xcode 7 beta 5