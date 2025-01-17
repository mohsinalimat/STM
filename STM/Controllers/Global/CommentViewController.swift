//
//  CommentViewController.swift
//  STM
//
//  Created by Kesi Maduka on 4/29/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import Foundation
import DGElasticPullToRefresh
import Keynode

class CommentViewController: KZViewController, UIViewControllerPreviewingDelegate, MessageToolbarDelegate {

    let tableView = UITableView()
    var replys = [Any]()
    let comment: STMComment

    lazy var keynode: Keynode = Keynode(view: self.view)
    var toolbarBottomConstraint: NSLayoutConstraint?
    let commentToolbar = MessageToolbarView()

    init(comment: STMComment) {
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
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
        tableView.register(cellType: ExtendedUserCommentCell.self)
        tableView.register(cellType: UserCommentCell.self)
        view.addSubview(tableView)

        commentToolbar.delegate = self
        commentToolbar.toolBar.placeholder = comment.replyPlaceholder()
        commentToolbar.toolBar.text = comment.replyPlaceholder()
        view.addSubview(commentToolbar)

        registerForPreviewing(with: self, sourceView: tableView)

        keynode.animations { [weak self] show, rect in
            guard let me = self else {
                return
            }

            if let con = me.toolbarBottomConstraint {
                con.constant = Constants.UI.Screen.keyboardAdjustment(show, rect: rect)
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
        tableView.dg_setPullToRefreshFillColor(RGB(255))
        tableView.dg_setPullToRefreshBackgroundColor(RGB(250, g: 251, b: 252))
    }

    /**
     Called on comment submit

     - parameter text: the text that was posted
     */
    func handlePost(_ text: String) {
        guard text.count > 0 else {
            return
        }

        guard let streamID = comment.stream?.id else {
            return
        }

        self.commentToolbar.sendBT.isEnabled = false
        self.commentToolbar.toolBar.text = comment.replyPlaceholder()
        Constants.Network.POST("/comment/\(comment.id)/reply", parameters: ["text": text, "streamID": streamID], completionHandler: { (response, error) -> Void in
            self.commentToolbar.sendBT.isEnabled = true
            self.handleResponse(response as AnyObject?, error: error as NSError?, successCompletion: { (result) -> Void in
                self.fetchData()
                Answers.logCustomEvent(withName: "Comment", customAttributes: [:])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notification.DidPostComment), object: nil)
            })
        })

        view.endEditing(true)
    }

    func messageToolbarPrefillText() -> String {
        return comment.replyPlaceholder()
    }

    func didBeginEditing() {
    }

    override func setupConstraints() {
        super.setupConstraints()

        tableView.autoPin(toTopLayoutGuideOf: self, withInset: 0)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)

        commentToolbar.autoPinEdge(.top, to: .bottom, of: tableView)
        commentToolbar.autoPinEdge(toSuperviewEdge: .left)
        commentToolbar.autoPinEdge(toSuperviewEdge: .right)
        toolbarBottomConstraint = commentToolbar.autoPinEdge(toSuperviewEdge: .bottom)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableViewCellData(_ tableView: UITableView, section: Int) -> [Any] {
        if section == 0 {
            return [comment]
        }

        return replys
    }

    override func tableViewNoDataText(_ tableView: UITableView) -> String {
        return "No Replys"
    }

    override func tableViewCellClass(_ tableView: UITableView, indexPath: IndexPath?) -> KZTableViewCell.Type {
        if indexPath?.section == 0 {
            return ExtendedUserCommentCell.self
        }

        return UserCommentCell.self
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        guard indexPath.section == 1 else {
            return
        }

        guard tableViewCellData(tableView, section: indexPath.section).count > 0 else {
            return
        }

        if let comment = tableViewCellData(tableView, section: indexPath.section)[indexPath.row] as? STMComment {
            let vc = CommentViewController(comment: comment)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? UserCommentCell {
            cell.streamView.isHidden = true
        }

        return cell
    }

    override func fetchData() {
        fetchDataWithCompletion(nil)
    }

    func fetchDataWithCompletion(_ completion: (() -> Void)?) {
        var count = 0

        func runCompletion() {
            count = count - 1
            if count == 0 {
                if let completion = completion {
                    completion()
                }
            }
        }

        count = count + 1
        Constants.Network.GET("/comment/\(comment.id)/replys", parameters: nil) { (response, error) -> Void in
            self.handleResponse(response as AnyObject?, error: error as NSError?, successCompletion: { (result) -> Void in
                self.replys.removeAll()

                guard let results = result as? [JSON] else {
                    return
                }

                let comments = [STMComment].from(jsonArray: results)
                comments?.forEach({ self.replys.append($0) })

                self.tableView.reloadData()
            })

            runCompletion()
        }
    }

    // MARK: UIViewController Previewing Delegate

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else {
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

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let vc = viewControllerToCommit as? PlayerViewController {
            vc.isPreviewing = false
            AppDelegate.del().presentStreamController(vc)
        } else {
            self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
        }
    }

}
