//
//  DashboardItemCell.swift
//  STM
//
//  Created by Kesi Maduka on 2/2/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import UIKit

class DashboardItemCell: KZTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let headerLabel = UILabel.styledForDashboardHeader()
    var collectionView: UICollectionView?

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = RGB(255)

        self.contentView.addSubview(headerLabel)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: 62, height: 62)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 10.0
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

        collectionView = UICollectionView(frame: self.contentView.bounds, collectionViewLayout: layout)
        if let collectionView = collectionView {
            collectionView.clipsToBounds = true
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.alwaysBounceVertical = false
            collectionView.alwaysBounceHorizontal = true
            collectionView.backgroundColor = UIColor.darkGrayColor()
            collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
            collectionView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
            collectionView.registerReusableCell(DashboardItemCollectionCell)
            self.contentView.addSubview(collectionView)
        }
    }

    override func getHeight() -> CGFloat {
        return 123
    }

    override func updateConstraints() {
        super.updateConstraints()
        headerLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        headerLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 12)
        headerLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 12)

        if let collectionView = collectionView {
            collectionView.autoPinEdge(.Top, toEdge: .Bottom, ofView: headerLabel, withOffset: 10)
            collectionView.autoPinEdgeToSuperviewEdge(.Left)
            collectionView.autoPinEdgeToSuperviewEdge(.Right)
            collectionView.autoPinEdgeToSuperviewEdge(.Bottom)

            NSLayoutConstraint.autoSetPriority(999, forConstraints: { () -> Void in
                collectionView.autoSetDimension(.Height, toSize: 62)
            })
        }
    }

    //MARK: UICollectionView

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let item = model as? STMDashboardItem {
            return item.items?.count ?? 0
        }

        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath: indexPath, cellType: DashboardItemCollectionCell.self)

        if let item = model as? STMDashboardItem {
            if let items = item.items {
                cell.setContent(items[indexPath.row])
            }
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 62, height: 62)
    }

    override func fillInCellData() {
        if let item = model as? STMDashboardItem {
            headerLabel.text = item.name
            self.collectionView?.reloadData()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        headerLabel.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        func change() {
            self.backgroundColor = highlighted ? RGB(250) : RGB(255)
        }

        if animated {
            UIView.animateWithDuration(0.5, animations: change)
        } else {
            change()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        func change() {
            self.backgroundColor = selected ? RGB(250) : RGB(255)
        }

        if animated {
            UIView.animateWithDuration(0.5, animations: change)
        } else {
            change()
        }
    }
}
