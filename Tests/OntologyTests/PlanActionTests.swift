import Foundation
import Testing

@testable import Ontology

@Suite
struct PlanActionTests {
    @Test("PlanAction basic initialization")
    func testBasicInitialization() throws {
        let planAction = PlanAction(
            name: "Buy groceries",
            dueDate: Date(timeIntervalSince1970: 1_640_995_200),  // 2022-01-01
            description: "Weekly grocery shopping",
            completed: false
        )

        #expect(planAction.name == "Buy groceries")
        #expect(planAction.description == "Weekly grocery shopping")
        #expect(planAction.status == .potential)
        #expect(planAction.scheduledTime?.value == Date(timeIntervalSince1970: 1_640_995_200))
    }

    @Test("PlanAction completed status")
    func testCompletedStatus() throws {
        let planAction = PlanAction(
            name: "Complete project",
            completed: true
        )

        #expect(planAction.status == .completed)
    }

    @Test("PlanAction status enum values")
    func testStatusEnumValues() throws {
        #expect(PlanAction.Status.active.rawValue == "ActiveAction")
        #expect(PlanAction.Status.completed.rawValue == "CompletedAction")
        #expect(PlanAction.Status.failed.rawValue == "FailedAction")
        #expect(PlanAction.Status.potential.rawValue == "PotentialAction")
    }

    @Test("PlanAction JSON-LD encoding")
    func testJSONLDEncoding() throws {
        var planAction = PlanAction(
            name: "Test task",
            dueDate: Date(timeIntervalSince1970: 1_640_995_200),
            description: "A test task",
            completed: false
        )
        planAction.id = "test-node-id"
        planAction.identifier = PropertyValue(
            propertyID: "apple-reminders:reminder-id",
            value: "test-id"
        )
        planAction.priority = 5
        planAction.url = URL(string: "https://example.com/task")
        planAction.agent = Person(name: "Taylor Example")
        planAction.agent?.id = "person-node-id"
        planAction.agent?.identifier = PropertyValue(
            propertyID: "apple-reminders:assignee-id",
            value: "assignee-id"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(planAction)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "PlanAction")
        #expect(json["@id"] as? String == "test-node-id")
        #expect(json["name"] as? String == "Test task")
        #expect(json["description"] as? String == "A test task")
        #expect(json["actionStatus"] as? String == "PotentialAction")
        #expect(json["priority"] as? Int == 5)
        #expect(json["url"] as? String == "https://example.com/task")

        let identifier = json["identifier"] as! [String: Any]
        #expect(identifier["@type"] as? String == "PropertyValue")
        #expect(identifier["propertyID"] as? String == "apple-reminders:reminder-id")
        #expect(identifier["value"] as? String == "test-id")

        let agent = json["agent"] as! [String: Any]
        #expect(agent["@type"] as? String == "Person")
        #expect(agent["@id"] as? String == "person-node-id")
        #expect(agent["name"] as? String == "Taylor Example")
        #expect(agent["givenName"] as? String == "Taylor")
        #expect(agent["familyName"] as? String == "Example")

        let agentIdentifier = agent["identifier"] as! [String: Any]
        #expect(agentIdentifier["@type"] as? String == "PropertyValue")
        #expect(agentIdentifier["propertyID"] as? String == "apple-reminders:assignee-id")
        #expect(agentIdentifier["value"] as? String == "assignee-id")
    }

    @Test("PlanAction JSON-LD decoding")
    func testJSONLDDecoding() throws {
        let json = """
            {
                "@context": "https://schema.org",
                "@type": "PlanAction",
                "@id": "test-node-id",
                "identifier": {
                    "@type": "PropertyValue",
                    "propertyID": "apple-reminders:reminder-id",
                    "value": "test-id"
                },
                "name": "Decoded task",
                "description": "A decoded task",
                "actionStatus": "CompletedAction",
                "priority": 3,
                "url": "https://example.com/decoded",
                "agent": {
                    "@type": "Person",
                    "@id": "person-node-id",
                    "identifier": {
                        "@type": "PropertyValue",
                        "propertyID": "apple-reminders:assignee-id",
                        "value": "assignee-id"
                    },
                    "name": "Taylor Example",
                    "givenName": "Taylor",
                    "familyName": "Example"
                }
            }
            """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let planAction = try decoder.decode(PlanAction.self, from: data)

        #expect(planAction.id == "test-node-id")
        #expect(planAction.identifier?.propertyID == "apple-reminders:reminder-id")
        #expect(planAction.identifier?.value == "test-id")
        #expect(planAction.name == "Decoded task")
        #expect(planAction.description == "A decoded task")
        #expect(planAction.status == .completed)
        #expect(planAction.priority == 3)
        #expect(planAction.url?.absoluteString == "https://example.com/decoded")
        #expect(planAction.agent?.id == "person-node-id")
        #expect(planAction.agent?.identifier?.propertyID == "apple-reminders:assignee-id")
        #expect(planAction.agent?.identifier?.value == "assignee-id")
        #expect(planAction.agent?.name == "Taylor Example")
        #expect(planAction.agent?.givenName == "Taylor")
        #expect(planAction.agent?.familyName == "Example")
    }

    @Test("PlanAction with ItemList object")
    func testPlanActionWithItemList() throws {
        var planAction = PlanAction(
            name: "Task in list",
            completed: false
        )

        var itemList = ItemList(
            name: "My Tasks",
            numberOfItems: 10,
            itemListElement: [
                ListItem(
                    identifier: PropertyValue(
                        propertyID: "apple-reminders:section-id",
                        value: "section-id"
                    ),
                    name: "Today"
                )
            ]
        )
        itemList.identifier = PropertyValue(
            propertyID: "apple-reminders:list-id",
            value: "list-id"
        )
        planAction.object = itemList

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(planAction)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["@context"] as? String == "https://schema.org")
        #expect(json["@type"] as? String == "PlanAction")
        #expect(json["name"] as? String == "Task in list")

        let object = json["object"] as! [String: Any]
        #expect(object["@type"] as? String == "ItemList")
        #expect(object["name"] as? String == "My Tasks")
        #expect(object["numberOfItems"] as? Int == 10)

        let objectIdentifier = object["identifier"] as! [String: Any]
        #expect(objectIdentifier["@type"] as? String == "PropertyValue")
        #expect(objectIdentifier["propertyID"] as? String == "apple-reminders:list-id")
        #expect(objectIdentifier["value"] as? String == "list-id")

        let elements = object["itemListElement"] as! [[String: Any]]
        #expect(elements.first?["@type"] as? String == "ListItem")
        #expect(elements.first?["name"] as? String == "Today")
    }

    @Test("PlanAction equality and hashing")
    func testEqualityAndHashing() throws {
        let planAction1 = PlanAction(name: "Test", completed: false)
        let planAction2 = PlanAction(name: "Test", completed: false)
        let planAction3 = PlanAction(name: "Different", completed: false)

        #expect(planAction1 == planAction2)
        #expect(planAction1 != planAction3)
        #expect(planAction1.hashValue == planAction2.hashValue)
    }
}
