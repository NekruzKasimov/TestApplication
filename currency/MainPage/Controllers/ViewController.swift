//
//  ViewController.swift
//  currency
//
//  Created by Niko on 8/26/18.
//  Copyright © 2018 Niko. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD
import SwiftyXMLParser

private struct Constants {
    static let currencies = ["TJS", "USD", "RUB", "GBP", "EUR"]
    static let flags = ["tj", "us", "ru", "gb", "eu"]
}

class ViewController: UIViewController {
    var valutes = [Valute]()
    var from = "TJS"
    var to = "TJS"
    var amount = 0.0
    var result = 0.0
    var curCurrency = Valute()

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var currencyTableView: UITableView! {
        didSet {
            currencyTableView.tableFooterView = UIView()
            currencyTableView.estimatedRowHeight = 50
            currencyTableView.rowHeight = UITableViewAutomaticDimension
            currencyTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var amountTF: SkyFloatingLabelTextField! {
        didSet {
            amountTF.textAlignment = .right
            amountTF.keyboardType = .decimalPad
            amountTF.title = ""
            amountTF.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var spinnerHeighConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currencyButton: UIButton! {
        didSet {
            currencyButton.setTitle("TJS", for: .normal)
        }
    }
    
    @IBAction func showCurrencyList(_ sender: Any) {
        self.spinnerHeighConstraint.constant = 150
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func convertCurrency(_ sender: Any) {
        self.amount = NSString(string: amountTF.text! as NSString).doubleValue
        self.from = curCurrency.charCode
        self.to = "TJS"
        convert(textField: nil)
        resultLabel.text = "\(amount) convert from \(from) to \(to) = \(result)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        self.setValutes()
    }
}

//MARK: UITableView Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currency") as! CurrenciesTableViewCell
        cell.currencyLabel.text = Constants.currencies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.currencyButton.setTitle(Constants.currencies[indexPath.row], for: .normal)
        self.flagImageView.image = UIImage(named: Constants.flags[indexPath.row])
        if valutes.count != 0 {
            self.curCurrency = valutes[indexPath.row]
            self.from = "TJS"
            self.to = Constants.currencies[indexPath.row]
            convert(textField: amountTF)
        }
        hideCurrencyList()
    }
}

//MARK: Helper Functions
extension ViewController {
    @objc private func amountChanged() {
        self.amount = NSString(string: amountTF.text! as NSString).doubleValue
    }
    
    private func hideCurrencyList() {
        self.spinnerHeighConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func convert(textField: UITextField?) {
        if from == "TJS" {
            result = amount / curCurrency.value
        } else {
            result = amount * curCurrency.value
        }
        textField?.text = "\(result)"
        resultLabel.text = "\(amount) convert from \(from) to \(to) = \(result)"
    }
    
    private func setValutes(){
        let valute = Valute()
        valute.charCode = "TJS"
        valute.value = 1
        self.curCurrency = valute
        self.valutes.append(valute)
        NetworkManager.getCurrencies { (v) in
            self.valutes.append(contentsOf: v)
            SVProgressHUD.dismiss()
        }
    }
}
