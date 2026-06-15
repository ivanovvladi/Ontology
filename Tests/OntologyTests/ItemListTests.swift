import Foundation
import Testing

@testable import Ontology

@Suite
struct ItemListTests {
    @Test("ItemList basic initialization")
    func testBasicInitialization() throws {
        let itemList = ItemList(name: "Shopping List", numberOfItems: 5)

        #expect(itemList.name == "Shopping List")
        #expect(itemList.numberOfItems == 5)
        #expect(itemList.identifier == nil)
        #expect(itemList.id == nil)
        #expect(itemList.url == nil)
    }

    @Test("ItemList JSON-LD encoding")
    func testJSONLDEncoding() throws {
        var itemList = ItemList(name: "Test List", numberOfItems: 3)
        itemList.id = "list-node-id"
        itemList.identifier = PropertyValue(propertyID: "apple-reminders:list-id", value: "list-id")
        itemList.url = URL(string: "https://example.com/list")
        itemList.itemListElement = [
            ListItem(
                id: "section-node-id",
                identifier: PropertyValue(
                    propertyID: "apple-reminders:section-id",
                    value: "section-id"
                ),
                name: "Section",
                position: 1
            )
        ]

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(itemList)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "ItemList")
        #expect(json["@id"] as? String == "list-node-id")
        #expect(json["name"] as? String == "Test List")
        #expect(json["numberOfItems"] as? Int == 3)
        #expect(json["url"] as? String == "https://example.com/list")

        let identifier = json["identifier"] as! [String: Any]
        #expect(identifier["@type"] as? String == "PropertyValue")
        #expect(identifier["propertyID"] as? String == "apple-reminders:list-id")
        #expect(identifier["value"] as? String == "list-id")

        let elements = json["itemListElement"] as! [[String: Any]]
        #expect(elements.count == 1)
        #expect(elements[0]["@type"] as? String == "ListItem")
        #expect(elements[0]["@id"] as? String == "section-node-id")
        #expect(elements[0]["name"] as? String == "Section")
        #expect(elements[0]["position"] as? Int == 1)
    }

    @Test("ItemList JSON-LD decoding")
    func testJSONLDDecoding() throws {
        let json = """
            {
                "@context": "https://schema.org",
                "@type": "ItemList",
                "@id": "decoded-list-node",
                "identifier": {
                    "@type": "PropertyValue",
                    "propertyID": "apple-reminders:list-id",
                    "value": "decoded-list"
                },
                "name": "Decoded List",
                "numberOfItems": 7,
                "url": "https://example.com/decoded",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "@id": "decoded-section-node",
                        "identifier": {
                            "@type": "PropertyValue",
                            "propertyID": "apple-reminders:section-id",
                            "value": "decoded-section"
                        },
                        "name": "Decoded Section"
                    }
                ]
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let itemList = try decoder.decode(ItemList.self, from: data)

        #expect(itemList.id == "decoded-list-node")
        #expect(itemList.identifier?.propertyID == "apple-reminders:list-id")
        #expect(itemList.identifier?.value == "decoded-list")
        #expect(itemList.name == "Decoded List")
        #expect(itemList.numberOfItems == 7)
        #expect(itemList.url?.absoluteString == "https://example.com/decoded")
        #expect(itemList.itemListElement?.first?.id == "decoded-section-node")
        #expect(itemList.itemListElement?.first?.identifier?.propertyID == "apple-reminders:section-id")
        #expect(itemList.itemListElement?.first?.identifier?.value == "decoded-section")
        #expect(itemList.itemListElement?.first?.name == "Decoded Section")
    }

    @Test("ItemList equality and hashing")
    func testEqualityAndHashing() throws {
        let itemList1 = ItemList(name: "Test List", numberOfItems: 5)
        let itemList2 = ItemList(name: "Test List", numberOfItems: 5)
        let itemList3 = ItemList(name: "Different List", numberOfItems: 5)

        #expect(itemList1 == itemList2)
        #expect(itemList1 != itemList3)
        #expect(itemList1.hashValue == itemList2.hashValue)
    }

    @Test("ItemList type validation on decode")
    func testTypeValidation() throws {
        let invalidJson = """
            {
                "@context": "https://schema.org",
                "@type": "WrongType",
                "name": "Invalid"
            }
            """

        let data = invalidJson.data(using: .utf8)!
        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            try decoder.decode(ItemList.self, from: data)
        }
    }
}
