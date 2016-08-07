//
//  ViewController.swift
//  XLSegmentDemo
//
//  Created by PixelShi on 16/7/27.
//  Copyright © 2016年 shifengming. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let titles = ["First", "Second", "Third", "Fourth","Fifth", "Sixth", "Seventh", "Eighth","Ninth", "Tenth", "Eleventh", "Twelfth"]
        let imageArray = ["button", "button", "button", "button", "button", "button", "button", "button"]

        let segment = XLSegmentControl(titles: imageArray, frame: CGRect(x: 0, y: 0, width: 375, height: 40), style: .Line)
        segment.buttonType = .Image
        segment.navColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        segment.selectTitleColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        segment.changeSelectedIndex(4, animate: false)
        segment.clickAction = { (index: Int) in
            print("Segment Select Index: \(index)")
        }
        view.addSubview(segment)
        segment.center = view.center


        let dotSegment = XLSegmentControl(titles: titles, frame: CGRect(x: 0, y: 150, width: 375, height: 40), style: .Dot)
        dotSegment.navColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        dotSegment.selectTitleColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        dotSegment.numOfDot = 4
        dotSegment.dotSpace = 6
        dotSegment.clickAction = { (index: Int) in
            print("Segment Select Index: \(index)")
        }
        view.addSubview(dotSegment)

        let noneSegment = XLSegmentControl(titles: titles, frame: CGRect(x: 0, y: 500, width: 375, height: 40), style: .None)
        noneSegment.navColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        noneSegment.selectTitleColor = UIColor(red:1,  green:0.539,  blue:0.490, alpha:1)
        noneSegment.clickAction = { (index: Int) in
            print("Segment Select Index: \(index)")
        }
        view.addSubview(noneSegment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

