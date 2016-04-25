//
//  CreateStreamViewController.swift
//  STM
//
//  Created by Kesi Maduka on 1/30/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class CreateStreamViewController: KZViewController {

    var scrollView = UIScrollView()
    var contentView = UIView()

    let streamTypeSegmentControl = UISegmentedControl(items: ["Global", "Local"])
    let streamNameTextField = UITextField()
    let privacySwitch = UISwitch()
    let passcodeTextField = UITextField()
    let streamDescriptionTextView = KMPlaceholderTextView()
    let hostBT = UIButton()

    // UI Adjustments
    lazy var keynode: Keynode.Connector = Keynode.Connector(view: self.contentView)
    var scrollViewBottomConstraint: NSLayoutConstraint?
    var passcodeHeightConstraint: NSLayoutConstraint?
    var passcodePaddingConstraint: NSLayoutConstraint?

    let formPadding = CGFloat(15)

    let publicLabel = UILabel()
    let privateLabel = UILabel()
    let tableView = KZIntrinsicTableView()
    var items = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        view.backgroundColor = RGB(234)

        streamTypeSegmentControl.selectedSegmentIndex = 0
        streamTypeSegmentControl.tintColor = Constants.Color.tint
        //contentView.addSubview(streamTypeSegmentControl)

        streamNameTextField.layer.cornerRadius = 5
        streamNameTextField.clipsToBounds = true
        streamNameTextField.placeholder = "Stream Name"
        streamNameTextField.textAlignment = .Center
        streamNameTextField.backgroundColor = RGB(255)
        streamNameTextField.autocorrectionType = .No
        streamNameTextField.inputAccessoryView = UIToolbar.styleWithButtons(self)
        contentView.addSubview(streamNameTextField)

        passcodeTextField.layer.cornerRadius = 5
        passcodeTextField.clipsToBounds = true
        passcodeTextField.placeholder = "Passcode"
        passcodeTextField.textAlignment = .Center
        passcodeTextField.backgroundColor = RGB(255)
        passcodeTextField.autocorrectionType = .No
        passcodeTextField.keyboardType = .NumberPad
        passcodeTextField.secureTextEntry = true
        passcodeTextField.alpha = 0.7
        passcodeTextField.enabled = false
        passcodeTextField.inputAccessoryView = UIToolbar.styleWithButtons(self)
        contentView.addSubview(passcodeTextField)

        privacySwitch.addTarget(self, action: #selector(CreateStreamViewController.togglePrivacy), forControlEvents: .ValueChanged)
        contentView.addSubview(privacySwitch)

        publicLabel.text = "Public Stream"
        contentView.addSubview(publicLabel)

        privateLabel.text = "Private Stream"
        contentView.addSubview(privateLabel)

        streamDescriptionTextView.font = UIFont.systemFontOfSize(15)
        streamDescriptionTextView.layer.cornerRadius = 5
        streamDescriptionTextView.clipsToBounds = true
        streamDescriptionTextView.placeholder = "Stream Description..."
        streamDescriptionTextView.backgroundColor = RGB(255)
        streamDescriptionTextView.textContainerInset = UIEdgeInsetsMake(formPadding, formPadding, formPadding, formPadding)
        streamDescriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        streamDescriptionTextView.inputAccessoryView = UIToolbar.styleWithButtons(self)
        contentView.addSubview(streamDescriptionTextView)

        hostBT.setTitle("Host", forState: .Normal)
        hostBT.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        hostBT.setTitleColor(Constants.Color.tint, forState: .Normal)
        hostBT.setBackgroundColor(UIColor.clearColor(), forState: .Normal)
        hostBT.setTitleColor(RGB(255), forState: .Highlighted)
        hostBT.setBackgroundColor(Constants.Color.tint, forState: .Highlighted)
        hostBT.clipsToBounds = true
        hostBT.layer.cornerRadius = 5
        hostBT.layer.borderColor = Constants.Color.tint.CGColor
        hostBT.layer.borderWidth = 1
        hostBT.addTarget(self, action: #selector(CreateStreamViewController.host), forControlEvents: .TouchUpInside)
        contentView.addSubview(hostBT)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = RGB(255)
        tableView.registerReusableCell(HostStreamCell)
        contentView.addSubview(tableView)

        keynode.animationsHandler = { [weak self] show, rect in
            guard let me = self else {
                return
            }

            if let con = me.scrollViewBottomConstraint {
                con.constant = (show ? -rect.size.height + 54 : 0)
                me.view.layoutIfNeeded()
            }
        }

        self.title = "Host Stream"
    }

    override func setupConstraints() {
        super.setupConstraints()

        scrollView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        scrollViewBottomConstraint = scrollView.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)

        contentView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        contentView.autoMatchDimension(.Width, toDimension: .Width, ofView: view)

        /*streamTypeSegmentControl.autoPinEdgeToSuperviewEdge(.Top, withInset: formPadding)
        streamTypeSegmentControl.autoPinEdgeToSuperviewEdge(.Left, withInset: formPadding)
        streamTypeSegmentControl.autoPinEdgeToSuperviewEdge(.Right, withInset: formPadding)
        streamTypeSegmentControl.autoSetDimension(.Height, toSize: 30)*/

        streamNameTextField.autoPinEdgeToSuperviewEdge(.Top, withInset: formPadding)
        //streamNameTextField.autoPinEdge(.Top, toEdge: .Bottom, ofView: streamTypeSegmentControl, withOffset: formPadding)
        streamNameTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: formPadding)
        streamNameTextField.autoPinEdgeToSuperviewEdge(.Right, withInset: formPadding)
        streamNameTextField.autoSetDimension(.Height, toSize: 50)

        privacySwitch.autoPinEdge(.Top, toEdge: .Bottom, ofView: streamNameTextField, withOffset: formPadding)
        privacySwitch.autoAlignAxisToSuperviewAxis(.Vertical)
        privacySwitch.autoPinEdge(.Left, toEdge: .Right, ofView: publicLabel, withOffset: formPadding)
        publicLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: privacySwitch)
        privateLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: privacySwitch)
        privateLabel.autoPinEdge(.Left, toEdge: .Right, ofView: privacySwitch, withOffset: formPadding)

        passcodePaddingConstraint = passcodeTextField.autoPinEdge(.Top, toEdge: .Bottom, ofView: privacySwitch, withOffset: 0)
        passcodeTextField.autoPinEdgeToSuperviewEdge(.Left, withInset: formPadding)
        passcodeTextField.autoPinEdgeToSuperviewEdge(.Right, withInset: formPadding)
        passcodeHeightConstraint = passcodeTextField.autoSetDimension(.Height, toSize: 0)

        streamDescriptionTextView.autoPinEdge(.Top, toEdge: .Bottom, ofView: passcodeTextField, withOffset: formPadding)
        streamDescriptionTextView.autoPinEdgeToSuperviewEdge(.Left, withInset: formPadding)
        streamDescriptionTextView.autoPinEdgeToSuperviewEdge(.Right, withInset: formPadding)
        streamDescriptionTextView.autoSetDimension(.Height, toSize: 100)

        hostBT.autoPinEdge(.Top, toEdge: .Bottom, ofView: streamDescriptionTextView, withOffset: formPadding)
        hostBT.autoPinEdgeToSuperviewEdge(.Left, withInset: formPadding)
        hostBT.autoPinEdgeToSuperviewEdge(.Right, withInset: formPadding)
        hostBT.autoSetDimension(.Height, toSize: 50)

        tableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: hostBT, withOffset: 15)
        tableView.autoPinEdgeToSuperviewEdge(.Left)
        tableView.autoPinEdgeToSuperviewEdge(.Right)
        tableView.autoPinEdgeToSuperviewEdge(.Bottom)
    }

    func togglePrivacy() {
        let enabled = privacySwitch.on
        passcodeTextField.enabled = enabled
        passcodeTextField.text = ""
        passcodeTextField.alpha = enabled ? 1.0 : 0.7

        UIView.animateWithDuration(0.2) {
            self.passcodeHeightConstraint?.constant = enabled ? 50.0 : 0.0
            self.passcodePaddingConstraint?.constant = enabled ? 14.0 : 0.0
            self.view.layoutIfNeeded()
        }
    }

    func host() {
        guard let name = streamNameTextField.text else {
            return showError("No Stream Name Entered")
        }

        guard name.characters.count > 0 else {
            return showError("No Stream Name Entered")
        }

        guard let description = streamDescriptionTextView.text else {
            return showError("No Description Entered")
        }

        guard description.characters.count > 0 else {
            return showError("No Description Entered")
        }

        let vc = HostViewController()
        let streamType = streamTypeSegmentControl.selectedSegmentIndex == 0 ? StreamType.Global : StreamType.Local
        let passcodeString = privacySwitch.on ? (passcodeTextField.text ?? "") : ""
        vc.start(streamType, name: name, passcode: passcodeString, description: description) { (nothing, error) -> Void in
            if error == nil {
                AppDelegate.del().presentStreamController(vc)
            }
        }
    }

    //MARK: Table View Delegate

    override func tableViewCellData(tableView: UITableView, section: Int) -> [Any] {
        return items
    }

    override func tableViewCellClass(tableView: UITableView, indexPath: NSIndexPath?) -> KZTableViewCell.Type {
        return HostStreamCell.self
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        if let stream = items[indexPath.row] as? STMStream {
            let vc = HostViewController()
            vc.start(stream) { (nothing, error) -> Void in
                if error == nil {
                    AppDelegate.del().presentStreamController(vc)
                }
            }
        }
    }

    //MARK: Cell Deletion

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let stream = items[indexPath.row] as? STMStream else {
                return
            }

            Constants.Network.GET("/delete/stream/\(stream.id)", parameters: nil, completionHandler: { (response, error) -> Void in
                self.handleResponse(response, error: error, successCompletion: { (result) -> Void in
                    self.items.removeAtIndex(indexPath.row)
                    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    self.fetchData()
                })
            })
        }
    }

    //MARK: Data Functions

    override func fetchData() {
        Constants.Network.GET("/streams/user/0", parameters: nil) { (response, error) -> Void in
            self.handleResponse(response, error: error, successCompletion: { (result) -> Void in
                self.items.removeAll()
                if let result = result as? [JSON] {
                    let streams = [STMStream].fromJSONArray(result)
                    streams.forEach({ self.items.append($0) })
                    self.tableView.reloadData()
                }
            })
        }
    }
}
