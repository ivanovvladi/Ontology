import Foundation
import Testing

@testable import Ontology

@Suite
struct PropertyValueTests {
    @Test("PropertyValue JSON-LD encoding")
    func testJSONLDEncoding() throws {
        let propertyValue = PropertyValue(
            propertyID: "apple-reminders:reminder-id",
            value: "reminder-id"
        )

        let data = try JSONEncoder().encode(propertyValue)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "PropertyValue")
        #expect(json["propertyID"] as? String == "apple-reminders:reminder-id")
        #expect(json["value"] as? String == "reminder-id")
    }

    @Test("PropertyValue JSON-LD decoding")
    func testJSONLDDecoding() throws {
        let json = """
            {
                "@context": "https://schema.org",
                "@type": "PropertyValue",
                "propertyID": "apple-reminders:reminder-id",
                "value": "reminder-id"
            }
            """

        let propertyValue = try JSONDecoder().decode(
            PropertyValue.self,
            from: json.data(using: .utf8)!
        )

        #expect(propertyValue.propertyID == "apple-reminders:reminder-id")
        #expect(propertyValue.value == "reminder-id")
    }
}

