- [Overview](#overview)
  - [URI Structure](#uri-structure)
  - [Versioning](#versioning)
  - [Response Format](#response-format)
  - [Errors](#errors)
  - [Pagination](#pagination)
  - [About the API Documentation](#about-the-api-documentation)
- [Authentication](#authentication)
- [Constants](#constants)
- [User Methods](#user-methods)
  - [POST ```/users``` - Create a new User](#post-users---create-a-new-user)
  - [POST ```/users/sign_in``` - User Authentication](#post-userssign_in---user-authentication)
  - [GET ```/users/{user_id|user_username}``` - User](#get-usersuser_iduser_username---user)
  - [PUT ```/users/{user_id}``` - Update User](#put-usersuser_id---update-user)
  - [GET ```/users/{user_id|user_username}/posts``` - User Posts](#get-usersuser_iduser_usernameposts---user-posts)
  - [POST ```/users/{user_id}/authorizations``` - Create User Authorizations](#post-usersuser_idauthorizations---create-user-authorizations)
  - [GET ```/users/{user_id}/authorizations``` - User Authorizations](#get-usersuser_idauthorizations---user-authorizations)
- [Morsel Methods](#morsel-methods)
  - [POST ```/morsels``` - Create a new Morsel](#post-morsels---create-a-new-morsel)
  - [GET ```/morsels/{morsel_id}``` - Morsel](#get-morselsmorsel_id---morsel)
  - [PUT ```/morsels/{morsel_id}``` - Update Morsel](#put-morselsmorsel_id---update-morsel)
  - [DELETE ```/morsels/{morsel_id}``` - Delete Morsel](#delete-morselsmorsel_id---delete-morsel)
  - [POST ```/morsels/{morsel_id}/like``` - Like Morsel](#post-morselsmorsel_idlike---like-morsel)
  - [DELETE ```/morsels/{morsel_id}/like``` - Unlike Morsel](#delete-morselsmorsel_idlike---unlike-morsel)
  - [POST ```/morsels/{morsel_id}/comments``` - Create Comment](#post-morselsmorsel_idcomments---create-comment)
  - [GET ```/morsels/{morsel_id}/comments``` - Morsel Comments](#get-morselsmorsel_idcomments---morsel-comments)
  - [DELETE ```/comments/{comment_id}``` - Delete Comment](#delete-commentscomment_id---delete-comment)
- [Post Methods](#post-methods)
  - [GET ```/posts``` - Posts](#get-posts---posts)
  - [GET ```/posts/{post_id}``` - Post](#get-postspost_id---post)
  - [PUT ```/posts/{post_id}``` - Update Post](#put-postspost_id---update-post)
  - [POST ```/posts/{post_id}/append``` - Append Morsel to Post](#post-postspost_idappend---append-morsel-to-post)
  - [DELETE ```/posts/{post_id}/append``` - Detach Morsel from Post](#delete-postspost_idappend---detach-morsel-from-post)
- [Subscriber Methods](#subscriber-methods)
  - [POST ```/subscribers``` - Create a new Subscriber](#post-subscribers---create-a-new-subscriber)
- [Response Objects](#response-objects)
  - [Authorization Objects](#authorization-objects)
    - [Authorization](#authorization)
  - [Comment Objects](#comment-objects)
    - [Comment](#comment)
  - [Morsel Objects](#morsel-objects)
    - [Morsel](#morsel)
    - [Morsel (w/ Post)](#morsel-w-post)
    - [Morsel (Authenticated)](#morsel-authenticated)
    - [Morsel (Authenticated w/ Post)](#morsel-authenticated-w-post)
    - [Morsel (Authenticated w/ Comments)](#morsel-authenticated-w-comments)
  - [Post Objects](#post-objects)
    - [Post](#post)
  - [User Objects](#user-objects)
    - [User](#user)
    - [User (w/ Private Attributes)](#user-w-private-attributes)
    - [User (w/ Auth Token)](#user-w-auth-token)


# Overview
## URI Structure
All Morsel API requests start with the URL for the API host. The next segment of the URI path depends on the type of request.

## Versioning
Versioning will be part of the HTTP HEADER instead of the URL. We'll worry about it when we get to that point.

## Response Format
The API returns a JSON-encoded object (content-type: application/json) that wraps the response data with extra information such as errors and other metadata.

So if you request a user: ```/users/1```
expect to get a user resource in return:
```json
{
  "meta": {
    "status": 200,
    "message": "OK"
  },
  "errors": null,
  "data": {
    "id": 1,
    "email": "turdferguson@eatmorsel.com",
    "first_name": "Turd",
    "last_name": "Ferguson"
  }
}
```

if you make a call for a user's posts: ```users/1/posts```
expect to get an array of resources in return:
```json
{
  "meta": {
    "status": 200,
    "message": "OK"
  },
  "errors": null,
  "data": [{
    "id": 4,
    "title": "Some Post Title"
  }, {
    "id": 5,
    "title": "Another Post Title"
  }]
```

## Errors

Errors are returned as a dictionary in ```errors```. Each key represents the resource the error originated from or 'api' if none is specified
```json
{
  "meta": {
    "status": 400,
    "message": "Bad Request"
  },
  "errors": {
    "password": [
      "is too short",
      "should be cooler"
    ],
    "api": [
      "access denied"
    ]
  },
  "data": null
}
```

## Pagination

The API uses a pagination method similar to how Facebook and Twitter do. For a nice post about why and how it works, check out this [link](https://dev.twitter.com/docs/working-with-timelines). You'll use ```max_id``` OR ```since_id``` per API call, don't combine them as the API will ignore it.

### Example

#### Getting the recent Posts:
Make a call to the API: ```/posts.json?api_key=whatever&count=10```
The API responds with the 10 most recent Posts, let's say their id's are from 100-91.

#### Getting a next set of Posts going back:
Based on the previous results, you want to get Posts that are older than id 91 (the lowest/oldest id). So you'll want to set a ```max_id``` parameter to that id - 1 (```max_id``` is inclusive, meaning it will include the Post with the id passed in the results, which in this case would duplicate a Post). So set ```max_id``` to 91-1, 90.
Make a call to the API: ```/posts.json?api_key=whatever&count=10&max_id=90```
The API responds with the next 10 Posts, in this case their id's are from 90-81.
And repeat this process as you go further back until you get no results (or ```max_id``` < 1).

#### Getting a set of Posts going forward (new Posts):
Apps like Facebook and Twitter will show a floating message while you're scrolling through a list telling you that X new Posts have been added to the top of your feed.
We can achieve the same thing by sending a call to the API every once awhile asking for any new Posts since the most recent one you have. To do this, you'll set a ```since_id``` parameter (which is not inclusive) to the id of the most recent Post. Continuing the example, this would be ```since_id``` = 100.
Make a call to the API: ```/posts.json?api_key=whatever&count=10&since_id=100```
The API responds with any new Posts since the Post with id = 100. So if there were three new Posts added, it would return Posts with id's from 101-103.

## About the API Documentation
__URI Conventions__

| Notation            | Meaning       | Example  |
| ------------------- | ------------- | -------- |
| Curly brackets {}   | Required Item | API_HOST/user/{user_id}/likes <br /><i>The user id is required.</i> |
| Square brackets []  | Optional Item | API_HOST/user/{user_id}/posts[/type] <br /><i>Specifying a Post type is optional (NOTE: This is just an example).</i> |


# Authentication
The API uses two different levels of authentication, depending on the method.

1. __None:__ No authentication. Anybody can query the method.
2. __API key:__ Requires an API key. User API keys are in the following format: {user.id}:{user.auth_token} Example: api_key=3:25TLfL6tvc_Qzx52Zh9q

# Constants
```
TIMELINE_DEFAULT_LIMIT = 20
```

# User Methods

## POST ```/users``` - Create a new User
Creates a new User and returns an authentication_token

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the new User | | X |
| user[username] | String | The username for the new User. Maximum 15 characters and must start with a letter. Regex: ```[a-zA-Z][A-Za-z0-9_]```| | X |
| user[password] | String | The password for the new User. Minimum 8 characters. | | X |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[title] | String | The title for the new User. In MTP this includes "at <Restaurant>" | | |
| user[photo] | File | The profile photo for the new User. Can be GIF, JPG, or PNG. | | |
| user[bio] | String | The bio for the new User. Maximum 255 characters. | | |

### Response

| __data__ |
| -------- |
| Created [User (w/ Auth Token)](#user-w-auth-token) |

<br />
<br />

## POST ```/users/sign_in``` - User Authentication
Authenticates a User and returns an authentication_token

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the User | | X |
| user[password] | String | The password for the User. Minimum 8 characters. | | X |

### Response

| __data__ |
| -------- |
| Authenticated [User (w/ Auth Token)](#user-w-auth-token) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ | ----------- |
| __Invalid email or password__ | 401 (Unauthorized) or 422 (Unprocessable Entity) | The email or password specified are invalid |

<br />
<br />

## GET ```/users/{user_id|user_username}``` - User
Returns the User with the specified ```user_id``` or ```user_username```
NOTE: This currently returns the User's Posts and Morsels. It's highly inefficient so the returning of Posts and Morsels in this call will be deprecated soon.

### Response

| Condition | __data__ |
| --------- | -------- |
| Authenticated User's ID or Username | [User (w/ Private Attributes)](#user-w-private-attributes) |
| Everyone Else | [User](#user) |

<br />
<br />

## PUT ```/users/{user_id}``` - Update User
Updates the User with the specified ```user_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the new User | | |
| user[username] | String | The username for the new User. Better if you don't allow the User to change this. | | |
| user[password] | String | The password for the new User. Minimum 8 characters. | | |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[title] | String | The title for the new User. In MTP this includes "at <Restaurant>" | | |
| user[photo] | File | The profile photo for the new User. Can be GIF, JPG, or PNG. | | |
| user[bio] | String | The bio for the new User. Maximum 255 characters | | |

### Response

| Condition | __data__ |
| --------- | -------- |
| Authenticated User's ID or Username | Updated [User (w/ Private Attributes)](#user-w-private-attributes) |
| Everyone Else | Updated [User](#user) |

<br />
<br />

## GET ```/users/{user_id|user_username}/posts``` - User Posts
Returns the Posts for the User with the specified ```user_id``` or ```user_username```.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Posts up to and including this ```id``` | | |
| since_id | Number | Return Posts since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Post](#post) |

<br />
<br />

## POST ```/users/{user_id}/authorizations``` - Create User Authorizations
Creates a new User authorization

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authorization[provider] | String | The provider the User is authorizing. Currently the only valid values are 'facebook' and 'twitter'. | | X |
| authorization[token] | String | The User's Access Token for the service. | | X |
| authorization[secret] | String | The User's Access Token Secret for the service. Only required for Twitter. | | Twitter |

### Response

| __data__ |
| -------- |
| Created [Authorization](#authorization) |

<br />
<br />

## GET ```/users/{user_id}/authorizations``` - User Authorizations
Returns the User's authorizations

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Authorizations up to and including this ```id``` | | |
| since_id | Number | Return Authorizations since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Authorization](#authorization) |

<br />
<br />


# Morsel Methods

## POST ```/morsels``` - Create a new Morsel
Created a new Morsel for the current User. Optionally append a Morsel to the Post with the specified ```post_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the new Morsel | | Only if photo is null |
| morsel[photo] | String | The photo for the new Morsel | | Only if description is null |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |
| post_id | Number | The ID of the Post to append this Morsel to. If none is specified, a new Post will be created for this Morsel. | | |
| post_title | String | If a Post already exists, renames the title to this. Otherwise sets the title for the new Post to this. | | |
| sort_order | Number | The ```sort_order``` for the Morsel in the Post. Requires ```post_id``` | end of Post | |
| post_to_facebook | Boolean | Post to the current_user's Facebook wall with the Post's title and Morsel description (if they exist) along with a link to the Morsel. __Requires a ```post_id```.__ | false | |
| post_to_twitter | Boolean | Send a Tweet from the current_user with the Post's title and Morsel description (if they exist) along with a link to the Morsel. If the title and description are too long they will be truncated to allow enough room for the links. __Requires a ```post_id```.__ | false | |

### Response

| Condition | __data__ |
| --------- | -------- |
| Authenticated | Created [Morsel (Authenticated)](#morsel-authenticated) |
| Appended to Post | Created [Morsel (w/ Post)](#morsel-w-post) |
| Authenticated && Appended to Post | Created [Morsel (Authenticated w/ Post)](#morsel-authenticated-w-post) |
| Default | Created [Morsel](#morsel) |

<br />
<br />

## GET ```/morsels/{morsel_id}``` - Morsel
Returns Morsel with the specified ```morsel_id```

### Response

| __data__ |
| -------- |
| [Morsel (Authenticated w/ Comments)](#morsel-authenticated-w-comments) |

<br />
<br />

## PUT ```/morsels/{morsel_id}``` - Update Morsel
Updates the Morsel with the specified ```morsel_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the Morsel | | |
| morsel[photo] | String | The photo for the Morsel | | |
| post_id | Number | Changes the ```sort_order``` of a Post when combined with ```sort_order```. | | |
| sort_order | Number | Changes the ```sort_order``` of a Post when combined with ```post_id```. | | |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |
| new_post_id | Number | Associates the Morsel to the Post with ID ```new_post_id``` and removes the previous relationship | | |
| post_to_facebook | Boolean | Post to the current_user's Facebook wall with the Post's title and Morsel description (if they exist) along with a link to the Morsel. __Requires a ```post_id``` or ```new_post_id```.__ | false | |
| post_to_twitter | Boolean | Send a Tweet from the current_user with the Post's title and Morsel description (if they exist) along with a link to the Morsel. If the title and description are too long they will be truncated to allow enough room for the links. __Requires a ```post_id``` or ```new_post_id```.__ | false | |

### Response

| Condition | __data__ |
| --------- | -------- |
| Post ID Included | Updated [Morsel (Authenticated w/ Post)](#morsel-authenticated-w-post) |
| Default | Updated [Morsel (Authenticated w/ Comments)](#morsel-authenticated-w-comments) |

<br />
<br />

## DELETE ```/morsels/{morsel_id}``` - Delete Morsel
Deletes the Morsel with the specified ```morsel_id```.

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## POST ```/morsels/{morsel_id}/like``` - Like Morsel
Likes the Morsel with the specified ```morsel_id``` for the authenticated User

### Response

| Status Code |
| ----------- |
|         200 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Already exists__ | 400 (Bad Request) | The Morsel is already liked by the User |

<br />
<br />

## DELETE ```/morsels/{morsel_id}/like``` - Unlike Morsel
Unlikes the Morsel with the specified ```morsel_id``` for the authenticated User

### Response

| Status Code |
| ----------- |
|         200 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Not liked__ | 404 (Not Found) | The Morsel is not liked by the User |

<br />
<br />

## POST ```/morsels/{morsel_id}/comments``` - Create Comment
Create a Comment for the Morsel with the specified ```morsel_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| comment[description] | String | The description for the Comment | | |

### Response

| __data__ |
| -------- |
| Created [Comment](#comment) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Morsel not found__ | 404 (Not Found) | The Morsel could not be found |

<br />
<br />

## GET ```/morsels/{morsel_id}/comments``` - Morsel Comments
List the Comments for the Morsel with the specified ```morsel_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Comments up to and including this ```id``` | | |
| since_id | Number | Return Comments since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Comment](#comment) |

<br />
<br />

## DELETE ```/comments/{comment_id}``` - Delete Comment
Deletes the Comment with the specified ```comment_id``` if the authenticated User is the Comment or Morsel Creator

### Response

| Status Code |
| ----------- |
|         200 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Comment not found__ | 404 (Not Found) | The Comment could not be found |
| __Forbidden__ | 403 (Forbidden) | The Authenticated User is not authorized to delete the Comment |

<br />
<br />


# Post Methods

## GET ```/posts``` - Posts
Returns the Posts for all Users.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Posts up to and including this ```id``` | | |
| since_id | Number | Return Posts since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Post](#post) |

<br />
<br />

## GET ```/posts/{post_id}``` -  Post
Returns the Post with the specified ```post_id```

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

### Response

| __data__ |
| -------- |
| [Post](#post) |

<br />
<br />

## PUT ```/posts/{post_id}``` - Update Post
Updates the Post with the specified ```post_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| post[title]         | String  | The title for the Post. Changing this will change the slug. | | |

### Response

| __data__ |
| -------- |
| Updated [Post](#post) |

<br />
<br />

## POST ```/posts/{post_id}/append``` - Append Morsel to Post
Appends a Morsel with the specified ```morsel_id``` to the Post with the specified ```post_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel_id         | Number  | ID of the Morsel to append | | x |
| sort_order         | Number  | The ```sort_order``` for the Morsel in the Post | end of Post | |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

### Response

| __data__ |
| -------- |
| Updated [Post](#post) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Relationship already exists__ | 400 (Bad Request) | The Morsel is already appended to the Post |

<br />
<br />

## DELETE ```/posts/{post_id}/append``` - Detach Morsel from Post
Detaches the Morsel with the specified ```morsel_id``` from the Post with the specified ```post_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel_id         | Number  | ID of the Morsel to detach | | x |

### Response

| Status Code |
| ----------- |
|         200 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Relationship not found__ | 404 (Not Found) | The Morsel is not appended to the Post |

<br />
<br />


# Subscriber Methods

## POST ```/subscribers``` - Create a new Subscriber
Creates a new Subscriber

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| subscriber[email] | String | The email address for the new Subscriber | | X |
| subscriber[url] | String | The URL of the page on Morsel | | |
| subscriber[source_url] | String | The URL of the page that referred to URL | | |
| subscriber[role] | String | The role of the subscriber. Currently only 'chef' is expected | | |
| subscriber[user_id] | String | The ID of the User who referred the User | | |

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />


# Response Objects

## Authorization Objects

### Authorization

```json
{
  "id": 1,
  "provider": "twitter",
  "uid": "12345",
  "user_id": 3,
  "token": "123-aB32C$F21gR1",
  "secret": "25fqrG3214ovvasCq",
  "name": "eatmorsel",
  "link": "https://twitter.com/eatmorsel"
}
```

## Comment Objects

### Comment

```json
{
  "id": 4,
  "description": "Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!",
  "creator": {
    "id": 1,
    "username": "marty",
    "first_name": "Marty",
    "last_name": "Trzpit",
    "photos": {
      "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
      "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
      "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
      "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg"
    }
  },
  "morsel_id": 5,
  "created_at": "2014-01-07T18:37:19.661Z"
}
```

## Morsel Objects

### Morsel

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "photos": {
      "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
    }
  }
```

### Morsel (w/ Post)
post_id exists

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "photos": {
      "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
    },
    "post_id": 4,
    "sort_order": 1,
    "url": "http://eatmorsel.com/marty/1-butter/1"
  }
```

### Morsel (Authenticated)
api_key exists

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "photos": {
      "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
    },
    "liked": false,
    "draft": false
  }
```

### Morsel (Authenticated w/ Post)
api_key && post_id exist

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "photos": {
      "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
    },
    "post_id": 4,
    "sort_order": 1,
    "url": "http://eatmorsel.com/marty/1-butter/1",
    "liked": false,
    "draft": false
  }
```

### Morsel (Authenticated w/ Comments)
ditto as w/ Post if post_id exists

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "photos": {
      "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
      "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
    },
    "liked": false,
    "draft": false,
    "comments": [{
      "id": 4,
      "description": "Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!",
      "creator": {
        "id": 1,
        "username": "marty",
        "first_name": "Marty",
        "last_name": "Trzpit",
        "photos": {
          "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
          "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
          "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg",
          "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/1/1389119757-batman.jpeg"
        }
      },
      "morsel_id": 5,
      "created_at": "2014-01-07T18:37:19.661Z"
    }, {
      "id": 7,
      "description": "Fuck yeah!",
      "creator": {
        "id": 3,
        "username": "turdferg",
        "first_name": "Turd",
        "last_name": "Ferguson",
        "photos": {
          "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
          "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
          "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
          "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
        }
      },
      "morsel_id": 5,
      "created_at": "2014-01-07T18:38:13.855Z"
    }]
  }
```

## Post Objects

### Post

```json
{
  "id": 4,
  "title": "Butter Rocks!",
  "creator_id": 3,
  "created_at": "2014-01-07T16:34:44.862Z",
  "slug": "butter-rocks",
  "creator": {
    "id": 3,
    "username": "turdferg",
    "first_name": "Turd",
    "last_name": "Ferguson",
    "created_at": "2014-01-07T18:35:57.877Z",
    "title": "Executive Chef at Jeopardy",
    "bio": "Suck It, Trebek",
    "photos": {
      "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
    }
  },
  "morsels": [
    {
      "id": 2,
      "description": null,
      "creator_id": 3,
      "created_at": "2014-01-07T16:34:43.071Z",
      "photos": {
        "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
      },
      "sort_order": 1,
      "url": "http://eatmorsel.com/turdferg/4-butter-rocks/1"
    }
  ]
}
```


## User Objects

### User

```json
{
  "id": 3,
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "created_at": "2014-01-07T18:35:57.877Z",
  "title": "Executive Chef at Jeopardy",
  "bio": "Suck It, Trebek",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  }
}
```

### User (w/ Private Attributes)
You'll only see these if the api_key matches the User you're looking up

```json
{
  "id": 3,
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "created_at": "2014-01-07T18:35:57.877Z",
  "title": "Executive Chef at Jeopardy",
  "bio": "Suck It, Trebek",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "draft_count": 0,
  "like_count": 3,
  "morsel_count": 1,
  "sign_in_count": 1,
  "facebook_uid": "1234567890",
  "twitter_username": "morsel_marty"
}
```

### User (w/ Auth Token)
Same as [User (w/ Private Attributes)](#user-w-private-attributes) but with ```auth_token```

```json
{
  "id": 3,
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "created_at": "2014-01-07T18:35:57.877Z",
  "title": "Executive Chef at Jeopardy",
  "bio": "Suck It, Trebek",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "auth_token": "butt-sack",
  "draft_count": 0,
  "like_count": 3,
  "morsel_count": 1,
  "sign_in_count": 1,
  "facebook_uid": "1234567890",
  "twitter_username": "morsel_marty"
}
```
