//
//  YDMenu.swift
//  YDMenu
//
//  Created by ZJXN on 2018/3/8.
//  Copyright © 2018年 YDZhao. All rights reserved.
//

import UIKit

private let kScreenWidth = UIScreen.main.bounds.width
private let kScreenHeight = UIScreen.main.bounds.height
private let kScreenScale = UIScreen.main.scale
private let kBottomHeight = CGFloat(UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0)

private let kAnimationDuration = 0.2

class YDMenu: UIView {
    
    /// 用于描述菜单中的下标
    public struct Index {
        /// 列
        var column: Int
        /// 行
        var row: Int
        /// 行的子行
        var item: Int
        
        init(column: Int, row: Int, item: Int = -1) {
            self.column = column
            self.row = row
            self.item = item
        }
    }
    
    // MARK: - 属性
    // Public
    weak var delegate: YDMenuDelegate?
    weak var dataSource: YDMenuDataSource? {
        didSet{
            if oldValue === dataSource {
                
                return
            }
            didSetDataSource(ds: dataSource!)
        }
    }
    var textColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    var selectedTextColor: UIColor = UIColor(red: 246/255.0, green: 79/255.0, blue: 0/255.0, alpha: 1)
    var detailTextColor: UIColor = UIColor(red: 246/255.0, green: 79/255.0, blue: 0/255.0, alpha: 1)
    var indicatorColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    var detailTextFontSize: CGFloat = 11
    var separatorColor = UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1)
    var fontSize:CGFloat = 14
    var tableViewHeight: CGFloat = 300
    var cellHeight: CGFloat = 44
    // Private
    private var menuOrigin: CGPoint
    private var menuHeight: CGFloat
    private var numberOfColumn = 0 //列数
    private var isShow: Bool = false
    private var currentSelectedColumn = -1
    private var currentSelectedRows = [Int]()
    
    private var currentTitleLayers = [CATextLayer]()
    private var currentIndicatorLayers = [CAShapeLayer]()
    private var currentBgLayers = [CALayer]()
    
    private lazy var backGroundView: UIView = {
        let view = UIView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y, width: kScreenWidth, height: kScreenHeight))
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        view.isOpaque = false
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped(sender:))))
        return view
    }()
    
    private lazy var leftTableView: UITableView = {
        let view = UITableView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y + menuHeight, width: kScreenWidth / 2, height: 0))
        view.dataSource = self;
        view.delegate = self;
        view.rowHeight = tableViewHeight
        view.separatorColor = separatorColor
        return view
    }()
    
    private lazy var rightTableView: UITableView = {
        let view = UITableView(frame: CGRect(x: menuOrigin.x + kScreenWidth / 2, y: menuOrigin.y + menuHeight, width: kScreenWidth / 2, height: 0))
        view.dataSource = self;
        view.delegate = self;
        view.rowHeight = tableViewHeight
        view.separatorColor = separatorColor
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: menuHeight - (1 / kScreenScale), width: kScreenWidth, height: 1 / kScreenScale))
        view.backgroundColor = separatorColor
        view.isHidden = true
        return view
    }()
    
    // MARK: - 初始化方法
    init(origin: CGPoint, menuheight height: CGFloat) {
        
        menuOrigin = origin
        menuHeight = height
        
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: kScreenWidth, height: height))
        
        backgroundColor = UIColor.white
        addSubview(bottomLine)
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        self.addGestureRecognizer(menuTap)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didSetDataSource(ds: YDMenuDataSource) {
        
        /// 背景layer
        func creatBackgroundLayer(position: CGPoint, backgroundColor: UIColor) -> CALayer {
            let layer = CALayer()
            layer.position = position
            layer.backgroundColor = backgroundColor.cgColor
            layer.bounds = CGRect(x: 0, y: 0, width: kScreenWidth / CGFloat(numberOfColumn), height: menuHeight - 1)
            return layer
        }
        /// 标题Layer
        func creatTitleLayer(text: String, position: CGPoint, textColor: UIColor) -> CATextLayer {
            // size
            let textSize = calculateStringSize(text)
            let maxWidth = kScreenWidth / CGFloat(numberOfColumn) - 25
            let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
            // textLayer
            let textLayer = CATextLayer()
            textLayer.bounds = CGRect(x: 0, y: 0, width: textLayerWidth, height: textSize.height)
            textLayer.fontSize = fontSize
            textLayer.string = text
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.truncationMode = kCATruncationEnd
            textLayer.foregroundColor = textColor.cgColor
            textLayer.contentsScale = kScreenScale
            textLayer.position = position
            return textLayer
        }
        /// indicatorLayer
        func creatIndicatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 5, y: 5))
            bezierPath.move(to: CGPoint(x: 5, y: 5))
            bezierPath.addLine(to: CGPoint(x: 10, y: 0))
            bezierPath.close()
            // shapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.lineWidth = 0.8
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.bounds = shapeLayer.path!.boundingBox
            shapeLayer.position = position
            return shapeLayer
        }
        /// separatorLayer
        func creatSeparatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: menuHeight - 16))
            bezierPath.close()
            // separatorLayer
            let separatorLayer = CAShapeLayer()
            separatorLayer.path = bezierPath.cgPath
            separatorLayer.strokeColor = color.cgColor
            separatorLayer.lineWidth = 1
            separatorLayer.bounds = separatorLayer.path!.boundingBox
            separatorLayer.position = position
            return separatorLayer
        }
        
        // 列数
        numberOfColumn = ds.numberOfColumnsInMenu(self)
        
        // 当前的每列的选择情况
        currentSelectedRows = Array<Int>(repeating: 0, count: numberOfColumn)
        
        let backgroundLayerWidth = kScreenWidth / CGFloat(numberOfColumn)
        
        currentBgLayers.removeAll()
        currentTitleLayers.removeAll()
        currentBgLayers.removeAll()
        
        // 画出菜单
        for i in 0 ..< numberOfColumn {
            let index = CGFloat(i)
            
            // backgroundLayer
            let backgroundLayerPosition = CGPoint(x: (index + 0.5) * backgroundLayerWidth, y: menuHeight * 0.5)
            let backgroundLayer = creatBackgroundLayer(position: backgroundLayerPosition, backgroundColor: UIColor.white)
            layer.addSublayer(backgroundLayer)
            currentBgLayers.append(backgroundLayer)
            
            // titleLayer
            var titleStr: String!
            if let itemsCount = dataSource?.menu(self, numberOfItemsInRow: 0, inColumn: i), itemsCount > 0 {
                titleStr = dataSource?.menu(self, titleForItemsInRowAtIndexPath: Index(column: i, row: 0, item: 0))
            }else{
                titleStr = dataSource?.menu(self, titleForRowAtIndexPath: YDMenu.Index(column: i, row: 0))
            }
            let titleLayerPosition = CGPoint(x: (index + 0.5) * backgroundLayerWidth, y: menuHeight * 0.5)
            let titleLayer = creatTitleLayer(text: titleStr, position: titleLayerPosition, textColor: textColor)
            layer.addSublayer(titleLayer)
            currentTitleLayers.append(titleLayer)
            
            // indicatorLayer
            let textSize = calculateStringSize(titleStr)
            let indicatorLayerPosition = CGPoint(x: titleLayerPosition.x + (textSize.width / 2) + 10, y: menuHeight / 2 + 2)
            let indicatorLayer = creatIndicatorLayer(position: indicatorLayerPosition, color: textColor)
            layer.addSublayer(indicatorLayer)
            currentIndicatorLayers.append(indicatorLayer)
            
            // separatorLayer
            if i != numberOfColumn - 1 {
                let separatorLayerPosition = CGPoint(x: ceil((index + 1) * backgroundLayerWidth) - 1, y: menuHeight / 2)
                let separatorLayer = creatSeparatorLayer(position: separatorLayerPosition, color: separatorColor)
                layer.addSublayer(separatorLayer)
            }
        }
    }
    
    private func calculateStringSize(_ string: String) -> CGSize {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = string.boundingRect(with: CGSize(width: 280, height: 0), options: option, attributes: attributes, context: nil).size
        return CGSize(width: ceil(size.width) + 2, height: size.height)
    }
    
}

// MARK: - UITableViewDataSource / Delegate
extension YDMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == leftTableView {
            
            if let ds = dataSource {
                return ds.menu(self, numberOfRowsInColumn: currentSelectedColumn)
            }
        }else {
            
            if let ds = dataSource {
                return ds.menu(self, numberOfItemsInRow: currentSelectedRows[currentSelectedColumn], inColumn: currentSelectedColumn)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "cellID"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        if cell == nil  {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
            cell.textLabel?.textColor = textColor
            cell.textLabel?.highlightedTextColor = selectedTextColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: fontSize)
            cell.detailTextLabel?.textColor = detailTextColor
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: detailTextFontSize)
        }
        
        if tableView == leftTableView {
            // 一级列表
            if let ds = dataSource {
                
                cell.textLabel?.text = ds.menu(self, titleForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row))
                cell.detailTextLabel?.text = ds.menu(self, detailTextForRowAtIndexPath: YDMenu.Index(column: currentSelectedColumn, row: indexPath.row))
                // image
                switch ds.menu(self, imageNameForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row)) {
                case .some(let imageName):
                    cell.imageView?.image = UIImage(named: imageName)
                    break
                case .none:
                    cell.imageView?.image = nil

                }
                
                // 选中上次选择的行
                if currentSelectedRows[currentSelectedColumn] == indexPath.row {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    
                }
                
                if ds.menu(self, numberOfItemsInRow: indexPath.row, inColumn: currentSelectedColumn) > 0 {
                    cell.accessoryType = .disclosureIndicator
                }else {
                    cell.accessoryType = .none
                }
            }
        }else {
            // 二级列表
            if let ds = dataSource {
                
                let currentSelectedRow = currentSelectedRows[currentSelectedColumn]
                
                cell.textLabel?.text = ds.menu(self, titleForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row))
                cell.detailTextLabel?.text = ds.menu(self, detailTextForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row))
                // image
                switch ds.menu(self, imageNameForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row)) {
                case .some(let imageName):
                    cell.imageView?.image = UIImage(named: imageName)
                    break
                case .none:
                    cell.imageView?.image = nil
                }
                
//                // 选中上次选择的行
//                if cell.textLabel?.text == currentTitleLayers[currentSelectedColumn].string as! String? {
//                    leftTableView.selectRow(at: IndexPath(row: currentSelectedRows[currentSelectedColumn], section: 0), animated: true, scrollPosition: .middle)
//                    rightTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//                }
                
                cell.accessoryType = .none
            }
            
        }
        return UITableViewCell()
    }
    
}

// MARK: - ActionEvent
extension YDMenu {
    
    @objc private func backTapped(sender: UITapGestureRecognizer) -> Void {
        
    }
    
    @objc private func menuTapped(sender: UITapGestureRecognizer) -> Void {
        
        guard let ds = dataSource else {
            return
        }
        
        // 确定点击的index
        let tapPoint = sender .location(in: self)
        let tapIndex: Int = Int(tapPoint.x / (kScreenWidth / CGFloat(numberOfColumn)))
        
        // 收回其他的column的menu
        for i in 0 ..< numberOfColumn {
            if i != tapIndex {
                animateFor(indicator: currentIndicatorLayers[i], reverse: false, complete: {
                    animateFor(titleLayer: currentTitleLayers[i], indicator: nil, show: false, complete: {
                        
                    })
                })
            }
            
        }
        
        // 收回或弹出当前的menu
        if currentSelectedColumn == tapIndex && isShow {
            // 收回menu
            animateFor(indicator: currentIndicatorLayers[tapIndex], title: currentTitleLayers[tapIndex], show: false, complete: {
                currentSelectedColumn = tapIndex
                isShow = false
            })
            
        }else {
            // 弹出menu
            currentSelectedColumn = tapIndex
            // 载入数据
            leftTableView.reloadData()
            
            if ds.menu(self, numberOfItemsInRow: currentSelectedRows[currentSelectedColumn], inColumn: currentSelectedColumn) > 0 {
                rightTableView.reloadData()
            }

            animateFor(indicator: currentIndicatorLayers[tapIndex], title: currentTitleLayers[tapIndex], show: true, complete: {
                isShow = true
            })
        }
        
    }
    
    
    
    
}

// MARK: - Animation
extension YDMenu {
    
    
    func animateFor(indicator: CAShapeLayer, title: CATextLayer, show: Bool, complete: () -> Void) -> Void {
        
        animateFor(indicator: indicator, reverse: show) {
            animateFor(titleLayer: title, indicator: indicator, show: show, complete: {
                animateForBackgroundView(show: show, complete: {
                    animateTableView(show: show, complete: {
                        
                    })
                })
            })
        }
        complete()
    }
    
    /// 指示符
    func animateFor(indicator: CAShapeLayer, reverse: Bool, complete: () -> Void) -> Void {
        
        // 旋转动画
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = reverse ? [0, Double.pi] : [Double.pi, 0]
        animation.duration = kAnimationDuration
        indicator.add(animation, forKey: animation.keyPath)
        
        if animation.isRemovedOnCompletion {
            indicator.setValue(animation.values?.last, forKey: animation.keyPath!)
        }
        
        
        
        /// indicator 颜色
        if reverse {
            indicator.strokeColor = selectedTextColor.cgColor
        }else {
            indicator.strokeColor = textColor.cgColor
        }
        
        
        
        complete()
    }
    
    /// backgroundView动画
    func animateForBackgroundView(show: Bool, complete: () -> Void) -> Void {
        
        if show {
            superview?.addSubview(backGroundView)
            superview?.addSubview(self)
            UIView.animate(withDuration: kAnimationDuration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            })
        }else {
            UIView.animate(withDuration: kAnimationDuration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0)
            }, completion: { (finished) in
                if finished {
                    self.backGroundView.removeFromSuperview()
                }
            })
        }
        
        complete()
    }
    
    /// tableView动画
    func animateTableView(show: Bool, complete: () -> Void) -> Void {
        
        var haveItems = false
        let numberOfRow = leftTableView.numberOfRows(inSection: 0)
        if let ds = dataSource {
            for i in 0 ..< numberOfRow {
                if ds.menu(self, numberOfItemsInRow: i, inColumn: currentSelectedColumn) > 0 {
                    haveItems = true
                    break
                }
            }
        }
        
        let heightForTableView = CGFloat(numberOfRow) * cellHeight > tableViewHeight ? tableViewHeight : CGFloat(numberOfRow) * cellHeight;
        
        
        if show {
            
            if haveItems {
                
                leftTableView.frame = CGRect(x: 0, y: menuOrigin.y + menuHeight, width: kScreenWidth / 2, height: 0)
                rightTableView.frame = CGRect(x: kScreenWidth / 2, y: menuOrigin.y + menuHeight, width: kScreenWidth / 2, height: 0)
                
                superview?.addSubview(leftTableView)
                superview?.addSubview(rightTableView)
            }else {
                
                leftTableView.frame = CGRect(x: 0, y: menuOrigin.y + menuHeight, width: kScreenWidth, height: 0)
                superview?.addSubview(leftTableView)
            }
            
            UIView.animate(withDuration: kAnimationDuration) {
                self.leftTableView.frame.size.height = heightForTableView
                if haveItems {
                    self.rightTableView.frame.size.height = heightForTableView
                }
            }
            
        }else {
            
            UIView.animate(withDuration: kAnimationDuration, animations: {
                
                self.leftTableView.frame.size.height = 0
                if haveItems {
                    self.rightTableView.frame.size.height = 0
                }
            }, completion: { (finished) in
                
                self.leftTableView.removeFromSuperview()
                if haveItems {
                    self.rightTableView.removeFromSuperview()
                }
            })
        }
        
        complete()
    }
    
    /// titleLayer动画
    func animateFor(titleLayer textLayer: CATextLayer, indicator: CAShapeLayer?, show: Bool, complete: () -> Void) -> Void {
        
        let textSize = calculateStringSize((textLayer.string as! String?) ?? "")
        let maxWidth = kScreenWidth / CGFloat(numberOfColumn) - 25
        let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
        
        textLayer.bounds.size.width = textLayerWidth
        textLayer.bounds.size.height = textSize.height
        
        if let indicatorR = indicator {
            indicatorR.position.x = textLayer.position.x + textLayerWidth / 2 + 10
        }
        
        if show {
            textLayer.foregroundColor = selectedTextColor.cgColor
        }else {
            textLayer.foregroundColor = textColor.cgColor
        }
        
        complete()
    }
    
    
}





























