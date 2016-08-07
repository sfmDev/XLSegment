//
//  XLSegmentControl.swift
//  XLSegment
//
//  Created by PixelShi on 16/7/26.
//  Copyright © 2016年 shifengming. All rights reserved.
//

import UIKit

enum Style {
    case Dot
    case Line
    case None
}

enum ButtonType {
    case Title
    case Image
}

/// 点击事件的闭包
typealias XLSegmentAction = (index: Int) -> Void

class XLSegmentControl: UIView {

    static let defaultColor = UIColor(red:0.298,  green:0.741,  blue:0.404, alpha:1)

    /**
     *  Dot点的自定义 View
     */
    class PLDot: UIView {
        var color: UIColor
        init(color: UIColor) {
            self.color = color
            super.init(frame: CGRect.zero)
            backgroundColor = UIColor.clearColor()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func drawRect(rect: CGRect) {
            let oval = UIBezierPath(ovalInRect: rect)
            color.setFill()
            oval.fill()
        }
    }

    /**
     *  Line style View
     */
    class Line: UIView {
        var color: UIColor
        init(color: UIColor) {
            self.color = color
            super.init(frame: CGRect.zero)
            backgroundColor = UIColor.clearColor()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func drawRect(rect: CGRect) {
            let oval = UIBezierPath(rect: rect)
            color.setFill()
            oval.fill()
        }
    }


    /**
     *  标题选项
     */
    var titles: [String] = [] {
        didSet {
            resetSegment()
        }
    }

    /**
     *  圆点数量
     */
    var numOfDot = 3 {
        didSet {
            resetSegment()
        }
    }

    /**
     *  圆点直径
     */
    var dotDiameter: CGFloat = 5 {
        didSet {
            changeDotFrameWithIndex(selectIndex, animate: false, toRight: false)
        }
    }

    /**
     *  圆角间距,小于0为自定义
     */
    var dotSpace: CGFloat = -1 {
        didSet {
            changeDotFrameWithIndex(selectIndex, animate: false, toRight: false)
        }
    }

    /**
     *  导航标签颜色
     */
    var navColor = XLSegmentControl.defaultColor {
        didSet {
            switch style {
            case .Dot:
                for dot in dotArray {
                    dot.color = navColor
                }
            case .Line:
                for dot in lineArray {
                    dot.color = navColor
                }
            case .None : break
            }

        }
    }

    /**
     *  选中时的颜色
     */
    var selectTitleColor: UIColor? = XLSegmentControl.defaultColor {
        didSet {
            for btn in titleButtonArray {
                btn.setTitleColor(selectTitleColor, forState: .Disabled)
            }
        }
    }

    /**
     *  未选中时的颜色
     */
    var unSelectTitleColor: UIColor? = UIColor.darkGrayColor() {
        didSet {
            for btn in titleButtonArray {
                btn.setTitleColor(selectTitleColor, forState: .Normal)
            }
        }
    }

    /**
     *  字体
     */
    var titleFont: UIFont = UIFont.systemFontOfSize(16) {
        didSet {
            for btn in titleButtonArray {
                btn.titleLabel?.font = titleFont
            }
        }
    }

    /**
     *  点击事件
     */
    var clickAction: XLSegmentAction?

    override var frame: CGRect {
        didSet {
            if oldValue.size != frame.size {
                resetSegment()
            }
        }
    }

    /**
     *  按钮宽度
     */
    var width: CGFloat = 70 {
        didSet {
            resetSegment()
        }
    }

    /**
     *  滑动条左右边距
     */
    var padding: CGFloat = 5 {
        didSet {
            resetSegment()
        }
    }


    /// 被选中的 Index
    private(set) var selectIndex: Int = -1

    /// 背景滚动的 scrollview
    var scrollView: UIScrollView?
    /// 动画类型
    var style: Style = .Dot

    var buttonType: ButtonType = .Title {
        didSet {
            resetSegment()
        }
    }

    private var titleButtonArray = [UIButton]()
    private var dotArray = [PLDot]()
    private var lineArray = [Line]()

    init(titles: [String], frame: CGRect, style: Style) {
        self.titles = titles
        self.style = style
        super.init(frame: frame)
        shareInit()
    }

    required init?(coder aDecoder: NSCoder) {
        titles = []
        super.init(coder: aDecoder)
        shareInit()
    }

    private func shareInit() {
        scrollView = UIScrollView.init(frame: self.bounds)

        guard titles.count > 0 else { return }
        scrollView!.userInteractionEnabled = true
        userInteractionEnabled = true

        func setNameForButton(name: String) -> UIButton {
            let button = UIButton(type: .Custom)
            switch buttonType {
                case .Title:
                    button.setTitle(name, forState: .Normal)
                    button.setTitleColor(unSelectTitleColor, forState: .Normal)
                    button.setTitleColor(selectTitleColor, forState: .Disabled)
                    button.titleLabel?.font = titleFont
                case .Image:
                    print(name)
                    button.setImage(UIImage(named: name), forState: .Normal)
            }

            button.addTarget(self, action: #selector(XLSegmentControl.titleButtonClick(_:)), forControlEvents: .TouchUpInside)
            return button
        }

        let height = bounds.height

        scrollView!.contentSize = CGSize(width: width * CGFloat(titles.count), height: height)
        scrollView!.showsHorizontalScrollIndicator = false

        var buttonFrame = CGRect(x: 0,y: 0,width: width,height: height)
        var titleButtonArrayTemp = [UIButton]()
        for (i, btnTitle) in titles.enumerate() {
            buttonFrame.origin.x = width * CGFloat(i)

            let button = setNameForButton(btnTitle)
            button.frame = buttonFrame
            button.tag = i
            titleButtonArrayTemp.append(button)
            scrollView!.addSubview(button)
        }


        switch style {
            case .Dot:
                var dotArrayTemp = [PLDot]()
                for i in 0..<numOfDot {
                    let dot = PLDot(color: navColor)
                    dot.tag = i
                    dotArrayTemp.append(dot)
                    scrollView!.addSubview(dot)
                }
                dotArray = dotArrayTemp
                titleButtonArray = titleButtonArrayTemp
                changeSelectedIndex(0, internaliFlag: false, animate: false)
                addSubview(scrollView!)

            case .Line:
                var lineArrayTemp = [Line]()
                let line = Line(color: navColor)
                lineArrayTemp.append(line)
                scrollView?.addSubview(line)

                lineArray = lineArrayTemp
                titleButtonArray = titleButtonArrayTemp
                changeSelectedIndex(0, internaliFlag: false, animate: false)
                addSubview(scrollView!)

            case .None:
                titleButtonArray = titleButtonArrayTemp
                changeSelectedIndex(0, internaliFlag: false, animate: false)
                addSubview(scrollView!)

        }

    }

    private func resetSegment() {
        subviews.forEach { $0.removeFromSuperview() }

        switch style {
        case .Dot:
            dotArray = []
        case .Line:
            lineArray = []
        case .None: break
        }

        titleButtonArray = []
        selectIndex = -1
        if titles.count > 0 {
            shareInit()
        }
    }
}

extension XLSegmentControl {

    @objc private func titleButtonClick(button: UIButton) {
        changeSelectedIndex(button.tag, internaliFlag: true)

    }

    func changeSelectedIndex(index: Int, animate: Bool = true) {
        changeSelectedIndex(index, internaliFlag: false, animate: animate)
    }
    /**
     发生点击事件时触发(私有)

     - parameter index:         被选中的 index
     - parameter internaliFlag: 是否内部点击触发的标志位
     - parameter animate:       是否需要动画效果
     */
    private func changeSelectedIndex(index: Int, internaliFlag: Bool, animate: Bool = true) {
        if selectIndex >= 0 {titleButtonArray[selectIndex].enabled = true }
        let flag = index > selectIndex
        guard index >= 0 && index < titles.count else { return }
        titleButtonArray[index].enabled = false
        selectIndex = index
        self.clickAction?(index: index)

        switch style {
        case .Dot:
            changeDotFrameWithIndex(selectIndex, animate: animate, toRight: flag)
        case .Line:
            changeLineFrameWithIndex(selectIndex, animate: animate, toRight: flag)
        case .None:
            changeSelctedBtnWithIndex(selectIndex, animate: animate, toRight: flag)
        }
        scrollItemVisiable(titleButtonArray[index])
    }

    /**
     scrollView item 可见(下一个 button 会滑动 可设置滑动出来的距离)
     default contentOfffset = width * 0.75
     - parameter item: 点击的 button
     */
    private func scrollItemVisiable(item: UIButton) {
        var frame = item.frame
        if item != self.scrollView?.subviews.first && item != self.scrollView!.subviews.last {
            let min: CGFloat = CGRectGetMinX(item.frame)
            let max: CGFloat = CGRectGetMaxX(item.frame)

            if min < self.scrollView?.contentOffset.x {
                frame = CGRect(origin: CGPoint(x: item.frame.origin.x - width*0.75, y: item.frame.origin.y), size: item.frame.size)
            } else if max > (self.scrollView?.contentOffset.x)! + self.scrollView!.frame.size.width {
                frame = CGRect(origin: CGPoint(x: item.frame.origin.x + width*0.75, y: item.frame.origin.y), size: item.frame.size)
            }
        }

        self.scrollView?.scrollRectToVisible(frame, animated: true)
    }

    private func changeDotFrameWithIndex(index: Int, animate: Bool, toRight: Bool) {
        let rect = titleButtonArray[index].frame
        let num = CGFloat(numOfDot)
        var s = dotSpace

        if s < 0 {
            // dotSpace 圆角间距小于0是自定义
            s = (rect.width - dotDiameter * num) / (num + 1)
        }

        let y = rect.origin.y + rect.height - dotDiameter - 2
        let beginSpace = (rect.width - (num * dotDiameter) - ((num + 1) * s))/2.0
        let originx = rect.origin.x + beginSpace
        var bRect = CGRect(x: s, y: y, width: dotDiameter, height: dotDiameter)

        for i in 0..<numOfDot {
            let index = toRight ? (numOfDot - 1 - i) : i
            let dot = dotArray[index]
            bRect.origin.x = s * CGFloat(index + 1) + dotDiameter * CGFloat(index) + originx
            if animate {
                UIView.animateWithDuration(0.2, delay: Double(i) * 0.1, options: .CurveLinear, animations: {
                    dot.frame = bRect
                    print(dot.frame)
                    }, completion: nil)
            } else {
                dot.frame = bRect
            }
        }
    }

    private func changeLineFrameWithIndex(index: Int, animate: Bool, toRight: Bool) {
        let rect = titleButtonArray[index].frame

        //定义下面滑动条的宽高 
        let smallWidth: CGFloat = rect.width - padding*2
        let smallHeight: CGFloat = 2
        let y = rect.origin.y + rect.height - smallHeight
        var bRect = CGRect(x: padding, y: y, width: smallWidth, height: smallHeight)

        let line = lineArray[0]

        bRect.origin.x = rect.width * CGFloat(index) + padding
        if animate {
            UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveLinear, animations: {
                line.frame = bRect
                print(line.frame)
                }, completion: nil)
        } else {
            line.frame = bRect
        }
    }

    private func changeSelctedBtnWithIndex(index: Int, animate: Bool, toRight: Bool) {

    }
}
