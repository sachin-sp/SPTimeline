//
//  SPRuler.swift
//  SPRuler
//
//  Created by Sachin Pampannavar on 07/01/23.
//  Copyright © 2023 Sachin Pampannavar. All rights reserved.
//

import UIKit

public protocol SPRulerDataSource: AnyObject {
    func spRuler(_ ruler: SPRuler, titleForIndex index: Int) -> String?
    func spRuler(_ ruler: SPRuler, highlightTitleForIndex index: Int) -> String?
}

public protocol SPRulerDelegate: AnyObject {
    func spRuler(_ ruler: SPRuler, didSelectItemAtIndex index: Int)
    func spRulerDidScroll(_ rulerScrollView: UIScrollView)
}

public struct SPRulerConfiguration {
    
    public enum Direction {
        case horizontal, vertical
    }
    
    public enum Alignment {
        case start, end
    }
    
    public struct Metrics {
        
        public var minimumValue: Int = 10
        public var defaultValue: Int = 55 {
            didSet {
                defaultValue = max(maximumValue, min(defaultValue, minimumValue))
            }
        }
        public var maximumValue: Int = 150
        public var divisions = 10
        
        public var fullLineSize: CGFloat = 40
        public var midLineSize: CGFloat = 28
        public var smallLineSize: CGFloat = 18
        
        var midDivision: Int {
            divisions / 2
        }
       
        public init(minimumValue: Int = 10, defaultValue: Int = 55, maximumValue: Int = 150, divisions: Int = 10, fullLineSize: CGFloat = 40, midLineSize: CGFloat = 28, smallLineSize: CGFloat = 18) {
            self.minimumValue = minimumValue
            self.defaultValue = defaultValue
            self.maximumValue = maximumValue
            self.divisions = divisions
            self.fullLineSize = fullLineSize
            self.midLineSize = midLineSize
            self.smallLineSize = smallLineSize
        }
        
        func value(for type: LineHeight) -> CGFloat {
            switch type {
            case .full: return fullLineSize
            case .mid: return midLineSize
            case .small: return smallLineSize
            }
        }
        
        func lineType(index: Int) -> LineHeight {
            if index % divisions == 0 {
                return .full
            } else if index % midDivision == 0 {
                return .mid
            } else {
                return .small
            }
        }
        
        public static var `default`: Metrics { Metrics() }
        
    }
    
    public var scrollDirection: Direction = .horizontal
    public var alignment: Alignment = .end
    public var lineSpacing: CGFloat = 10
    public var lineAndLabelSpacing: CGFloat = 6
    public var metrics: Metrics = .default
    /// Enabling Haptic Feedbacks to Supporting devices. Default value is `true`.
    public var isHapticsEnabled: Bool = true
    public var isPrecisionScrollEnabled: Bool = true
    
    static var `default`: SPRulerConfiguration { SPRulerConfiguration() }
    
    public init(scrollDirection: SPRulerConfiguration.Direction = .horizontal, alignment: SPRulerConfiguration.Alignment = .end, lineSpacing: CGFloat = 10, lineAndLabelSpacing: CGFloat = 6, metrics: SPRulerConfiguration.Metrics = .default, isHapticsEnabled: Bool = true, isPrecisionScrollEnabled: Bool = true) {
        self.scrollDirection = scrollDirection
        self.alignment = alignment
        self.lineSpacing = lineSpacing
        self.lineAndLabelSpacing = lineAndLabelSpacing
        self.metrics = metrics
        self.isHapticsEnabled = isHapticsEnabled
        self.isPrecisionScrollEnabled = isPrecisionScrollEnabled
    }
    
    
    public var isHorizontal: Bool {
        scrollDirection == .horizontal
    }
}

enum LineHeight {
    case full, mid, small
    
    init(index: Int, divisions: Int, midDivision: Int) {
        if index % divisions == 0 {
            self = .full
        } else if index % midDivision == 0 {
            self = .mid
        } else {
            self = .small
        }
    }
}

public class SPRuler: UIView {
    
    // MARK: - Public properties
    
    public var configuration: SPRulerConfiguration = .default {
        didSet {
            configureCollectionView()
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 12)
    public var highlightFont: UIFont = .boldSystemFont(ofSize: 14) {
        didSet {
            indicatorLabel.font = highlightFont
            indicatorLabel.textColor = highlightTextColor
        }
    }
    
    public var highlightLineColor: UIColor = .black {
        didSet { indicatorLine.backgroundColor = highlightLineColor }
    }
    
    public var highlightTextColor: UIColor = .black {
        didSet { indicatorLabel.textColor = highlightTextColor }
    }
    
    public weak var dataSource: SPRulerDataSource?
    
    public weak var delegate: SPRulerDelegate?
    
    public var highlightedIndex: Int = 0
    
    // MARK: - UI Elements
    
    public lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.register(SPRulerLineCell.self, forCellWithReuseIdentifier: SPRulerLineCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    public lazy var indicatorLabel: UILabel = {
        let lable = UILabel()
        lable.font = highlightFont
        lable.textColor = highlightLineColor
        lable.textAlignment = .center
        return lable
    }()
    
    public lazy var indicatorLabelGradientView: UIView = {
        let view = UIView()
        return view
    }()
    public lazy var indicatorLabelGradient = CAGradientLayer()
    
    public lazy var indicatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = highlightLineColor
        return view
    }()
        
    private var layout: UICollectionViewFlowLayout {
        collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var itemSize: CGSize = CGSize(width: 1, height: 1)
    
    private var cellWidthIncludingSpacing: CGFloat {
        if configuration.isHorizontal {
            return itemSize.width + layout.minimumLineSpacing
        } else {
            return itemSize.height + layout.minimumInteritemSpacing
        }
    }
    
    @available(iOS 10.0, *)
    lazy var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        
        indicatorLabel.sizeToFit()
        if configuration.isHorizontal {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: bounds.midX, bottom: 0, right: bounds.midX)
            indicatorLabel.center.x = collectionView.center.x
            indicatorLine.center.x = collectionView.center.x
            indicatorLine.frame.size = CGSize(width: 2, height: configuration.metrics.fullLineSize)
            switch configuration.alignment {
            case .start:
                indicatorLine.frame.origin.y = 0
                indicatorLabel.frame.origin.y = indicatorLine.frame.origin.y + indicatorLine.frame.size.height + configuration.lineAndLabelSpacing + 20
            case .end:
                indicatorLine.frame.origin.y = bounds.height - indicatorLine.frame.size.height
                indicatorLabel.frame.origin.y = indicatorLine.frame.origin.y - configuration.lineAndLabelSpacing - indicatorLabel.frame.size.height - 20
            }
            
        } else {
            collectionView.contentInset = UIEdgeInsets(top: bounds.midY, left: 0, bottom: bounds.midY, right: 0)
            indicatorLabel.center.y = collectionView.center.y
            indicatorLine.center.y = collectionView.center.y
            indicatorLine.frame.size = CGSize(width: configuration.metrics.fullLineSize, height: 2)
            switch configuration.alignment {
            case .start:
                indicatorLine.frame.origin.x = 0
                indicatorLabel.frame.origin.x = configuration.metrics.fullLineSize + configuration.lineAndLabelSpacing + 20
            case .end:
                indicatorLabel.frame.origin.x = configuration.metrics.fullLineSize + configuration.lineAndLabelSpacing + 20
                indicatorLine.frame.origin.x = indicatorLabel.frame.origin.x
                
            }
        }
        indicatorLabelGradientView.frame = indicatorLabel.frame
        indicatorLabelGradient.frame = indicatorLabelGradientView.bounds
        
        let bgColor = backgroundColor ?? UIColor.white
        let tranparentWhite = bgColor.withAlphaComponent(0)
        indicatorLabelGradient.colors = [tranparentWhite.cgColor, bgColor.cgColor, bgColor.cgColor, tranparentWhite.cgColor]
        
    }
    
    private func commonInit() {
        addSubview(collectionView)
        addSubview(indicatorLabelGradientView)
        addSubview(indicatorLabel)
        addSubview(indicatorLine)
        indicatorLabelGradientView.layer.insertSublayer(indicatorLabelGradient, at: 0)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionView.superview!.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: collectionView.superview!.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.superview!.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: collectionView.superview!.rightAnchor),
        ])
        configureCollectionView()
    }
    
    public func reload() {
        collectionView.reloadData()
    }
    
    // MARK: - Config
    
    private func configureCollectionView() {
        layout.minimumLineSpacing = configuration.lineSpacing
        layout.minimumInteritemSpacing = configuration.lineSpacing
        if configuration.isHorizontal {
            layout.scrollDirection = .horizontal
        } else {
            layout.scrollDirection = .vertical
        }
        scrollToValue(configuration.metrics.defaultValue, animated: false)
    }
    
    func scrollToValue(_ value: Int, animated: Bool = true) {
        layoutSubviews()
        collectionView.reloadData()
        collectionView.layoutSubviews()
        
        let offset: CGPoint
        let selected = CGFloat(value - configuration.metrics.minimumValue)
        if configuration.isHorizontal {
            offset = CGPoint(x: selected * cellWidthIncludingSpacing - collectionView.contentInset.left, y: 0)
        } else {
            offset = CGPoint(x: 0, y: selected * cellWidthIncludingSpacing - collectionView.contentInset.top)
        }
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(offset, animated: animated)
        }
    }
}

extension SPRuler: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        configuration.metrics.maximumValue - configuration.metrics.minimumValue + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SPRulerLineCell.identifier, for: indexPath) as! SPRulerLineCell // swiftlint:disable:this force_cast
        cell.tintColor = tintColor
        let text = dataSource?.spRuler(self, titleForIndex: indexPath.row)
        let rulerLineNumberSetup: RulerLineNumberSetup = (font: font, text: text)
        cell.configure(indexPath.row,
                       using: configuration,
                       rulerLineNumberSetup: rulerLineNumberSetup)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if configuration.isHorizontal {
            itemSize = CGSize(width: 1, height: bounds.height)
        } else {
            itemSize = CGSize(width: bounds.width, height: 1)
        }
        return itemSize
    }
}

extension SPRuler: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var offset = targetContentOffset.pointee
        let contentInset = scrollView.contentInset
        
        if configuration.isHorizontal {
            let roundedIndex = round((offset.x + contentInset.left) / cellWidthIncludingSpacing)
            offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - contentInset.left, y: -contentInset.top)
        } else {
            let roundedIndex = round((offset.y + contentInset.top) / cellWidthIncludingSpacing)
            offset = CGPoint(x: -contentInset.left, y: roundedIndex * cellWidthIncludingSpacing - contentInset.top)
        }
        if self.configuration.isPrecisionScrollEnabled {
            targetContentOffset.pointee = offset
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if #available(iOS 10.0, *), configuration.isHapticsEnabled {
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let contentInset = scrollView.contentInset
        let index: Int
        let itemsCount = collectionView.numberOfItems(inSection: 0) - 1
        if configuration.isHorizontal {
            let roundedIndex = round((offset.x + contentInset.left) / cellWidthIncludingSpacing)
            index = max(0, min(itemsCount, Int(roundedIndex)))
        } else {
            let roundedIndex = round((offset.y + contentInset.top) / cellWidthIncludingSpacing)
            index = max(0, min(itemsCount, Int(roundedIndex)))
        }
        if highlightedIndex != index {
            if #available(iOS 10.0, *), configuration.isHapticsEnabled {
                feedbackGenerator?.selectionChanged()
                feedbackGenerator?.prepare()
            }
            highlightedIndex = index
            indicatorLabel.text = dataSource?.spRuler(self, highlightTitleForIndex: index)
            indicatorLabel.sizeToFit()
        }
        delegate?.spRulerDidScroll(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            delegate?.spRuler(self, didSelectItemAtIndex: indexPath.row)
        }
        if #available(iOS 10.0, *) {
            feedbackGenerator = nil
        }
    }
    
}
