//
//  ViewController.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class ViewController: UIViewController {
    

    
    var timelineSpan: TimelineSpan = .minutes
    var currentTime: Int64 = 0
    var button: UIButton!
    
    var timelineView: TimelineView!
    var startTime = 1672338600000
    var endTime = 1672349400000
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle("Mins", for: .normal)
        button.addTarget(self, action: #selector(didChangeSpan), for: .touchUpInside)
        let b = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = b
        
        setupTimelineView()
    }
    
    func setupTimelineView() {
        self.timelineView = TimelineView(startTime: startTime, endTime: endTime, timelineSpan: self.timelineSpan)
        self.timelineView.currentTime = { [weak self] ct in
            self?.currentTime = ct
        }
        view.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.layer.cornerRadius = 12
        timelineView.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            timelineView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            timelineView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            timelineView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            timelineView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func addTimelineView() {
        self.timelineView = TimelineView(startTime: startTime, endTime: endTime, timelineSpan: self.timelineSpan)
        self.timelineView.currentTime = { [weak self] ct in
            self?.currentTime = ct
        }
        view.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.layer.cornerRadius = 12
        timelineView.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            timelineView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            timelineView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            timelineView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            timelineView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func removeTimelineView() {
        self.timelineView.clearConstraints()
        self.timelineView.removeFromSuperview()
        self.timelineView = nil
    }
    
    @objc func didChangeSpan() {
        
        removeTimelineView()
        
        switch timelineSpan {
        case .seconds:
            self.timelineSpan = .minutes
            button.setTitle("Mins", for: .normal)
            
            var currTime = self.currentTime
            let offsetSeconds = currTime.getSecondFromDate()
            currTime -= offsetSeconds.toMiliSeconds()
            
            let start = currTime //- Int64(3 * Int(secondsInAnHour)).toMiliSeconds()
            let end = currTime + Int64(3 * Int(secondsInAnHour)).toMiliSeconds()
            
            self.startTime = Int(start)
            self.endTime = Int(end)
            addTimelineView()
            
        case .minutes:
            self.timelineSpan = .days
            button.setTitle("Days", for: .normal)
            
            var currTime = self.currentTime
            let offsetSeconds = currTime.getSecondFromDate()
            let offsetMinutes = (currTime.getMinuteFromDate() * secondsInAMinute)
            let offsetHours = (currTime.getHourFromDate() * secondsInAnHour)
            currTime -= offsetSeconds.toMiliSeconds()
            currTime -= offsetMinutes.toMiliSeconds()
            currTime -= offsetHours.toMiliSeconds()
            
            let start = currTime //- Int64(30 * Int(secondsInADay)).toMiliSeconds()
            let end = currTime + Int64(30 * Int(secondsInADay)).toMiliSeconds()
            
            self.startTime = Int(start)
            self.endTime = Int(end)
            addTimelineView()
            
        case .days:
            self.timelineSpan = .seconds
            button.setTitle("Sec", for: .normal)
           
            let currTime = self.currentTime
            let start = currTime //- Int64(30 * Int(secondsInAMinute)).toMiliSeconds()
            let end = currTime + Int64(30 * Int(secondsInAMinute)).toMiliSeconds()
            
            self.startTime = Int(start)
            self.endTime = Int(end)
            addTimelineView()
        }
    }
    
}

extension UIView {
    func clearConstraints() {
        for subview in self.subviews {
            subview.clearConstraints()
        }
        self.removeConstraints(self.constraints)
    }
}
