//
//  DashboardStreamInfo.swift
//  STM
//
//  Created by Kesi Maduka on 3/1/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import UIKit

class DashboardStreamInfoView: UIView {
    var color = UIColor.whiteColor()
    let triangleIndicator = TriangleView()
    let infoViewHolder = UIView()
    let startBT = UIButton.styledForStreamInfoView()
    let streamNameLabel = UILabel()

    var stream: STMStream?

    convenience init(stream: STMStream) {
        self.init(frame: CGRect.zero)
        self.stream = stream

        streamNameLabel.text = stream.name
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()

        addSubview(triangleIndicator)

        infoViewHolder.layer.cornerRadius = 15.0
        infoViewHolder.backgroundColor = color
        infoViewHolder.clipsToBounds = true
        addSubview(infoViewHolder)

        streamNameLabel.textColor = Constants.Color.tint
        streamNameLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        infoViewHolder.addSubview(streamNameLabel)

        startBT.setTitle("Tune In", forState: .Normal)
        infoViewHolder.addSubview(startBT)

        setUpConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpConstraints() {
        triangleIndicator.autoPinEdgeToSuperviewEdge(.Top)
        triangleIndicator.autoSetDimensionsToSize(CGSize(width: 62, height: 31))

        infoViewHolder.autoPinEdgeToSuperviewEdge(.Top, withInset: 31)
        infoViewHolder.autoPinEdgeToSuperviewEdge(.Left)
        infoViewHolder.autoPinEdgeToSuperviewEdge(.Right)
        infoViewHolder.autoSetDimension(.Height, toSize: 248)
        infoViewHolder.autoPinEdgeToSuperviewEdge(.Bottom)

        streamNameLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15), excludingEdge: .Bottom)

        startBT.autoPinEdgeToSuperviewEdge(.Left)
        startBT.autoPinEdgeToSuperviewEdge(.Right)
        startBT.autoPinEdgeToSuperviewEdge(.Bottom)
    }
}