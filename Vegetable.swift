#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct Vegetable:Codable {

    enum Kind:Codable {
        case fruit
        case leaf
        case root
        case stem
    }

    let id: UUID
    let name: String
    let type: Self.Kind
    let notes: String
}

