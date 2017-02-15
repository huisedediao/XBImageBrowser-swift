//
//  ViewController.swift
//  ImageBrowserExample
//
//  Created by xxb on 2017/1/20.
//  Copyright © 2017年 xxb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  
    @IBAction func show(_ sender: Any) {
        let browser = XBImageBrowser()
        browser.arr_imagePathOrUrlstr = ["http://img5q.duitang.com/uploads/item/201502/23/20150223111936_XH3m8.jpeg","http://cdn.duitang.com/uploads/item/201507/26/20150726235001_3iH4x.thumb.700_0.jpeg","http://img4.duitang.com/uploads/item/201308/22/20130822233017_zPwVZ.thumb.700_0.jpeg","http://img4q.duitang.com/uploads/item/201505/28/20150528074128_SREUh.thumb.700_0.jpeg","http://img5q.duitang.com/uploads/item/201504/08/20150408H5738_MxjmX.jpeg","http://img4.duitang.com/uploads/item/201410/05/20141005204955_imwRj.png","http://imgsrc.baidu.com/forum/w%3D580/sign=acd2738992529822053339cbe7cb7b3b/5343fbf2b21193135a8fb0fe67380cd790238db4.jpg"]
        browser.indexOfItem = 1
        /*
        browser.createLoadingViewBlcok = { () ->UIView in
            let view = UIView()
            view.backgroundColor = UIColor.red
            view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            return view
        }
         */
        present(browser, animated: true, completion: nil)
    }


    

    @IBAction func love(_ sender: Any) {
        let browser = XBImageBrowser()
        browser.arr_imagePathOrUrlstr = [Bundle.main.path(forResource: "IMG_0145.JPG", ofType: nil)!,Bundle.main.path(forResource: "IMG_0146.JPG", ofType: nil)!,Bundle.main.path(forResource: "IMG_0147.JPG", ofType: nil)!,Bundle.main.path(forResource: "IMG_0148.JPG", ofType: nil)!,Bundle.main.path(forResource: "IMG_0149.JPG", ofType: nil)!]
        browser.indexOfItem = 1
        present(browser, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

