- [Overview](#overview)
  - [URI Structure](#uri-structure)
  - [Versioning](#versioning)
  - [Response Format](#response-format)
  - [Errors](#errors)
  - [About the API Documentation](#about-the-api-documentation)
- [Authentication](#authentication)
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


## Overview
### URI Structure
All Morsel API requests start with the URL for the API host. The next segment of the URI path depends on the type of request.

### Versioning
Versioning will be part of the HTTP HEADER instead of the URL. We'll worry about it when we get to that point.

### Response Format
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

### Errors

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

### About the API Documentation
__URI Conventions__

| Notation            | Meaning       | Example  |
| ------------------- | ------------- | -------- |
| Curly brackets {}   | Required Item | API_HOST/user/{user_id}/likes <br /><i>The user id is required.</i> |
| Square brackets []  | Optional Item | API_HOST/user/{user_id}/posts[/type] <br /><i>Specifying a Post type is optional (NOTE: This is just an example).</i> |


## Authentication
The API uses two different levels of authentication, depending on the method.

1. __None:__ No authentication. Anybody can query the method.
2. __API key:__ Requires an API key. User API keys are in the following format: {user.id}:{user.auth_token} Example: api_key=3:25TLfL6tvc_Qzx52Zh9q



## User Methods

### POST ```/users``` - Create a new User
Creates a new User and returns an authentication_token

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the new User | | X |
| user[username] | String | The username for the new User. Maximum 15 characters and must start with a letter. Regex: ```[a-zA-Z][A-Za-z0-9_]```| | X |
| user[password] | String | The password for the new User. Minimum 8 characters. | | X |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[title] | String | The title for the new User. In MTP this includes "at <Restaurant>" | | |
| user[bio] | String | The bio for the new User. Maximum 255 characters. | | |

__Example "data" Response__ (Created User)

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "username": "turdferg",
  "first_name": null,
  "last_name": null,
  "sign_in_count": 0,
  "created_at": "2014-01-07T18:35:57.877Z",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "title": "Executive Chef at Jeopardy",
  "twitter_username": null,
  "facebook_uid": "1234567890",
  "bio": "I like turtles",
  "like_count": 0,
  "morsel_count": 1,
  "draft_count": 0,
  "auth_token": "25TLfL6tvc_Qzx52Zh9q"
}
```


### POST ```/users/sign_in``` - User Authentication
Authenticates a User and returns an authentication_token

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the User | | X |
| user[password] | String | The password for the User. Minimum 8 characters. | | X |

__Example "data" Response__ (User)

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "first_name": null,
  "last_name": null,
  "sign_in_count": 1,
  "created_at": "2014-01-07T18:35:57.877Z",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "title": "Executive Chef at Jeopardy",
  "twitter_username": null,
  "facebook_uid": "1234567890",
  "bio": "I like turtles",
  "like_count": 0,
  "morsel_count": 1,
  "draft_count": 0,
  "auth_token": "25TLfL6tvc_Qzx52Zh9q"
}
```

__Unique Errors__

| Message | Status | Description |
| ------- | ------ | ----------- |
| __Invalid email or password__ | 401 (Unauthorized) or 422 (Unprocessable Entity) | The email or password specified are invalid |


### GET ```/users/{user_id|user_username}``` - User
Returns the User with the specified ```user_id``` or ```user_username```
NOTE: In MTP, this will return the User's Posts and their Morsels. After that we'll need to use pagination since there may be too many Posts and Morsels to return in a response.

__Example "data" Response__ (User)

```json
{
  "id": 3,
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "sign_in_count": 1,
  "created_at": "2014-01-07T18:35:57.877Z",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "title": "Executive Chef at Jeopardy",
  "twitter_username": null,
  "facebook_uid": null,
  "bio": "I like turtles",
  "like_count": 0,
  "morsel_count": 1,
  "draft_count": 0
}
```


### PUT ```/users/{user_id}``` - Update User
Updates the User with the specified ```user_id```

__Request__

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

__Example "data" Response__ (Updated User)

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "sign_in_count": 1,
  "created_at": "2014-01-07T18:35:57.877Z",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  },
  "title": "Executive Chef at Jeopardy",
  "twitter_username": null,
  "facebook_uid": "1234567890",
  "bio": "I like turtles",
  "like_count": 0,
  "morsel_count": 1,
  "draft_count": 0
}
```


### GET ```/users/{user_id|user_username}/posts``` - User Posts
Returns the Posts for the User with the specified ```user_id``` or ```user_username```.

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

__Example "data" Response__ (Array of Posts)

```json
[
  {
    "id": 2,
    "title": null,
    "slug": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:44.862Z",
    "morsels": [
      {
        "id": 2,
        "description": null,
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": null,
        "creator_id": 1,
        "created_at": "2014-01-07T16:34:43.071Z",
        "liked": false,
        "draft": false
      }
    ]
  },
  {
    "id": 1,
    "title": null,
    "slug": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:28.012Z",
    "morsels": [
      {
        "id": 1,
        "description": "Some other description!!!!213@!#!@$%",
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id": 1,
        "created_at": "2014-01-07T16:34:27.938Z",
        "liked": true,
        "draft": true
      }
    ]
  }
]
```


### POST ```/users/{user_id}/authorizations``` - Create User Authorizations
Creates a new User authorization

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authorization[provider] | String | The provider the User is authorizing. Currently the only valid values are 'facebook' and 'twitter'. | | X |
| authorization[token] | String | The User's Access Token for the service. | | X |
| authorization[secret] | String | The User's Access Token Secret for the service. Only required for Twitter. | | Twitter |

__Example "data" Response__ (Authorization)

```json
{
  "id": 1,
  "provider": "twitter",
  "uid": "12345",
  "user_id": 3,
  "token": "25T-LfL6tvc_Qzx52Zh9q",
  "secret": "25fqrG3214ojivxCq",
  "name": "eatmorsel",
  "link": "https://twitter.com/eatmorsel"
}
```


### GET ```/users/{user_id}/authorizations``` - User Authorizations
Returns the User's authorizations

__Example "data" Response__ (Array of Authorizations)

```json
[{
  "id": 1,
  "provider": "facebook",
  "uid": "1249832184",
  "user_id": 3,
  "token": "25T-Cac6vtt_QzgfrZh9q",
  "secret": null,
  "name": "Turd Ferguson",
  "link": "https://facebook.com/turd.ferguson"
}, {
  "id": 2,
  "provider": "twitter",
  "uid": "12345",
  "user_id": 3,
  "token": "25T-LfL6tvc_Qzx52Zh9q",
  "secret": "25fqrG3214ojivxCq",
  "name": "eatmorsel",
  "link": "https://twitter.com/eatmorsel"
}]
```



## Morsel Methods

### POST ```/morsels``` - Create a new Morsel
Created a new Morsel for the current User. Optionally append a Morsel to the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the new Morsel | | Only if photo is null |
| morsel[photo] | String | The photo for the new Morsel | | Only if description is null |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |
| post_id | Number | The ID of the Post to append this Morsel to. If none is specified, a new Post will be created for this Morsel. | | |
| post_title | String | If a Post already exists, renames the title to this. Otherwise sets the title for the new Post to this. | | |
| sort_order | Number | The ```sort_order``` for the Morsel in the Post. Requires ```post_id``` | end of Post | |
| post_to_facebook | Boolean | Post to the current_user's Facebook wall with the Post's title and Morsel description (if they exist) along with a link to the Morsel. | false | |
| post_to_twitter | Boolean | Send a Tweet from the current_user with the Post's title and Morsel description (if they exist) along with a link to the Morsel. If the title and description are too long they will be truncated to allow enough room for the links. | false | |

__Example "data" Response__ (Created Morsel)

```json
{
  "id": 4,
  "description": "This is a description!",
  "url": "http://eatmorsel.com/marty/1/butter/1",
  "photos": {
    "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
  },
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z",
  "post_id": 4,
  "liked": false,
  "draft": false
}
```

### GET ```/morsels/{morsel_id}``` - Morsel
Returns Morsel with the specified ```morsel_id```

__Example "data" Response__ (Morsel)

```json
{
  "id": 4,
  "description": "This is a description!",
  "url": "http://eatmorsel.com/marty/1/butter/1",
  "photos": {
    "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
  },
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z",
  "liked": false,
  "draft": false,
  "comments": [{
    "id": 4,
    "description": "Your dish sucks bro!",
    "creator_id": 1,
    "morsel_id": 5,
    "created_at": "2014-01-07T18:37:19.661Z"
  }, {
    "id": 7,
    "description": "Worst dish, eva.",
    "creator_id": 2,
    "morsel_id": 5,
    "created_at": "2014-01-07T18:38:13.855Z"
  }]

}
```


### PUT ```/morsels/{morsel_id}``` - Update Morsel
Updates the Morsel with the specified ```morsel_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the Morsel | | |
| morsel[photo] | String | The photo for the Morsel | | |
| post_id | Number | Changes the ```sort_order``` of a Post when combined with ```sort_order```. | | |
| sort_order | Number | Changes the ```sort_order``` of a Post when combined with ```post_id```. | | |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |

__Example "data" Response__ (Updated Morsel)

```json
{
  "id": 4,
  "description": "This is a modified description!",
  "url": "http://eatmorsel.com/marty/1/butter/1",
  "photos": {
    "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
    "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
  },
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z",
  "liked": false,
  "draft": false
}
```


### DELETE ```/morsels/{morsel_id}``` - Delete Morsel
Deletes the Morsel with the specified ```morsel_id```.

__Example Response__ (HTTP Status Code 200 on success)


### POST ```/morsels/{morsel_id}/like``` - Like Morsel
Likes the Morsel with the specified ```morsel_id``` for the authenticated User

__Example Response__ (HTTP Status Code 200 on success)

__Unique Errors__

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Already liked__ | 400 (Bad Request) | The Morsel is already liked by the User |


### DELETE ```/morsels/{morsel_id}/like``` - Unlike Morsel
Unlikes the Morsel with the specified ```morsel_id``` for the authenticated User

__Example Response__ (HTTP Status Code 200 on success)

__Unique Errors__

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Not liked__ | 404 (Not Found) | The Morsel is not liked by the User |


### POST ```/morsels/{morsel_id}/comments``` - Create Comment
Create a Comment for the Morsel with the specified ```morsel_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| comment[description] | String | The description for the Comment | | |

__Example "data" Response__ (Created Comment)

```json
{
  "id": 4,
  "description": "Your dish sucks bro!",
  "creator_id": 1,
  "morsel_id": 5
  "created_at": "2014-01-07T18:37:19.661Z",
}
```

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Morsel not found__ | 404 (Not Found) | The Morsel could not be found |


### GET ```/morsels/{morsel_id}/comments``` - Morsel Comments
List the Comments for the Morsel with the specified ```morsel_id```

__Example "data" Response__ (Array of Comments)

```json
[{
  "id": 4,
  "description": "Your dish sucks bro!",
  "creator_id": 1,
  "morsel_id": 5,
  "created_at": "2014-01-07T18:37:19.661Z"
}, {
  "id": 7,
  "description": "Worst dish, eva.",
  "creator_id": 2,
  "morsel_id": 5,
  "created_at": "2014-01-07T18:38:13.855Z"
}]
```

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Morsel not found__ | 404 (Not Found) | The Morsel could not be found |


### DELETE ```/comments/{comment_id}``` - Delete Comment
Deletes the Comment with the specified ```comment_id``` if the authenticated User is the Comment or Morsel Creator

__Example Response__ (HTTP Status Code 200 on success)

__Unique Errors__

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Comment not found__ | 404 (Not Found) | The Comment could not be found |
| __Forbidden__ | 403 (Forbidden) | The Authenticated User is not authorized to delete the Comment |



## Post Methods

### GET ```/posts``` - Posts
Returns the Posts for all Users.

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

__Example "data" Response__ (Array of Posts)

```json
[
  {
    "id":1,
    "title":null,
    "slug": null,
    "creator_id":1,
    "created_at":"2014-01-07T16:34:28.012Z",
    "creator": {
      "id": 1,
      "username": "marty",
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "photos": {
        "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
      },
      "title": "Backend Chef at Morsel",
      "twitter_username": "martytrzpit"
      "facebook_uid": null,
    },
    "morsels":[
      {
        "id":1,
        "description":"Some other description!!!!213@!#!@$%",
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id":1,
        "created_at":"2014-01-07T16:34:27.938Z",
        "liked": true,
        "draft": false
      }
    ]
  },
  {
    "id":2,
    "title":null,
    "slug": null,
    "creator_id":1,
    "created_at":"2014-01-07T16:34:44.862Z",
    "creator": {
      "id": 1,
      "username": "marty",
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "photos": {
        "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
      },
      "title": "Backend Chef at Morsel",
      "twitter_username": "martytrzpit"
      "facebook_uid": null,
    },
    "morsels":[
      {
        "id":2,
        "description":null,
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id":1,
        "created_at":"2014-01-07T16:34:43.071Z",
        "liked": false,
        "draft": false
      }
    ]
  },
  {
    "id":3,
    "title":null,
    "slug": null,
    "creator_id":1,
    "created_at":"2014-01-07T18:09:10.996Z",
    "creator": {
      "id": 1,
      "username": "marty",
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "photos": {
        "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
      },
      "title": "Backend Chef at Morsel",
      "twitter_username": "martytrzpit"
      "facebook_uid": null,
    },
    "morsels":[
      {
        "id":3,
        "description":null,
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id":1,
        "created_at":"2014-01-07T18:09:10.145Z",
        "liked": false,
        "draft": false
      }
    ]
  },
  {
    "id":4,
    "title":null,
    "slug": null,
    "creator_id":1,
    "created_at":"2014-01-07T18:37:20.544Z",
    "creator": {
      "id": 1,
      "username": "marty",
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "photos": {
        "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
      },
      "title": "Backend Chef at Morsel",
      "twitter_username": "martytrzpit"
      "facebook_uid": null,
    },
    "morsels":[
      {
        "id":4,
        "description":"This is a modified description!",
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id":1,
        "created_at":"2014-01-07T18:37:19.661Z",
        "liked": false,
        "draft": false
      }
    ]
  },
  {
    "id":5,
    "title":null,
    "slug": null,
    "creator_id":2,
    "created_at":"2014-01-07T19:11:33.937Z",
    "creator": {
      "id": 2,
      "username": "viagra_bob",
      "first_name": "Bob",
      "last_name": "Dole",
      "sign_in_count": 23,
      "created_at": "2014-01-03T11:12:52.763Z",
      "photos": {
        "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
        "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
      },
      "title": "Bob Dole at Bob Dole",
      "twitter_username": null
      "facebook_uid": null,
    },
    "morsels":[
      {
        "id":5,
        "description":"Here's a nice picture of tacos",
        "url": "http://eatmorsel.com/marty/1/butter/1",
        "photos": {
          "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
          "_640x640": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
        },
        "creator_id":2,
        "created_at":"2014-01-07T19:11:33.929Z",
        "liked": false,
        "draft": false
      }
    ]
  }
]
```

### GET ```/posts/{post_id}``` -  Post
Returns the Post with the specified ```post_id```

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

__Example "data" Response__ (Post)

```json
{
  "id": 4,
  "title": null,
  "slug": null,
  "creator_id": 1,
  "created_at": "2014-01-03T22:31:47.113Z"
  "creator": {
    "id": 1,
    "username": "marty",
    "first_name": "Marty",
    "last_name": "Trzpit",
    "sign_in_count": 1,
    "created_at": "2014-01-06T12:30:32.533Z",
    "photos": {
      "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
    },
    "title": "Backend Chef at Morsel"
    "twitter_username": "martytrzpit",
    "facebook_uid": null,
  },
  "morsels":[
    {
      "id":4,
      "description":"This is a modified description!",
      "url": "http://eatmorsel.com/marty/1/butter/1",
      "photos": {
        "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
      },
      "creator_id":1,
      "created_at":"2014-01-07T18:37:19.661Z",
      "liked": false,
      "draft": false
    }
  ]
}
```


### PUT ```/posts/{post_id}``` - Update Post
Updates the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| post[title]         | String  | The title for the Post. Changing this will change the slug. | | |

__Example "data" Response__ (Updated Post)

```json
{
  "id": 4,
  "title": "Look ma! A Title!",
  "slug": "look-ma-a-title",
  "creator_id": 1,
  "created_at": "2014-01-03T22:31:47.113Z"
}
```


### POST ```/posts/{post_id}/append``` - Append Morsel to Post
Appends a Morsel with the specified ```morsel_id``` to the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel_id         | Number  | ID of the Morsel to append | | x |
| sort_order         | Number  | The ```sort_order``` for the Morsel in the Post | end of Post | |
| include_drafts | Boolean | Set to true to return all Morsel drafts | false | |

__Example "data" Response__ (Post with Appended Morsel)

```json
{
  "id": 4,
  "title": null,
  "slug": null,
  "creator_id": 1,
  "created_at": "2014-01-03T22:31:47.113Z"
  "creator": {
    "id": 1,
    "username": "marty",
    "first_name": "Marty",
    "last_name": "Trzpit",
    "sign_in_count": 1,
    "created_at": "2014-01-06T12:30:32.533Z",
    "photos": {
      "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
    },
    "title": "Backend Chef at Morsel",
    "twitter_username": "martytrzpit"
    "facebook_uid": null,
  },
  "morsels":[
    {
      "id":4,
      "description":"This is a modified description!",
      "url": "http://eatmorsel.com/marty/1/butter/1",
      "photos": {
        "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
      },
      "creator_id":1,
      "created_at":"2014-01-07T18:37:19.661Z",
      "liked": false,
      "draft": false
    },
    {
      "id":7,
      "description":"I got appended!",
      "url": "http://eatmorsel.com/marty/1/butter/1",
      "photos": {
        "_104x104": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_208x208": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_320x214": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "_640x428": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png"
      },
      "creator_id":1,
      "created_at":"2014-03-09T18:37:19.661Z",
      "liked": false,
      "draft": false
    }
  ]
}
```

__Unique Errors__

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Relationship already exists__ | 400 (Bad Request) | The Morsel is already appended to the Post |


### DELETE ```/posts/{post_id}/append``` - Detach Morsel from Post
Detaches the Morsel with the specified ```morsel_id``` from the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel_id         | Number  | ID of the Morsel to detach | | x |

__Example Response__ (HTTP Status Code 200 on success)

__Unique Errors__

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Relationship not found__ | 404 (Not Found) | The Morsel is not appended to the Post |



## Subscriber Methods

### POST ```/subscribers``` - Create a new Subscriber
Creates a new Subscriber

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| subscriber[email] | String | The email address for the new Subscriber | | X |
| subscriber[url] | String | The URL of the page on Morsel | | |
| subscriber[source_url] | String | The URL of the page that referred to URL | | |
| subscriber[role] | String | The role of the subscriber. Currently only 'chef' is expected | | |
| subscriber[user_id] | String | The ID of the User who referred the User | | |

__Example Response__ (HTTP Status Code 200 on success)
