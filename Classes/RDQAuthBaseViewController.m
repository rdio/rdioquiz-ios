/*
 Copyright (c) 2011 Rdio Inc
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "RDQAuthBaseViewController.h"
#import "Settings.h"

@implementation RDQAuthBaseViewController

- (void) presentLoginModal {
  /**
   * Display the login modal so the user can log in.
   */
  [[RDQuizAppDelegate rdioInstance] authorizeFromController:self];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
  UIAlertView* av = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
  [av show];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  /**
   * Make sure we are sent delegate messages.
   */
  [[RDQuizAppDelegate rdioInstance] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  /**
   * Don't send us any delegate messages.
   */
  [[RDQuizAppDelegate rdioInstance] setDelegate:nil];
}

#pragma mark -
#pragma mark RdioDelegate methods
/**
 * The user has successfully authorized the application, so we should store the access token
 * and any other information we might want access to later.
 */

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
  [[Settings settings] setUser:[NSString stringWithFormat:@"%@ %@", [user valueForKey:@"firstName"], [user valueForKey:@"lastName"]]];
  [[Settings settings] setAccessToken:accessToken];
  [[Settings settings] setUserKey:[user objectForKey:@"key"]];
  [[Settings settings] setIcon:[user objectForKey:@"icon"]];
  [[Settings settings] save];  
}

/**
 * Authentication failed so we should alert the user.
 */
- (void)rdioAuthorizationFailed:(NSString *)message {
  NSLog(@"Rdio authorization failed: %@", message);
}

@end
