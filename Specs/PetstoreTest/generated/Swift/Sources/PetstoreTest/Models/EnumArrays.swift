//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation
import JSONUtilities

public class EnumArrays: JSONDecodable, JSONEncodable, PrettyPrintable {

    public enum ArrayEnum: String {
        case fish = "fish"
        case crab = "crab"

        public static let cases: [ArrayEnum] = [
          .fish,
          .crab,
        ]
    }

    public enum JustSymbol: String {
        case greaterThanOrEqualTo = ">="
        case dollar = "$"

        public static let cases: [JustSymbol] = [
          .greaterThanOrEqualTo,
          .dollar,
        ]
    }

    public var arrayEnum: [ArrayEnum]?

    public var justSymbol: JustSymbol?

    public init(arrayEnum: [ArrayEnum]? = nil, justSymbol: JustSymbol? = nil) {
        self.arrayEnum = arrayEnum
        self.justSymbol = justSymbol
    }

    public required init(jsonDictionary: JSONDictionary) throws {
        arrayEnum = jsonDictionary.json(atKeyPath: "array_enum")
        justSymbol = jsonDictionary.json(atKeyPath: "just_symbol")
    }

    public func encode() -> JSONDictionary {
        var dictionary: JSONDictionary = [:]
        if let arrayEnum = arrayEnum?.encode() {
            dictionary["array_enum"] = arrayEnum
        }
        if let justSymbol = justSymbol?.encode() {
            dictionary["just_symbol"] = justSymbol
        }
        return dictionary
    }

    /// pretty prints all properties including nested models
    public var prettyPrinted: String {
        return "\(Swift.type(of: self)):\n\(encode().recursivePrint(indentIndex: 1))"
    }
}