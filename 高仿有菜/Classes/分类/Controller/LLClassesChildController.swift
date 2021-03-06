//
//  LLClassesChildController.swift
//  高仿有菜
//
//  Created by JYD on 16/9/27.
//  Copyright © 2016年 周尊贤. All rights reserved.
//

import UIKit
import MJRefresh
import SVProgressHUD
import BACustomAlertView
class LLClassesChildController: LLBaseViewController {

    
    var cateType = -1
    
    /// 上拉下拉的标题
    var start:Int = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
       loadResustDate()
        view.addSubview(childColletionView)
       view.addSubview(childTabView)
     childTabView.mj_header = MJRefreshNormalHeader.header(refreshingBlock: {
        self.start = 0
        self.loadResustDate()
     }) as! MJRefreshHeader!
        
        childColletionView.mj_header = MJRefreshNormalHeader.header(refreshingBlock: {
            self.start = 0
            self.loadResustDate()
        }) as! MJRefreshHeader!
        
        childTabView.mj_footer = MJRefreshBackNormalFooter.footer(refreshingBlock: { 
            self.start = self.start + 10
            self.loadResustDate()
        }) as! MJRefreshFooter!
        
        childColletionView.mj_footer = MJRefreshBackNormalFooter.footer(refreshingBlock: { 
            self.start = self.start + 10
            self.loadResustDate()
        }) as! MJRefreshFooter!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
             // MARK: ---- 请求数据
    private func loadResustDate() {
        
          SVProgressHUD.show(withStatus: "正在拼命加载中")
        let urlString = "https:api.youcai.xin/item/list?cate=\(cateType)&length=10&start=\(start)"
        LLNetworksTools.request(with: httpRequestType.requestTypeGet, withUrlString: urlString, withParameters: nil, withSuccessBlock: { (response) in
            
            //热门销售数据
            var topModelArr = [LLHomeModel]()
            if let topArr = ((response as?NSDictionary)?.object(forKey: "tops")) as?NSArray {
                for index in 0..<topArr.count {
                    let model = LLHomeModel(dict: topArr[index] as! [String : AnyObject])
                    topModelArr.append(model)
                }
            }
            
            //优选商品
            //热门销售数据
            var itemsModelArr = [LLHomeModel]()
            if let itemsArr = ((response as?NSDictionary)?.object(forKey: "items")) as?NSArray {
                for index in 0..<itemsArr.count {
                    let model = LLHomeModel(dict: itemsArr[index] as! [String : AnyObject])
                    itemsModelArr.append(model)
                }
            }
            
            if self.start == 0 {  //请求的新数据
                self.topsArr.count > 0 ?  (self.topsArr = topModelArr) :  (self.topsArr = topModelArr + self.topsArr)
                  self.itemsArr.count > 0 ?  (self.itemsArr = itemsModelArr) :  (self.itemsArr = itemsModelArr + self.itemsArr)
            }else { // 请求的老数据
                self.topsArr = self.topsArr + topModelArr
                    self.itemsArr = self.itemsArr + itemsModelArr
            }
            self.childColletionView.reloadData()
            self.childTabView.reloadData()
            self.childColletionView.mj_header.endRefreshing()
            self.childTabView.mj_header.endRefreshing()
            self.childColletionView.mj_footer.endRefreshing()
            self.childTabView.mj_footer.endRefreshing()
            SVProgressHUD.dismiss()
            }) { (error) in
              print(error)
                self.childColletionView.mj_header.endRefreshing()
                self.childTabView.mj_header.endRefreshing()
                SVProgressHUD.showError(withStatus: "数据异常!!")
        }
    }

   
    // MARK: ---- 懒加载
    lazy var childColletionView:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WITH, height: SCREEN_HEIGHT - 165), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
         collectionView.register(LLChildCollectionViewCell.self, forCellWithReuseIdentifier: "LLClassesChildController")
        collectionView.backgroundColor = UIColor.init(red: 233 / 255.0, green: 233 / 255.0, blue: 233 / 255.0, alpha: 0.78)
         collectionView.isHidden = true
         collectionView.register(LLChildCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "LLChildCollectionHeaderView")
        return collectionView
    }()
    lazy var childTabView:UITableView = {
       let tabView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WITH, height: SCREEN_HEIGHT - 165), style: .grouped)
        tabView.dataSource = self
        tabView.delegate = self
      tabView.isHidden = false
        tabView.register(LLClassesChildCell.self, forCellReuseIdentifier: "LLClassesChildController")
        tabView.register(LLChildTabHeadView.self, forHeaderFooterViewReuseIdentifier: "LLChildTabHeadView")
        

    return tabView
    }()
     lazy var topsArr = [LLHomeModel]()
     lazy var itemsArr = [LLHomeModel]()
    //已购买过的产品
    lazy var buyProduct = [LLHomeModel]()


}

extension LLClassesChildController:UICollectionViewDataSource,UICollectionViewDelegate,ChildCollectionViewCellBuyProductDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if topsArr.count > 0 {
            return 2
        }
        return 1
    }
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if section == 0 {
            if topsArr.count > 0 {
                return topsArr.count
            }else {
                return  itemsArr.count
                
            }
        }else  {
            return itemsArr.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LLClassesChildController", for: indexPath) as?LLChildCollectionViewCell
        if indexPath.section == 0 {
            if topsArr.count > 0 {
                let model = topsArr[indexPath.item]
                cell?.model = model
            } else {
                let model = itemsArr[indexPath.item]
                cell?.model = model
            }
            
        }else if indexPath.section == 1 {
            let model = itemsArr[indexPath.item]
            cell?.model = model
        }
       cell?.delegate = self
        return cell!
    
    }
    
    //swift2.3
//      func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        return CGSize(width: SCREEN_WITH / 2 - 36, height: 180)
//    }
 
      //swift3.0
    func collectionView(_ collectionView: UICollectionView,  layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: (SCREEN_WITH - 10 - 10) / 2  , height: 220)

    }
    
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
              return CGSize(width: SCREEN_WITH, height: 35)
    }
    
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "LLChildCollectionHeaderView", for: indexPath as IndexPath) as?LLChildCollectionHeaderView
        
        if indexPath.section == 0 {
            if topsArr.count > 0 {
                headView?.titleLable.text = "热门推荐"
            } else {
                headView?.titleLable.text = "优选\(title!)制品"
            }
        } else if indexPath.section == 1 {
            headView?.titleLable.text = "优选\(title!)制品"
        }
    
            return headView!
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detialVc = LLHomeDetailViewController()
        
        if indexPath.section == 0 {
            
            if topsArr.count > 0 {
                
                let model = topsArr[indexPath.row]
                detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"
                
            } else {
                let model = itemsArr[indexPath.row]
                detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"
                
            }
            
        }else if indexPath.section == 1 {
            let model = itemsArr[indexPath.row]
            detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"
            
            
        }

        navigationController?.pushViewController(detialVc, animated: true)
    }
    
    // MARK: ---- 自定义代理方法
    func CollectionViewCeltDelegate(iconImage: UIImageView, modelArr: NSMutableArray,imagePoint:CGPoint) {
        let dict = NSMutableDictionary(capacity: 1)
        dict["modelArr"] = modelArr
        //通知名称常量
        let NotifyChatMsgRecv = NSNotification.Name(rawValue:LLShoppingNotification)
        //发送通知
        NotificationCenter.default.post(name:NotifyChatMsgRecv, object: dict, userInfo:nil)
        let endPointer = CGPoint(x: SCREEN_WITH - SCREEN_WITH / 5 - 35 , y: SCREEN_HEIGHT - 44)
        self.addProductsAnimation(iconImage , endPoint: endPointer)
    }

    

    
    }
    
    
    


extension LLClassesChildController:UITableViewDataSource,UITableViewDelegate,classesChildCellBuyProductDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if topsArr.count > 0 {
        return 2
        }
        return 1
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if topsArr.count > 0 {
         return topsArr.count
            }else {
                return  itemsArr.count

            }
        }else  {
        return itemsArr.count
        }
       
    
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LLClassesChildController", for: indexPath) as?LLClassesChildCell
      
        if indexPath.section == 0 {
            if topsArr.count > 0 {
        let model = topsArr[indexPath.row]
            cell?.model = model
            } else {
                let model = itemsArr[indexPath.row]
                cell?.model = model
            }
        
        }else if indexPath.section == 1 {
            let model = itemsArr[indexPath.row]
            cell?.model = model
        }
    cell?.delegate = self
          return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "LLChildTabHeadView") as?LLChildTabHeadView
        if section == 0 {
            if topsArr.count > 0 {
            headView?.titleLable.text = "热门推荐"
            } else {
               headView?.titleLable.text = "优选\(title!)制品"
            }
        } else if section == 1 {
         headView?.titleLable.text = "优选\(title!)制品"
        }
       
            return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detialVc = LLHomeDetailViewController()
        
        if indexPath.section == 0 {
            
            if topsArr.count > 0 {
                
             let model = topsArr[indexPath.row]
            detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"
            
            } else {
                let model = itemsArr[indexPath.row]
                detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"

            }
        
        }else if indexPath.section == 1 {
            let model = itemsArr[indexPath.row]
            detialVc.detetailURLString = "https://api.youcai.xin/item/detail?id=\(model.id )"

        }
        
        navigationController?.pushViewController(detialVc, animated: true)
    }
          // MARK: ---- 自定义代理方法
    func childCellbuyProuductDelegate(iconImage: UIImageView, modelArr: NSMutableArray,imagePoint:CGPoint) {
        let dict = NSMutableDictionary(capacity: 1)
        dict["modelArr"] = modelArr
        for model in modelArr {
            let buyModel   = model as!LLHomeModel
            buyProduct.append(buyModel)
        }
        //通知名称常量
        let NotifyChatMsgRecv = NSNotification.Name(rawValue:LLShoppingNotification)
        //发送通知
        NotificationCenter.default.post(name:NotifyChatMsgRecv, object: dict, userInfo:nil)
          let endPointer = CGPoint(x: SCREEN_WITH - SCREEN_WITH / 5 - 35 , y: SCREEN_HEIGHT - 44)
        self.addProductsAnimation(iconImage , endPoint: endPointer)
    }

}
