/// A ListItem model following Schema.org ontology (https://schema.org/ListItem)
public struct ListItem: Hashable, Sendable {
    /// JSON-LD node identifier for the list item.
    public var id: String?

    /// Schema.org identifier for the list item.
    public var identifier: PropertyValue?

    /// The name of the item.
    public var name: String?

    /// The position of an item in a series or sequence of items.
    public var position: Int?

    public init(
        id: String? = nil,
        identifier: PropertyValue? = nil,
        name: String? = nil,
        position: Int? = nil
    ) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.position = position
    }
}

extension ListItem: Codable {
    private enum CodingKeys: String, CodingKey {
        case identifier, name, position
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)

        if encoder.codingPath.isEmpty {
            try container.encode(schema.org, forKey: .context)
        }

        try container.encode("ListItem", forKey: .type)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(identifier, forKey: .attribute(.identifier))
        try container.encodeIfPresent(name, forKey: .attribute(.name))
        try container.encodeIfPresent(position, forKey: .attribute(.position))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)
        let decodedType = try container.decode(String.self, forKey: .type)
        guard decodedType == "ListItem" else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Expected type to be 'ListItem', but found \(decodedType)"
            )
        }

        id = try container.decodeIfPresent(String.self, forKey: .id)
        identifier = try container.decodeIfPresent(
            PropertyValue.self, forKey: .attribute(.identifier))
        name = try container.decodeIfPresent(String.self, forKey: .attribute(.name))
        position = try container.decodeIfPresent(Int.self, forKey: .attribute(.position))
    }
}
