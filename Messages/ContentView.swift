//
//  ContentView.swift
//  Messages
//
//  Created by William Finnis on 02/08/2021.
//

import SwiftUI

extension URLSession {
    func decode<T: Decodable>(_ type: T.Type = T.self, from url: URL) async throws -> T {
        let (data, _) = try await data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct Message: Codable, Identifiable {
    let id: Int
    let from: String
    let message: String
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let age: Int
}

struct ContentView: View {
    @State var messages = [Message]()
    @State var favourites = [Int]()
    @State var user: User?
    
    var friends: [String: [Message]] {
        Dictionary(
            grouping: messages,
            by: { $0.from }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(friends.keys.sorted(), id: \.self) { friend in
                    Section(header: Text(friend)) {
                        ForEach(friends[friend]!) { message in
                            Text(message.message)
                        }
                    }
                }
            }
            .navigationTitle(user == nil ? "Loading..." : user!.name)
        }
        .task {
            Task {
                let messagesUrl = URL(string: "https://hws.dev/user-messages.json")!
                messages = try await URLSession.shared.decode(from: messagesUrl)
            }
            Task {
                let favouritesUrl = URL(string: "https://hws.dev/user-favorites.json")!
                favourites = try await URLSession.shared.decode(from: favouritesUrl)
            }
            Task {
                let userUrl = URL(string: "https://hws.dev/user-24601.json")!
                user = try await URLSession.shared.decode(from: userUrl)
            }
        }
    }
}
