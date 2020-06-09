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
        
        return Currency.getKind(kindCode: kind)
    }
    
    func getValue() -> String {
        // return: value in format "*.??"
        // example: "4499.99"
        
        return String.init(format: "%.2f", value)
    }
    
    static func getKind(kindCode: String) -> String {
        let path = Bundle.main.path(forResource: "Currencies", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        let names = (plist as! [String:Any])["Currencies"] as! [String:String]
        
        return names[kindCode]!
    }
    
    static func getKind(kindName: String) -> String {
        let path = Bundle.main.path(forResource: "Currencies", ofType: "plist")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        let names = (plist as! [String:Any])["Currencies"] as! [String:String]
        
        var revNames = [String:String]()
        for i in names.keys {
            revNames[names[i]!] = i
        }
        
        return revNames[kindName]!
    }
}
