//
//  YDMenuDataSource.swift
//  YDMenu
//
//  Created by ZJXN on 2018/3/8.
//  Copyright © 2018年 YDZhao. All rights reserved.
//

import Foundation

protocol YDMenuDataSource: class {
    
    // required
    ///每个column有多少行
    func menu(_ menu: YDMenu, numberOfRowsInColumn column: Int) -> Int

    ///每个column中每行的title
    func menu(_ menu: YDMenu, titleForRowAtIndexPath indexPath: YDMenu.Index) -> String
    
    // optional
    /// 有多少个column，默认为1列
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int
    
    
    // MARK: - 一级菜单
    /// 第column列，每行的image
    func menu(_ menu: YDMenu, imageNameForRowAtIndexPath: YDMenu.Index) -> String?
    
    /// detail text
    func menu(_ menu: YDMenu, detailTextForRowAtIndexPath indexPath: YDMenu.Index) -> String?
    
    /// 某列的某行item的数量，如果有，则说明有二级菜单，反之亦然
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int
    
    
    // MARK: - 二级菜单
    /// 二级菜单的标题
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String

    /// 二级菜单的image
    func menu(_ menu: YDMenu, imageNameForItemsInRowAtIndexPath: YDMenu.Index) -> String?

    /// 二级菜单的detail text
    func menu(_ menu: YDMenu, detailTextForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String?
}

extension YDMenuDataSource {
    
    /// 有多少个column，默认为1列
    func numberOfColumnsInMenu(_ menu: YDMenu) -> Int {
        return 1
    }
    
    
    // MARK: - 一级菜单
    /// 第column列，每行的image
    func menu(_ menu: YDMenu, imageNameForRowAtIndexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// detail text
    func menu(_ menu: YDMenu, detailTextForRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// 某列的某行item的数量，如果有，则说明有二级菜单，反之亦然
    func menu(_ menu: YDMenu, numberOfItemsInRow row: Int, inColumn column: Int) -> Int {
        return 0
    }
    

    // MARK: - 二级菜单
    /// 二级菜单的标题
    func menu(_ menu: YDMenu, titleForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String {
        return ""
    }
    
    /// 二级菜单的image
    func menu(_ menu: YDMenu, imageNameForItemsInRowAtIndexPath: YDMenu.Index) -> String? {
        return nil
    }
    
    /// 二级菜单的detail text
    func menu(_ menu: YDMenu, detailTextForItemsInRowAtIndexPath indexPath: YDMenu.Index) -> String? {
        return nil
    }
}


