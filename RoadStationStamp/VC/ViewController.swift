//
//  ViewController.swift
//  RoadStationStamp
//
//  Created by 藤森太暉 on 2022/08/24.
//

import UIKit
import MapKit
import CoreLocation

//MARK: - コピーです

// MKPointAnnotationを継承したクラス
class CustomMKPointAnnotation : MKPointAnnotation {
    var markerColor : UIColor = UIColor.red
}

class ViewController: UIViewController,
                      CLLocationManagerDelegate,
                      MKMapViewDelegate {
    //MARK: - プロパティ
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var achievementLabel: UILabel!
    
    @IBOutlet var locationButton: UIButton!
    
    //userdefaultsから読み込んだ配列を格納する変数
    var stations : [RoadStation] = []
    
//    var stations2 : [RoadStation] = []
    
   
    
    // 自身の位置情報を表示するための変数
    // 非同期処理を行うため、強参照のプロパティとしてアプリ内保管
    var myLocationManager : CLLocationManager!
    
    var stationName : String?
    
    var location : CLLocationCoordinate2D?
    
    // ユーザーの位置情報を取得する変数
    var userLocation :CLLocationCoordinate2D?
    
    // ユーザーの位置情報の取得状況
    var isUserLocation : Bool = false
    
    // 地図の拡大率　（0〜1）
    // 数値が0に近づくほど拡大率が上がる
    var span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    
   
    
  //MARK: - Viewの表示時の処理
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    
//        locationButton.isHidden = true
        
        //userdefaults 配列呼び出し
        if let unwrapedStations = loadStationsArray(){ //UserDefaultsにデータがあれば（nilでないとき）
            saveStationsArray(stations: unwrapedStations)
            stations = unwrapedStations
        }else{ //nilの場合の処理
            saveStationsArray(stations: stationsList)
            self.stations = stationsList
        }
        
        print("\(stations.filter{$0.area == "hokuriku"}.filter{$0.isStamp == true}.count) / \(stations.filter{$0.area == "hokuriku"}.count)")
        
//         userdefaults 辞書型呼び出し
//        if let unwrappedStationDic = loadStationsDictionary() {
//            saveStationsDictionary(dictionary: unwrappedStationDic)
//              stations2 = arrayFromDict(dictionary: unwrappedStationDic)
//        }else {
//            saveStationsDictionary(dictionary: zenkokuStationsDic)
//            stations2 = arrayFromDict(dictionary: zenkokuStationsDic)
//        }
//
//        print("stations2: \(stations2)")
//
        
        // マネージャーの初期化
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        // アプリの使用中のみ位置情報サービスの利用許可を求める
        myLocationManager.requestWhenInUseAuthorization()
        
       
        // 位置情報マーカーを表示
        mapView.showsUserLocation  = true
        
        
        if CLLocationManager.locationServicesEnabled() {
            print("せいこうしました")

            myLocationManager.startUpdatingLocation()
        }
//        mapView.setCenter(mapView.userLocation.coordinate, animated: false)
        
       
    
        // 現在地を画面中央にする
        mapView.setUserTrackingMode(.follow, animated: true)
        
        achievementLabel.layer.cornerRadius = 10
        achievementLabel.clipsToBounds = true
        
 
       
    }//:viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
       
        // addAnnotationメソッドを使って追加することでピンで表示される

        

//
        guard let unwrapedStations = loadStationsArray() else {return}
            for station in unwrapedStations {
                addAnnotation(latitude: station.latitude, longitude: station.longitude, title: station.name,isStamp: station.isStamp)
            }
        
//        guard let unwrappedStationDict = loadStationsDictionary() else {return}
//        stations2 = arrayFromDict(dictionary: unwrappedStationDict)
//        for station in stations2 {
//            addAnnotation(latitude: station.latitude, longitude: station.longitude, title: station.name, isStamp: station.isStamp)
//        }
        
       
        

        let filterdArray = unwrapedStations.filter{$0.isStamp == true}
//        let filterArray = stations2.filter{$0.isStamp == true}
        
        achievementLabel.text = "\(filterdArray.count) / \(unwrapedStations.count)"
//        achievementLabel.text = "\(filterArray.count) / \(stations2.count)"
        
        print("ViewController.viewWillAppear")
        
        super.viewWillAppear(animated)
    }
    
   
    

    

    //MARK: - デリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last?.coordinate != nil {// 現在地が取得できたら
//            self.locationButton.isHidden = true
            self.isUserLocation = true
        }
        
        self.userLocation = locations.last?.coordinate
        
        
    }
    
    //位置情報が取得できなかった時の処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        self.locationButton.isHidden = false
        self.isUserLocation = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { // annotationがMKUserLodation型なら
            return nil
        }
      
        let reuseID = "marker"
       let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)

        if let anno = annotation as? CustomMKPointAnnotation{
            marker.markerTintColor = anno.markerColor
        }
        return marker
    }
    
    // ピンをタップした時の処理
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation {return} // 現在地マーカをタップしたら処理を抜ける
        
        let annotation = view.annotation
        
        let title = annotation!.title
        
        let location = annotation?.coordinate
        
        self.stationName = title!!
        
        self.location = location
        
        
        screenShift()
        
    }
    
   
    
    //MARK: - メソッド
    // 画面遷移に使う
    func screenShift () {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "detailVC")as! DetailViewController
        let navigationController = UINavigationController(rootViewController: detailVC)
        
        detailVC.stationName = stationName!
        detailVC.stationLocation = location
//        detailVC.roadStations = self.roadStations
        
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.present(navigationController, animated: true,completion: nil)
        
    }
    
    // 地図にピンで座標を追加
    func addAnnotation (latitude : CLLocationDegrees,// 緯度
                        longitude: CLLocationDegrees ,// 経度
                        title : String,
                        isStamp : Bool){
        mapView.delegate = self
        let annotation = CustomMKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = title
        
        switch isStamp {
        case true :
            annotation.markerColor = .red
        default :
            annotation.markerColor = .gray
        }
        
      
        self.mapView.addAnnotation(annotation)
    }//: addAnnotationメソッド

    
    @IBAction func locationBtnTapped(_ sender: UIButton) {
        print("位置情報切り替えボタン")
            
        if self.isUserLocation {// 位置情報が取得できたらuserlocationを画面中央に表示する機能
            mapView.setUserTrackingMode(.follow, animated: true)
        }else {// 位置情報が取得できなければアラートを介して設定アプリへの遷移
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            let alert = UIAlertController(title: "位置情報の設定をオンにします", message: nil, preferredStyle: .alert)
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
        }
      
    }
    
}//:ViewController

    

