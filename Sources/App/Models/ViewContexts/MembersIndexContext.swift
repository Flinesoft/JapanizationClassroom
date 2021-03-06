import Vapor

struct MembersIndexContext: Encodable {
    let members: [Member]
    let average: Average
    let sortBy: String
}
