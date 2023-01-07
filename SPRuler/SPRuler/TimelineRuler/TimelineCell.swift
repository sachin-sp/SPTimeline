//
//  TimelineCell.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//

import UIKit

class TimelineCell: SPRulerLineCell {
    
    static var cellId: String {
        return String(describing: self)
    }
    
    private lazy var lineView: UIImageView = {
        let lv = UIImageView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.image = UIImage(named: "ic_vertical_line")
        return lv
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var eventView: UIView = {
        let lv = UIView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.backgroundColor = .white
        lv.layer.cornerRadius = 3
        lv.isHidden = true
        return lv
    }()
    
    private var grayBackgroundView: UIView = {
        let lv = UIView(frame: .zero)
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.backgroundColor = .clear
        return lv
    }()
    
    private var lvTopConstraint: NSLayoutConstraint!
    private var lvBottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(timeLabel)
        addSubview(lineView)
        addSubview(eventView)
        addSubview(grayBackgroundView)
        
        
        self.timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        self.timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        self.timeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        self.lvTopConstraint = lineView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4)
        self.lvBottomConstraint  = lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        self.lineView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        self.lineView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        
        self.lvTopConstraint.isActive = true
        self.lvBottomConstraint.isActive = true
        
        self.eventView.widthAnchor.constraint(equalToConstant: 6).isActive = true
        self.eventView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        self.eventView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        self.eventView.leftAnchor.constraint(equalTo: lineView.rightAnchor, constant: 0).isActive = true
        
        self.grayBackgroundView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4).isActive = true
        self.grayBackgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        self.grayBackgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        self.grayBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        sendSubviewToBack(self.grayBackgroundView)
        
    }
    
    override func configure(_ index: Int, using config: SPRulerConfiguration, rulerLineNumberSetup: RulerLineNumberSetup) {
        setupLineNumber(rulerLineNumberSetup: rulerLineNumberSetup)
        lineHeight = LineHeight(index: index, divisions: config.metrics.divisions, midDivision: config.metrics.midDivision)
        updateHeight(for: lineHeight, config: config)
    }
    
    private func setupLineNumber(rulerLineNumberSetup: RulerLineNumberSetup) {
        timeLabel.font = rulerLineNumberSetup.font
        timeLabel.text = rulerLineNumberSetup.text
    }
    
    private func updateHeight(for type: LineHeight, config: SPRulerConfiguration) {
        switch type {
        case .small:
            lvTopConstraint.constant = 4 + 3
            lvBottomConstraint.constant = -3
        case .mid:
            lvTopConstraint.constant = 4 + 3
            lvBottomConstraint.constant = -3
        case .full:
            lvTopConstraint.constant = 4
            lvBottomConstraint.constant = 0
        }
    }
}
