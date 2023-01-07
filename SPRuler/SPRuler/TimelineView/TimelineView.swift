//
//  TimelineView.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class TimelineView: UIView {
    
    var rulerView = TimelineRuler()
    
    var minVal = 1669833000000.toSeconds()
    var defaultVal = 1669833180000.toSeconds()
    var maxVal = 1669833300000.toSeconds()
    
    let tickDuration:CGFloat = 6
    let lineSpacing: CGFloat = 20
    
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
        
        let rulerMetrics = SPRulerConfiguration.Metrics(
            minimumValue: self.minVal,
            defaultValue: self.defaultVal,
            maximumValue: self.maxVal,
            divisions: 10,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 22)
        rulerView.configuration = SPRulerConfiguration(scrollDirection: .horizontal, alignment: .end, lineSpacing: self.lineSpacing, metrics: rulerMetrics, isPrecisionScrollEnabled: false)
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
    
    func changeRange() {
        
        let min = self.minVal - 50
        let def = self.minVal
        let max = self.maxVal
        
        self.minVal = min
        
        let rulerMetrics = SPRulerConfiguration.Metrics(
            minimumValue: min,
            defaultValue: def,
            maximumValue: max,
            divisions: 10,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 22)
        rulerView.configuration.metrics = rulerMetrics
    }
}

extension TimelineView: SPRulerDelegate {
    func spRulerDidScroll(_ rulerScrollView: UIScrollView) {
        
        let centerX = rulerScrollView.frame.width / 2
        let x = (rulerScrollView.contentOffset.x + (centerX)) // / scale
        let timelineCellHalfWidth:CGFloat = (self.lineSpacing + 1) / 2
        let tickHalfDurationInSeconds = CGFloat(self.tickDuration) / CGFloat(2)
        let k = (timelineCellHalfWidth) / CGFloat(tickHalfDurationInSeconds)
        let secondsInt = Int(x/k)
        let miliSeconds = Int64(secondsInt).toMiliSeconds()
        let date = Int64(self.minVal.toMiliSeconds()) + miliSeconds
        currentTime.text = date.toDayTimelineCurrentTime()
    }
    
    func spRuler(_ ruler: SPRuler, didSelectItemAtIndex index: Int) {
        currentTime.text = spRuler(ruler, highlightTitleForIndex: index)
    }
}

extension TimelineView: SPRulerDataSource {
    func spRuler(_ ruler: SPRuler, titleForIndex index: Int) -> String? {
        guard index % ruler.configuration.metrics.divisions == 0 else { return nil }
        let tick = Int(self.tickDuration)
        let t = (index * tick + Int(minVal)).toMiliSeconds()
        let minSec = Int64(t).toMinutesSeconds()
        return minSec
    }
    
    func spRuler(_ ruler: SPRuler, highlightTitleForIndex index: Int) -> String? {
        if index % self.minVal == 0 {
            changeRange()
        }
        let tick = Int(self.tickDuration)
        let time = (index * tick + Int(minVal)).toMiliSeconds()
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
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    func toDay() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    func toYear() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    func toDayTimelineCurrentTime() -> String {
        var dateStr = ""
        let date = Date.init(milliseconds: self).toLocalTime()
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
        let date = Date.init(milliseconds: self).toLocalTime()
        let daySuffix = date.daySuffix()
        let day = self.toDay()
        dateStr = "\(day)\(daySuffix)"
        return dateStr
    }
    
    func toHoursMinutesSeconds() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss a"
        return formatter.string(from: date)
    }
    
    func toHoursMinutes() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func toDaysHoursMinutes() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd HH"
        return formatter.string(from: date)
    }
    
    func toMinutesSeconds() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
    
    func toSecondsString() -> String {
        let date = Date.init(milliseconds: self).toLocalTime()
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
