//  CustomFormCell.swift
//  TIVirtualAssistant
//  Created by Sanjeev Kumar on 27/11/24.
//  Copyright © 2024 Telus International. All rights reserved.

import UIKit

class CustomFormCell: UITableViewCell {

    // MARK: Outlet Declaration
    @IBOutlet weak var senderImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarViewWidth: NSLayoutConstraint!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var formTable: UITableView!
    @IBOutlet weak var formTableHeight: NSLayoutConstraint!
    
    // MARK: Property Declaration
    static let nibName = "CustomFormCell"
    static let identifier = "CustomFormCell"
    var formValues:[[String:String]] = []
    var configurationModal: VAConfigurationModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureFormTable()
    }
    
    func configureFormTable() {
        formTable.tableFooterView = UIView()
        formTable.rowHeight = UITableView.automaticDimension
        formTable.estimatedRowHeight = 56
        formTable.register(UINib(nibName: FormDataCell.nibName, bundle: Bundle.module), forCellReuseIdentifier: FormDataCell.identifier)
        formTable.delegate = self
        formTable.dataSource = self
        formTable.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(cellWithData formData: String, date: Date) {
        self.dateLabel.text = getMessageTime(date: date)
        do {
            if let data1 = formData.data(using: .utf8, allowLossyConversion: false) {
                let json = try JSONSerialization.jsonObject(with: data1, options: .mutableLeaves)
                if let values = json as? [[String:String]] {
                    formValues = values
                    formTable.reloadData()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        self.setCardUI()
    }
    func setCardUI() {
        if configurationModal?.result?.enableAvatar ?? true {
            avatarView.isHidden = false
        } else {
            avatarViewWidth.constant = 0
            avatarView.isHidden = true
            dateViewHeight.constant = 20
        }
    }
}

extension CustomFormCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formValues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FormDataCell.identifier, for: indexPath) as? FormDataCell {
            cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .white : VAColorUtility.lightGrey_NT
            cell.titleLabel.text = formValues[indexPath.row]["title"]
            cell.descLabel.text = formValues[indexPath.row]["desc"]
            cell.seperatorView.isHidden = (indexPath.row == formValues.count-1) ? true : false
            return cell
        }
        return UITableViewCell()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                self.formTableHeight.constant = newsize.height
            }
        }
    }
}
