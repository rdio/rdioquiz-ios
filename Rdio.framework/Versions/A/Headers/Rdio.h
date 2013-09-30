/**
 *  @file Rdio.h
 *  Rdio iOS SDK
 *  Copyright 2011-2013 Rdio Inc. All rights reserved.
 */

#import "RDPlayer.h"
#import "RDAPIRequest.h"

@protocol RdioDelegate;
@class RDSession;
@class RDAuthViewController;

////////////////////////////////////////////////////////////////////////////////

/** @mainpage
 * The Rdio iOS SDK lets developers call the web service API, authenticate users,
 * and play full song streams or 30 second samples.
 * <br/><br/>
 * To get started:
 * <ul>
 *  <li>Visit http://developer.rdio.com to register a developer account and apply for a key</li>
 *  <li>Download the <a href="https://github.com/rdio/rdioquiz-ios">sample app</a></li>
 *  <li>Download the <a href="http://www.rdio.com/media/static/developer/ios/rdio-ios.tar.gz">framework</a></li>
 *  <li>Drag the Rdio framework into your XCode project</li>
 *  <li><b>Add the following frameworks to your project:</b>
 *    <ul>
 *      <li>CoreGraphics</li>
 *      <li>CFNetwork</li>
 *      <li>CoreMedia</li>
 *      <li>SystemConfiguration</li>
 *      <li>AudioToolbox</li>
 *      <li>Security</li>
 *    </ul>
 *  </li>
 *  <li><b>Add <a href="http://developer.apple.com/library/mac/#qa/qa1490/_index.html">-all_load</a> under Other Linker Flags in the project build info</b></li>
 *  <li>Try the following code in your app delegate:</li>
 * </ul>
 * \code
 *   #import <Rdio/Rdio.h>
 *   Rdio *rdio = [[Rdio alloc] initWithConsumerKey:@"YOUR KEY" andSecret:@"YOUR SECRET" delegate:nil];
 *   [rdio.player playSource:@"t2742133"];
 * \endcode
 *
 * Please direct feature requests and bug reports to
 * <a href="mailto:developersupport@rd.io">Developer Support</a> or the
 * <a href="http://groups.google.com/group/rdio-api">Rdio API Google Group</a>.
 */

////////////////////////////////////////////////////////////////////////////////

/**
 * Façade for interacting with the Rdio API.
 * Supports server API calls and track playback for anonymous and authorized users.
 */
@interface Rdio : NSObject {
  RDPlayer *player_;
  RDSession *session_;
  RDAuthViewController *authViewController_;
  UIViewController *currentController_;
  id<RdioDelegate> delegate_;
  BOOL authorizingFromToken_;
}

/**
 * Initializes the Rdio API with your consumer key and secret.
 * Visit http://developer.rdio.com/ to register and apply for a key.
 * @param key Your consumer key
 * @param secret Your secret
 * @param delegate Delegate for receiving state changes, or nil
 */
- (id)initWithConsumerKey:(NSString *)key andSecret:(NSString *)secret delegate:(id<RdioDelegate>)delegate;

/**
 * Presents a modal login dialog and attempts to get an authorized Rdio user.
 * @param currentController Controller from which the login view should be launched
 */
- (void)authorizeFromController:(UIViewController *)currentController;

/**
 * Attempts to reauthorize using an access token from a previous session.
 * If this process fails, it calls the `rdioAuthorizationFailed:` method of the RdioDelegate passed to `initWithConsumerKey:`.
 * Calling this method is the same as calling `authorizeUsingAccessToken:fromController:` with the controller set to `nil`.
 * @param accessToken A token received from a previous <code>rdioDidAuthorizeUser:withAccessToken:</code> delegate call
 */
- (void)authorizeUsingAccessToken:(NSString *)accessToken;

/**
 * Attempts to reauthorize using an access token from a previous session.
 *
 * @deprecated You should use `authorizeUsingAccessToken:` in new apps, and explicitly call `authorizeFromController:` on failure if that's your desired behavior.
 *
 * If this process fails and the `currentController` is not nil, the user is presented with a modal login view as
 * if you had called `authorizeFromController:`
 * If `currentController` is nil, this method behaves the same way as `authorizeUsingAccessToken:`.
 */
- (void)authorizeUsingAccessToken:(NSString *)accessToken fromController:(UIViewController *)currentController;

/**
 * Logs out the current user.  Calls <code>rdioDidLogout</code> on delegate on completion.  Clients are responsible
 * for clearing any application-persisted state (user data, access token, etc).
 */
- (void)logout;

/**
 * Calls an Rdio Web Service API method with the given parameters.
 * @param method Name of the method to call. See http://developer.rdio.com/docs/read/rest/Methods for available methods.
 * @param params A dictionary of parameters as required for the method. Note that all keys and values in the `parameters` dictionary should be instances of NSString.
 * For example, if you're
 * passing the `count` parameter to an API call, you would use `@"count": @"20"`
 * instead of `@"count": @20`.
 * @param delegate An object implementing the RDAPIRequestDelegate protocol or an instance of the RDAPIRequestDelegate class, to be notified on request complete.
 */
- (RDAPIRequest *)callAPIMethod:(NSString *)method 
                 withParameters:(NSDictionary *)params 
                       delegate:(id<RDAPIRequestDelegate>)delegate;

/**
 * Delegate used to receive Rdio API state changes.
 */
@property (nonatomic, assign) id<RdioDelegate> delegate;

/**
 * A dictionary describing the current user, or nil if no user is logged in.
 * See http://developer.rdio.com/docs/read/rest/types
 */
@property (nonatomic, readonly) NSDictionary *user;

/**
 * The playback interface.
 */
@property (nonatomic, readonly) RDPlayer *player;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Delegate used to receive Rdio API state changes.
 */
@protocol RdioDelegate
@optional

/**
 * Called when an authorize request finishes successfully. 
 * @param user A dictionary containing information about the user that was authorized. See http://developer.rdio.com/docs/read/rest/types
 * @param accessToken A token that can be used to automatically reauthorize the current user in subsequent sessions
 */
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken;

/**
 * Called if authorization cannot be completed due to network, server, or token problems.
 *
 * If you used `authorizeFromController` to inititate authorization, the user will be notified from the
 * login view before this method is called.
 *
 * If you called `authorizeUsingAccessToken:fromController:` with a non-nil fromController, the SDK will
 * respond to an error by popping up the login view without calling this method.  Subsequent failures within
 * the same flow will be handled as if you had called `authorizeFromController`.
 *
 * If you called `authorizeUsingAccessToken:` or provided a nil fromController, this method will be called
 * without any notification to the end user.  In this circumstance, it's up to you to handle any changes
 * this might imply for your UI.
 * @param error A description of what went wrong.
 */
- (void)rdioAuthorizationFailed:(NSString *)error;

/**
 * Called if the user aborts the authorization process.
 */
- (void)rdioAuthorizationCancelled;

/**
 * Called when logout completes.
 */
-(void)rdioDidLogout;

@end
