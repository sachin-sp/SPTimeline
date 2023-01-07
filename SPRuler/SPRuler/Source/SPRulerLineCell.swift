//
//  SPRulerLineCell.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

typealias RulerLineNumberSetup = (font: UIFont?, text: String?)
class SPRulerLineCell: UICollectionViewCell {
    
    static let identifier = String(describing: SPRulerLineCell.self)
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = tintColor
        return view
    }()
    
    private lazy var numberLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = tintColor
        lable.textAlignment = .center
        return lable
    }()
    
    override var tintColor: UIColor! {
        didSet {
            numberLabel.textColor = tintColor
            lineView.backgroundColor = tintColor
        }
    }
    
    var lineHeight: LineHeight = .full
    
    var config: SPRulerConfiguration = .default
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func initialSetup() {
        clipsToBounds = false
        addSubview(lineView)
        addSubview(numberLabel)
    }
    
    private func updateHeight(for type: LineHeight, config: SPRulerConfiguration) {
        var origin: CGPoint
        var size: CGSize
        size = .init(width: bounds.width, height: config.metrics.value(for: type))
        switch config.alignment {
        case .start:
            origin = .zero
        case .end:
            origin = .init(x: 0, y: bounds.height - size.height)
        }
        if !config.isHorizontal {
            origin = .zero
            size = .init(width: config.metrics.value(for: type), height: bounds.height)
        }
        lineView.frame = .init(origin: origin, size: size)
    }
    
    func configure(_ index: Int, using config: SPRulerConfiguration, rulerLineNumberSetup: RulerLineNumberSetup) {
        setupLineNumber(rulerLineNumberSetup: rulerLineNumberSetup)
        lineHeight = LineHeight(index: index, divisions: config.metrics.divisions, midDivision: config.metrics.midDivision)
        updateHeight(for: lineHeight, config: config)
        
        numberLabel.sizeToFit()

        if config.isHorizontal {
            numberLabel.center.x = lineView.center.x
            switch config.alignment {
            case .start:
                numberLabel.frame.origin.y = lineView.frame.origin.y + lineView.frame.size.height + config.lineAndLabelSpacing
            case .end:
                numberLabel.frame.origin.y = bounds.height - lineView.frame.size.height - config.lineAndLabelSpacing - numberLabel.frame.size.height
            }
        } else {
            numberLabel.center.y = lineView.center.y
            numberLabel.frame.origin.x = config.metrics.fullLineSize + config.lineAndLabelSpacing
        }
    }
    
    private func setupLineNumber(rulerLineNumberSetup: RulerLineNumberSetup) {
        numberLabel.font = rulerLineNumberSetup.font
        numberLabel.text = rulerLineNumberSetup.text
    }
}
