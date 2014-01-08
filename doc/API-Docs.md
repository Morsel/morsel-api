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
  - [PUT ```/users/{user_id}``` - Update User](#put-usersuser_id---update-user)
  - [GET ```/users/{user_id}/posts``` - User Posts](#get-usersuser_idposts---user-posts)
- [Morsel Methods](#morsel-methods)
  - [POST ```/morsels``` - Create a new Morsel](#post-morsels---create-a-new-morsel)
  - [GET ```/morsels/{morsel_id}``` - Morsel](#get-morselsmorsel_id---morsel)
  - [PUT ```/morsels/{morsel_id}``` - Update Morsel](#put-morselsmorsel_id---update-morsel)
  - [DELETE ```/morsels/{morsel_id}``` - Delete Morsel](#delete-morselsmorsel_id---delete-morsel)
- [Post Methods](#post-methods)
  - [GET ```/posts``` - Posts](#get-posts---posts)
  - [GET ```/posts/{post_id}``` - Post](#get-postspost_id---post)
  - [PUT ```/posts/{post_id}``` - Update Post](#put-postspost_id---update-post)


## Overview
### URI Structure
All Morsel API requests start with the URL for the API host. The next segment of the URI path depends on the type of request.

### Versioning
Versioning will be part of the HTTP HEADER instead of the URL. We'll worry about it when we get to that point.

### Response Format
The API returns JSON-encoded objects (content-type: application/json) for the resource requested, unless an error occurs. Any additional metadata (like pagination info) will be returned in the HTTP response headers.

So if you request a user: ```/users/1```
expect to get a user resource in return:
```json
{
  "id": 1,
  "email": "turdferguson@eatmorsel.com",
  "first_name": "Turd",
  "last_name": "Ferguson"
}
```

if you make a call for a user's posts: ```users/1/posts```
expect to get an array of resources in return:
```json
[{
  "id": 4,
  "title": "Some Post Title"
}, {
  "id": 5,
  "title": "Another Post Title"
}]
```

### Errors

Errors are returned as an array with an ```errors``` key. This lets the client handle how it wants to display multiple errors:
```json
{
  "errors": [
    {
      "msg": "Email has already been taken"
    }, {
      "msg": "Password is too short (minimum is 8 characters)"
    }
  ]
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
| user[password] | String | The password for the new User. Minimum 8 characters. | | X |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[profile] | File | The profile picture for the new User. Can be GIF, JPG, or PNG. | | |

__Example Response__
Created User

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "first_name": null,
  "last_name": null,
  "sign_in_count": 0,
  "created_at": "2014-01-07T18:35:57.877Z",
  "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg",
  "auth_token=": "25TLfL6tvc_Qzx52Zh9q"
}
```


### POST ```/users/sign_in``` - User Authentication
Authenticates a User and returns an authentication_token

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the User | | X |
| user[password] | String | The password for the User. Minimum 8 characters. | | X |

__Example Response__
User

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "first_name": null,
  "last_name": null,
  "sign_in_count": 1,
  "created_at": "2014-01-07T18:35:57.877Z",
  "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg",
  "auth_token=": "25TLfL6tvc_Qzx52Zh9q"
}
```


### PUT ```/users/{user_id}``` - Update User
Updates the User with the specified ```user_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the new User | | |
| user[password] | String | The password for the new User. Minimum 8 characters. | | |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[profile] | File | The profile picture for the new User. Can be GIF, JPG, or PNG. | | |

__Example Response__
Updated User

```json
{
  "id": 3,
  "email": "turdferg@eatmorsel.com",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "sign_in_count": 1,
  "created_at": "2014-01-07T18:35:57.877Z",
  "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg",
}
```


### GET ```/users/{user_id}/posts``` - User Posts
Returns the Posts for the User with the specified ```user_id```.

__Example Response__
Array of Posts

```json
[
  {
    "id": 4,
    "description": "This is a description!",
    "photo_url": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
    "creator_id": 1,
    "created_at": "2014-01-07T18:37:19.661Z",
    "post_id": 4
  },
  {
    "id": 2,
    "title": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:44.862Z",
    "morsels": [
      {
        "id": 2,
        "description": null,
        "photo_url": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "creator_id": 1,
        "created_at": "2014-01-07T16:34:43.071Z"
      }
    ]
  },
  {
    "id": 1,
    "title": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:28.012Z",
    "morsels": [
      {
        "id": 1,
        "description": "Some other description!!!!213@!#!@$%",
        "photo_url": null,
        "creator_id": 1,
        "created_at": "2014-01-07T16:34:27.938Z"
      }
    ]
  }
]
```


## Morsel Methods

### POST ```/morsels``` - Create a new Morsel
Created a new Morsel for the current User. Optionally append a Morsel to the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the new Morsel | | Only if photo is null |
| morsel[photo] | String | The photo for the new Morsel | | Only if description is null |
| post_id | Number | The ID of the Post to append this Morsel to. If none is specified, a new Post will be created for this Morsel. | | |
| post_title | String | If a Post already exists, renames the title to this. Otherwise sets the title for the new Post to this. | | |

__Example Response__
Created Morsel

```json
{
  "id": 4,
  "description": "This is a description!",
  "photo_url": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z",
  "post_id": 4
}
```

### GET ```/morsels/{morsel_id}``` - Morsel
Returns Morsel with the specified ```morsel_id```

__Example Response__
Morsel

```json
{
  "id": 4,
  "description": "This is a description!",
  "photo_url": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z"
}
```


### PUT ```/morsels/{morsel_id}``` - Update Morsel
Updates the Morsel with the specified ```morsel_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[description] | String | The description for the Morsel | | |
| morsel[photo] | String | The photo for the Morsel | | |

__Example Response__
Updated Morsel

```json
{
  "id": 4,
  "description": "This is a modified description!",
  "photo_url": "https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
  "creator_id": 1,
  "created_at": "2014-01-07T18:37:19.661Z"
}
```


### DELETE ```/morsels/{morsel_id}``` - Delete Morsel
Deletes the Morsel with the specified ```morsel_id```. Returns a 200 Status Code on success.


## Post Methods

### GET ```/posts``` - Posts
Returns the Posts for all Users.

__Example Response__
Array of Posts

```json
[
  {
    "id":1,
    "title":null,
    "creator_id":1,
    "created_at":"2014-01-07T16:34:28.012Z",
    "creator": {
      "id": 1,
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
    },
    "morsels":[
      {
        "id":1,
        "description":"Some other description!!!!213@!#!@$%",
        "photo_url":null,
        "creator_id":1,
        "created_at":"2014-01-07T16:34:27.938Z"
      }
    ]
  },
  {
    "id":2,
    "title":null,
    "creator_id":1,
    "created_at":"2014-01-07T16:34:44.862Z",
    "creator": {
      "id": 1,
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
    },
    "morsels":[
      {
        "id":2,
        "description":null,
        "photo_url":"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/1389112483-morsel.png",
        "creator_id":1,
        "created_at":"2014-01-07T16:34:43.071Z"
      }
    ]
  },
  {
    "id":3,
    "title":null,
    "creator_id":1,
    "created_at":"2014-01-07T18:09:10.996Z",
    "creator": {
      "id": 1,
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
    },
    "morsels":[
      {
        "id":3,
        "description":null,
        "photo_url":"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/3/1389118150-morsel.png",
        "creator_id":1,
        "created_at":"2014-01-07T18:09:10.145Z"
      }
    ]
  },
  {
    "id":4,
    "title":null,
    "creator_id":1,
    "created_at":"2014-01-07T18:37:20.544Z",
    "creator": {
      "id": 1,
      "first_name": "Marty",
      "last_name": "Trzpit",
      "sign_in_count": 1,
      "created_at": "2014-01-06T12:30:32.533Z",
      "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
    },
    "morsels":[
      {
        "id":4,
        "description":"This is a modified description!",
        "photo_url":"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
        "creator_id":1,
        "created_at":"2014-01-07T18:37:19.661Z"
      }
    ]
  },
  {
    "id":5,
    "title":null,
    "creator_id":2,
    "created_at":"2014-01-07T19:11:33.937Z",
    "creator": {
      "id": 2,
      "first_name": "Bob",
      "last_name": "Dole",
      "sign_in_count": 23,
      "created_at": "2014-01-03T11:12:52.763Z",
      "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
    },
    "morsels":[
      {
        "id":5,
        "description":"Here's a nice picture of tacos",
        "photo_url":null,
        "creator_id":2,
        "created_at":"2014-01-07T19:11:33.929Z"
      }
    ]
  }
]
```

### GET ```/posts/{post_id}``` -  Post
Returns the Post with the specified ```post_id```

__Example Response__
Post

```json
{
  "id": 4,
  "title": null,
  "creator_id": 1,
  "created_at": "2014-01-03T22:31:47.113Z"
  "creator": {
    "id": 1,
    "first_name": "Marty",
    "last_name": "Trzpit",
    "sign_in_count": 1,
    "created_at": "2014-01-06T12:30:32.533Z",
    "profile_url": "https://morsel-staging.s3.amazonaws.com/profile-images/user/3/1389119757-batman.jpeg"
  },
  "morsels":[
    {
      "id":4,
      "description":"This is a modified description!",
      "photo_url":"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/4/1389119839-morsel.png",
      "creator_id":1,
      "created_at":"2014-01-07T18:37:19.661Z"
    }
  ]
}
```


### PUT ```/posts/{post_id}``` - Update Post
Updates the Post with the specified ```post_id```

__Request__

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| post[title]         | String  | The title for the Post | | |

__Example Response__
Updated Post

```json
{
  "id": 4,
  "title": "Look ma! A Title!",
  "creator_id": 1,
  "created_at": "2014-01-03T22:31:47.113Z"
}
```
