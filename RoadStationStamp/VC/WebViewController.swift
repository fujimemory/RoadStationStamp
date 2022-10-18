//
//  WebViewController.swift
//  RoadStationStamp
//
//  Created by 藤森太暉 on 2022/08/28.
//

import UIKit
import WebKit

class WebViewController: UIViewController,WKNavigationDelegate{
    
    // 詳細画面からurlを受け取る
    var urlStr : String?
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var myToolBar: UIToolbar!
    
    var progressView = UIProgressView()
    
   
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        
        //監視の設定
              self.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
              self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

              //プログレスバーを生成(NavigationBar下)
              progressView = UIProgressView(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.size.height - 2, width: self.view.frame.size.width, height: 10))
              progressView.progressViewStyle = .bar

        self.navigationController?.navigationBar.addSubview(progressView)
        
        load()
        
        // ナビゲーションバーのタイトル指定
        navigationItem.title = urlStr!
        
        // navigationbarスワイプで非表示
//        navigationController?.hidesBarsOnSwipe = true
        
        // ツールバーの高さを端末によって指定
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
               //iPhone X 以降で、以下のコードが実行されます
        if height > 800.0 && height < 1000.0{
            myToolBar.frame = CGRect(x: 0, y: height * 0.92, width: width, height: height * 0.055)
        }
        
       
    }//: viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func load() {
        guard let unwrapedURLStr = urlStr else {return}
        
        if let url = URL(string: unwrapedURLStr){
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // プログレスビュー関連
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
           if keyPath == "estimatedProgress"{
               //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
               self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
           }else if keyPath == "loading"{
               //非推奨につきコメントアウト
//               UIApplication.shared.isNetworkActivityIndicatorVisible = self.webView.isLoading
               if self.webView.isLoading {
                   self.progressView.setProgress(0.1, animated: true)
               }else{
                   //読み込みが終わったら0に
                   self.progressView.setProgress(0.0, animated: false)
               }
           }
       }
    
    // プログレスビュー関連
    deinit{
            //監視の解除
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
            self.webView.removeObserver(self, forKeyPath: "loading")
        }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let e = error as NSError
        
        print("didFail : \(e)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         let e = error as NSError
        
         print("didFailProvisionalNavigation:\(e)")

//         if e.code == -1009 {
//             print("NotConnectedToInternet")
//         }
     }
    
    // window.alert()
     func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
     }

     // window.confirm()
     func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

     }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
       guard let url = navigationAction.request.url else {
         return nil
       }
       guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
         webView.load(URLRequest(url: url))
         return nil
       }
       return nil
     }
    
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forwardBtn(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    
    @IBAction func reloadBtn(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func goSafariBtn(_ sender: UIBarButtonItem) {
        //safariに遷移
        print("safari起動")
        
        guard let unwrapedURLStr = urlStr else {return}
        
        if let url = URL(string: unwrapedURLStr){
            UIApplication.shared.open(url)
        }
    }
    
    
    
   

}
