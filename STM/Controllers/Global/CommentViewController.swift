//
//  CommentViewController.swift
//  STM
//
//  Created by Kesi Maduka on 4/29/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import Foundation
import DGElasticPullToRefresh

class CommentViewController: KZViewController, UIViewControllerPreviewingDelegate, MessageToolbarDelegate {

    let tableView = UITableView()
    var replys = [Any]()
    let comment: STMComment

    lazy var keynode: Keynode.Connector = Keynode.Connector(view: self.view)
    var toolbarBottomConstraint: NSLayoutConstraint?
    let commentToolbar = MessageToolbarView()

    init(comment: STMComment) {
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tableView.dg_removePullToRefresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Comment"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerReusableCell(ExtendedUserCommentCell)
        tableView.registerReusableCell(UserCommentCell)
        view.addSubview(tableView)

        commentToolbar.delegate = self
        view.addSubview(commentToolbar)

        registerForPreviewingWithDelegate(self, sourceView: tableView)

        keynode.animationsHandler = { [weak self] show, rect in
            guard let me = self else {
                return
            }

            if let con = me.toolbarBottomConstraint {
                con.constant = (show ? -rect.size.height + 54 : 0)
                me.view.layoutIfNeeded()
            }
        }

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = Constants.UI.Color.tint

        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            if let me = self {
                me.fetchDataWithCompletion() {
                    me.tableView.dg_stopLoading()
                }
            }
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(RGB(250, g: 251, b: 252))
    }

    /**
     Called on comment submit

     - parameter text: the text that was posted
     */
    func handlePost(text: String) {
        guard text.characters.count > 0 else {
            return
        }

        guard let streamID = comment.stream?.id else {
            return
        }

        self.commentToolbar.sendBT.enabled = false
        Constants.Network.POST("/comment/\(comment.id)/reply", parameters: ["text": text, "streamID": streamID], completionHandler: { (response, error) -> Void in
            self.commentToolbar.sendBT.enabled = true
            self.handleResponse(response, error: error, successCompletion: { (result) -> Void in
                self.fetchData()
                Answers.logCustomEventWithName("Comment", customAttributes: [:])
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.DidPostComment, object: nil)
            })
        })

        view.endEditing(true)
    }

    func didBeginEditing() {
    }

    override func setupConstraints() {
        super.setupConstraints()

        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)

        commentToolbar.autoPinEdge(.Top, toEdge: .Bottom, ofView: tableView)
        commentToolbar.autoPinEdgeToSuperviewEdge(.Left)
        commentToolbar.autoPinEdgeToSuperviewEdge(.Right)
        toolbarBottomConstraint = commentToolbar.autoPinToBottomLayoutGuideOfViewController(self, withInset: 0)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableViewCellData(tableView: UITableView, section: Int) -> [Any] {
        if section == 0 {
            return [comment]
        }

        return replys
    }

    override func tableViewNoDataText(tableView: UITableView) -> String {
        return "No Replys"
    }

    override func tableViewCellClass(tableView: UITableView, indexPath: NSIndexPath?) -> KZTableViewCell.Type {
        if indexPath?.section == 0 {
            return ExtendedUserCommentCell.self
        }

        return UserCommentCell.self
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableViewCellData(tableView, section: indexPath.section).count == 0 {
            return 100
        }

        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }

        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        if indexPath.section == 1 {
            if let comment = replys[indexPath.row] as? STMComment {
                let vc = CommentViewController(comment: comment)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    override func fetchData() {
        fetchDataWithCompletion(nil)
    }

    func fetchDataWithCompletion(completion: (() -> Void)?) {
        var count = 0

        func runCompletion() {
            count = count - count
            if count == 0 {
                if let completion = completion {
                    completion()
                }
            }
        }

        count = count + 1
        Constants.Network.GET("/comment/\(comment.id)/replys", parameters: nil) { (response, error) -> Void in
            self.handleResponse(response, error: error, successCompletion: { (result) -> Void in
                self.replys.removeAll()

                guard let results = result as? [JSON] else {
                    return
                }

                let comments = [STMComment].fromJSONArray(results)
                comments.forEach({ self.replys.append($0) })

                self.tableView.reloadData()
            })

            runCompletion()
        }
    }

    //MARK: UIViewController Previewing Delegate

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return nil
        }

        var vc: UIViewController?
        previewingContext.sourceRect = cell.frame

        if indexPath.section == 0 {
            return nil
        } else if indexPath.section == 1 {
            if let comment = replys[indexPath.row] as? STMComment {
                vc = CommentViewController(comment: comment)
            }
        }

        if let vc = vc {
            vc.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        }

        return vc
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let vc = viewControllerToCommit as? PlayerViewController {
            vc.isPreviewing = false
            AppDelegate.del().presentStreamController(vc)
        } else {
            self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
        }
    }


}
