//
//  StudentMainViewController.swift
//  DinnerSystem
//
//  Created by Sean on 2020/2/17.
//  Copyright © 2020 DinnerSystem Team. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire

class StudentMainViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var barcodeView: UIImageView!
    @IBOutlet var cardDetailLabel: UILabel!
    
    //MARK: - Declarations
    
    
    override func viewWillAppear(_ animated: Bool) {
        do{
            let cardResponse = try Data(contentsOf: URL(string: dsURL("get_pos"))!)     //get POS info
            POSInfo = try decoder.decode(CardInfo.self, from: cardResponse)
            barcodeView.image = getBarcode(POSData: POSInfo) //get barcode image
            cardDetailLabel.text = "卡號：\(POSInfo.card!)\n餘額：\(POSInfo.money!)元（非即時）"
            titleLabel.text = "歡迎使用午餐系統，\n\(POSInfo.name!.trimmingCharacters(in: .whitespacesAndNewlines))."
        }catch let error{
            print(error)
            Crashlytics.sharedInstance().recordError(error)
            let alert = UIAlertController(title: "請重新登入", message: "查詢餘額失敗，我們已經派出最精銳的猴子去修理這個問題，若長時間出現此問題請通知開發人員！", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) -> () in
                logout()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sry light here
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func moreButton(_ sender: AnyObject){
        self.performSegue(withIdentifier: "moreSegue", sender: nil)
    }
    
    @IBAction func menuButton(_ sender: Any) {
        self.performSegue(withIdentifier: "menuSegue", sender: nil)
    }
    
    @IBAction func orderButton(_ sender: Any) {
        self.performSegue(withIdentifier: "historySegue", sender: nil)
    }
    
    @IBAction func cart_button(_ sender: Any) {             //turned to oldHistory
        oldHistoryArr = []
        oldHistoryTableList = []
        let histParam: Parameters = ["cmd": "select_self", "history": "true"]
        AF.request(dsRequestURL, method: .post, parameters: histParam).responseData{ response in
            if response.error != nil {
                
                let errorAlert = UIAlertController(title: "Bad Internet.", message: "Please check your internet connection and retry.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action: UIAlertAction!) -> () in
                    logout()
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
            let responseStr = String(data: response.data!, encoding: .utf8)
            if responseStr == ""{
                let alert = UIAlertController(title: "請重新登入", message: "您已經登出", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action: UIAlertAction!) -> () in
                    logout()
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }else if responseStr == "{}"{
                let alert = UIAlertController(title: "無點餐紀錄", message: "過去無點餐紀錄！", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                do{
                    oldHistoryArr = try decoder.decode([History].self, from: response.data!)
                    oldHistoryArr.reverse()
                    print("HI")
                    for order in oldHistoryArr{
                        if order.dish!.count == 1{
                            let tmp = HistoryList(id: order.id, dishName: order.dish![0].dishName, dishCost: order.dish![0].dishCost, recvDate: order.recvDate, money: order.money)
                            oldHistoryTableList.append(tmp)
                        }else{
                            var dName = ""
                            var dCost = 0
                            for dish in order.dish!{
                                dName += "\(dish.dishName!)+"
                                dCost += Int(dish.dishCost!)!
                            }
                            dName = String(dName.dropLast(1))
                            let tmp = HistoryList(id: order.id, dishName: dName, dishCost: String(dCost), recvDate: order.recvDate, money: order.money)
                            oldHistoryTableList.append(tmp)
                        }
                    }
                    self.performSegue(withIdentifier: "oldHistorySegue", sender: self)
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
            }
        }
    }
    
}
