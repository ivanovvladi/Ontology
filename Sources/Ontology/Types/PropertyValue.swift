/// A PropertyValue model following Schema.org ontology (https://schema.org/PropertyValue)
public struct PropertyValue: Hashable, Sendable {
    /// A commonly used identifier for the characteristic represented by the property.
    public var propertyID: String?

    /// The value of a property value node.
    public var value: String?

    public init(propertyID: String? = nil, value: String? = nil) {
        self.propertyID = propertyID
        self.value = value
    }
}

extension PropertyValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case propertyID, value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)

        if encoder.codingPath.isEmpty {
            try container.encode(schema.org, forKey: .context)
        }

        try container.encode("PropertyValue", forKey: .type)
        try container.encodeIfPresent(propertyID, forKey: .attribute(.propertyID))
        try container.encodeIfPresent(value, forKey: .attribute(.value))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONLDCodingKey<CodingKeys>.self)
        let decodedType = try container.decode(String.self, forKey: .type)
        guard decodedType == "PropertyValue" else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Expected type to be 'PropertyValue', but found \(decodedType)"
            )
        }

        propertyID = try container.decodeIfPresent(String.self, forKey: .attribute(.propertyID))
        value = try container.decodeIfPresent(String.self, forKey: .attribute(.value))
    }
}
