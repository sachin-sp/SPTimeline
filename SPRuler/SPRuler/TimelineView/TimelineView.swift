//
//  TimelineView.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

let secondsInADay: Int64 = 86400
let secondsInAnHour: Int64 = 3600
let secondsInAMinute: Int64 = 60
let hoursInADay: Int64 = 24
let minutesInAnHour: Int64 = 60

class TimelineView: UIView {
    
    var rulerView = TimelineRuler()
    
    var startTime = 1669833000000
    var endTime = 1671474600000
    
    var tickDuration:CGFloat = 7200
    var lineSpacing: CGFloat = 20
    
    var minValue = 0
    var defaultValue = 0
    var maxValue = 0
    
    private lazy var centerLineIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.borderWidth = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var currentTime: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    private func configureViews() {
        setupCurrentTimeLabel()
        setupRuler()
        setupCenterLineIndicatorLabel()
    }
    
    func setupCurrentTimeLabel() {
        addSubview(currentTime)
        
        NSLayoutConstraint.activate([
            currentTime.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            currentTime.leftAnchor.constraint(equalTo: leftAnchor),
            currentTime.rightAnchor.constraint(equalTo: rightAnchor),
            currentTime.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func setupRuler() {
        addSubview(rulerView)
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rulerView.topAnchor.constraint(equalTo: currentTime.bottomAnchor, constant: 10),
            rulerView.leftAnchor.constraint(equalTo: leftAnchor),
            rulerView.rightAnchor.constraint(equalTo: rightAnchor),
            rulerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        rulerView.layoutIfNeeded()
        configureDaysTimeline()
        
        rulerView.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
        rulerView.highlightFont = UIFont(name: "AmericanTypewriter-Bold", size: 18)!
        rulerView.dataSource = self
        rulerView.delegate = self
    }
    
    func setupCenterLineIndicatorLabel() {
        addSubview(centerLineIndicator)
        
        NSLayoutConstraint.activate([
            centerLineIndicator.centerXAnchor.constraint(equalTo: rulerView.centerXAnchor, constant: 0),
            centerLineIndicator.centerYAnchor.constraint(equalTo: rulerView.centerYAnchor, constant: 5),
            centerLineIndicator.heightAnchor.constraint(equalToConstant: 40),
            centerLineIndicator.widthAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    func configureDaysTimeline() {
        let startDate = Date.init(milliseconds: Int64(self.startTime)).toLocalTime()
        let endDate = Date.init(milliseconds: Int64(self.endTime)).toLocalTime()
        let elapsed = endDate.timeIntervalSince(startDate)
        let tick = Int(self.tickDuration)
        self.maxValue = Int(Int(elapsed) / tick)
        self.defaultValue = (self.maxValue / 2)
        self.minValue = 0
        rulerView.setupRuler(minValue: self.minValue, defaultValue: self.defaultValue, maxValue: self.maxValue, lineSpacing: self.lineSpacing)
    }
    
    func pagingateDaysForward() {
        self.defaultValue = self.maxValue
        
        let e = self.endTime + (20 * Int(secondsInADay)).toMiliSeconds()
        self.endTime = e
        
        let startDate = Date.init(milliseconds: Int64(self.startTime)).toLocalTime()
        let endDate = Date.init(milliseconds: Int64(self.endTime)).toLocalTime()
        let elapsed = endDate.timeIntervalSince(startDate)
        let tick = Int(self.tickDuration)
        self.maxValue = Int(Int(elapsed) / tick)
        
        rulerView.setupRuler(minValue: self.minValue, defaultValue: self.defaultValue, maxValue: self.maxValue, lineSpacing: self.lineSpacing)
    }
    
    func paginateDaysReverse() {
        self.defaultValue = (self.maxValue / 2) + 6
        
        let s = self.startTime - (20 * Int(secondsInADay)).toMiliSeconds()
        self.startTime = s
        
        let startDate = Date.init(milliseconds: Int64(self.startTime)).toLocalTime()
        let endDate = Date.init(milliseconds: Int64(self.endTime)).toLocalTime()
        let elapsed = endDate.timeIntervalSince(startDate)
        let tick = Int(self.tickDuration)
        self.maxValue = Int(Int(elapsed) / tick)
        
        rulerView.setupRuler(minValue: self.minValue, defaultValue: self.defaultValue, maxValue: self.maxValue, lineSpacing: self.lineSpacing)
    }
}

extension TimelineView: SPRulerDelegate {
    func spRulerDidScroll(_ rulerScrollView: UIScrollView) {
        
        let offset = rulerScrollView.contentOffset
        let contentInset = rulerScrollView.contentInset
        let index: Int
        let itemsCount = self.rulerView.collectionView.numberOfItems(inSection: 0) - 1
        if self.rulerView.configuration.isHorizontal {
            let roundedIndex = round((offset.x + contentInset.left) / (lineSpacing + 1))
            index = max(0, min(itemsCount, Int(roundedIndex)))
        } else {
            let roundedIndex = round((offset.y + contentInset.top) / (lineSpacing + 1))
            index = max(0, min(itemsCount, Int(roundedIndex)))
        }
        
        if index == self.rulerView.configuration.metrics.maximumValue {
            pagingateDaysForward()
        }
        if index == self.rulerView.configuration.metrics.minimumValue {
            paginateDaysReverse()
        }
        
        let centerX = rulerScrollView.frame.width / 2
        let x = (rulerScrollView.contentOffset.x + (centerX)) // / scale
        let timelineCellHalfWidth:CGFloat = (self.lineSpacing + 1) / 2
        let tickHalfDurationInSeconds = CGFloat(self.tickDuration) / CGFloat(2)
        let k = (timelineCellHalfWidth) / CGFloat(tickHalfDurationInSeconds)
        let secondsInt = Int(x/k)
        let miliSeconds = Int64(secondsInt).toMiliSeconds()
        let date = Int64(self.startTime) + miliSeconds
        currentTime.text = date.toDayTimelineCurrentTime()
    }
    
    func spRuler(_ ruler: SPRuler, didSelectItemAtIndex index: Int) {
        currentTime.text = spRuler(ruler, highlightTitleForIndex: index)
    }
}

extension TimelineView: SPRulerDataSource {
    func spRuler(_ ruler: SPRuler, titleForIndex index: Int) -> String? {
        guard index % ruler.configuration.metrics.divisions == 0 else { return nil }
        let tick = Int(self.tickDuration).toMiliSeconds()
        let time = (index * tick + Int(self.startTime))
        let minSec = Int64(time).toDayTimelineDay()
        return minSec
    }
    
    func spRuler(_ ruler: SPRuler, highlightTitleForIndex index: Int) -> String? {
        let tick = Int(self.tickDuration)
        let time = (index * tick + Int(self.startTime)).toMiliSeconds()
        let minSec = Int64(time).toDayTimelineCurrentTime()
        let text = minSec
        currentTime.text = text
        return text
    }
}

extension Int {
    
    func toMiliSeconds() -> Int {
        self * 1000
    }
    
    func toSeconds() -> Int {
        self / 1000
    }
    
    func toInt64() -> Int64 {
        return Int64(self)
    }

}

extension Int64 {
    
    func toMonth() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    func toDay() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    func toYear() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    func toDayTimelineCurrentTime() -> String {
        var dateStr = ""
        let date = Date.init(milliseconds: self)
        let daySuffix = date.daySuffix()
        
        let month = self.toMonth()
        let day = self.toDay()
        let year = self.toYear()
        let hoursMinutesSecons = self.toHoursMinutesSeconds()
        
        dateStr = "\(month) \(day)\(daySuffix) \(year) - \(hoursMinutesSecons)"
        
        return dateStr
    }
    
    func toDayTimelineDay() -> String {
        var dateStr = ""
        let date = Date.init(milliseconds: self)
        let daySuffix = date.daySuffix()
        let day = self.toDay()
        dateStr = "\(day)\(daySuffix)"
        return dateStr
    }
    
    func toHoursMinutesSeconds() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss a"
        return formatter.string(from: date)
    }
    
    func toHoursMinutes() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func toDaysHoursMinutes() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd HH"
        return formatter.string(from: date)
    }
    
    func toMinutesSeconds() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
    
    func toSecondsString() -> String {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "ss"
        return formatter.string(from: date)
    }
    
    func toMiliSeconds() -> Int64 {
        self * 1000
    }
    
    func toSeconds() -> Int64 {
        self / 1000
    }
    
    func toInt() -> Int {
        return Int(self)
    }

}

extension Int64 {
    func getSecondFromDate() -> Int64 {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "ss"
        let dateStr = formatter.string(from: date)
        return Int64(dateStr) ?? 0
    }
    func getMinuteFromDate() -> Int64 {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "mm"
        let dateStr = formatter.string(from: date)
        return Int64(dateStr) ?? 0
    }
    func getHourFromDate() -> Int64 {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH"
        let dateStr = formatter.string(from: date)
        return Int64(dateStr) ?? 0
    }
    func getDayFromDate() -> Int64 {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd"
        let dateStr = formatter.string(from: date)
        return Int64(dateStr) ?? 0
    }
    func getYearFromDate() -> Int64 {
        let date = Date.init(milliseconds: self)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy"
        let dateStr = formatter.string(from: date)
        return Int64(dateStr) ?? 0
    }
}

extension Date {
    
    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

// MARK: UTC(GMT) to Local & Local to UTC(GMT)
extension Date {

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
