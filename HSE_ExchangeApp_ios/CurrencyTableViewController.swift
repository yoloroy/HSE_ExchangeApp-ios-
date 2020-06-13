import UIKit

class CurrencyTableViewController: UITableViewController {
    // current viewed cells data
    var items = [Currency]()
    
    var convertValues: [String: Double] = [:]
    
    var usedKinds: [String] {
        get { items.map { $0.kind } }
    }
    
    var unusedKinds: [String] {
        get { convertValues.keys.filter({ !usedKinds.contains($0) }) }
    }
    
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if items.count < 2 { return }
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
        } else if editingStyle == .insert {
            tableView.insertRows(
                at: [indexPath], with: .automatic)
            
            tableView.reloadData()
        } else {
            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let scc = segue.destination as? SearchCurrencyController else { return }
        
        if let senderIndex = (sender as! UIView).superview?.superview?.tag {
            scc.senderIndex = senderIndex
            scc.tableData = unusedKinds + [items[senderIndex].kind]  // TODO: convert to beautify names
        }
    }
    
    @IBAction func unwindSegueWithResult(segue: UIStoryboardSegue) {
        guard let ms = segue.source as? SearchCurrencyController else { return }
        
        // TODO: beautify it and Currency.getKindWithKindName
        recalcCell(index: ms.senderIndex!,
                   newKind: Currency.getKind(kindName: (ms.tableView!.cellForRow(at: ms.tableView.indexPathForSelectedRow!)?.textLabel?.text)!))
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
        let senderCell = sender.superview?.superview as! CurrencyTableViewCell
        let senderRow = senderCell.tag  // setted in cell creation
        
        items[senderRow].value = sender.text!.toDouble()
        
        for row in 0..<items.count {
            // for saving selection
            if row == senderRow {continue}
            
            // calculate value from rates
            items[row].value = calcValueForKind(
                from: items[senderRow],
                toKind: items[row].kind
            )
            
            // view values
            (tableView.cellForRow(at: IndexPath(row: row, section:0)) as? CurrencyTableViewCell)?
                .value = items[row].value
        }
    }
    
    @IBAction func addRow(_ sender: UIButton) {
        if unusedKinds.count > 0 {
            items.insert(
                Currency(
                    kind: unusedKinds[0],
                    value: calcValueForKind(
                        from: items[sender.row],
                        toKind: unusedKinds[0]
                    )
                ),
                at: sender.row+1
            )
            
            tableView(tableView,
                       commit: .insert,
                       forRowAt:IndexPath.init(
                        row: sender.row,
                        section: 0))
        }
    }
    
    func recalcCell(index: Int, newKind: String) {
        items[index].value = calcValueForKind(
            from: items[index],
            toKind: newKind
        )
        items[index].kind = newKind
        
        tableView.reloadData()
    }
    
    func calcValueForKind(from: Currency, toKind: String) -> Double {
        return
            from.value
                / convertValues[from.kind]!  // clear from kind
                * convertValues[toKind]!  // convert to kind
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
extension UIButton {
    var row: Int {
        get {
            /// Button -> Content View -> Cell -> tag (row)
            (superview?.superview!.tag)!
        }
    }
}
