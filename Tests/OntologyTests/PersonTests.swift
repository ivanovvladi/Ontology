import Foundation
import Testing

@testable import Ontology

@Suite
struct PersonTests {
    @Test("Person JSON-LD encoding includes Thing name and identifier")
    func testJSONLDEncoding() throws {
        var person = Person(name: "Taylor Example")
        person.id = "person-node-id"
        person.identifier = PropertyValue(
            propertyID: "apple-reminders:assignee-id",
            value: "assignee-id"
        )
        person.alternateName = "Taylor"
        person.email = ["taylor@example.com"]

        let data = try JSONEncoder().encode(person)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "Person")
        #expect(json["@id"] as? String == "person-node-id")
        #expect(json["name"] as? String == "Taylor Example")
        #expect(json["alternateName"] as? String == "Taylor")
        #expect(json["givenName"] as? String == "Taylor")
        #expect(json["familyName"] as? String == "Example")
        #expect(json["email"] as? [String] == ["taylor@example.com"])

        let identifier = json["identifier"] as! [String: Any]
        #expect(identifier["@type"] as? String == "PropertyValue")
        #expect(identifier["propertyID"] as? String == "apple-reminders:assignee-id")
        #expect(identifier["value"] as? String == "assignee-id")
    }

    @Test("Person JSON-LD decoding includes Thing name and identifier")
    func testJSONLDDecoding() throws {
        let json = """
            {
                "@context": "https://schema.org",
                "@type": "Person",
                "@id": "person-node-id",
                "identifier": {
                    "@type": "PropertyValue",
                    "propertyID": "apple-reminders:assignee-id",
                    "value": "assignee-id"
                },
                "name": "Taylor Example",
                "alternateName": "Taylor",
                "givenName": "Taylor",
                "familyName": "Example",
                "email": ["taylor@example.com"]
            }
            """

        let person = try JSONDecoder().decode(
            Person.self,
            from: json.data(using: .utf8)!
        )

        #expect(person.id == "person-node-id")
        #expect(person.identifier?.propertyID == "apple-reminders:assignee-id")
        #expect(person.identifier?.value == "assignee-id")
        #expect(person.name == "Taylor Example")
        #expect(person.alternateName == "Taylor")
        #expect(person.givenName == "Taylor")
        #expect(person.familyName == "Example")
        #expect(person.email == ["taylor@example.com"])
    }
}

