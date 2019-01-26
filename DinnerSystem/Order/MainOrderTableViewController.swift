//
//  MainOrderTableViewController.swift
//  DinnerSystem
//
//  Created by Sean on 2018/9/13.
//  Copyright © 2018年 Sean.Inc. All rights reserved.
//

import UIKit
import Alamofire
import TrueTime

class MainOrderTableViewController: UITableViewController {
    
    var activityIndicator = UIActivityIndicatorView()
    var indicatorBackView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        var foodCount = 0
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        indicatorBackView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        indicatorBackView.center = self.view.center
        indicatorBackView.isHidden = true
        indicatorBackView.layer.cornerRadius = 20
        indicatorBackView.alpha = 0.5
        indicatorBackView.backgroundColor = UIColor.black
        self.view.addSubview(indicatorBackView)
        self.view.addSubview(activityIndicator)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.activityIndicator.startAnimating()
        self.indicatorBackView.isHidden = false
        
        Alamofire.request(dsURL("show_dish")).responseData{ response in
            if response.error != nil {
                let errorAlert = UIAlertController(title: "Error", message: "不知名的錯誤，請注意網路連線狀態或聯絡管理員。", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action: UIAlertAction!) -> () in
                    logout()
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }else{
                
            let responseStr = String(data: response.data!, encoding: .utf8)
            if responseStr == ""{
                let alert = UIAlertController(title: "請重新登入", message: "您已經登出", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action: UIAlertAction!) -> () in
                    logout()
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
            mainMenuArr = []
            taiwanMenuArr = []
            aiJiaMenuArr = []
            cafetMenuArr = []
            guanDonMenuArr = []
            originMenuArr = []
            //mainMenuArr = try! decoder.decode([Menu].self, from: response.data!)
                do{
                    mainMenuArr = try decoder.decode([Menu].self, from: response.data!)
                }catch let error{
                    print(error)
                    let alert = UIAlertController(title: "請重新登入", message: "發生了不知名的錯誤，若重複發生此錯誤請務必通知開發人員！", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        (action: UIAlertAction!) -> () in
                        logout()
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                originMenuArr = mainMenuArr
            for food in mainMenuArr{
                if food.isIdle! == "1"{
                    mainMenuArr.remove(at: foodCount)
                }else{
                    foodCount += 1
                }
            }
            for food in mainMenuArr{
                if food.department?.factory?.name! == "台灣小吃部"{
                    taiwanMenuArr.append(food)
                }else if food.department?.factory?.name! == "愛佳便當"{
                    aiJiaMenuArr.append(food)
                }else if food.department?.factory?.name! == "合作社"{
                    cafetMenuArr.append(food)
                }else if food.department?.factory?.name! == "關東煮"{
                    guanDonMenuArr.append(food)
                }
            }
                for i in 0..<guanDonMenuArr.count{
                    Alamofire.request("\(dsURL("get_remaining"))&id=\(guanDonMenuArr[i].dishId!)").responseString{ remainResponse in
                        if remainResponse.error != nil {
                            let errorAlert = UIAlertController(title: "Error", message: "不知名的錯誤，請注意網路連線狀態或聯絡管理員。", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                (action: UIAlertAction!) -> () in
                                logout()
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(errorAlert, animated: true, completion: nil)
                        }else{
                            guanDonMenuArr[i] = try! decoder.decode(Menu.self, from: remainResponse.data!)
                        }
                    }
                }
        }
                
            }
            self.indicatorBackView.isHidden = true
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }


}

