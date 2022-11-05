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
    
    @IBOutlet var mapTypeBtn: UIButton!
    //userdefaultsから読み込んだ配列を格納する変数
    var stations : [RoadStation] = []
    
    
   
    
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
 
    // ユーザピンを格納した変数
    var userPinView : MKAnnotationView!
   
      //MARK: - Viewの表示時の処理
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    
        
        //userdefaults 配列呼び出し
        if let unwrapedStations = loadStationsArray(){ //UserDefaultsにデータがあれば（nilでないとき）
            saveStationsArray(stations: unwrapedStations)
            stations = unwrapedStations
        }else{ //nilの場合の処理
            saveStationsArray(stations: stationsList)
            self.stations = stationsList
        }
        
        print("\(stations.filter{$0.area == "hokuriku"}.filter{$0.isStamp == true}.count) / \(stations.filter{$0.area == "hokuriku"}.count)")
        

        
        // マネージャーの初期化
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        // アプリの使用中のみ位置情報サービスの利用許可を求める
        myLocationManager.requestWhenInUseAuthorization()
        
       
        // 位置情報マーカーを表示
        mapView.showsUserLocation  = true
        
        
        if CLLocationManager.locationServicesEnabled() {
            print("せいこうしました")
            myLocationManager.startUpdatingHeading()
            myLocationManager.startUpdatingLocation()
        }
        
                // 現在地を画面中央にする
        mapView.userTrackingMode = .follow

       
        
        achievementLabel.layer.cornerRadius = 10
        achievementLabel.clipsToBounds = true
        
        
        
 
       
    }//:viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
       
        // addAnnotationメソッドを使って追加することでピンで表示される
        guard let unwrapedStations = loadStationsArray() else {return}
            for station in unwrapedStations {
                addAnnotation(latitude: station.latitude, longitude: station.longitude, title: station.name,isStamp: station.isStamp)
            }
        

        
       
        

        let filterdArray = unwrapedStations.filter{$0.isStamp == true}
        
        achievementLabel.text = "\(filterdArray.count) / \(unwrapedStations.count)"
        
        print("ViewController.viewWillAppear")
        
        super.viewWillAppear(animated)
    }
    
   
    

    

    //MARK: - デリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last?.coordinate != nil {// 現在地が取得できたら
            self.isUserLocation = true
        }
        
        self.userLocation = locations.last?.coordinate
        
    }
    
    //位置情報が取得できなかった時の処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.isUserLocation = false
    }
    
    //方角取得
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //ユーザの向きを格納する定数
        let userHeading : CLLocationDirection = newHeading.magneticHeading
        // 地図の回転角度を格納する定数
        let mapHeading : CLLocationDirection = mapView.camera.heading
        // ピンの角度を取得して格納する変数
        var pinHeading : CLLocationDirection = 0
        
        if userHeading < mapHeading {
            pinHeading = (userHeading + 360) - mapHeading
        }else {
            pinHeading = userHeading - mapHeading
        }
        if mapView.userTrackingMode != .followWithHeading {// トラッキングモードが.followWithHeadingではないとき
            userPinView?.transform = CGAffineTransform(rotationAngle: pinHeading * Double.pi / 180)
        }else {
            userPinView?.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "userPinImage.png")
            userPinView = pin
            return pin
        }else {
            let reuseID = "marker"
            let marker = MKMarkerAnnotationView(annotation: annotation,
                                                reuseIdentifier: reuseID)

            if let anno = annotation as? CustomMKPointAnnotation{
                marker.markerTintColor = anno.markerColor
            }
            return marker
        }
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
            switch mapView.userTrackingMode {
            case .none :
                locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
                mapView.setUserTrackingMode(.follow, animated: true)
            case .follow :
                locationButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
                mapView.setUserTrackingMode(.followWithHeading, animated: true)
            default :
                locationButton.setImage(UIImage(systemName: "location"), for: .normal)
                mapView.setUserTrackingMode(.none, animated: true)
            }
            //MARK: UIButtonのイメージ切り替えうまくいかず
            // スワイプでモード切り替えしたときにイメージを切り替えるにはどうしたらいいのか
        }else {// 位置情報が取得できなければアラートを介して設定アプリへの遷移
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
      
    }
    
    
    @IBAction func mapTypeBtnTapped(_ sender: UIButton) {
        print("地図タイプ変更ダイアログ表示")
        
        let actionSheet = UIAlertController(title: "地図タイプの変更", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "標準", style: .default) { action in
            print("標準")
            // 非推奨
//            self.mapView.mapType = MKMapType.standard
            self.mapView.preferredConfiguration = MKStandardMapConfiguration()
            
            
        }
        let action2 = UIAlertAction(title: "航空写真", style: .default) { action in
            print("ハイブリッド")
            // 非推奨
//            self.mapView.mapType = MKMapType.hybrid
            self.mapView.preferredConfiguration = MKHybridMapConfiguration()
            
        }
        let close = UIAlertAction(title: "閉じる", style: .destructive) { action in
            print("閉じる")
        }
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(close)
        
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    
}//:ViewController

    

