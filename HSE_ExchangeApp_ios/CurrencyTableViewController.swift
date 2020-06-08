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
        
        // for feature know who is it
        cell.tag = indexPath.row
        cell.setData(newData: items[indexPath.row])
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let scc = segue.destination as? SearchCurrencyController else { return }
        scc.tableData = Array(convertValues.keys)  // TODO: convert to beautify names
        scc.senderIndex = (sender as! UIView).superview?.superview?.tag
    }
    
    @IBAction func unwindSegueWithResult(segue: UIStoryboardSegue) {
        guard let ms = segue.source as? SearchCurrencyController else { return }
        print("return")
        print(ms.senderIndex!)
        print((ms.tableView!.cellForRow(at: ms.tableView.indexPathForSelectedRow!)?.textLabel?.text)!)
        
        recalcCell(index: ms.senderIndex!,
                   newKind: (ms.tableView!.cellForRow(at: ms.tableView.indexPathForSelectedRow!)?.textLabel?.text)!)
        
    }
    
    private func loadDefaults() {
        let url = URL(string: "https://api.exchangeratesapi.io/latest")!
        
        // request for currency rates
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        // saving result
                        self.convertValues = (json["rates"] as! [String: Double])
                        self.convertValues["EUR"] = 1.0  // standart base currency
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
    
    @IBAction func valueChanged(_ sender: UITextField) {
        // setted in cell creation
        let senderCell = sender.superview?.superview as! CurrencyTableViewCell
        let senderRow = senderCell.tag
        
        items[senderRow].value = sender.text!.toDouble()
        
        for row in 0...items.count-1 {
            // for saving selection
            if row == senderRow {continue}
            
            // calculate value from rates
            items[row].value = items[senderRow].value / convertValues[items[senderRow].kind]! * convertValues[items[row].kind]!
            
            // view values
            (tableView.visibleCells[row] as! CurrencyTableViewCell)
                .value = items[row].value
        }
    }
    
    func recalcCell(index: Int, newKind: String) {
        items[index].value = items[index].value / convertValues[items[index].kind]! * convertValues[newKind]!
        items[index].kind = newKind
        
        tableView.reloadData()
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
