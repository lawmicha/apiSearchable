### How to create a searchable API query to your AppSync service

#### Pre-req

This uses the schema from `schema.graphql` so you can go straight ahead into

1. `amplify init`

2. `amplify add api` and choose GraphQL, and use `schema.graphql`

3. `amplify push`

4. `cd apiSearchableApp` and run `pod install`

5. `xed` to open the app

### Searchable query

The schema contains a model with `@searchable` annotated
```
type Blog6 @model @searchable {
  id: ID!
  name: String!
  posts: [Post6] @connection(keyName: "byBlog", fields: ["id"])
}
```

Run `amplify console api` and navigate to the Queries tab, and determine the search query you want to perform and its parameters.

This sample provides an extension that makes it easy to map to a AppSync search query.

```swift
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
```
Extension https://gist.github.com/lawmicha/d8a9453a3dfdc976f4cfa976a9c4eb30






