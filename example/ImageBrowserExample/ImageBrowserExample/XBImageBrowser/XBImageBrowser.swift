//
//  XBImageBrowser.swift
//  XBImageBrowser_swift
//
//  Created by xxb on 2017/1/19.
//  Copyright © 2017年 xxb. All rights reserved.
//

import UIKit

class XBImageBrowser: UIViewController {
    
    // MARK: - 懒加载
    
    lazy var xbCollectionView:UICollectionView = {
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = UICollectionViewScrollDirection.horizontal
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        
        let _xbCollectionView:UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flow)
        // 设置collectionView的代理：
        _xbCollectionView.delegate = self
        _xbCollectionView.dataSource = self
        _xbCollectionView.isPagingEnabled = true
        _xbCollectionView.showsHorizontalScrollIndicator = false
        // 注册item:
        _xbCollectionView.register(XBImageBrowserCell.self , forCellWithReuseIdentifier: "cell")
        _xbCollectionView.backgroundColor = UIColor.clear
        return _xbCollectionView
    }()
    
    
    
    
    // MARK: - 属性
    
    var arr_imagePathOrUrlstr:[String] = [String]()
    
    /** 当前展示的是第几张 */
    var indexOfItem:Int = 0

    /** 创建等待view的block，如果没有设置则默认为菊花 */
    var createLoadingViewBlcok:CreateLoadingViewBlockType?
    
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        view.addSubview(xbCollectionView)
        
        addNotice()
    }
    
    deinit {
        XBImageManager.shared.removeImagesFromTempDictWith(arr_urlStrOrPath: arr_imagePathOrUrlstr)
        removeNotice()
        print("销毁")
    }
    
    override func viewWillAppear(_ animated: Bool) {

        var tempOffset = xbCollectionView.contentOffset
        tempOffset.x = CGFloat(indexOfItem) * XBImageBorwserConfig.getRightSize().width
        xbCollectionView.contentOffset=tempOffset
    }

    
    // MARK: - 通知相关
    
    func addNotice () -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleTap), name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_itemImageClicked), object: nil)
    }
    
    func removeNotice () -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_itemImageClicked), object: nil)
    }
    
    func handleTap (noti:Notification) -> Void {
        print("tap")
        dismiss(animated: true, completion: nil)
    }


    // MARK: - 旋转相关
    
    func deviceOrientationWillChange(toInterfaceOrientation:UIInterfaceOrientation) -> Void {
        //如果没有完成滚动，重复执行，等待滚动完成
        if xbCollectionView.isDecelerating == true
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: { 
                self.deviceOrientationWillChange(toInterfaceOrientation: toInterfaceOrientation)
            })
            return
        }

        UIView.animate(withDuration: 0.5) { 
            self.xbCollectionView.frame = CGRect(x: 0, y: 0, width: XBImageBorwserConfig.getRightSize().width, height: XBImageBorwserConfig.getRightSize().height)
        }
        

        
        xbCollectionView.reloadData()
        
        var tempOffset = xbCollectionView.contentOffset
        tempOffset.x = CGFloat(indexOfItem) * XBImageBorwserConfig.getRightSize().width
        xbCollectionView.contentOffset=tempOffset
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_deviceOrientationWillChange), object: nil)
    }

    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        deviceOrientationWillChange(toInterfaceOrientation: toInterfaceOrientation)
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension XBImageBrowser:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr_imagePathOrUrlstr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XBImageBrowserCell
        cell.createLoadingViewBlcok = createLoadingViewBlcok
        cell.str_imagePathOrUrlstr = arr_imagePathOrUrlstr[indexPath.item]
        cell.index = indexPath.item
        print(cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    //某个item从显示到不显示后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:XBImageBorwserConfig.kNotice_currentImageIndexChange), object: indexPath.item)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 将collectionView在控制器view的中心点转化成collectionView上的坐标
        let pInView = view.convert(xbCollectionView.center, to: xbCollectionView)
        // 获取这一点的indexPath
        let indexPathNow = xbCollectionView.indexPathForItem(at: pInView)
        // 赋值给记录当前坐标的变量
        if indexPathNow != nil {
            indexOfItem = indexPathNow!.item
        }
    }

}
