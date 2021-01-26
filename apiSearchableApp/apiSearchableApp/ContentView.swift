//
//  ContentView.swift
//  apiSearchableApp
//
//  Created by Law, Michael on 1/26/21.
//

import SwiftUI
import Amplify
import AWSPluginsCore

struct AppSyncSearchResponse<Element: Model>: Codable {
    let items: [Element]
    let nextToken: String?
    let total: Int?
}

extension GraphQLRequest {
    static func search<M: Model>(_ modelType: M.Type,
                                 filter: [String: Any]? = nil,
                                 from: Int? = nil,
                                 limit: Int? = nil,
                                 nextToken: String? = nil,
                                 sort: QuerySortBy? = nil) -> GraphQLRequest<AppSyncSearchResponse<M>> {
        let name = modelType.modelName
        let documentName = "search" + name + "s"
        var variables = [String: Any]()
        if let filter = filter {
            variables.updateValue(filter, forKey: "filter")
        }
        if let from = from {
            variables.updateValue(from, forKey: "from")
        }
        if let limit = limit {
            variables.updateValue(limit, forKey: "limit")
        }
        if let nextToken = nextToken {
            variables.updateValue(nextToken, forKey: "nextToken")
        }
        if let sort = sort {
            switch sort {
            case .ascending(let field):
                let sort = [
                    "direction": "asc",
                    "field": field.stringValue
                ]
                variables.updateValue(sort, forKey: "sort")
            case .descending(let field):
                let sort = [
                    "direction": "desc",
                    "field": field.stringValue
                ]
                variables.updateValue(sort, forKey: "sort")
            }
        }
        let graphQLFields = modelType.schema.sortedFields.filter { field in
            !field.hasAssociation || field.isAssociationOwner
        }.map { (field) -> String in
            field.name
        }.joined(separator: "\n      ")
        let document = """
        query \(documentName)($filter: Searchable\(name)FilterInput, $from: Int, $limit: Int, $nextToken: String, $sort: Searchable\(name)SortInput) {
          \(documentName)(filter: $filter, from: $from, limit: $limit, nextToken: $nextToken, sort: $sort) {
            items {
              \(graphQLFields)
            }
            nextToken
            total
          }
        }
        """
        return GraphQLRequest<AppSyncSearchResponse<M>>(document: document,
                                                        variables: variables.count != 0 ? variables : nil,
                                                        responseType: AppSyncSearchResponse<M>.self,
                                                        decodePath: documentName)
    }
}

struct ContentView: View {
    func createBlog() {
        let blog = Blog6(name: "my first blog")
        Amplify.API.mutate(request: .create(blog)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let blog):
                    print("Successfully created the blog: \(blog)")
                case .failure(let graphQLError):
                    print("Failed to create graphql \(graphQLError)")
                }
            case .failure(let apiError):
                print("Failed to create a todo", apiError)
            }
        }
    }
    
    func searchBlogs() {
        let filter: [String: Any] = [
            "name": [
                "matchPhrase": "first"
            ]
        ]
        Amplify.API.query(request: .search(Blog6.self,
                                           filter: filter,
                                           limit: 1000,
                                           sort: QuerySortBy.ascending(Blog6.keys.id))) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let blogs):
                    print("Successfully searched blogs: \(blogs)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }

    
    var body: some View {
        VStack {
            Button("create blog", action: {
                createBlog()
            })
            Button("search blog", action: {
                searchBlogs()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




