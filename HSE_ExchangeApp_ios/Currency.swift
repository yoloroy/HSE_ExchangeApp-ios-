import Foundation

class Currency {
    internal init(kind: String, value: Double) {
        self.kind = kind
        self.value = value
    }
    
    var kind: String
    var value: Double
    
    // returns formatted strings
    func getKind() -> String {
        // return: kind in format "{symbol} {name}"
        // example: "$ US Dollar" ("$ US" - symbol)
        
        return kind  // temporally
    }
    
    func getValue() -> String {
        // return: value in format "*.??"
        // example: "4499.99"
        
        return String.init(format: "%.2f", value)
    }
}
