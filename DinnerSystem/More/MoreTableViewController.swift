//
//  MoreTableViewController.swift
//  DinnerSystem
//
//  Created by Sean on 2018/9/16.
//  Copyright © 2018年 Sean.Inc. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics
import FirebaseMessaging
import UserNotifications

var counter=0
class MoreTableViewController: UITableViewController {
    @IBOutlet var dailySwitch: UISwitch!
    var uDefault: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uDefault = UserDefaults.standard
        if uDefault.bool(forKey: "dailyNotifiacation") != false{
            dailySwitch.isOn = true
        }else{
            dailySwitch.isOn = false
        }
    }
    @IBAction func Logout(_ sender: Any) {
        logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chgPass(_ sender: Any) {
        let chgAlert = UIAlertController(title: "更改密碼", message: "請輸入新密碼與舊密碼", preferredStyle: .alert)
        chgAlert.addAction(UIAlertAction(title: "確定更改", style: .default, handler: {
            (action:UIAlertAction) -> () in
            let oldpw = chgAlert.textFields![0] as UITextField
            let newpw = chgAlert.textFields![1] as UITextField
            let newpw2 = chgAlert.textFields![2] as UITextField
            let oldPassword = oldpw.text!
            let newPassword = newpw.text!
            if (oldpw.text! == "") || (newpw.text! == "") || (newpw2.text! == ""){
                let alert = UIAlertController(title: "請確定有填入所有輸入欄", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) -> () in
                    self.present(chgAlert, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if oldPassword != pwd{
                let alert = UIAlertController(title: "原密碼錯誤", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) -> () in
                    self.present(chgAlert, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if newPassword != newpw2.text!{
                let alert = UIAlertController(title: "新密碼不吻合", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) -> () in
                    self.present(chgAlert, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if newPassword.contains(" "){
                let alert = UIAlertController(title: "請勿輸入空白鍵", message: "請再試一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) -> () in
                    self.present(chgAlert, animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                print("\(dsURL("change_password"))&old_pswd=\(oldPassword)&new_pswd=\(newPassword)")
                Alamofire.request("\(dsURL("change_password"))&old_pswd=\(oldPassword)&new_pswd=\(newPassword)").responseData{ response in
                    if response.error != nil {
                        let errorAlert = UIAlertController(title: "Bad Internet.", message: "Please check your internet connection and retry.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            (action: UIAlertAction!) -> () in
                            logout()
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    let responseString = String(data: response.data!, encoding: .utf8)!
                    print(responseString)
                    if(responseString == "Invalid string."){
                        let alert = UIAlertController(title: "輸入格式錯誤", message: "輸入內容僅限大小寫英數及底線!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            (action:UIAlertAction) -> () in
                            self.present(chgAlert, animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else if((responseString.contains("short"))){
                        let alert = UIAlertController(title: "輸入格式錯誤", message: "密碼長度需大於等於三字元!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            (action:UIAlertAction) -> () in
                            self.present(chgAlert, animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else if responseString == ""{
                        let alert = UIAlertController(title: "您已經登出", message: "請重新登入", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            (action: UIAlertAction!) -> () in
                            logout()
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "更改成功", message: "請重新登入", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            (action:UIAlertAction) -> () in
                            Alamofire.request("\(dsURL("logout"))").responseString{resp in}
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))
        chgAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        chgAlert.addTextField{
            (textfield:UITextField!) -> Void in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "舊密碼"
        }
        chgAlert.addTextField{
            (textfield:UITextField!) -> Void in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "新密碼"
        }
        chgAlert.addTextField{
            (textfield:UITextField!) -> Void in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "請再輸入一次新密碼"
        }
        self.present(chgAlert, animated: true)
    }
    
    
    @IBAction func switchedDaily(_ sender: Any) {
        if dailySwitch.isOn{
            var canNotify = false
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(completionHandler: { (setting) in
                print(setting)
                if(setting.authorizationStatus == .authorized){
                    print("authed")
                    canNotify = true
                    Messaging.messaging().subscribe(toTopic: "com.dinnersystem.dailyNotification"){ error in
                        if error != nil{
                            self.present(createAlert("訂閱過程發生錯誤", "\(error!)"), animated: true, completion: nil)
                            DispatchQueue.main.async {
                                self.dailySwitch.isOn = false 
                            }
                            
                        }else{
                            self.present(createAlert("訂閱成功", "每日通知已開啟"), animated: true, completion: nil)
                            self.uDefault.set(true, forKey: "dailyNotifiacation")
                        }
                    }

                }else{
                    let alert = UIAlertController(title: "尚未開啟通知", message: "請至設定開啟通知", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "跳轉至設定", style: .default, handler: { (action) in
                        if let url = URL(string:UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                        self.dailySwitch.isOn = false
                    }
                }
                
            })
            print(canNotify)
//            if canNotify{
//                Messaging.messaging().subscribe(toTopic: "com.dinnersystem.dailyNotification"){ error in
//                    if error != nil{
//                        self.present(createAlert("訂閱過程發生錯誤", "\(error!)"), animated: true, completion: nil)
//                    }else{
//                        self.present(createAlert("訂閱成功", "每日通知已開啟"), animated: true, completion: nil)
//                        self.uDefault.set(true, forKey: "dailyNotifiacation")
//                    }
//                }
//            }else{
//                let alert = UIAlertController(title: "尚未開啟通知", message: "請至設定開啟通知", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "跳轉至設定", style: .default, handler: { (action) in
//                    if let url = URL(string:UIApplication.openSettingsURLString) {
//                        if UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        }
//                    }
//                }))
//                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                self.dailySwitch.isOn = false
//            }
        }else{              //closed
            Messaging.messaging().unsubscribe(fromTopic: "com.dinnersystem.dailyNotification"){error in
                if error != nil{
                    self.present(createAlert("取消訂閱過程發生錯誤", "\(error!)"), animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.dailySwitch.isOn = true
                    }
                    
                }else{
                    self.present(createAlert("取消訂閱成功", "每日通知已關閉"), animated: true, completion: nil)
                    self.uDefault.set(false, forKey: "dailyNotifiacation")
                }
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            if counter == 13{
                counter = 0
                self.performSegue(withIdentifier: "bonusSegue", sender: self)
            }else{
                counter += 1
                self.performSegue(withIdentifier: "normalSegue", sender: self)
            }
        }else if indexPath.row == 3{
            let policiyURL = URL(string: "\(dinnersysURL)/frontend/FoodPolicies.pdf")!
            UIApplication.shared.open(policiyURL, options: [:], completionHandler: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        //        else if indexPath.row == 2{
        //            do{
        //                let cardResponse = try Data(contentsOf: URL(string: dsURL("get_pos"))!)
        //                POSInfo = try decoder.decode(CardInfo.self, from: cardResponse)
        //                self.performSegue(withIdentifier: "barcodeSegue", sender: self)
        //            }catch let error{
        //                print(error)
        //                Crashlytics.sharedInstance().recordError(error)
        //                let alert = UIAlertController(title: "請重新登入", message: "查詢餘額失敗，我們已經派出最精銳的猴子去修理這個問題，若長時間出現此問題請通知開發人員！", preferredStyle: UIAlertController.Style.alert)
        //                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        //                    (action: UIAlertAction!) -> () in
        //                    logout()
        //                    self.dismiss(animated: true, completion: nil)
        //                }))
        //                self.present(alert, animated: true, completion: nil)
        //            }
        //
        //        }
    }
}
