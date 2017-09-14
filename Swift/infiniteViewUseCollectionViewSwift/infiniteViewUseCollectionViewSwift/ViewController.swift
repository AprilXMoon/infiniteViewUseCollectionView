//
//  ViewController.swift
//  infiniteViewUseCollectionViewSwift
//
//  Created by April on 2017/7/18.
//  Copyright © 2017年 April. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorView: UIView!
    var colorItems : [[String: Any]] = [[:]]
    
    var infiniteView : ALInfiniteView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createColorItems()
        
        infiniteView = ALInfiniteView(frame:colorView.frame)
        infiniteView?.delegate = self
        infiniteView?.setInfiniteViewItems(orginItems: colorItems)
        infiniteView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        colorView.addSubview(infiniteView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if infiniteView != nil {
            infiniteView?.scrollToVisibleFirstItem()
        }
        
    }

    func createColorItems() {
        let grayColor : [String: Any] = ["Name": "Gray Color", "Color": UIColor.gray]
        let purpleColor : [String: Any] = ["Name": "Purple Color", "Color": UIColor.purple]
        let brownColor : [String: Any] = ["Name": "Brown Color", "Color": UIColor.brown]
        
        colorItems = [grayColor, purpleColor, brownColor]
    }
    
}

extension ViewController: ALInfiniteViewDelegate {
    func alInfiniteViewDidSelectedItem(infiniteView: ALInfiniteView, selectedIndex: Int) {
        
    }
}

