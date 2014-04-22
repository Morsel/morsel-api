- [Overview](#overview)
  - [URI Structure](#uri-structure)
  - [Versioning](#versioning)
  - [Response Format](#response-format)
  - [Errors](#errors)
  - [Pagination](#pagination)
  - [About the API Documentation](#about-the-api-documentation)
- [Authentication](#authentication)
- [Constants](#constants)
- [Feed Methods](#feed-methods)
  - [GET ```/feed``` - Feed](#get-feed---feed)
- [User Methods](#user-methods)
  - [POST ```/users``` - Create a new User](#post-users---create-a-new-user)
  - [POST ```/users/sign_in``` - User Authentication](#post-userssign_in---user-authentication)
  - [GET ```/users/me``` - Me](#get-usersme---me)
  - [POST ```/users/unsubscribe``` - Unsubscribe](#post-usersunsubscribe---unsubscribe)
  - [GET ```/users/checkusername``` - Check Username](#get-userscheckusername---check-username)
  - [POST ```/users/reserveusername``` - Reserve Username](#post-usersreserveusername---reserve-username)
  - [PUT ```/users/{user_id}/updateindustry``` - Update Industry](#put-usersuser_idupdateindustry---update-industry)
  - [GET ```/users/{user_id|user_username}``` - User](#get-usersuser_iduser_username---user)
  - [PUT ```/users/{user_id}``` - Update User](#put-usersuser_id---update-user)
  - [GET ```/users/{user_id|user_username}/morsels``` - User Morsels](#get-usersuser_iduser_usernamemorsels---user-morsels)
  - [POST ```/users/authorizations``` - Create User Authorizations](#post-usersauthorizations---create-user-authorizations)
  - [GET ```/users/authorizations``` - User Authorizations](#get-usersauthorizations---user-authorizations)
  - [GET ```/users/activities``` - User Activities](#get-usersactivities---user-activities)
  - [GET ```/users/notifications``` - User Notifications](#get-usersnotifications---user-notifications)
  - [GET ```/users/{user_id}/cuisines``` - User Cuisines](#get-usersuser_idcuisines---user-cuisines)
- [Item Methods](#item-methods)
  - [POST ```/items``` - Create a new Item](#post-items---create-a-new-item)
  - [GET ```/items/{item_id}``` - Item](#get-itemsitem_id---item)
  - [PUT ```/items/{item_id}``` - Update Item](#put-itemsitem_id---update-item)
  - [DELETE ```/items/{item_id}``` - Delete Item](#delete-itemsitem_id---delete-item)
  - [POST ```/items/{item_id}/like``` - Like Item](#post-itemsitem_idlike---like-item)
  - [DELETE ```/items/{item_id}/like``` - Unlike Item](#delete-itemsitem_idlike---unlike-item)
  - [GET ```/items/{item_id}/likers``` - Likers](#get-itemsitem_idlikers---likers)
  - [POST ```/items/{item_id}/comments``` - Create Comment](#post-itemsitem_idcomments---create-comment)
  - [GET ```/items/{item_id}/comments``` - Item Comments](#get-itemsitem_idcomments---item-comments)
  - [DELETE ```/comments/{comment_id}``` - Delete Comment](#delete-commentscomment_id---delete-comment)
- [Morsel Methods](#morsel-methods)
  - [POST ```/morsels``` - Create a new Morsel](#post-morsels---create-a-new-morsel)
  - [GET ```/morsels``` - Morsels](#get-morsels---morsels)
  - [GET ```/morsels/drafts``` - Morsel Drafts](#get-morselsdrafts---morsel-drafts)
  - [GET ```/morsels/{morsel_id}``` - Morsel](#get-morselsmorsel_id----morsel)
  - [PUT ```/morsels/{morsel_id}``` - Update Morsel](#put-morselsmorsel_id---update-morsel)
  - [POST ```/morsels/{morsel_id}/publish``` - Publish Morsel](#post-morselsmorsel_idpublish---Publish-morsel)
  - [DELETE ```/morsels/{morsel_id}``` - Delete Morsel](#delete-morselsmorsel_id---delete-morsel)
- [Cuisine Methods](#cuisine-methods)
  - [GET ```/cuisines``` - Cuisines](#get-cuisines---cuisines)
  - [GET ```/cuisines/{cuisine_id}/users``` - Cuisine Users](#get-cuisinescuisine_id---cuisine-users)
- [Misc Methods](#misc-methods)
  - [GET ```/status``` - Status](#get-status---status)
  - [GET ```/configuration``` - Configuration](#get-configuration---configuration)
- [Response Objects](#response-objects)
  - [Authorization Objects](#authorization-objects)
    - [Authorization](#authorization)
  - [Comment Objects](#comment-objects)
    - [Comment](#comment)
  - [Item Objects](#item-objects)
    - [Item](#item)
    - [Item (for Feed)](#item-for-feed)
    - [Item (w/ Morsel)](#item-w-morsel)
    - [Item (Authenticated)](#item-authenticated)
    - [Item (Authenticated w/ Morsel)](#item-authenticated-w-morsel)
  - [Morsel Objects](#morsel-objects)
    - [Morsel](#morsel)
  - [User Objects](#user-objects)
    - [User](#user)
    - [User (w/ Private Attributes)](#user-w-private-attributes)
    - [User (w/ Auth Token)](#user-w-auth-token)
  - [Feed Objects](#feed-objects)
    - [Feed Item](#feed-item)
  - [Activity Objects](#activity-objects)
    - [Activity](#activity)
  - [Notification Objects](#notification-objects)
    - [Notification](#notification)
  - [Misc Objects](#misc-objects)
    - [Configuration](#configuration)
- [Notes](#notes)
  - [sort_order](#sort_order)

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

if you make a call for a user's morsels: ```users/1/morsels```
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
    "title": "Some Morsel Title"
  }, {
    "id": 5,
    "title": "Another Morsel Title"
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

The API uses a pagination method similar to how Facebook and Twitter do. For a nice article about why and how it works, check out this [link](https://dev.twitter.com/docs/working-with-timelines). You'll use ```max_id``` OR ```since_id``` per API call, don't combine them as the API will ignore it.

### Example

#### Getting the recent Morsels:
Make a call to the API: ```/morsels.json?api_key=whatever&count=10```
The API responds with the 10 most recent Morsels, let's say their id's are from 100-91.

#### Getting a next set of Morsels going back:
Based on the previous results, you want to get Morsels that are older than id 91 (the lowest/oldest id). So you'll want to set a ```max_id``` parameter to that id - 1 (```max_id``` is inclusive, meaning it will include the Morsel with the id passed in the results, which in this case would duplicate a Morsel). So set ```max_id``` to 91-1, 90.
Make a call to the API: ```/morsels.json?api_key=whatever&count=10&max_id=90```
The API responds with the next 10 Morsels, in this case their id's are from 90-81.
And repeat this process as you go further back until you get no results (or ```max_id``` < 1).

#### Getting a set of Morsels going forward (new Morsels):
Apps like Facebook and Twitter will show a floating message while you're scrolling through a list telling you that X new Morsels have been added to the top of your feed.
We can achieve the same thing by sending a call to the API every once awhile asking for any new Morsels since the most recent one you have. To do this, you'll set a ```since_id``` parameter (which is not inclusive) to the id of the most recent Morsel. Continuing the example, this would be ```since_id``` = 100.
Make a call to the API: ```/morsels.json?api_key=whatever&count=10&since_id=100```
The API responds with any new Morsels since the Morsel with id = 100. So if there were three new Morsels added, it would return Morsels with id's from 101-103.

## About the API Documentation
__URI Conventions__

| Notation            | Meaning       | Example  |
| ------------------- | ------------- | -------- |
| Curly brackets {}   | Required Item | API_HOST/morsels/{morsel_id}/likers <br /><i>The `morsel_id` is required.</i> |
| Square brackets []  | Optional Item | API_HOST/feed?[count] <br /><i>Specifying a `count` is optional</i> |


# Authentication
The API uses two different levels of authentication, depending on the method.

1. __None:__ No authentication. Anybody can query the method.
2. __API key:__ Requires an API key. User API keys are in the following format: {user.id}:{user.auth_token} Example: api_key=3:25TLfL6tvc_Qzx52Zh9q

# Constants
```
TIMELINE_DEFAULT_LIMIT = 20
```

# Feed Methods

## GET ```/feed``` - Feed
Returns the Feed for the authenticated User. The Feed consists of [Feed Item](#feed-item)s sorted by their created_at date, with the most recent one's appearing first.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Feed Items up to and including this ```id``` | | |
| since_id | Number | Return Feed Items since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Feed Item](#feed-item) |

<br />
<br />


# User Methods

## POST ```/users``` - Create a new User
Creates a new User and returns an authentication_token
Image processing is done in a background job. `photo_processing` will be set to `null` when it has finished.

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
| __utmz | String | Google Analytics information to pass to the server | | |

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

## GET ```/users/me``` - Me
Returns the authenticated User

### Response

| __data__ |
| -------- |
| [User (w/ Private Attributes)](#user-w-private-attributes) |

<br />
<br />

## POST ```/users/unsubscribe``` - Unsubscribe
Unsubscribes the User with the specified user_id from all emails

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| email | String | The email address for the User | | X |

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## DEPRECATED
## GET ```/users/checkusername``` - Check Username
Returns ```true``` if the username already exists, otherwise ```false```.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| username | String | The username to check | | X |

### Response

| Condition | __data__ |
| --------- | -------- |
| Username does exist | true |
| Username does NOT exist | false |
| Username is invalid | Errors |

<br />
<br />

## GET ```/users/validateusername``` - Check Username
Returns ```true``` if the username is valid, otherwise errors.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| username | String | The username to validate | | X |

### Response

| Condition | __data__ |
| --------- | -------- |
| Username does NOT exist | true |
| Username is invalid or already exists | Errors (see below) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| 'username': ['is required'] | 422 (Unprocessible Entity) | username not passed |
| 'username': ['must be less than 16 characters'] | 422 (Unprocessible Entity) | |
| 'username': ['cannot contain spaces'] | 422 (Unprocessible Entity) | |
| 'username': ['has already been taken'] | 422 (Unprocessible Entity) | username has already been taken or is a reserved path |
| 'username': ['must start with a letter and can only contain alphanumeric characters and underscores'] | 422 (Unprocessible Entity) | |

<br />
<br />

## POST ```/users/reserveusername``` - Reserve Username
Returns the user_id if the user is successfully created, otherwise an error.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[username] | String | The username reserve | | X |
| user[email] | String | The email associated with the username | | X |
| __utmz | String | Google Analytics information to pass to the server | | |

### Response

| Condition | __data__ |
| --------- | -------- |
| User created | ```{user_id: USER_ID}``` |
| Username or Email is invalid | Errors |

<br />
<br />

## PUT ```/users/{user_id}/updateindustry``` - Update Industry
Updates the type ('industry') of the User with the specified user_id
Returns the user_id if the user is successfully created, otherwise an error.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[industry] | String | The User's industry. Currently the only valid values are 'chef', 'diner', and 'media'. | | X |

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## GET ```/users/{user_id|user_username}``` - User
Returns the User with the specified ```user_id``` or ```user_username``` if the User exists and is `active`. Otherwise, returns 404 (Not Found).

### Response

| __data__ |
| -------- |
| [User](#user) |

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

## GET ```/users/{user_id|user_username}/morsels``` - User Morsels
Returns the Morsels for the User with the specified ```user_id``` or ```user_username```.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Morsels up to and including this ```id``` | | |
| since_id | Number | Return Morsels since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Morsel](#morsel) |

<br />
<br />

## POST ```/users/authorizations``` - Create User Authorizations
Creates a new Authorization for the authenticated User

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

## GET ```/users/authorizations``` - User Authorizations
Returns the current User's authorizations

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

## GET ```/users/activities``` - User Activities
Returns the Authenticated User's Activities. An Activity is created when a User likes or comments on a Item. Think Facebook's Activity Log (https://www.facebook.com/<username>/allactivity).

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Activities up to and including this ```id``` | | |
| since_id | Number | Return Authorizations since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Activity](#activity) |

<br />
<br />

## GET ```/users/notifications``` - User Notifications
Returns the Authenticated User's Notifications. A Notification is created when someone likes or comments on your Items. Think Facebook or Twitter Notifications.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Notifications up to and including this ```id``` | | |
| since_id | Number | Return Notifications since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Notification](#notification) |

<br />
<br />

## GET ```/users/{user_id}/cuisines``` - User Cuisines
Returns the Cuisines for the User with the specified ```user_id```.

### Response

| __data__ |
| -------- |
| Array of [Cuisine](#cuisine) |

<br />
<br />


# Item Methods

## POST ```/items``` - Create a new Item
Created a new Item for the current User.
Image processing is done in a background job. `photo_processing` will be set to `null` when it has finished.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| item[description] | String | The description for the new Item | | |
| item[photo] | String | The photo for the new Item | | |
| item[nonce] | String | Unique UUID to prevent duplicates | | |
| item[sort_order] | Number | The ```sort_order``` for the Item in the Morsel. | end of Morsel | |
| item[morsel_id] | Number | The ID of the Morsel to set this Item to. | | X |

### Response

| Condition | __data__ |
| --------- | -------- |
| Authenticated | Created [Item (Authenticated)](#item-authenticated) |
| Default | Created [Item](#item) |

<br />
<br />

## GET ```/items/{item_id}``` - Item
Returns Item with the specified ```item_id```

### Response

| __data__ |
| -------- |
| [Item (Authenticated)](#item-authenticated) |

<br />
<br />

## PUT ```/items/{item_id}``` - Update Item
Updates the Item with the specified ```item_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| item[description] | String | The description for the Item | | |
| item[photo] | String | The photo for the Item | | |
| item[sort_order] | Number | Changes the ```sort_order``` of a Morsel when combined with ```morsel_id```. | | |
| item[morsel_id] | Number | Changes the ```sort_order``` of a Morsel when combined with ```sort_order```. | | |

### Response

| __data__ |
| -------- |
| [Item (Authenticated)](#item-authenticated) |

<br />
<br />

## DELETE ```/items/{item_id}``` - Delete Item
Deletes the Item with the specified ```item_id```.

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## POST ```/items/{item_id}/like``` - Like Item
Likes the Item with the specified ```item_id``` for the authenticated User

### Response

| Status Code |
| ----------- |
|         201 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Already exists__ | 400 (Bad Request) | The Item is already liked by the User |

<br />
<br />

## DELETE ```/items/{item_id}/like``` - Unlike Item
Unlikes the Item with the specified ```item_id``` for the authenticated User

### Response

| Status Code |
| ----------- |
|         200 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Not liked__ | 404 (Not Found) | The Item is not liked by the User |

<br />
<br />

## GET ```/items/{item_id}/likers``` - Likers
Returns the Users who have liked the Item with the specified ```item_id```

### Response

| __data__ |
| -------- |
| Array of [User](#user) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Item not found__ | 404 (Not Found) | The Item could not be found |

<br />
<br />

## POST ```/items/{item_id}/comments``` - Create Comment
Create a Comment for the Item with the specified ```item_id```

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
| __Item not found__ | 404 (Not Found) | The Item could not be found |

<br />
<br />

## GET ```/items/{item_id}/comments``` - Item Comments
List the Comments for the Item with the specified ```item_id```

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
Deletes the Comment with the specified ```comment_id``` if the authenticated User is the Comment or Item Creator

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


# Morsel Methods

## POST ```/morsels``` - Create a new Morsel
Creates a new Morsel for the current User.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[title] | String | The title for the new Morsel | | x |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |

### Response

| __data__ |
| -------- |
| Created [Morsel](#morsel) |

<br />
<br />

## GET ```/morsels``` - Morsels
Returns the Morsels for all Users.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Morsels up to and including this ```id``` | | |
| since_id | Number | Return Morsels since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Morsel](#morsel) |

<br />
<br />

## GET ```/morsels/drafts``` - Morsel Drafts
Returns the Morsel Drafts for the authenticated User sorted by their updated_at, with the most recent one's appearing first.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return Morsels up to and including this ```id``` | | |
| since_id | Number | Return Morsels since this ```id``` | | |

### Response

| __data__ |
| -------- |
| Array of [Morsel](#morsel) |

<br />
<br />

## GET ```/morsels/{morsel_id}``` -  Morsel
Returns the Morsel with the specified ```morsel_id```

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |

### Response

| __data__ |
| -------- |
| [Morsel](#morsel) |

<br />
<br />

## PUT ```/morsels/{morsel_id}``` - Update Morsel
Updates the Morsel with the specified ```morsel_id```

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[title]         | String  | The title for the Morsel. Changing this will change the slug. | | |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |
| morsel[primary_item_id] | Number | The ID of the Item to set as the primary Item for this Morsel. Must be the ID of a Item that is part of the Morsel | | |

### Response

| __data__ |
| -------- |
| Updated [Morsel](#morsel) |

<br />
<br />

POST ```/morsels/{morsel_id}/publish``` - Publish Morsel
Publishes the Morsel with the specified ```morsel_id``` by setting a `published_at` DateTime and `draft`=false

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[primary_item_id] | Number | The ID of the Item to set as the primary Item for this Morsel. Must be the ID of a Item that is part of the Morsel | | |
| post_to_facebook | Boolean | Post to the current_user's Facebook wall with the Morsel's title and a link to the Morsel. | false | |
| post_to_twitter | Boolean | Send a Tweet from the current_user with the Morsel's title and a link to the Morsel. If the title and description are too long they will be truncated to allow enough room for the link. | false | |

### Response

| __data__ |
| -------- |
| Publishes [Morsel](#morsel) |

<br />
<br />


# Cuisine Methods

## GET ```/cuisines``` - Cuisines
Returns the list of Cuisines

### Response

| __data__ |
| -------- |
| Array of [Cuisine](#cuisine) |

<br />
<br />

## GET ```/cuisines/{cuisine_id}/users``` - Cuisine Users
Returns a list of Users who belong to the Cuisine with the specified `cuisine_id`

### Response

| __data__ |
| -------- |
| Array of [User](#user) |

<br />
<br />


# Misc Methods

## GET ```/status``` - Status
Used by third-party services to ping the API.

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## GET ```/configuration``` - Configuration

### Response

| __data__ |
| -------- |
| [Configuration](#configuration) |

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
  "item_id": 5,
  "created_at": "2014-01-07T18:37:19.661Z"
}
```

## Item Objects

### Item

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "updated_at": "2014-01-07T16:34:43.071Z",
    "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    "photos": {
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing": null
  }
```

### Item (for Feed)

```json
  {
    "id": 2,
    "description": null,
    "created_at": "2014-01-07T16:34:43.071Z",
    "updated_at": "2014-01-07T16:34:43.071Z",
    "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    "photos": {
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing": null,
    "in_progression": false,
    "liked": false,
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
      },
      "photo_processing": null
    },
    "morsel": {
      "id": 4,
      "title": "Butter Rocks!",
      "slug": "butter-rocks"
      "created_at": "2014-01-07T16:34:44.862Z",
    }
  }
```

### Item (w/ Morsel)
morsel_id exists

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "updated_at": "2014-01-07T16:34:43.071Z",
    "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    "photos": {
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing": null,
    "morsel_id": 4,
    "sort_order": 1,
    "url": "http://eatmorsel.com/marty/1-butter/1"
  }
```

### Item (Authenticated)
api_key exists

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "updated_at": "2014-01-07T16:34:43.071Z",
    "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    "photos": {
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing": null,
    "liked": false,
  }
```

### Item (Authenticated w/ Morsel)
api_key && morsel_id exist

```json
  {
    "id": 2,
    "description": null,
    "creator_id": 1,
    "created_at": "2014-01-07T16:34:43.071Z",
    "updated_at": "2014-01-07T16:34:43.071Z",
    "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    "photos": {
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing": null,
    "morsel_id": 4,
    "sort_order": 1,
    "url": "http://eatmorsel.com/marty/1-butter/1",
    "liked": false,
  }
```

## Morsel Objects

### Morsel

```json
{
  "id": 4,
  "title": "Butter Rocks!",
  "creator_id": 3,
  "created_at": "2014-01-07T16:34:44.862Z",
  "updated_at": "2014-01-07T16:34:44.862Z",
  "slug": "butter-rocks",
  "draft": false,
  "primary_item_id": 2,
  "published_at": "2014-01-07T16:34:44.862Z",
  "photos": {
    "_800x600":"https://morsel-staging.s3.amazonaws.com/morsel-images/4/648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
  },
  "url": "http://eatmorsel.com/turdferg/4-butter-rocks",
  "facebook_mrsl": "http://mrsl.co/facebook",
  "twitter_mrsl": "http://mrsl.co/twitter",
  "creator": {
    "id": 3,
    "username": "turdferg",
    "first_name": "Turd",
    "last_name": "Ferguson",
    "created_at": "2014-01-07T18:35:57.877Z",
    "updated_at": "2014-01-07T18:35:57.877Z",
    "title": "Executive Chef at Jeopardy",
    "bio": "Suck It, Trebek",
    "photos": {
      "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
      "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
    }
  },
  "items": [
    {
      "id": 2,
      "description": null,
      "creator_id": 3,
      "created_at": "2014-01-07T16:34:43.071Z",
      "updated_at": "2014-01-07T16:34:43.071Z",
      "nonce": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
      "photos": {
        "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
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
  },
  "facebook_uid": "1234567890",
  "twitter_username": "morsel_marty",
  "item_count": 1,
  "like_count": 3
}
```

### User (w/ Private Attributes)
You'll only see these if the api_key matches the User you're looking up.
This includes the same keys as [User](#user), along with:
```json
{
  "staff": true,
  "draft_count": 0,
  "sign_in_count": 1,
  "photo_processing": null
}
```

### User (w/ Auth Token)
This includes the same keys as [User (w/ Private Attributes)](#user-w-private-attributes), along with:

```json
{
  "auth_token": "butt-sack",
}
```


## Feed Objects

### Feed Item

```json
{
  "id":11,
  "created_at":"2014-03-25T21:18:02.349Z",
  "updated_at":"2014-03-25T21:18:02.360Z",
  "subject_type":"Morsel",
  "subject":{
    "id":6,
    "title":"Eum perspiciatis tempora omnis ab qui.",
    "creator_id":null,
    "created_at":"2014-03-25T21:18:02.354Z",
    "updated_at":"2014-03-25T21:18:02.354Z",
    "published_at":"2014-03-25T21:18:02.353Z",
    "draft":false,
    "slug":"eum-perspiciatis-tempora-omnis-ab-qui",
    "creator":null,
    "items":[]
  }
}
```


## Activity Objects

### Activity

```json
{
  "id":2,
  "action_type":"Like",
  "action": {
    "id":6,
    "user_id":2,
    "item_id":3,
    "deleted_at":null,
    "created_at":"2014-04-01T22:05:20.683Z",
    "updated_at":"2014-04-01T22:05:20.683Z"
  },
  "created_at":"2014-03-13T17:01:38.370Z",
  "subject_type":"Item",
  "subject":{
    "id":3,
    "description":"Voluptatem dolores beatae id labore ut corporis tempora id numquam in vel et nemo sed natus quos provident commodi quia quo officiis distinctio qui aut non iure nam illum reprehenderit debitis hic et esse molestiae nulla eaque excepturi quaerat eveniet nisi asperiores voluptate.",
    "creator_id":1,
    "updated_at":"2014-03-13T17:01:37.955Z",
    "created_at":"2014-03-13T17:01:37.955Z",
    "nonce":null,
    "photos":{
      "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
      "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/3/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
    },
    "photo_processing":true,
    "morsel_id":1,
    "sort_order":2,
    "url":"https://test.eatmorsel.com/user_3yugjkugvv/1-rem-adipisci-et-ut-totam-repudiandae-est/2",
    "liked":true
  },
  "creator":{
    "id":2,
    "username":"user_m3m6m78gkr",
    "first_name":"Kody",
    "last_name":"Fritsch",
    "created_at":"2014-03-13T17:01:38.219Z",
    "title":null,
    "bio":"Hi! I like turtles!",
    "photos":null,
    "photo_processing":null
  }
}
```

## Notification Objects

### Notification

```json
{
  "id":4,
  "message":"Drew Muller (user_jtu6g7nacn) liked Enim quia sequi aut vel.: Soluta quo saepe nemo voluptatem... ",
  "created_at":"2014-03-13T17:04:22.411Z",
  "payload_type":"Activity",
  "payload":{
    "id":4,
    "action_type":"Like",
    "action": {
      "id":6,
      "user_id":2,
      "item_id":3,
      "deleted_at":null,
      "created_at":"2014-04-01T22:05:20.683Z",
      "updated_at":"2014-04-01T22:05:20.683Z"
    },
    "created_at":"2014-03-13T17:04:22.403Z",
    "subject_type":"Item",
    "subject":{
      "id":1,
      "description":"Soluta quo saepe nemo voluptatem similique et et veniam ipsa et dolore dolorem beatae nam doloremque enim distinctio quasi in architecto iure ut sit facere reiciendis alias quis.",
      "creator_id":1,
      "updated_at":"2014-03-13T17:04:21.899Z",
      "created_at":"2014-03-13T17:04:21.899Z",
      "nonce":null,
      "photos":{
        "_50x50":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_50x50_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_80x80":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_80x80_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_100x100":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_100x100_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_240x240":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_240x240_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_320x320":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_320x320_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_480x480":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_480x480_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_640x640":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_640x640_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png",
        "_992x992":"https://morsel-staging.s3.amazonaws.com/item-images/item/2/_992x992_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
      },
      "photo_processing":true,
      "morsel_id":1,
      "sort_order":1,
      "url":"https://test.eatmorsel.com/user_qaa0jncv99/1-enim-quia-sequi-aut-vel/1",
      "liked":false
    },
    "creator":{
      "id":5,
      "username":"user_jtu6g7nacn",
      "first_name":"Drew",
      "last_name":"Muller",
      "created_at":"2014-03-13T17:04:22.381Z",
      "title":null,
      "bio":"Hi! I like turtles!",
      "photos":null,
      "photo_processing":null
    }
  }
}
```


## Misc Objects

### Cuisine

```json
{
  "id": 7,
  "name": "African"
}
```

### Configuration
NOTE: "non_username_paths" is just a sample of the real list, for an up to date list of these reserved usernames, see NOTE: [lib/reserved_paths.rb](../lib/reserved_paths.rb)


```json
{
  "non_username_paths": [
    "about",
    "account",
    "tos",
    "translate",
    "trends",
    "unsubscribe",
    "user",
    "users",
    "welcome",
    "who_to_follow",
    "widgets"
  ]
}
```

## Notes

### sort_order
`sort_order` is a property of a Item that determines what the order of it is within a Morsel. `sort_order` is not guaranteed to always be 1,2,3, etc. However, it can always be guaranteed to be in the correct sequential order (e.g. 3,6,8).

Several things can determine the value of `sort_order` depending on how it is passed. Assuming we're creating a Item and passing a `morsel_id`:
```
  if sort_order is passed
    if sort_order is already taken by another Item in that morsel
      increment the sort_order of every item with a sort_order >= passed_sort_order
      sort_order = passed_sort_order
    else
      sort_order = passed_sort_order

  if no sort_order is passed
    if morsel already has Items
      sort_order = morsel.items.maximum(sort_order) + 1
    else
      sort_order = 1
```
