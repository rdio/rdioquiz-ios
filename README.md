[Rdio Quiz](http://itunes.apple.com/us/app/music-quiz-for-rdio/id434015378) is a complete example of how to use the [Rdio iOS library](http://www.rdio.com/media/static/developer/ios/docs/) and [API](http://developer.rdio.com/docs/read/REST).

The goal of this project is to provide best practices of how to perform user authentication, music playback and perform API calls, as well as to give developers a general feel for what the library can do and how to integrate it into their applications.


# Installation
Get a developer key and secret from [developer.rdio.com](http://developer.rdio.com) and set the values in RDQuizAppDelegate.m

# Usage
All tasks are accomplished with the Rdio class. To start using it create an instance of the Rdio object with your [API key and secret](http://developer.rdio.com/).

`Rdio *rdio = [[Rdio alloc] initWithConsumerKey:@"myKey" andSecret:@"mySecret" delegate:nil];`

And in order to be informed when certain tasks complete you will need to implement a few delegate protocols:

* RdioDelegate
* RDPlayerDelegate
* RDAPIRequestDelegate 

## Authentication
To access an Rdio user's information the user must authenticate with your application. Luckily, the Rdio library provides an easy to use authentication mechanism that takes care of all the heavy lifting for you. 

To initiate authentication call `- (void)authorizeFromController:(UIViewController *)currentController`. This will present a login modal to the user, when the user completes logging in 1 of 3 delegate methods will be called: `- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken` if the user was successfully authenticated, `- (void)rdioAuthorizationFailed:(NSString *)error` if the user was not authenticated, and `- (void)rdioAuthorizationCancelled` if the user cancelled the login modal.

Upon successful authentication you should store the returned accessToken for future use so the user doesn't have to re-authorize your application. Then you can call `- (void)authorizeUsingAccessToken:(NSString *)accessToken fromController:(UIViewController *)currentController` and no user interaction is necessary. You cannot make any API calls that require authentication without first performing a successful `authorize*` call.

## Playback
This is perhaps the most interesting functionality the Rdio library provides, it allows your application to stream Rdio music content. And it is extremely easy to use, simply access the `player` attribute of the Rdio object to access the instance of RDPlayer. To play a track call `- (void)playSource:(NSString *)source` with a track key (currently only single-track sources are supported). You can then use RDPlayer's methods to control playback (stop, pause, seek). Don't forget to add the UIBackgroundModes key with value of "audio" to your Info.plist to enable background audio playback.

## Accessing Web Service API
The Rdio class provides a means of performing web service API calls and handling their results. To make an API call use `- (RDAPIRequest *)callAPIMethod:(NSString *)method withParameters:(NSDictionary *)params delegate:(id<RDAPIRequestDelegate>)delegate` your delegate will be notified when the request completes (successfully or not). See RDAPIRequest.h for more detail on delegate methods and the RDAPIRequest class.

