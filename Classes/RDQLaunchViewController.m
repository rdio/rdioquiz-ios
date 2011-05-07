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

#import "RDQLaunchViewController.h"
#import "RDQAboutViewController.h"
#import "RDQIntroViewController.h"
#import "Reachability.h"
#import "RDQConstants.h"
#import "Settings.h"

@implementation RDQLaunchViewController

@synthesize activityIndicator;
@synthesize startButton;

#pragma mark View Life Cycle
- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self initializeUI];
  self.title = @"Home";
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
  netReachable = [[Reachability reachabilityForInternetConnection] retain];
  [netReachable startNotifier];
  hostReachable = [[Reachability reachabilityWithHostName:RDIO_WEB_HOST] retain];
  [hostReachable startNotifier];
  
  NSString* savedToken = [[Settings settings] accessToken];
  if(savedToken != nil) {
    
    /**
     * We've got an access token so let's authorize with it so we can make API requests that require user authentication.
     */
    [[RDQuizAppDelegate rdioInstance] authorizeUsingAccessToken:savedToken fromController:self];
  }       
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [activityIndicator release];
  [startButton release];
  [netReachable stopNotifier];
  [hostReachable stopNotifier];
  [super dealloc];
}

#pragma mark -
#pragma mark Functions

- (void)checkNetworkStatus:(NSNotification *)notif {
  [netReachable stopNotifier];
  [hostReachable stopNotifier];
  
  hasConnection = YES;
  
  NetworkStatus netStatus = [netReachable currentReachabilityStatus];
  switch (netStatus) {
    case NotReachable:
      hasConnection = NO;
      break;
  }
  
  NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
  switch (hostStatus) {
    case NotReachable:
      hasConnection = NO;
      break;
  }
  [self updateUIAfterConnectivityCheck];
}

- (void)initializeUI {
  [startButton setBackgroundImage:[[UIImage imageNamed:@"button-yellow.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
  [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
}

- (void)promptForRdioAuth {
  if ([[Settings settings] user] == nil) {
    UIAlertView* av = [[[UIAlertView alloc] initWithTitle:RDIO_CONNECT_ALERT_TITLE 
                                                  message:RDIO_CONNECT_ALERT_MSG 
                                                 delegate:self 
                                        cancelButtonTitle:RDIO_CONNECT_NEG_BUTTON 
                                        otherButtonTitles:RDIO_CONNECT_POS_BUTTON, nil] autorelease];
    [av show];
  }
}

- (void)updateUIAfterConnectivityCheck {
  [activityIndicator stopAnimating];
  if (hasConnection) {
    startButton.hidden = NO;
    [self promptForRdioAuth];
  }
  else {
    [self showAlertWithTitle:@"Connection Required" message:@"In order to play Guess the Artist you must have a WiFi or 3G connection."];
  }
  
}

- (void)toggleAboutView {
  RDQAboutViewController* aboutController = [[RDQAboutViewController alloc] initWithNibName:@"RDQAboutViewController" bundle:nil];
  aboutController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  [self presentModalViewController:aboutController animated:YES];
  [aboutController release];
}

- (void)startButtonClicked {
  RDQIntroViewController *introController = [[RDQIntroViewController alloc] initWithNibName:@"RDQIntroViewController" bundle:nil];
  [self.navigationController pushViewController:introController animated:YES];
  [introController release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != [alertView cancelButtonIndex]) {
    [self presentLoginModal];
  }
}

#pragma mark -
#pragma mark RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
  [super rdioDidAuthorizeUser:user withAccessToken:accessToken];
  startButton.hidden = NO;
  [activityIndicator stopAnimating];
}

@end
