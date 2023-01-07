//
//  ViewController.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class ViewController: UIViewController {
    
    var currentValueLabel = UILabel()
    var rulerView = SPRuler()
    
    var minVal = 900
    var defaultVal = 950
    var maxVal = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(currentValueLabel)
        currentValueLabel.translatesAutoresizingMaskIntoConstraints = false
        currentValueLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            currentValueLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            currentValueLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            currentValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            currentValueLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        setupRuler()
    }
    
    
    func setupRuler() {
        view.addSubview(rulerView)
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rulerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            rulerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            rulerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            rulerView.heightAnchor.constraint(equalToConstant: 100)
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
        rulerView.configuration = SPRulerConfiguration(scrollDirection: .horizontal, alignment: .end, metrics: rulerMetrics)
        rulerView.font = UIFont(name: "AmericanTypewriter-Bold", size: 12)!
        rulerView.highlightFont = UIFont(name: "AmericanTypewriter-Bold", size: 18)!
        rulerView.dataSource = self
        rulerView.delegate = self
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

extension ViewController: SPRulerDelegate {
    func spRuler(_ ruler: SPRuler, didSelectItemAtIndex index: Int) {
        currentValueLabel.text = spRuler(ruler, highlightTitleForIndex: index)
    }
}

extension ViewController: SPRulerDataSource {
    func spRuler(_ ruler: SPRuler, titleForIndex index: Int) -> String? {
        guard index % ruler.configuration.metrics.divisions == 0 else { return nil }
        return "\(ruler.configuration.metrics.minimumValue + index)"
        
    }
    
    func spRuler(_ ruler: SPRuler, highlightTitleForIndex index: Int) -> String? {
        
        if index % self.minVal == 0 {
            changeRange()
        }
        
        let text = "\(ruler.configuration.metrics.minimumValue + index)"
        currentValueLabel.text = text
        return text
    }
}
