//
//  HostStreamCell.swift
//  STM
//
//  Created by Kesi Maduka on 2/2/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import UIKit

class HostStreamCell: KZTableViewCell {
    let avatar = UIImageView()
    let nameLabel = UILabel()
    let tagLabel = Label()

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = RGB(255)

        avatar.layer.cornerRadius = 35.0/2.0
        avatar.backgroundColor = RGB(197, g: 198, b: 199)
        avatar.clipsToBounds = true
        self.contentView.addSubview(avatar)

        nameLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(nameLabel)

        tagLabel.textColor = RGB(127, g: 127, b: 127)
        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        tagLabel.setContentEdgeInsets(UIEdgeInsets(top: 4, left: 5, bottom: 4, right: 5))
        tagLabel.backgroundColor = RGB(230)
        tagLabel.layer.cornerRadius = 5
        self.contentView.addSubview(tagLabel)

        self.accessoryType = .disclosureIndicator
    }

    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.autoSetPriority(UILayoutPriority(rawValue: 999)) { () -> Void in
            self.avatar.autoSetDimensions(to: CGSize(width: 35.0, height: 35.0))
        }

        avatar.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        avatar.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        avatar.autoPinEdge(toSuperviewEdge: .left, withInset: 10)

        nameLabel.autoPinEdge(.left, to: .right, of: avatar, withOffset: 10)
        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatar)

        tagLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
        tagLabel.autoPinEdge(.left, to: .right, of: nameLabel, withOffset: 10, relation: .greaterThanOrEqual)
        tagLabel.autoAlignAxis(.horizontal, toSameAxisOf: nameLabel)
    }

    @objc override func estimatedHeight() -> CGFloat {
        return 10 + 35 + 10
    }

    override func fillInCellData(_ shallow: Bool) {
        if let stream = model as? STMStream {
            nameLabel.text = stream.name
            tagLabel.text = stream.alphaID()

            if !shallow {
                avatar.kf.setImage(with: stream.pictureURL(), placeholder: UIImage(named: "defaultStreamImage"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        tagLabel.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        func change() {
            self.backgroundColor = highlighted ? RGB(250) : RGB(255)
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: change)
        } else {
            change()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        func change() {
            self.backgroundColor = selected ? RGB(250) : RGB(255)
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: change)
        } else {
            change()
        }
    }
}
