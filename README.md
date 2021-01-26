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

Run `amplify console api` to see your search queries and their parameters

This sample provides an extension that makes it easy for you to map exactly what you see in the AppSync console to a GraphQL request.






