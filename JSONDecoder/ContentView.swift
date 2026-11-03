
import SwiftUI

@MainActor
class UserData: ObservableObject {
  @Published var users: [User] = []

  // …
}

struct UsersView: View {
  @StateObject var userData = UserData()

  var body: some View {
    NavigationView {
      List(userData.users) { user in
        Text(user.fullName)
      }
      .navigationTitle("Random Users")
    }
  }
}

struct UserFetchingClient {
  static private let url = URL(string: "https://randomuser.me/api/?results=10&format=pretty")!

  static func getUsers() async throws -> [User] {
    async let (data, _) = URLSession.shared.data(from: url)
    let response = try await JSONDecoder().decode(Response.self, from: data)
    return response.users
  }
}

struct Response: Decodable {
    let users: [User]
    
    enum CodingKeys: String, CodingKey {
        case users = "results"
    }
}

struct User: Decodable, Identifiable {
    let id: String
    let name: Name
    
    var fullName: String {
        name.title + ". " + name.first + " " + name.last
      }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(Name.self, forKey: .name)
        let loginInfo = try values.nestedContainer(keyedBy: LoginInfoCodingKeys.self, forKey: .login)
        id = try loginInfo.decode(String.self, forKey: .uuid)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case login
    }
    enum LoginInfoCodingKeys: String, CodingKey {
        case uuid
    }
}

struct Name: Decodable {
    let title: String
    let first: String
    let last: String
}



#Preview {
    UsersView()
}
