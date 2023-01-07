//
//  ViewController.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class ViewController: UIViewController {
    
    var timelineView = TimelineView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimelineView()
    }
    
    func setupTimelineView() {
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
    
}
