import UIKit

class CurrencyTableViewCell: UITableViewCell {
    @IBOutlet weak var currencyChooser: UIButton!
    @IBOutlet weak var valueView: UITextField!
    
                         // for example
    var data: Currency = Currency(kind: "USD", value: 1.1)
    
    func setData(newData: Currency) {
        kind = newData.kind
        value = newData.value
    }
    
    var kind: String {
        get {
            data.kind
        }
        set(newKind) {
            data.kind = newKind
            
            let controlStates: Array<UIControl.State> = [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved]
            for controlState in controlStates {
                currencyChooser.setTitle(data.getKind(), for: controlState)
            }
        }
    }
    
    var value: Double {
        get {
            data.value
        }
        set(newValue) {
            data.value = newValue
            valueView.text = data.getValue()
        }
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        valueView.resignFirstResponder()
        
        return true
    }
}
