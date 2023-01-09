//
//  TimelineRuler.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

protocol TimelineRulerDataSource: SPRulerDataSource {
    func timeline(_ ruler: TimelineRuler, timelineData index: Int) -> TimelineData?
}

class TimelineRuler: SPRuler {
    
    weak var timelineDataSource: TimelineRulerDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    private func configureViews() {
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: TimelineCell.cellId)
        collectionView.backgroundColor = .black
        indicatorLabel.isHidden = true
        indicatorLabelGradientView.isHidden = true
        indicatorLine.isHidden = true
    }
    
    func setupRuler(minimumValue: Int,
                    defaultValue: Int,
                    maximumValue: Int,
                    divisions: Int,
                    lineSpacing: CGFloat) {
        let rulerMetrics = SPRulerConfiguration.Metrics(
            minimumValue: minimumValue,
            defaultValue: defaultValue,
            maximumValue: maximumValue,
            divisions: divisions,
            fullLineSize: 40,
            midLineSize: 32,
            smallLineSize: 22)
        configuration = SPRulerConfiguration(scrollDirection: .horizontal, alignment: .end, lineSpacing: lineSpacing, metrics: rulerMetrics, isPrecisionScrollEnabled: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = configuration.metrics.maximumValue - configuration.metrics.minimumValue
        return (count) + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimelineCell.cellId, for: indexPath) as! TimelineCell // swiftlint:disable:this force_cast
        let timelineData = timelineDataSource?.timeline(self, timelineData: indexPath.row)
        let timelineCellSetup: TimelineCellSetup = (font: font, timelineData: timelineData)
        cell.timelineRulerCellSetup(indexPath.row, using: configuration, timelineCellSetup: timelineCellSetup)
        return cell
    }
}

struct TimelineData: Codable {
    let time: Int
    let startTime: Int
    let title: String
}
