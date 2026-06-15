import Foundation

/// An ItemList model following Schema.org ontology (https://schema.org/ItemList)
public struct ItemList: Hashable, Sendable {
    /// JSON-LD node identifier for the item list.
    public var id: String?

    /// Schema.org identifier for the item list.
    public var identifier: PropertyValue?

    /// The name/title of the item list
    public var name: String?

    /// URL associated with the item list
    public var url: URL?

    /// The number of items in the list
    public var numberOfItems: Int?

    /// List elements represented as Schema.org ListItem values.
    public var itemListElement: [ListItem]?

    public init(
        name: String? = nil,
        numberOfItems: Int? = nil,
        itemListElement: [ListItem]? = nil
    ) {
        self.name = name
        self.numberOfItems = numberOfItems
        self.itemListElement = itemListElement
    }
}

#if canImport(EventKit)
    import EventKit

    extension ItemList {
        /// Initialize an ItemList from an EKCalendar
        public init(_ calendar: EKCalendar) {
            self.id = calendar.calendarIdentifier
            self.name = calendar.title
        }
    }
#endif

extension ItemList: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier, name, url, numberOfItems, itemListElement
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)

        if encoder.codingPath.isEmpty {
            try container.encode(schema.org, forKey: .context)
        }

        try container.encode("ItemList", forKey: .type)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(identifier, forKey: .attribute(.identifier))
        try container.encodeIfPresent(name, forKey: .attribute(.name))
        try container.encodeIfPresent(url, forKey: .attribute(.url))
        try container.encodeIfPresent(numberOfItems, forKey: .attribute(.numberOfItems))
        try container.encodeIfPresent(itemListElement, forKey: .attribute(.itemListElement))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)
        let decodedType = try container.decode(String.self, forKey: .type)
        guard decodedType == "ItemList" else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Expected type to be 'ItemList', but found \(decodedType)"
            )
        }

        id = try container.decodeIfPresent(String.self, forKey: .id)
        identifier = try container.decodeIfPresent(
            PropertyValue.self, forKey: .attribute(.identifier))
        name = try container.decodeIfPresent(String.self, forKey: .attribute(.name))
        url = try container.decodeIfPresent(URL.self, forKey: .attribute(.url))
        numberOfItems = try container.decodeIfPresent(Int.self, forKey: .attribute(.numberOfItems))
        itemListElement = try container.decodeIfPresent(
            [ListItem].self, forKey: .attribute(.itemListElement))
    }
}
