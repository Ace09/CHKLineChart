//
//  ViewController.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet var chartView: CHKLineChartView!
    
    var klineDatas = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartView.delegate = self
        self.chartView.style = CHKLineChartStyle.Default
        self.getDataByFile()
//        self.getRemoteServiceData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getRemoteServiceData() {
        // 快捷方式获得session对象
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: "https://www.btc123.com/kline/klineapi?symbol=chbtcbtccny&type=1min&size=300")
        // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
        let task = session.dataTaskWithURL(url!) {
            (data, response, error) in
            if let data = data {
                /*
                 对从服务器获取到的数据data进行相应的处理.
                 */
                do {
                    NSLog("\(NSString(data: data, encoding: NSUTF8StringEncoding))")
                    let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as! [String: AnyObject]
                    
                    let isSuc = dict["isSuc"] as? Bool ?? false
                    if isSuc {
                        let datas = dict["datas"] as! [AnyObject]
                        NSLog("chart.datas = \(datas.count)")
                        self.klineDatas = datas
                        self.chartView.reloadData()
                    }
                    
                } catch _ {
                    
                }
                
            }
        }
        
        // 启动任务
        task.resume()
    }
    
    func getDataByFile() {
        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("data", ofType: "json")!)
        let dict = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! [String: AnyObject]
        
        let isSuc = dict["isSuc"] as? Bool ?? false
        if isSuc {
            let datas = dict["datas"] as! [AnyObject]
            NSLog("chart.datas = \(datas.count)")
            self.klineDatas = datas
            self.chartView.reloadData()
        }
    }

}

extension DemoViewController: CHKLineChartDelegate {
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.klineDatas.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.klineDatas[index] as! [Double]
        let item = CHChartItem()
        item.time = Int(data[0] / 1000)
        item.openPrice = CGFloat(data[1])
        item.highPrice = CGFloat(data[2])
        item.lowPrice = CGFloat(data[3])
        item.closePrice = CGFloat(data[4])
        item.vol = CGFloat(data[5])
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineDatas[index] as! [Double]
        let timestamp = Int(data[0])
        return NSDate.getTimeByStamp(timestamp, format: "HH:mm")
    }
    

    
}


// MARK: - 竖屏切换重载方法实现
extension DemoViewController {
    
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        self.chartView.reloadData()
    }
    
}