//
//  CHSection.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 16/8/31.
//  Copyright © 2016年 bitbank. All rights reserved.
//

import UIKit

/**
 *  K线的区域
 */
class CHSection: NSObject {
    
    /// MARK: - 成员变量
    var upColor: UIColor = UIColor.greenColor()     //升的颜色
    var downColor: UIColor = UIColor.redColor()     //跌的颜色
    
    var name: String = ""                           //区域的名称
    var hidden: Bool = false
    var isInitialized: Bool = false
    var paging: Bool = false
    var selectedIndex: Int = 0
    var padding: UIEdgeInsets = UIEdgeInsetsZero
    var series = [[CHChartModel]]()                  //每个分区包含多组系列，每个系列包含多个点线模型
    var tickInterval: Int = 0
    var title: String = ""                                      //标题
    var titleShowOutSide: Bool = false                          //标题是否显示在外面
    var decimal: Int = 0                                        //小数位的长度
    var ratios: Int = 1                                         //所占区域比例
    var frame: CGRect = CGRectZero
    var yAxis: CHYAxis = CHYAxis()                           //Y轴参数
    
    
    /**
     建立Y轴左边对象，由起始位到结束位
     */
    func buildYAxis(datas: [CHChartItem], startIndex: Int, endIndex: Int) {
        
        if datas.count == 0 {
            return  //没有数据返回
        }
        
        self.yAxis.decimal = self.decimal
        
        let fisrtItem = datas[0]
        self.yAxis.max = fisrtItem.highPrice
        self.yAxis.min = fisrtItem.lowPrice
        
        for _ in startIndex.stride(to: endIndex, by: 1) {
            let item = datas[startIndex]
            let high = item.highPrice
            let low = item.lowPrice
            
            //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
            if high > self.yAxis.max {
                self.yAxis.max = high
            }
            if low < self.yAxis.min {
                self.yAxis.min = low
            }
        }
        
        //让边界溢出些，这样图表不会占满屏幕
        self.yAxis.max += (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        self.yAxis.min -= (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        
        if !self.yAxis.baseValueSticky {        //不使用固定基值
            if self.yAxis.max >= 0 && self.yAxis.min >= 0 {
                self.yAxis.baseValue = self.yAxis.min;
            } else if self.yAxis.max < 0 && self.yAxis.min < 0 {
                self.yAxis.baseValue = self.yAxis.max;
            } else {
                self.yAxis.baseValue = 0;
            }
        } else {                                //使用固定基值
            if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min = self.yAxis.baseValue
            }
            
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue
            }
        }
        
        //如果使用水平对称显示y轴，基本基值计算上下的边界值
        if self.yAxis.symmetrical {
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
            } else if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min =  self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
            } else {
                if (self.yAxis.max - self.yAxis.baseValue) > (self.yAxis.baseValue - self.yAxis.min) {
                    self.yAxis.min = self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
                } else {
                    self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
                }
            }
        }
    }
    
    /**
     获取y轴上标签数值对应在坐标系中的y值
     
     - parameter val: 标签值
     
     - returns: 坐标系中实际的y值
     */
    func getLocalY(val: CGFloat) -> CGFloat {
        let max = self.yAxis.max;
        let min = self.yAxis.min;
        
        if (max == min) {
            return 0
        }
        
        /*
         计算公式：
         y轴有值的区间高度 = 整个分区高度-（paddingTop+paddingBottom）
         当前y值所在位置的比例 =（当前值 - y最小值）/（y最大值 - y最小值）
         当前y值的实际的相对y轴有值的区间的高度 = 当前y值所在位置的比例 * y轴有值的区间高度
         当前y值的实际坐标 = 分区高度 + 分区y坐标 - paddingBottom - 当前y值的实际的相对y轴有值的区间的高度
         */
        let baseY = self.frame.size.height + self.frame.origin.y - self.padding.bottom - (self.frame.size.height - self.padding.top - self.padding.bottom) * (val - min) / (max - min)
        return baseY;
    }
}
