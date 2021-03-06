import Vapor
import FluentPostgreSQL
import UAParserSwift

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("") { req in
        req.redirect(to: "members")
    }

    router.get("members") { req -> Future<View> in
        var sortBy: String = "waniKaniStartDate"

        if let membersQuery = try? req.query.decode(MembersQuery.self) {
            sortBy = membersQuery.sortBy
        }

        let members: QueryBuilder<PostgreSQLDatabase, Member> = {
            switch sortBy {
            case "waniKaniStartDate":
                return Member.query(on: req).sort(\Member.waniKaniStartDate)

            case "username":
                return Member.query(on: req).sort(\Member.username)

            case "level":
                return Member.query(on: req).sort(\Member.level)

            case "apprentice":
                return Member.query(on: req).sort(\Member.apprentice)

            case "guru":
                return Member.query(on: req).sort(\Member.guru)

            case "master":
                return Member.query(on: req).sort(\Member.master)

            case "enlightened":
                return Member.query(on: req).sort(\Member.enlightened)

            case "burned":
                return Member.query(on: req).sort(\Member.burned)

            case "unlocked":
                return Member.query(on: req).sort(\Member.unlocked)

            case "unlocksPerDay":
                return Member.query(on: req).sort(\Member.unlocksPerDay)

            case "nativeLanguages":
                return Member.query(on: req).sort(\Member.nativeLanguages)

            case "ajcJoinDate":
                return Member.query(on: req).sort(\Member.ajcJoinDate)

            default:
                return Member.query(on: req).sort(\Member.waniKaniStartDate)
            }
        }()

        return members.all().flatMap(to: View.self) { members in
            let average = Average(
                level:          Double(members.reduce(0) { $0 + $1.level })         / Double(members.count),
                apprentice:     Double(members.reduce(0) { $0 + $1.apprentice })    / Double(members.count),
                guru:           Double(members.reduce(0) { $0 + $1.guru })          / Double(members.count),
                master:         Double(members.reduce(0) { $0 + $1.master })        / Double(members.count),
                enlightened:    Double(members.reduce(0) { $0 + $1.enlightened })   / Double(members.count),
                burned:         Double(members.reduce(0) { $0 + $1.burned })        / Double(members.count),
                unlocked:       Double(members.reduce(0) { $0 + $1.unlocked })      / Double(members.count),
                unlocksPerDay:  Double(members.reduce(0) { $0 + $1.unlocksPerDay }) / Double(members.count)
            )

            return try req.view().render("Members/index", MembersIndexContext(members: members, average: average, sortBy: sortBy))
        }
    }

    router.get("members", "new") { req -> Future<View> in
        let browserSupportsDateInput: Bool = {
            if let userAgentString = req.http.headers["User-Agent"].first {
                let userAgent: UAParser = UAParser(agent: userAgentString)

                if let browser: Browser = userAgent.browser {
                    switch browser.name {
                    case "Firefox", "Chrome", "Opera", "Android Browser", "Chromium", "Edge", "Baidu":
                        return true

                    default:
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        }()

        return try req.view().render("Members/new", MembersNewContext(browserSupportsDateInput: browserSupportsDateInput))
    }

    router.post("members") { req -> Future<View> in
        return try req.content.decode(MemberInput.self).flatMap { memberInput in
            return Member.query(on: req).all().flatMap { members in
                guard !members.contains(where: { $0.apiKey == memberInput.apiKey }) else {
                    throw HTTPError(identifier: "existingUser", reason: "User with given API key already exists.")
                }

                return try WaniKaniFetchService().fetchUserSRSDistribution(on: req, apiKey: memberInput.apiKey).flatMap { waniKaniUserSRSDistribution in
                    return Member(memberInput: memberInput, waniKaniUserSRSDistribution: waniKaniUserSRSDistribution).create(on: req).flatMap { member in
                        try req.view().render("success")
                    }
                }
            }
        }
    }
}
