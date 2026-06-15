import Foundation
import Testing

@testable import Ontology

@Suite
struct ListItemTests {
    @Test("ListItem JSON-LD encoding")
    func testJSONLDEncoding() throws {
        let listItem = ListItem(
            id: "section-node-id",
            identifier: PropertyValue(
                propertyID: "apple-reminders:section-id",
                value: "section-id"
            ),
            name: "Section",
            position: 2
        )

        let data = try JSONEncoder().encode(listItem)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "ListItem")
        #expect(json["@id"] as? String == "section-node-id")
        #expect(json["name"] as? String == "Section")
        #expect(json["position"] as? Int == 2)

        let identifier = json["identifier"] as! [String: Any]
        #expect(identifier["@type"] as? String == "PropertyValue")
        #expect(identifier["propertyID"] as? String == "apple-reminders:section-id")
        #expect(identifier["value"] as? String == "section-id")
    }

    @Test("ListItem JSON-LD decoding")
    func testJSONLDDecoding() throws {
        let json = """
            {
                "@context": "https://schema.org",
                "@type": "ListItem",
                "@id": "section-node-id",
                "identifier": {
                    "@type": "PropertyValue",
                    "propertyID": "apple-reminders:section-id",
                    "value": "section-id"
                },
                "name": "Section",
                "position": 2
            }
            """

        let listItem = try JSONDecoder().decode(
            ListItem.self,
            from: json.data(using: .utf8)!
        )

        #expect(listItem.id == "section-node-id")
        #expect(listItem.identifier?.propertyID == "apple-reminders:section-id")
        #expect(listItem.identifier?.value == "section-id")
        #expect(listItem.name == "Section")
        #expect(listItem.position == 2)
    }
}

