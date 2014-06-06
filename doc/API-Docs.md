- [Overview](#overview)
  - [URI Structure](#uri-structure)
  - [Versioning](#versioning)
  - [Response Format](#response-format)
  - [Errors](#errors)
  - [About the API Documentation](#about-the-api-documentation)

- [API Authentication](#api-authentication)

- [Constants](#constants)

- [Behaviors](#behaviors)
  - [Followable](#followable)
    - [POST `/{{followables}}/:id/follow` - Follow {{Followable}}](#post-followablesidfollow---follow-followable)
    - [DELETE `/{{followables}}/:id/follow` - Unfollow {{Followable}}](#delete-followablesidfollow---unfollow-followable)
    - [GET `/{{followables}}/:id/followers` - {{Followable}} Followers](#get-followablesidfollowers---followable-followers)
  - [Pagination](#pagination)

- [Feed Methods](#feed-methods)
  - [GET `/feed` - Feed](#get-feed---feed)

- [Authentication Methods](#authentication-methods)
  - [POST `/authentications` - Create Authentication](#post-authentications---create-authentication)
  - [GET `/authentications` - Authentications](#get-authentications---authentications)
  - [PUT `/authentications/:id` - Update Authentication](#put-authenticationsid---update-authentication)
  - [DELETE `/authentications/:id` - Delete Authentication](#delete-authenticationsid---delete-authentication)
  - [GET `/authentications/check` - Authentication Check](#get-authenticationscheck---authentication-check)
  - [GET `/authentications/connections` - Authentication Connections](#get-authenticationsconnections---authentication-connections)

- [User Methods](#user-methods) [\<Followable\>](#followable)
  - [POST `/users` - Create a new User](#post-users---create-a-new-user)
  - [POST `/users/sign_in` - User Authentication](#post-userssign_in---user-authentication)
  - [POST `/users/forgot_password` - Forgot Password](#post-usersforgot_password---forgot-password)
  - [POST `/users/reset_password` - Reset Password](#post-usersreset_password---reset-password)
  - [GET `/users/me` - Me](#get-usersme---me)
  - [GET `/users/search` - Search Users](#get-userssearch---search-users)
  - [POST `/users/unsubscribe` - Unsubscribe](#post-usersunsubscribe---unsubscribe)
  - [GET `/users/validate_email` - Validate Email](#get-usersvalidate_email---validate-_email)
  - [GET `/users/validateusername` - Validate Username](#get-usersvalidateusername---validate-username)
  - [POST `/users/reserveusername` - Reserve Username](#post-usersreserveusername---reserve-username)
  - [PUT `/users/:id/updateindustry` - Update Industry](#put-usersidupdateindustry---update-industry)
  - [GET `/users/:id|:username` - User](#get-usersidusername---user)
  - [PUT `/users/:id` - Update User](#put-usersid---update-user)
  - [GET `/users/:id|:username/morsels` - User Morsels](#get-usersidusernamemorsels---user-morsels)
  - [GET `/users/activities` - User Activities](#get-usersactivities---user-activities)
  - [GET `/users/followables_activities` - User Followables Activities](#get-usersfollowables_activities---user-followables-activities)
  - [GET `/users/notifications` - User Notifications](#get-usersnotifications---user-notifications)
  - [GET `/users/:id/likeables` - User Likeables](#get-usersidlikeables---user-likeables)
  - [POST `/users/:id/tags` - Create User Tag](#post-usersidtags---create-user-tag)
  - [DELETE `/users/:id/tags/:tag_id` - Delete User Tag](#delete-usersidtagstag_id---delete-user-tag)
  - [GET `/users/:id/cuisines` - User Cuisines](#get-usersidcuisines---user-cuisines)
  - [GET `/users/:id/specialties` - User Specialties](#get-usersidspecialties---user-specialties)
  - [GET `/users/:id/followables` - User Followables](#get-usersidfollowables---user-followables)
  - [GET `/users/:id/places` - User Places](#get-usersidplaces---user-places)

- [Place Methods](#place-methods) [\<Followable\>](#followable)
  - [GET `/places/suggest` - Suggest Completion](#get-placessuggest---suggest-completion)
  - [POST `/places/join` - Join User w/ Place](#post-placesjoin---join-user-w-place)
  - [GET `/places/:id` - Place](#get-placesid--place)
  - [GET `/places/:id/users` - Place Users](#get-placesidusers--place-users)

- [Item Methods](#item-methods)
  - [POST `/items` - Create a new Item](#post-items---create-a-new-item)
  - [GET `/items/:id` - Item](#get-itemsid---item)
  - [PUT `/items/:id` - Update Item](#put-itemsid---update-item)
  - [DELETE `/items/:id` - Delete Item](#delete-itemsid---delete-item)
  - [POST `/items/:id/like` - Like Item](#post-itemsidlike---like-item)
  - [DELETE `/items/:id/like` - Unlike Item](#delete-itemsidlike---unlike-item)
  - [GET `/items/:id/likers` - Likers](#get-itemsidlikers---likers)
  - [POST `/items/:id/comments` - Create Comment](#post-itemsidcomments---create-comment)
  - [GET `/items/:id/comments` - Item Comments](#get-itemsidcomments---item-comments)
  - [DELETE `/items/:id/comments/:comment_id` - Delete Comment](#delete-itemsidcommentscomment_id---delete-comment)

- [Morsel Methods](#morsel-methods)
  - [POST `/morsels` - Create a new Morsel](#post-morsels---create-a-new-morsel)
  - [GET `/morsels` - Morsels](#get-morsels---morsels)
  - [GET `/morsels/drafts` - Morsel Drafts](#get-morselsdrafts---morsel-drafts)
  - [GET `/morsels/:id` - Morsel](#get-morselsid----morsel)
  - [PUT `/morsels/:id` - Update Morsel](#put-morselsid---update-morsel)
  - [POST `/morsels/:id/publish` - Publish Morsel](#post-morselsidpublish---Publish-morsel)
  - [DELETE `/morsels/:id` - Delete Morsel](#delete-morselsid---delete-morsel)

- [Keyword Methods](#keyword-methods) [\<Followable\>](#followable)
  - [GET `/cuisines` - Cuisines](#get-cuisines---cuisines)
  - [GET `/cuisines/:id/users` - Cuisine Users](#get-cuisinesidusers---cuisine-users)
  - [GET `/specialties` - Specialties](#get-specialties---specialties)
  - [GET `/specialties/:id/users` - Specialty Users](#get-specialtiesidusers---specialty-users)

- [Misc Methods](#misc-methods)
  - [GET `/status` - Status](#get-status---status)
  - [GET `/configuration` - Configuration](#get-configuration---configuration)

- [Response Objects](#response-objects)
  - [Authentication Objects](#authentication-objects)
    - [Authentication](#authentication)
  - [Comment Objects](#comment-objects)
    - [Comment](#comment)
  - [Item Objects](#item-objects)
    - [Item](#item)
    - [Liked Item](#liked-item)
  - [Morsel Objects](#morsel-objects)
    - [Slim Morsel](#slim-morsel)
    - [Morsel](#morsel)
  - [User Objects](#user-objects)
    - [Slim User](#slim-user)
    - [Slim Followed User](#slim-followed-user)
    - [User](#user)
    - [User (w/ Private Attributes)](#user-w-private-attributes)
    - [User (w/ Auth Token)](#user-w-auth-token)
  - [Place Objects](#place-objects)
    - [Slim Place](#slim-place)
    - [Place](#place)
  - [Tag Objects](#tag-objects)
    - [Tag](#tag)
    - [Keyword](#keyword)
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

So if you request a user: `/users/1`
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

if you make a call for a user's morsels: `users/1/morsels`
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

Errors are returned as a dictionary in `errors`. Each key represents the resource the error originated from or 'api' if none is specified
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

# API Authentication
The API uses two different levels of authentication, depending on the method.

1. __None:__ No authentication. Anybody can query the method.
2. __API key:__ Requires an API key. User API keys are in the following format: `user.id`:`user.auth_token` Example: api_key=3:25TLfL6tvc_Qzx52Zh9q


# Terminology

## current_user
`current_user` refers to the User accessing the API via an `api_key`.

# Constants
```
TIMELINE_DEFAULT_LIMIT = 20
```

# Behaviors
Since a lot of functionality is shared between different resources within the app, certain behaviors have been defined to DRY the API Docs (and code). An example of this is following a User, Place, or Keyword. All three can be followed so we can call any of them _'Followable'_ and define a set of behaviors for anything that can be _'Followable'_. Angled brackets are used a placeholders for the resource that you are dealing with. For example, if you want to follow a Place, you would substitute 'Place' into the [`/{{followables}}/:id/follow`](#post-followablesidfollow---follow-followable) call and get: `/places/:id/follow`. Other existing behaviors will be added here in the future (like pagination)

# Followable

## POST `/{{followables}}/:id/follow` - Follow _{{Followable}}_
Follows the _{{Followable}}_ with the specified `id`.

### Response

| Status Code |
| ----------- |
|         201 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __already followed__ | 400 (Bad Request) | [current_user](#current_user) has already followed the _{{Followable}}_ |

<br />
<br />

## DELETE `/{{followables}}/:id/follow` - Unfollow _{{Followable}}_
Unfollows the _{{Followable}}_ with the specified `id`.

### Response

| Status Code |
| ----------- |
|         204 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __not followed__ | 400 (Bad Request) | [current_user](#current_user) has not followed that _{{Followable}}_ |

<br />
<br />

## GET `/{{followables}}/:id/followers` - _{{Followable}}_ Followers
Returns the followers for the _{{Followable}}_ with the specified `id`.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [User Followers](#user-follower)[] |

<br />
<br />

# Pagination

The API uses a pagination method similar to how Facebook and Twitter do. For a nice article about why and how it works, check out this [link](https://dev.twitter.com/docs/working-with-timelines). You'll use `max_id` OR `since_id` per API call, don't combine them as the API will ignore it.

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| count | Number | The number of results to return | [TIMELINE_DEFAULT_LIMIT](#constants) | |
| max_id | Number | Return results up to and including this `id` | | |
| since_id | Number | Return results since this `id` | | |


## Example

### Getting the recent Morsels:
Make a call to the API: `/morsels.json?api_key=whatever&count=10`
The API responds with the 10 most recent Morsels, let's say their id's are from 100-91.

### Getting a next set of Morsels going back:
Based on the previous results, you want to get Morsels that are older than id 91 (the lowest/oldest id). So you'll want to set a `max_id` parameter to that id - 1 (`max_id` is inclusive, meaning it will include the Morsel with the id passed in the results, which in this case would duplicate a Morsel). So set `max_id` to 91-1, 90.
Make a call to the API: `/morsels.json?api_key=whatever&count=10&max_id=90`
The API responds with the next 10 Morsels, in this case their id's are from 90-81.
And repeat this process as you go further back until you get no results (or `max_id` < 1).

### Getting a set of Morsels going forward (new Morsels):
Apps like Facebook and Twitter will show a floating message while you're scrolling through a list telling you that X new Morsels have been added to the top of your feed.
We can achieve the same thing by sending a call to the API every once awhile asking for any new Morsels since the most recent one you have. To do this, you'll set a `since_id` parameter (which is not inclusive) to the id of the most recent Morsel. Continuing the example, this would be `since_id` = 100.
Make a call to the API: `/morsels.json?api_key=whatever&count=10&since_id=100`
The API responds with any new Morsels since the Morsel with id = 100. So if there were three new Morsels added, it would return Morsels with id's from 101-103.


# Feed Methods

## GET `/feed` - Feed
Returns the Feed. If [current_user](#current_user) exists, the results will include your Feed Items, any followed Users' Feed Items, any followed Places' Feed Items, and any Feed Items marked as `featured`. If no [current_user](#current_user) exists only Feed Items marked as `featured` will be returned. In either case results are sorted by their `created_at` date, with the most recent one's appearing first.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Feed Items](#feed-item)[] |

<br />
<br />


# Authentication Methods

## POST `/authentications` - Create Authentication
Creates a new Authentication for [current_user](#current_user)

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authentication[provider] | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | X |
| authentication[uid] | String | The User's ID for the provider. | | X |
| authentication[token] | String | The User's Access Token for the provider. | | X |
| authentication[secret] | String | The User's Access Token Secret for the provider. Only required for Twitter. | | Twitter |
| authentication[short_lived] | Boolean | Set to `true` if the token passed is a short-lived token. | false | |

### Response

| __data__ |
| -------- |
| Created [Authentication](#authentication) |

<br />
<br />

## GET `/authentications` - Authentications
Returns authentications for [current_user](#current_user)

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Authentications](#authentication)[] |

<br />
<br />

## PUT `/authentications/:id` - Update Authentication
Updates the authentication with the specified `id`

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authentication[provider] | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | |
| authentication[uid] | String | The User's ID for the provider. | | |
| authentication[token] | String | The User's Access Token for the provider. | | |
| authentication[secret] | String | The User's Access Token Secret for the provider. Only required for Twitter. | | Twitter |
| authentication[short_lived] | Boolean | Set to `true` if the token passed is a short-lived token. | | |

### Response

| __data__ |
| -------- |
| Updated [Authentication](#authentication) |

<br />
<br />

## DELETE `/authentications/:id` - Delete Authentication
Deletes the authentication with the specified `id`

### Response

| Status Code |
| ----------- |
|         204 |

<br />
<br />

## GET `/authentications/check` - Authentication Check
Returns `true` if the authentication exists, otherwise false.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authentication[provider] | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | |
| authentication[uid] | String | The User's ID for the provider. | | |

### Response

| Condition | __data__ |
| --------- | -------- |
| Authentication exists | true |
| Authentication does NOT exists | false |

<br />
<br />

## GET `/authentications/connections` - Authentication Connections
Returns the Users that have authenticated with the specified `provider` and have a `uid` that is in `uids`.

__Request Behaviors__
* [Pagination](#pagination)

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| provider | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | X |
| uids | String | Comma-separated `uid` strings for the `provider` specified. e.g. "'12345','67890'" | | X |

### Response

| __data__ |
| -------- |
| [Users](#user)[] found in `uids` for the specified `provider` |

<br />
<br />


# User Methods
* [\<Followable\>](#followable)

## POST `/users` - Create a new User
Creates a new User and returns an authentication_token.
Image processing is done in a background job. `photo_processing` will be set to `null` when it has finished.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the new User | | X |
| user[username] | String | The username for the new User. Maximum 15 characters and must start with a letter. Regex: `[a-zA-Z][A-Za-z0-9_]`| | X |
| user[password] | String | The password for the new User. Minimum 8 characters. If an authentication is passed and this field is omitted the User's password will be randomly generated. | | X |
| user[first_name] | String | The first name for the new User. | | |
| user[last_name] | String | The last name for the new User. | | |
| user[photo] | File | The profile photo for the new User. Can be GIF, JPG, or PNG. | | |
| user[remote_photo_url] | String | URL to the profile photo for the new User. Can be GIF, JPG, or PNG. | | |
| user[bio] | String | The bio for the new User. Maximum 255 characters. | | |
| __utmz | String | Google Analytics information to pass to the server | | |
| authentication[provider] | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | |
| authentication[uid] | String | The User's ID for the provider. | | |
| authentication[token] | String | The User's Access Token for the provider. | | |
| authentication[secret] | String | The User's Access Token Secret for the provider. Only required for Twitter. | | |
| authentication[short_lived] | Boolean | Set to `true` if the token passed is a short-lived token. | false | |

### Response

| __data__ |
| -------- |
| Created [User (w/ Auth Token)](#user-w-auth-token) |

<br />
<br />

## POST `/users/sign_in` - User Authentication
Authenticates a User using one of the request parameters below and returns a [User (w/ Auth Token)](#user-w-auth-token).
If the `Authentication` passed in [Sign In w/ Authentication](#sign-in-w--authentication) is valid, the previously stored `token` and `secret` values will be overwritten with the new ones passed in.

### Request

#### Sign In w/ (Email OR Username) AND Password
| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The email address for the User. | | X |
| user[username] | String | The username for the User. Can be used instead of an email. | | |
| user[login] | String | A generic attribute that can be the email or username. | | |
| user[password] | String | The password for the User. Minimum 8 characters. | | X |

#### Sign In w/ Authentication
| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| authentication[provider] | String | The authentication provider. Currently the only valid values are 'facebook', 'instagram', and 'twitter'. | | X |
| authentication[uid] | String | The User's ID for the provider. | | X |
| authentication[token] | String | The User's Access Token for the provider. | | X |
| authentication[secret] | String | The User's Access Token Secret for the provider. Only required for Twitter. | | Twitter |
| authentication[short_lived] | Boolean | Set to `true` if the token passed is a short-lived token. | false | |

### Response

| __data__ |
| -------- |
| Authenticated [User (w/ Auth Token)](#user-w-auth-token) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ | ----------- |
| __login or password is invalid__ | 401 (Unauthorized) or 422 (Unprocessable Entity) | The email, username, or password specified are invalid |

<br />
<br />

## POST `/users/forgot_password` - Forgot Password
Sends a Reset Password email for the User with the specified `email`.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| email | String | The email address for the User. | | X |

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## POST `/users/reset_password` - Reset Password
Sets the password for the User with the specified `reset_password_token` to the `password` provided. Changing a `password` will regenerate the User's `authentication_token`.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| reset_password_token | String | The User's token from the Reset Password email. | | x |
| password | String | The new password for the User. Minimum 8 characters. | | x |

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## GET `/users/me` - Me
Returns [current_user](#current_user)

### Response

| __data__ |
| -------- |
| [User (w/ Private Attributes)](#user-w-private-attributes) |

<br />
<br />

## GET `/users/search` - Search Users
Returns [Slim Followed User](#slim-followed-user)s matching the parameters

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[query] | String | Used to return Users by `first_name` OR `last_name`. Must be at least 3 characters. | | |
| user[first_name] | String | User's `first_name`. Must be at least 3 characters. | | |
| user[last_name] | String | User's `last_name`. Must be at least 3 characters. | | |
| user[promoted] | Boolean | Used to return `promoted` Users | false | |

### Response

| __data__ |
| -------- |
| [Slim Followed User](#slim-followed-user) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ | ----------- |
| __invalid search__ | 400 (Bad Request) | No valid parameters passed |

<br />
<br />

## POST `/users/unsubscribe` - Unsubscribe
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

## GET `/users/validateusername` - Validate Username
Returns `true` if the username is valid, otherwise errors.

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


## GET `/users/validate_email` - Validate Email
Returns `true` if the email is valid, otherwise errors.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| email | String | The email to validate | | X |

### Response

| Condition | __data__ |
| --------- | -------- |
| Email does NOT exist | true |
| Email is invalid or already exists | Errors (see below) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| 'email': ['is required'] | 422 (Unprocessible Entity) | email not passed |
| 'email': ['has already been taken'] | 422 (Unprocessible Entity) | email has already been taken |
| 'email': ['is invalid'] | 422 (Unprocessible Entity) | |

<br />
<br />

## POST `/users/reserveusername` - Reserve Username
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
| User created | `{user_id: USER_ID}` |
| Username or Email is invalid | Errors |

<br />
<br />

## PUT `/users/:id/updateindustry` - Update Industry
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

## GET `/users/:id|:username` - User
Returns the User with the specified `user_id` or `user_username` if the User exists and is `active`. Otherwise, returns 404 (Not Found).

### Response

| __data__ |
| -------- |
| [User](#user) |

<br />
<br />

## PUT `/users/:id` - Update User
Updates the User with the specified `user_id`. If a new `email`, `username`, or `password` is specified, `current_password` is required.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| user[email] | String | The new email address for the User | | |
| user[username] | String | The new username for the User. Better if you don't allow the User to change this. | | |
| user[password] | String | The new password for the User. Minimum 8 characters. | | |
| user[first_name] | String | The new first name for the User. | | |
| user[last_name] | String | The new last name for the User. | | |
| user[photo] | File | The new profile photo for the User. Can be GIF, JPG, or PNG. | | |
| user[remote_photo_url] | String | URL to the new profile photo for the User. Can be GIF, JPG, or PNG. | | |
| user[bio] | String | The new bio for the User. Maximum 255 characters | | |
| user[current_password] | String | The current password for the User. Required for sensitive changes such as `email`, `username`, or `password`.| | |
| user[settings][auto_follow] | Boolean | `true` to have the User auto-follow social friends that join | | |

### Response

| Condition | __data__ |
| --------- | -------- |
| `password` changed | Updated [User (w/ Auth Token)](#user-w-auth-token) |
| Default | Updated [User (w/ Private Attributes)](#user-w-private-attributes) |

<br />
<br />

## GET `/users/:id|:username/morsels` - User Morsels
Returns the Morsels for the User with the specified `user_id` or `user_username`.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Morsels](#morsel)[] |

<br />
<br />

## GET `/users/activities` - User Activities
Returns the [current_user](#current_user)'s Activities. An Activity is created when a User likes or comments on a Item. Think Facebook's Activity Log (https://www.facebook.com/<username>/allactivity).

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Activities](#activity)[] |

<br />
<br />

GET `/users/followables_activities` - User Followables Activities
Returns the [current_user](#current_user)'s Followed Users' Activities.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Activities](#activity)[] |

<br />
<br />

## GET `/users/notifications` - User Notifications
Returns the [current_user](#current_user)'s Notifications. A Notification is created when someone likes or comments on your Items. Think Facebook or Twitter Notifications.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Notifications](#notification)[] |

<br />
<br />

## GET `/users/:id/likeables` - User Likeables
Returns the Likeables that the User with the specified `user_id` has liked along with a `liked_at` DateTime key

__Request Behaviors__
* [Pagination](#pagination)

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| type | String | The type of likeables to return. Currently only 'Item' is acceptable. | | X |

### Response

| type= | __data__ |
| --------- | -------- |
| Item | [Liked Items](#liked-item)[] |

<br />
<br />

## POST `/users/:id/tags` - Create User Tag
Tags the User with the specified `user_id` with the Keyword for the specified `keyword_id`. Valid Keyword types are __Cuisines__ and __Specialty__.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| tag[keyword_id] | Number | The `id` of the Keyword to tag with. | | X |

### Response

| __data__ |
| -------- |
| Created [Tag](#tag) |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __already tagged with that keyword__ | 400 (Bad Request) | The User has already been tagged with that Keyword |

<br />
<br />

## DELETE `/users/:id/tags/:tag_id` - Delete User Tag
Deletes the Tag with the specified `tag_id` for the User with the specified `user_id`

### Response

| Status Code |
| ----------- |
|         204 |

<br />
<br />

## GET `/users/:id/cuisines` - User Cuisines
Returns the Cuisines for the User with the specified `user_id`.

### Response

| __data__ |
| -------- |
| [Tags](#tag)[] of keyword `type` 'Cuisine' |

<br />
<br />

## GET `/users/:id/specialties` - User Specialties
Returns the Specialties for the User with the specified `user_id`.

### Response

| __data__ |
| -------- |
| [Tags](#tag)[] of keyword `type` 'Specialty' |

<br />
<br />

## GET `/users/:id/followables` - User Followables
Returns the Followables that the User with the specified `user_id` is following along with a `followed_at` DateTime.

__Request Behaviors__
* [Pagination](#pagination)

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| type | String | The type of followables to return. Currently only `Keyword` and `User` is acceptable. | | X |

### Response

| type= | __data__ |
| --------- | -------- |
| Keyword | [Followed Keywords](#followed-keyword)[] |
| User | [Slim Followed Users](#slim-followed-user)[] |

<br />
<br />


## GET `/users/:id/places` - User Places
Returns the Place that the User with the specified `user_id` belongs to.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Slim Places](#slim-place)[] w/ the User's `title` |

<br />
<br />


# Place Methods
* [\<Followable\>](#followable)

## GET `/places/suggest` - Suggest Completion
Proxy for the [Foursquare Venues suggestcompletion](https://developer.foursquare.com/docs/venues/suggestcompletion). Returns the response in `data`.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| query | String | String to search for. Must be at least 3 characters. | | X |
| lat_lon | String | The User's lat, lon | | X |

<br />
<br />

## POST `/places/join` - Join User w/ Place
Associates the [current_user](#current_user) with the Place with the specified `place_id` or `foursquare_venue_id`.
If the Place does not yet exist (`foursquare_venue_id` passed) it will be created with the additional place parameters and return it.
Creating a new Place will kick off a background job to import all of its data from Foursquare.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| title| String | [current_user](#current_user)'s `title` at the Place | | X |
| place[id] | String |  | | if `foursquare_venue_id` not passed |
| place[foursquare_venue_id] | String | The photo for the new Item | | if `id` not passed |
| place[name] | String | The name of the Place | | |
| place[address] | String | The address of the Place | | |
| place[city] | String | The city of the Place | | |
| place[state] | String | The state of the Place | | |

### Response

| __data__ |
| -------- |
| [Place](#place) |

<br />
<br />

## GET `/places/:id` - Place
Returns Place with the specified `id`

### Response

| __data__ |
| -------- |
| [Place](#place) |

<br />
<br />

## GET `/places/:id/users` - Place Users
Returns Users belonging to the Place with the specified `id`

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Users](#user)[] |

<br />
<br />


# Item Methods

## POST `/items` - Create a new Item
Created a new Item for the current User.
Image processing is done in a background job. `photo_processing` will be set to `null` when it has finished.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| item[description] | String | The description for the new Item | | |
| item[photo] | String | The photo for the new Item | | |
| item[nonce] | String | Unique UUID to prevent duplicates | | |
| item[sort_order] | Number | The `sort_order` for the Item in the Morsel. | end of Morsel | |
| item[morsel_id] | Number | The ID of the Morsel to set this Item to. | | X |

### Response

| Condition | __data__ |
| --------- | -------- |
| Authenticated | Created [Item](#item) |
| Default | Created [Item](#item) |

<br />
<br />

## GET `/items/:id` - Item
Returns Item with the specified `id`

### Response

| __data__ |
| -------- |
| [Item](#item) |

<br />
<br />

## PUT `/items/:id` - Update Item
Updates the Item with the specified `id`

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| item[description] | String | The description for the Item | | |
| item[photo] | String | The photo for the Item | | |
| item[sort_order] | Number | Changes the `sort_order` of a Morsel when combined with `morsel_id`. | | |
| item[morsel_id] | Number | Changes the `sort_order` of a Morsel when combined with `sort_order`. | | |

### Response

| __data__ |
| -------- |
| [Item](#item) |

<br />
<br />

## DELETE `/items/:id` - Delete Item
Deletes the Item with the specified `id`.

### Response

| Status Code |
| ----------- |
|         204 |

<br />
<br />

## POST `/items/:id/like` - Like Item
Likes the Item with the specified `id` for [current_user](#current_user)

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

## DELETE `/items/:id/like` - Unlike Item
Unlikes the Item with the specified `id` for [current_user](#current_user)

### Response

| Status Code |
| ----------- |
|         204 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Not liked__ | 404 (Not Found) | The Item is not liked by the User |

<br />
<br />

## GET `/items/:id/likers` - Likers
Returns the Users who have liked the Item with the specified `id`

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Users](#user)[] |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Item not found__ | 404 (Not Found) | The Item could not be found |

<br />
<br />

## POST `/items/:id/comments` - Create Comment
Create a Comment for the Item with the specified `id`

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

## GET `/items/:id/comments` - Item Comments
List the Comments for the Item with the specified `id`

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Comments](#comment)[] |

<br />
<br />

## DELETE `/items/:id/comments/:comment_id` - Delete Comment
Deletes the Comment with the specified `comment_id` for the `id` if [current_user](#current_user) is the Comment or Item Creator

### Response

| Status Code |
| ----------- |
|         204 |

### Unique Errors

| Message | Status | Description |
| ------- | ------ |  ----------- |
| __Comment not found__ | 404 (Not Found) | The Comment could not be found |
| __Forbidden__ | 403 (Forbidden) | The [current_user](#current_user) is not authorized to delete the Comment |

<br />
<br />


# Morsel Methods

## POST `/morsels` - Create a new Morsel
Creates a new Morsel for the current User.

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[title] | String | The title for the new Morsel | | x |
| morsel[place_id] | Number | A [Place](#place) to associate this Morsel to | | |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |

### Response

| __data__ |
| -------- |
| Created [Morsel](#morsel) |

<br />
<br />

## GET `/morsels` - Morsels
Returns the Morsels (including Drafts) for [current_user](#current_user) sorted by their `id`.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Morsels](#morsel)[] |

<br />
<br />

## GET `/morsels/drafts` - Morsel Drafts
Returns the Morsel Drafts for [current_user](#current_user) sorted by their updated_at, with the most recent one's appearing first.

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Morsels](#morsel)[] |

<br />
<br />

## GET `/morsels/:id` -  Morsel
Returns the Morsel with the specified `id`

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |

### Response

| __data__ |
| -------- |
| [Morsel](#morsel) |

<br />
<br />

## PUT `/morsels/:id` - Update Morsel
Updates the Morsel with the specified `id`

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[title]         | String  | The title for the Morsel. Changing this will change the slug. | | |
| morsel[place_id] | Number | A [Place](#place) to associate this Morsel to | | |
| morsel[draft] | Boolean | Set to true if the Morsel is a draft | false | |
| morsel[primary_item_id] | Number | The ID of the Item to set as the primary Item for this Morsel. Must be the ID of a Item that is part of the Morsel | | |

### Response

| __data__ |
| -------- |
| Updated [Morsel](#morsel) |

<br />
<br />

POST `/morsels/:id/publish` - Publish Morsel
Publishes the Morsel with the specified `id` by setting a `published_at` DateTime and `draft`=false

### Request

| Parameter           | Type    | Description | Default | Required? |
| ------------------- | ------- | ----------- | ------- | --------- |
| morsel[primary_item_id] | Number | The ID of the Item to set as the primary Item for this Morsel. Must be the ID of a Item that is part of the Morsel | | |
| post_to_facebook | Boolean | Post to the [current_user](#current_user)'s Facebook wall with the Morsel's title and a link to the Morsel. | false | |
| post_to_twitter | Boolean | Send a Tweet from the [current_user](#current_user) with the Morsel's title and a link to the Morsel. If the title and description are too long they will be truncated to allow enough room for the link. | false | |

### Response

| __data__ |
| -------- |
| Publishes [Morsel](#morsel) |

<br />
<br />


# Keyword Methods
* [\<Followable\>](#followable)

## GET `/cuisines` - Cuisines
Returns the list of Cuisines

### Response

| __data__ |
| -------- |
| [Keywords](#keyword)[] of `type` 'Cuisine' |

<br />
<br />

## GET `/cuisines/:id/users` - Cuisine Users
Returns a list of Users who belong to the Cuisine with the specified `id`

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Users](#user)[] |

<br />
<br />

## GET `/specialties` - Specialties
Returns the list of Specialties

### Response

| __data__ |
| -------- |
| [Keywords](#keyword)[] of `type` 'Specialty' |

<br />
<br />

## GET `/specialties/:id/users` - Specialty Users
Returns a list of Users who belong to the Specialty with the specified `id`

__Request Behaviors__
* [Pagination](#pagination)

### Response

| __data__ |
| -------- |
| [Users](#user)[] |

<br />
<br />


# Misc Methods

## GET `/status` - Status
Used by third-party services to ping the API.

### Response

| Status Code |
| ----------- |
|         200 |

<br />
<br />

## GET `/configuration` - Configuration

### Response

| __data__ |
| -------- |
| [Configuration](#configuration) |

<br />
<br />


# Response Objects

## Authentication Objects

### Authentication

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
* Includes:
  * `creator`: [Slim User](#slim-user)

```json
{
  "id": 4,
  "description": "Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!",
  "commentable_id": 5,
  "commentable_type": "Item",
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
    "photo_processing": null,
    "liked": false
  }
```

### Liked Item
Response for any Like Item related requests.
* Inherits from [Item](#item)
* Includes:
  * `creator`: [Slim User](#slim-user)
  * `morsel`: [Slim Morsel](#slim-morsel)

```json
{
  "liked_at": "2014-04-28T16:50:42.352Z"

}
```


## Morsel Objects

### Slim Morsel

```json
{
  "id": 4,
  "title": "Butter Rocks!",
  "slug": "butter-rocks",
  "creator_id": 3,
  "place_id": 4,
  "created_at": "2014-01-07T16:34:44.862Z",
  "updated_at": "2014-01-07T16:34:44.862Z"
}

### Morsel
* Inherits from [Slim Morsel](#slim-morsel)
* Includes:
  * `creator`: [Slim User](#slim-user)
  * `items`: [Items](#item)[] \(ordered by `sort_order` ASC)
  * `place`: [Slim Place](#slim-place)

```json
{
  "published_at": "2014-01-07T16:34:44.862Z",
  "draft": false,
  "total_like_count": 10,
  "total_comment_count": 3,
  "primary_item_id": 2,
  "url": "http://eatmorsel.com/turdferg/4-butter-rocks",
  "facebook_mrsl": "http://mrsl.co/facebook",
  "twitter_mrsl": "http://mrsl.co/twitter",
  "photos": {
    "_800x600":"https://morsel-staging.s3.amazonaws.com/morsel-images/4/648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"
  }
}
```


## User Objects

### Slim User

```json
{
  "id": 3,
  "username": "turdferg",
  "first_name": "Turd",
  "last_name": "Ferguson",
  "bio": "Suck It, Trebek",
  "industry": "chef",
  "photos": {
    "_40x40": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_72x72": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_80x80": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg",
    "_144x144": "https://morsel-staging.s3.amazonaws.com/user-images/user/3/1389119757-batman.jpeg"
  }
}
```

### Slim Followed User
* Inherits from [Slim User](#slim-user)

```json
{
  "following": false
}
```

### User
* Inherits from [Slim User](#slim-user)

```json
{
  "created_at": "2014-01-07T18:35:57.877Z",
  "facebook_uid": "1234567890",
  "twitter_username": "morsel_marty",
  "morsel_count": 1,
  "liked_item_count": 3,
  "following": false,
  "followed_user_count": 3,
  "follower_count": 3
}
```

### User (w/ Private Attributes)
You'll only see these if the api_key matches the User you're looking up.
* Inherits from [User](#user)

```json
{
  "staff": true,
  "draft_count": 0,
  "sign_in_count": 1,
  "photo_processing": null,
  "email": "buttsackmcgee@eatmorsel.com",
  "options": {
    "auto_follow": "true"
  }
}
```

### User (w/ Auth Token)
* Inherits from [User (w/ Private Attributes)](#user-w-private-attributes)

```json
{
  "auth_token": "butt-sack",
}
```

### Followed User
Response for any Follow User related requests.
* Inherits from [User](#user)

```json
{
  "followed_at": "2014-04-28T16:50:42.352Z"
}
```

### User Follower
Response for any User Follower related requests.
* Inherits from [User](#user)

```json
{
  "followed_at": "2014-04-28T16:50:42.352Z"
}
```

## Feed Objects

### Feed Item
* Includes:
  * `subject`: [Morsel](#morsel)

```json
{
  "id":11,
  "created_at":"2014-03-25T21:18:02.349Z",
  "updated_at":"2014-03-25T21:18:02.360Z",
  "subject_type":"Morsel",
  "user_id": 1,
  "featured": false
}
```


## Place Objects

### Slim Place

```json
{
  "id":11,
  "created_at":"2014-03-25T21:18:02.349Z",
  "updated_at":"2014-03-25T21:18:02.360Z",
  "name": "Big Star",
  "slug": "big-star",
  "address": "1531 N Damen Ave",
  "city": "Chicago",
  "state": "IL",
  "postal_code": "60622",
  "country": "United States",
  "lat": 41.896917,
  "lon": -87.643547
}
```

### Place
* Inherits from [Slim Place](#slim-place)
* _(NOTE: Refer to Foursquare's Documentation for the format of `foursquare_timeframes` as it may vary)_

```json
{
  "facebook_page_id": "162760584142",
  "twitter_username": "BigStarChicago",
  "foursquare_venue_id": "4adbf2bbf964a520242b21e3",
  "foursquare_timeframes": [
    {
      "days": "Mon-Fri, Sun",
      "includesToday": true,
      "open": [
        {
          "renderedTime": "11:30 AM-2:00 AM"
        }
      ],
      "segments": []
    },
    {
      "days": "Sat",
      "open": [
        {
          "renderedTime": "11:30 AM-3:00 AM"
        }
      ],
      "segments": []
    }
  ],
  "information" {
      "website_url": "http://www.bigstarchicago.com",
      "formatted_phone": '(773) 235-4039',
      "price_tier": 2,
      "reservations_url": "http://www.opentable.com/single.aspx?rid=20791&ref=9601",
      "menu_url": "https://foursquare.com/v/big-star/4adbf2bbf964a520242b21e3/menu",
      "menu_mobile_url": "https://foursquare.com/v/4adbf2bbf964a520242b21e3/device_menu",
      "reservations": "Yes",
      "credit_cards": "Yes (incl. American Express)",
      "outdoor_seating": "Yes",
      "dining_options": "Take-out; No Delivery",
      "dress_code": "Casual Dress",
      "dining_style": "Casual Dining",
      "public_transit": "Take the bus.",
      "parking": "Street Parking",
      "parking_details": "We don't have valet or private parking. We recommend street parking or side streets."
    }
}
```


## Tag Objects

### Tag
* Includes:
  * `keyword`: [Keyword](#keyword)

```json
{
  "id":11,
  "created_at":"2014-03-25T21:18:02.349Z",
  "updated_at":"2014-03-25T21:18:02.360Z",
  "taggable_id":4,
  "taggable_type":"User"
}
```

### Keyword

```json
{
  "id":6,
  "type":"Cuisine",
  "name":"Polish"
}
```

### Followed Keyword
Response for any Follow Keyword related requests.
* Inherits from [Keyword](#keyword)

```json
{
  "followed_at": "2014-04-28T16:50:42.352Z"
}
```


## Activity Objects

### Activity
* Includes:
  * `creator`: [Slim User](#slim-user)
  * `subject`: [Item](#item) OR [User](#user)
  * `action`: [Comment](#comment) OR [Follow](#) OR [Like](#)

```json
{
  "id":2,
  "action_type":"Like",
  "created_at":"2014-03-13T17:01:38.370Z",
  "subject_type":"Item"
}
```


## Notification Objects

### Notification
* Includes:
  * `payload`: [Activity](#activity)

```json
{
  "id":4,
  "message":"Drew Muller (user_jtu6g7nacn) liked Enim quia sequi aut vel.: Soluta quo saepe nemo voluptatem... ",
  "created_at":"2014-03-13T17:04:22.411Z",
  "payload_type":"Activity"
}
```


## Misc Objects

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
