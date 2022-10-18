//
//  DetailViewController.swift
//  RoadStationStamp
//
//  Created by 藤森太暉 on 2022/08/24.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController,CLLocationManagerDelegate {
 
    
    //MARK: - プロパティ

    
    // userdefaultsから取得した配列を格納する変数
    var stations : [RoadStation] = []
    
    var stations2 : [RoadStation] = []
    
    var areaValue : String?
    var kenValue : String?
    
    // 現在地を格納する変数
    var currentLocation : CLLocation?
    
    var targetLocation : CLLocation?
   
    var number : Int!
    
    var isStamp : Bool = false
    
    var locationManager : CLLocationManager?
    
    var stationLocation : CLLocationCoordinate2D?
    
    var stationName : String = ""
    
    @IBOutlet var stampView: UIImageView!
    @IBOutlet var stationNameLabel: UILabel!
    
    @IBOutlet var stampButton : UIButton!
    
    @IBOutlet var topbarView: UIView!
    
    @IBOutlet var stampEntryView: UIView!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet weak var networkLabel: UIButton!
    
//    // 訪れた回数を表示する
//    @IBOutlet var visitLabel: UILabel!
    
    //MARK: - Viewの表示
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loadStationsでuserdefaultsの配列を呼び出し定数に格納
        if let unwrapedStations = loadStationsArray(){
            stations = unwrapedStations
        }else {
            print("userDefaultsから取得できませんでした")
        }
        
//        if let unwrappedStationDict = loadStationsDictionary(){
//            stations2 = arrayFromDict(dictionary: unwrappedStationDict)
//        }else {
//            print("取得失敗")
//        }
        
  
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        if height > 800.0 && height < 1000.0{
            self.topbarView.frame = CGRect(x: 0, y: 0, width: width, height: height * 0.12 )
        }

        

        //名前と座標が一致した道の駅のインデックス番号を取得できたら
        if let index = stations.firstIndex(of: RoadStation(name: stationName, latitude: stationLocation!.latitude, longitude: stationLocation!.longitude, address: "", url: "",area: "",ken: "")){

            self.number = index
            stationNameLabel.text = stations[number].name

        }
        
//        if let index = stations2.firstIndex(of: RoadStation(name: stationName, latitude: stationLocation!.latitude, longitude: stationLocation!.longitude, address: "", url: "")){
//
//            self.number = index
//            stationNameLabel.text = stations2[number].name
//
//        }
        
        if stations[number].isStamp {
           
            stampButton.isEnabled = false
            print("スタンプ押せません")
            topbarView.backgroundColor = UIColor(named: "TopBarViewColor")
        }else {
            
            stampButton.isEnabled = true
            print("スタンプ押せます")
            topbarView.backgroundColor = .gray
        }
        
        
        
       
        networkLabel.setTitle(stations[number].url, for: .normal)
        networkLabel.titleLabel?.font = .systemFont(ofSize: 14)
        addressLabel.text = stations[number].address
       

        
        if self.stations[number].isStamp {
            stampView.isHidden = false
        }else {
            stampView.isHidden = true
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
       


        
        self.targetLocation = CLLocation(latitude: stations[number].latitude,
                                         longitude: stations[number].longitude)
        
        stampEntryView.layer.borderWidth = 2
        stampEntryView.layer.cornerRadius = 20
        
        // 遷移先（webView）の戻るボタンテキスト非表示
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
     
    
    }//: viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ナビゲーションバーを隠す
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.navigationController?.navigationBar.isHidden = true
        
       
    }
    

    
   //MARK: - デリゲート
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在地を取得し格納
        self.currentLocation = CLLocation(latitude: (locations.last?.coordinate.latitude)!,
                                          longitude: (locations.last?.coordinate.longitude)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 現在地が取得できなかったらnilを代入
        self.currentLocation = nil
    }
    
 
    
   
    
    //MARK: - メソッド
    
    @IBAction func tappedStamp(_ sender: UIButton) {
        guard let unwrapedCurrentLocation = currentLocation else {
            print("現在地が取得できません")
            
            let alert = UIAlertController(title: "スタンプが押せません", message: "位置情報の取得が許可されていません", preferredStyle: .alert)
            //ここから追加
            let toSettingApp = UIAlertAction(title: "設定へ", style: .default) { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            let stay = UIAlertAction(title: "オフのままにする", style: .default) { (action) in
                
            }
            alert.addAction(toSettingApp)
            alert.addAction(stay)
            //ここまで追加
            present(alert, animated: true, completion: nil)
            
            return
        }
        if (targetLocation?.distance(from: unwrapedCurrentLocation))! <= 50 {
            print("スタンプが押されました")
//            roadStations.stations[number].isStamp = true
            stations[number].isStamp = true
            
            self.isStamp = true
            
            // userdefaultsに保存
            saveStationsArray(stations: stations)
            print("loadStations\(loadStationsArray()!)")
            
            stampView.isHidden = false
        }else {
            let alert = UIAlertController(title: "スタンプが押せません", message: "道の駅に近づいてください", preferredStyle: .alert)
            //ここから追加
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                
            }
            alert.addAction(ok)
            //ここまで追加
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func toOfficial(_ sender: UIButton) {
        print("公式HPへGO")
////        performSegue(withIdentifier: "toWeb", sender: nil)
//        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "webVC") as! WebViewController
//        self.navigationController?.navigationBar.isHidden = false
//
////        webVC.urlStr = roadStations.stations[number].url
//        webVC.urlStr = stations[number].url
//
//        self.navigationController?.pushViewController(webVC, animated: true)
        
       
        
        if let url = URL(string: stations[number].url){
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // zenkokuStationからエリアと県のキーを取得
//    func findKeyForValue(value: RoadStation,
//                          dictionary: [String: [String : [Int]]]){
//        for (areaKey , dict) in dictionary {
//            // dict の値の配列にvalueが含まれてたらwantKeyが欲しい
//            for (kenKey ,array) in dict {
//                if (array.contains(value)) {
//                    self.kenValue = kenKey
//                    self.areaValue = areaKey
//                }
//            }
//        }
//    }
    
   
}
