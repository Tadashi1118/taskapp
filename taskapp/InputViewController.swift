//
//  InputViewController.swift
//  taskapp
//
//  Created by 吉田直志 on 2018/10/20.
//  Copyright © 2018年 Tadashi1118. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task: Task!
    let realm = try! Realm() //レルムクラスのインスタンス作成 変数 = クラス名()
    
    override func viewDidLoad() { // 綺麗にする 見やすさ　ファットビューコントローラー
        super.viewDidLoad()

        // 枠のカラー
        contentsTextView.layer.borderColor = UIColor.darkGray.cgColor
        // 枠の幅
        contentsTextView.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        contentsTextView.layer.cornerRadius = 10.0
        contentsTextView.layer.masksToBounds = true

        titleTextField.delegate = self
        categoryTextView.delegate = self

        self.dataSet()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        //        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //        self.view.addGestureRecognizer(tapGesture)
    }
    
    func dataSet () {
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextView.text = task.category
        datePicker.date = task.date
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //UITextFieldに全て入ってくる
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) { //通知登録のフック、キャンセルボタン
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text!
            self.task.category = self.categoryTextView.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task) //登録のフック
        
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default()

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false) //通知のフック
  
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    
//    @objc func dismissKeyboard(){
//        // キーボードを閉じる
//        view.endEditing(true)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    }
}
