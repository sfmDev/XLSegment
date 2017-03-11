//
//  XLSegmentControl.swift
//  XLSegment
//
//  Created by PixelShi on 16/7/26.
//  Copyright © 2016年 shifengming. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

enum isHasExtra {
    case has
    case none
}

enum Style {
    case dot
    case line
    case none
}

enum ButtonType {
    case title
    case image
}


/// 点击事件的闭包
typealias XLSegmentAction = (_ index: Int) -> Void

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
            backgroundColor = UIColor.clear
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            let oval = UIBezierPath(ovalIn: rect)
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
            backgroundColor = UIColor.clear
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ rect: CGRect) {
            let oval = UIBezierPath(rect: rect)
            color.setFill()
            oval.fill()
        }
    }


    /**
     *  标题选项
     */
    var titles: [String] = []
        {
        didSet {
            resetSegment()
            self.selectCollecionView?.reloadData()
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
            case .dot:
                for dot in dotArray {
                    dot.color = navColor
                }
            case .line:
                for dot in lineArray {
                    dot.color = navColor
                }
            case .none : break
            }

        }
    }

    /**
     *  选中时的颜色
     */
    var selectTitleColor: UIColor? = XLSegmentControl.defaultColor {
        didSet {
            for btn in titleButtonArray {
                btn.setTitleColor(selectTitleColor, for: .disabled)
            }
        }
    }

    /**
     *  未选中时的颜色
     */
    var unSelectTitleColor: UIColor? = UIColor.darkGray {
        didSet {
            for btn in titleButtonArray {
                btn.setTitleColor(selectTitleColor, for: UIControlState())
            }
        }
    }

    /**
     *  字体
     */
    var titleFont: UIFont = UIFont.systemFont(ofSize: 16) {
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
    var btnWidth: CGFloat = 70 {
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
    /**
     *  是否是固定宽度
     */
    var isRegularWidth: Bool = false {
        didSet {
            resetSegment()
        }
    }


    /// 被选中的 Index
    fileprivate(set) var selectIndex: Int = -1
    fileprivate var animationDuration: TimeInterval = 0.3
    fileprivate var collectionViewCellHeight: CGFloat = 45

    /// 背景滚动的 scrollview
    var scrollView: UIScrollView?
    /// 右边更多按钮
    var moreBtn: UIButton?
    /// 弹出来的选择框
    var selectCollecionView: UICollectionView?
    /// 蒙版
    var blackView: UIView?
    /// 遮罩 label
    var maskLabel: UILabel?
    /// 遮罩 label in view
    var spaceView: UIView?
    /// 动画类型
    var style: Style = .dot
    var isHasExtra: isHasExtra = .none

    var buffCount: Int = 0
    var collectionViewH: CGFloat = 0

    var buttonType: ButtonType = .title {
        didSet {
            resetSegment()
        }
    }

    fileprivate var titleButtonArray = [UIButton]()
    fileprivate var dotArray = [PLDot]()
    fileprivate var lineArray = [Line]()

    init(titles: [String], frame: CGRect, style: Style, isHasExtra: isHasExtra = .none) {
        self.titles = titles
        self.selectCollecionView?.reloadData()
        self.isHasExtra = isHasExtra
        self.style = style
        super.init(frame: frame)

        let buff = self.titles.count % 4 == 0 ? 0 : 1
        buffCount = buff
        let collectionH: CGFloat = CGFloat((self.titles.count / 4) + buffCount) * self.collectionViewCellHeight
        collectionViewH = collectionH

        shareInit()
    }

    required init?(coder aDecoder: NSCoder) {
        titles = []
        super.init(coder: aDecoder)
        shareInit()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var result: UIView? = super.hitTest(point, with: event)
        if result == nil {
            let newPoint = self.selectCollecionView?.convert(point, from: self)
            let hitTestView = self.selectCollecionView?.hitTest(newPoint!, with: event)
            if (hitTestView != nil) {
                result = hitTestView
            }
        }
        return result
    }

    fileprivate func shareInit() {
        //不是文字没有 右边更多
        if self.buttonType != .title {
            isHasExtra = .none
        }
        switch isHasExtra {
        case .none:
            scrollView = UIScrollView.init(frame: self.bounds)
        default:
            // 右边的点
            let frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width - self.bounds.height, height: self.bounds.height)
            scrollView = UIScrollView(frame: frame)
            let btnFrame = CGRect(x: self.bounds.width - self.bounds.height, y: self.bounds.origin.y, width: self.bounds.height, height: self.bounds.height)

            moreBtn = UIButton(frame: btnFrame)
            moreBtn?.setImage(UIImage(named: "arrow_down@2x"), for: .normal)
            moreBtn?.backgroundColor = UIColor(hexString: "#F0F0F0")
            moreBtn?.addTarget(self, action: #selector(XLSegmentControl.moreBtnTapped), for: .touchUpInside)
            addSubview(moreBtn!)

            let layout = UICollectionViewFlowLayout.init()
            selectCollecionView = UICollectionView(frame: CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + self.bounds.height, width: self.bounds.width, height: 0), collectionViewLayout: layout)
            selectCollecionView?.backgroundColor = UIColor.white
            selectCollecionView?.delegate = self
            selectCollecionView?.showsVerticalScrollIndicator = false
            selectCollecionView?.dataSource = self
            selectCollecionView?.register(UINib(nibName: "XLCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "XLCollectionViewCell")
            addSubview(selectCollecionView!)
//            self.window?.addSubview(selectCollecionView!)

            blackView = UIView()
            blackView?.backgroundColor = UIColor(hexString: "#000000", alpha: 0.3)
            blackView?.frame = CGRect(x: 0, y: (selectCollecionView?.frame.origin.y)! + collectionViewH, width: self.bounds.width, height: 0)
//            blackView?.addTapGesture(action: { (tap) in
//                print("tapped")
//            })
            addSubview(blackView!)

            spaceView = UIView()
            spaceView?.frame = frame
            spaceView?.backgroundColor = UIColor(hexString: "#F0F0F0")
            addSubview(spaceView!)
            spaceView?.isHidden = true

            maskLabel = UILabel()
            maskLabel?.frame = CGRect(x: 20, y: (self.spaceView?.frame.origin.y)!, width: frame.width, height: frame.height)
            maskLabel?.text = "全部分类"
            maskLabel?.textColor = UIColor(hexString: "#474747")
            maskLabel?.font = UIFont.systemFont(ofSize: 14)
            spaceView?.addSubview(maskLabel!)

            self.bringSubview(toFront: selectCollecionView!)
        }

        guard titles.count > 0 else { return }
        scrollView!.isUserInteractionEnabled = true
        isUserInteractionEnabled = true

        func setNameForButton(_ name: String) -> UIButton {
            let button = UIButton(type: .custom)
            switch buttonType {
                case .title:
                    button.setTitle(name, for: UIControlState())
                    button.setTitleColor(unSelectTitleColor, for: UIControlState())
                    button.setTitleColor(selectTitleColor, for: .disabled)
                    button.titleLabel?.font = titleFont

                case .image:
                    print(name)
                    button.setImage(UIImage(named: name), for: UIControlState())
            }
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(XLSegmentControl.titleButtonClick(_:)), for: .touchUpInside)
            return button
        }

        let height = bounds.height
        var totleWidthArray: [CGFloat] = []

        if isRegularWidth == true {
            scrollView?.contentSize = CGSize(width: btnWidth*CGFloat(titles.count), height: height)
        } else {
            for i in titles {
                let width = i.widthWith(titleFont, height: height)
                totleWidthArray.append(width + 5)
            }
            print(totleWidthArray)
            scrollView!.contentSize = CGSize(width: totleWidthArray.reduce(0, +), height: height)
        }
        scrollView!.showsHorizontalScrollIndicator = false

        var buttonFrame = CGRect(x: 0,y: 0,width: btnWidth,height: height)
        var titleButtonArrayTemp = [UIButton]()
        for (i, btnTitle) in titles.enumerated() {
            if isRegularWidth == true {
                buttonFrame.origin.x = btnWidth * CGFloat(i)
            } else {
                buttonFrame.origin.x = totleWidthArray[0...i].reduce(0, +) - totleWidthArray[i]
                buttonFrame.size.width = totleWidthArray[i]
            }
            let button = setNameForButton(btnTitle)
            button.frame = buttonFrame
            button.tag = i
            titleButtonArrayTemp.append(button)
            scrollView!.addSubview(button)
        }

        switch style {
            case .dot:
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

            case .line:
                var lineArrayTemp = [Line]()
                let line = Line(color: navColor)
                lineArrayTemp.append(line)
                scrollView?.addSubview(line)

                lineArray = lineArrayTemp
                titleButtonArray = titleButtonArrayTemp
                changeSelectedIndex(0, internaliFlag: false, animate: false)
                addSubview(scrollView!)

            case .none:
                titleButtonArray = titleButtonArrayTemp
                changeSelectedIndex(0, internaliFlag: false, animate: false)
                addSubview(scrollView!)
        }

    }

    func moreBtnTapped() {
        self.moreBtn?.isSelected = !(self.moreBtn?.isSelected)!
        if self.moreBtn?.isSelected == true {
            spaceView?.isHidden = false
            self.bringSubview(toFront: spaceView!)
            self.moreBtn?.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.selectCollecionView?.frame = CGRect(x: self.bounds.origin.x , y: self.bounds.origin.y + self.bounds.height, width: self.bounds.width, height: self.collectionViewH)
            }, completion: { (finished) in
            })
            self.blackView?.frame = CGRect.init(x: 0, y: (self.selectCollecionView?.frame.origin.y)!, width: self.bounds.width, height: self.frame.width - (self.selectCollecionView?.frame.origin.x)! - (self.selectCollecionView?.frame.height)!)
        } else {
            spaceView?.isHidden = true
            self.moreBtn?.imageView?.transform = CGAffineTransform.identity
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.selectCollecionView?.frame = CGRect(x: self.bounds.origin.x , y: self.bounds.origin.y + self.bounds.height, width: self.bounds.width, height: 0)
            }, completion: { (finished) in
                self.blackView?.frame = CGRect.init(x: 0, y: (self.selectCollecionView?.frame.origin.y)!, width: self.bounds.width, height: 0)
            })
        }
    }

    fileprivate func resetSegment() {
        subviews.forEach { $0.removeFromSuperview() }

        switch style {
        case .dot:
            dotArray = []
        case .line:
            lineArray = []
        case .none: break
        }

        titleButtonArray = []
        selectIndex = -1
        if titles.count > 0 {
            shareInit()
        }
    }
}

extension XLSegmentControl {

    @objc fileprivate func titleButtonClick(_ button: UIButton) {
        changeSelectedIndex(button.tag, internaliFlag: true)
    }

    func changeTitle(_ index: Int, title: String) {
        self.titles[index] = title
    }

    func changeSelectedIndex(_ index: Int, animate: Bool = true) {
        changeSelectedIndex(index, internaliFlag: true, animate: animate)
    }

    /**
     发生点击事件时触发(私有)

     - parameter index:         被选中的 index
     - parameter internaliFlag: 是否内部点击触发的标志位
     - parameter animate:       是否需要动画效果
     */
    fileprivate func changeSelectedIndex(_ index: Int, internaliFlag: Bool, animate: Bool = true) {
        if selectIndex >= 0 {titleButtonArray[selectIndex].isEnabled = true }
        let flag = index > selectIndex
        guard index >= 0 && index < titles.count else { return }
        titleButtonArray[index].isEnabled = false
        selectIndex = index
        self.selectCollecionView?.reloadData()
        self.clickAction?(index)

        switch style {
        case .dot:
            changeDotFrameWithIndex(selectIndex, animate: animate, toRight: flag)
        case .line:
            changeLineFrameWithIndex(selectIndex, animate: animate, toRight: flag)
        case .none:
            changeSelctedBtnWithIndex(selectIndex, animate: animate, toRight: flag)
        }
        scrollItemVisiable(titleButtonArray[index])
    }

    /**
     scrollView item 可见(下一个 button 会滑动 可设置滑动出来的距离)
     default contentOfffset = width * 0.75
     - parameter item: 点击的 button
     */
    fileprivate func scrollItemVisiable(_ item: UIButton) {
        var frame = item.frame
        if item != self.scrollView?.subviews.first && item != self.scrollView!.subviews.last {
            let min: CGFloat = item.frame.minX
            let max: CGFloat = item.frame.maxX

            if min < self.scrollView?.contentOffset.x {
                frame = CGRect(origin: CGPoint(x: item.frame.origin.x - btnWidth*0.75, y: item.frame.origin.y), size: item.frame.size)
            } else if max > (self.scrollView?.contentOffset.x)! + self.scrollView!.frame.size.width {
                frame = CGRect(origin: CGPoint(x: item.frame.origin.x + btnWidth*0.75, y: item.frame.origin.y), size: item.frame.size)
            }
        }

        self.scrollView?.scrollRectToVisible(frame, animated: true)
    }

    fileprivate func changeDotFrameWithIndex(_ index: Int, animate: Bool, toRight: Bool) {
        let rect = titleButtonArray[index].frame
        let num = CGFloat(numOfDot)
        var s = dotSpace

        if s < 0 {
            // dotSpace 圆角间距小于0是自定义
            s = (rect.width - dotDiameter * num) / (num + 1)
        }

        let y = rect.origin.y + rect.height - dotDiameter - 2
        let numWidth = num * dotDiameter
        let beginSpace = (rect.width - numWidth - ((num + 1) * s))/2.0
        let originx = rect.origin.x + beginSpace
        var bRect = CGRect(x: s, y: y, width: dotDiameter, height: dotDiameter)

        for i in 0..<numOfDot {
            let index = toRight ? (numOfDot - 1 - i) : i
            let dot = dotArray[index]
            bRect.origin.x = s * CGFloat(index + 1) + dotDiameter * CGFloat(index) + originx
            if animate {
                UIView.animate(withDuration: 0.2, delay: Double(i) * 0.1, options: .curveLinear, animations: {
                    dot.frame = bRect
                    print(dot.frame)
                    }, completion: nil)
            } else {
                dot.frame = bRect
            }
        }
    }

    fileprivate func changeLineFrameWithIndex(_ index: Int, animate: Bool, toRight: Bool) {
        let rect = titleButtonArray[index].frame

        //定义下面滑动条的宽高 
        let smallWidth: CGFloat = rect.width - padding*2
        let smallHeight: CGFloat = 2
        let y = rect.origin.y + rect.height - smallHeight
        var bRect = CGRect(x: padding, y: y, width: smallWidth, height: smallHeight)

        let line = lineArray[0]

        bRect.origin.x = rect.width * CGFloat(index) + padding
    
        if animate {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
                line.frame = bRect
                print(line.frame)
                }, completion: nil)
        } else {
            line.frame = bRect
        }
    }

    fileprivate func changeSelctedBtnWithIndex(_ index: Int, animate: Bool, toRight: Bool) {

    }
}

extension XLSegmentControl: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width / 4, height: 45)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.changeSelectedIndex(indexPath.row, animate: true)
        self.moreBtn?.isSelected = true
        self.moreBtnTapped()
    }
}

extension XLSegmentControl: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: XLCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "XLCollectionViewCell", for: indexPath) as! XLCollectionViewCell
        cell.cellBtn.setTitle(self.titles[indexPath.row], for: .normal)
        return cell
    }

    func titleClick(_ sender: UIButton) {
        self.changeSelectedIndex(sender.tag, animate: true)
        self.moreBtn?.isSelected = true
        self.moreBtnTapped()
    }
}

extension String {
    func widthWith(_ font: UIFont, height: CGFloat) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat(height))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy()]

        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.width
    }
}

extension UIColor {
    /// EZSE: init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

    /// EZSE: init method with hex string and alpha(default: 1)
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)        } else {
            return nil
        }
    }
}
