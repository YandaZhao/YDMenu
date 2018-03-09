//
//  ViewController.swift
//  YDMenu
//
//  Created by ZJXN on 2018/3/8.
//  Copyright © 2018年 YDZhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YDMenuDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let menu = YDMenu(origin: CGPoint(x: 0, y: 50), menuheight: 40)
        view.addSubview(menu)
        
        menu.dataSource = self
        
        
       
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///每个column有多少行
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int {
        return 3
    }
    
    func menu(_ menu: YDMenu, numberOfRowsInColumn column: Int) -> Int {
        
        return 3
    }
    
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int {
        return 1
    }
    
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String {
        return "哈哈"
    }
    
    ///每个column中每行的title
    func menu(_ menu: YDMenu, titleForRowAtIndexPath indexPath: YDMenu.Index) -> String {
        return "你好"
    }
    

}


