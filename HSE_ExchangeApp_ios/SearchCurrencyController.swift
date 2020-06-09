import UIKit

class SearchCurrencyController: UITableViewController, UISearchResultsUpdating {
    var tableData = ["something1", "something2"]
    var filteredTableData = [String]()
    
    var items: [String] {
        get {
            if  (resultSearchController.isActive) {
                return filteredTableData
            } else {
                return tableData
            }
        }
    }
    
    var resultSearchController = UISearchController()
    
    var senderIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()

            tableView.tableHeaderView = controller.searchBar

            return controller
        })()

        // Reload the table
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       // 1
       // return the number of sections
       return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // 2
      // return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      // 3
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

      cell.tag = indexPath.row
      cell.textLabel?.text = Currency.getKind(kindCode: items[indexPath.row])
        
      return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)

        if !searchController.searchBar.text!.isEmpty {
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (tableData as NSArray).filtered(using: searchPredicate)
            filteredTableData = array as! [String]
        } else {
            filteredTableData = (tableData as NSArray) as! [String]
        }

        self.tableView.reloadData()
    }
}
