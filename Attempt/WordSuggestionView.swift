//
//  WordChipView.swift
//  Attempt
//
//  Created by Vaibhav Maheshwari on 03/06/19.
//  Copyright © 2019 Learning. All rights reserved.
//

import UIKit

@IBDesignable class WordSuggestionView: UIView {
    
    enum State{
        case NORMAL, FAVOURITE
    }
    
    let labelView: UILabel
    let leadingSpace = CGFloat(25)
    let trailingSpace = CGFloat(25)
    let topSpace = CGFloat(5)
    let bottomSpace = CGFloat(5)
    
    var displayType = State.NORMAL {
        didSet {
            invalidateDisplay()
        }
    }
    
    @IBInspectable var text: String? {
        didSet {
            labelView.text = text
            invalidateDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    override init(frame: CGRect) {
        labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        addSubview(labelView)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        super.init(coder: aDecoder)
        addSubview(labelView)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: labelView.intrinsicContentSize.width + leadingSpace + trailingSpace, height: labelView.intrinsicContentSize.height + topSpace + bottomSpace)
        }
    }
    
    func setup() {
        labelView.font = UIFont(name: "Helvetica-Bold", size: 16.0)
        
        /**
         * Setting up inner constraints
         */
        labelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingSpace).isActive = true
        self.trailingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: trailingSpace).isActive = true
        
        labelView.topAnchor.constraint(equalTo: self.topAnchor, constant: topSpace).isActive = true
        self.bottomAnchor.constraint(equalTo: labelView.bottomAnchor, constant: bottomSpace).isActive = true
        
        invalidateDisplay()
    }
    
    func invalidateDisplay() {
        
        let width = labelView.intrinsicContentSize.width + leadingSpace + trailingSpace
        let height = labelView.intrinsicContentSize.height + topSpace + bottomSpace
        let drawingRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        /**
         * Setting up path
         */
        let radii = CGSize(width: height / 2, height: height / 2)
        let corners = UIRectCorner(arrayLiteral: [.topLeft, .bottomRight])
        let path = UIBezierPath(roundedRect: drawingRect, byRoundingCorners: corners, cornerRadii: radii)
        
        /**
         * Setting up shadow layer
         */
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        shadowLayer.path = path.cgPath
        shadowLayer.shadowOpacity = 0.5
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowColor = displayType == .NORMAL ? #colorLiteral(red: 0, green: 0.231372549, blue: 1, alpha: 0.4103745719) : #colorLiteral(red: 1, green: 0.5333333333, blue: 0.1058823529, alpha: 0.6066502568)
        shadowLayer.shadowRadius = 6
        
        /**
         * label view text color
         */
        labelView.textColor = displayType == .NORMAL ? #colorLiteral(red: 0, green: 0.1725490196, blue: 0.6352941176, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let textLayer = layer.sublayers?.last
        layer.sublayers?.removeAll()
        
        if (displayType == .NORMAL) {
            layer.addSublayer(shadowLayer)
        } else if (displayType == .FAVOURITE){
            /**
             * Setting up gradient layer
             */
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = drawingRect
            gradientLayer.colors = [#colorLiteral(red: 1, green: 0.8117647059, blue: 0.09411764706, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.5333333333, blue: 0.1058823529, alpha: 1).cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.mask = maskLayer
            
            layer.addSublayer(shadowLayer)
            layer.addSublayer(gradientLayer)
        }
        
        layer.addSublayer(textLayer!)
    }
    
}

