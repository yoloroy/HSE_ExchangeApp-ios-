import UIKit

class CurrencyTableViewController: UITableViewController {
    var items = [Currency]()
    var convertValues: [String: Double] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaults()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath) as? CurrencyTableViewCell else {
            fatalError("The dequeued cell is not an instance of CurrencyTableViewCell.")
        }
        
        cell.tag = indexPath.row
        cell.setData(newData: items[indexPath.row])
        
        return cell
    }
    
    private func loadDefaults() {
        let url = URL(string: "https://api.exchangeratesapi.io/latest")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        self.convertValues = (json["rates"] as! [String: Double])
                        self.convertValues["EUR"] = 1.0
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
        
        items += [Currency(kind: "USD", value: 0.0)]
        items += [Currency(kind: "RUB", value: 0.0)]
    }
    
    @IBAction func chooseCurrency(_ sender: UIButton) {
        // TODO: add choose
        let alert = UIAlertController(title: "Alert title", message: "Alert message.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func valueChanged(_ sender: UITextField) {
        // setted in cell creation
        let senderCell = sender.superview?.superview as! CurrencyTableViewCell
        let senderRow = senderCell.tag
        
        items[senderRow].value = sender.text!.toDouble()
        
        for row in 0...items.count-1 {
            if row == senderRow {continue}
            
            items[row].value = items[senderRow].value / convertValues[items[senderRow].kind]! * convertValues[items[row].kind]!
            
            (tableView.visibleCells[row] as! CurrencyTableViewCell)
                .value = items[row].value
        }
    }
}
extension String {
    func toDouble() -> Double{
        return (self as NSString).doubleValue
    }
}
extension Dictionary {
    static func + <K, V> (left: inout [K:V], right: [K:V]) -> [K:V] {
        for (k, v) in right {
            left[k] = v
        }
        return left
    }
}
