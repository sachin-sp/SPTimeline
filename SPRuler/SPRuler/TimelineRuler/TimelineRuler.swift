//
//  TimelineRuler.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class TimelineRuler: SPRuler {
    
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
    
    func setupRuler(minValue: Int, defaultValue: Int, maxValue: Int, lineSpacing: CGFloat) {
        let rulerMetrics = SPRulerConfiguration.Metrics(
            minimumValue: minValue,
            defaultValue: defaultValue,
            maximumValue: maxValue,
            divisions: 12,
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
        let text = dataSource?.spRuler(self, titleForIndex: indexPath.row)
        let rulerLineNumberSetup: RulerLineNumberSetup = (font: font, text: text)
        cell.configure(indexPath.row,
                       using: configuration,
                       rulerLineNumberSetup: rulerLineNumberSetup)
        return cell
    }
}
