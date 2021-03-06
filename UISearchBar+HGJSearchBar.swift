//
//  UISearchBar+HGJSearchBar.swift
//  UISearchBar+HGJSearchBar
//
//  Created by 胡古斤 on 2017/2/21.
//  Copyright © 2017年 胡古斤. All rights reserved.
//



/**
    
    一.说明: 在系统搜索栏基础上扩展自定义搜索栏
            1.自动处理cancle按钮显示与隐藏
            2.新增输入框背景颜色
    
    二.使用方法:
             1.创建搜索栏，默认输入框0.92灰度,输入栏边框白色,屏幕宽度44高度。
 
                let searchBar = UISearchBar(HGJDelegate: self)
 
 
             2.修改输入栏背景颜色（默认0.92灰度）
 
                searchBar.textfieldColor = UIColor.red
 
 
             2.代理对象实现HGJSearchDelegate代理方法
 
                 func HGJSearchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                     print(searchText)
                 }
 */





import UIKit

public protocol HGJSearchDelegate : NSObjectProtocol {
    
    func HGJSearchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    
}

typealias HGJSearchBlock = (_ searchBar: UISearchBar, _ searchText: String) -> Void



extension UISearchBar {
    
    
    
    //MARK: - Interface
    convenience init(HGJDelegate delegate : HGJSearchDelegate ,_ placeholder : String = "搜索") {
        
        self.init()
        
        // 1.配置系统搜索栏
        self.setupSearchBar()
        
        // 2.占位符
        self.placeholder = placeholder
        
        // 3.设置原系统代理处理容器
        self.originalDelegateContainer = HGJOriginalDelegateContainer.init(searchBar: self)
        self.delegate = self.originalDelegateContainer

        // 4.设置自定义代理
        self.HGJDelegate = delegate
        
    }
    
    
    convenience init(HGJSearchBlock block : @escaping HGJSearchBlock ,_ placeholder : String = "搜索") {
        
        self.init()
        
        // 1.配置系统搜索栏
        self.setupSearchBar()
        
        // 2.设置原系统代理处理容器
        let container = HGJOriginalDelegateContainer.init(searchBar: self)
        container.searchBlock = block
        self.originalDelegateContainer = container
        self.delegate = self.originalDelegateContainer
        
        
        // 1.3占位符
        self.placeholder = placeholder
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Property
    
    /** 定义扩展属性key */
    private struct key {
        
        static var textfieldColor = "textfieldColor"
        
        static var HGJSearchDelegate = "HGJSearchDelegate"
        
        static var HGJOriginalDelegateContainer = "HGJOriginalDelegateContainer"
        
    }
    
    
    /** 文本框背景颜色 */
    final var textfieldColor : UIColor? {
        set {
            objc_setAssociatedObject(self, &UISearchBar.key.textfieldColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let textFild = self.value(forKey: "searchField") as? UIView
            textFild?.backgroundColor = newValue
        }
        
        get {
            return objc_getAssociatedObject(self, &UISearchBar.key.textfieldColor) as? UIColor
        }
    }
    
    
    /** 自定义代理 */
    weak final var HGJDelegate : HGJSearchDelegate? {
        
        set {
            objc_setAssociatedObject(self, &UISearchBar.key.HGJSearchDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &UISearchBar.key.HGJSearchDelegate) as? HGJSearchDelegate
        }
        
    }
    
    
    
    /** 强引用原代理 */
    private var originalDelegateContainer : HGJOriginalDelegateContainer? {
        
        set {
            objc_setAssociatedObject(self, &UISearchBar.key.HGJOriginalDelegateContainer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &UISearchBar.key.HGJOriginalDelegateContainer) as? HGJOriginalDelegateContainer
        }
        
    }
    
    
    
    
    
    
    
    
    
    //MARK: - PrivateFunctions
    
    /** 配置搜索栏 */
    
    private func setupSearchBar() {
        
        
        // 0.设置大小
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        
        // 1.设置颜色
        self.textfieldColor = UIColor.init(white: 0.95, alpha: 1)
        self.barTintColor = UIColor.white
        
    }
    
    
    
    
}












/** 搜索栏原始代理处理处 */

fileprivate class HGJOriginalDelegateContainer : NSObject, UISearchBarDelegate {
    
    
    //MARK: - Property
    
    /** delegate */
    var searchBar : UISearchBar?
    
    /** block */
    var searchBlock : HGJSearchBlock?
    
    
    //MARK: - Initial
    convenience init(searchBar: UISearchBar, block: HGJSearchBlock? = Optional.none) {
        self.init()
        self.searchBar = searchBar
        self.searchBlock = block
    }
    
    
    
    //MARK: - UISearchBarDelegate
    
    /** 点击搜索框事件 */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar?.showsCancelButton = true
    }
    
    
    /** 点击cancel按钮事件 */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.resignFirstResponder()
        self.searchBar?.showsCancelButton = false
        self.searchBar?.text = ""
        self.searchBar(searchBar, textDidChange: "")
    }
    
    /** 输入框改变 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        guard self.searchBlock != nil else {
        
            guard self.searchBar?.delegate != nil else {return}
            
            self.searchBar?.HGJDelegate?.HGJSearchBar(searchBar, textDidChange: searchText)
        
            return
        }
        
        self.searchBlock!(searchBar, searchText)
    }
    
    
}




