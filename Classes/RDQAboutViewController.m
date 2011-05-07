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

#import "RDQAboutViewController.h"
#import "Settings.h"
#import "RDQuizAppDelegate.h"

@implementation RDQAboutViewController

@synthesize getAppButton;
@synthesize learnMoreButton;
@synthesize navBar;

#pragma mark Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initializeUI];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if([[Settings settings] user] != nil) {
    [NSThread detachNewThreadSelector:@selector(loadAvatarURL:) toTarget:self withObject:[[Settings settings] icon]];
  }
}
- (void)dealloc {
  [getAppButton release];
  [learnMoreButton release];
  [navBar release];
  [super dealloc];
}

#pragma mark -
#pragma mark Functions

- (void)showLogout {
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connected to Rdio"
                                               message:[NSString stringWithFormat:@"You are signed in to Rdio as user: %@", [[Settings settings] user]]
                                              delegate:self
                                     cancelButtonTitle:@"Continue"
                                     otherButtonTitles:@"Sign Out", nil];
  [av show];
  [av release];
}


- (void)loadAvatarURL:(NSString *) icon {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]]];
  UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
  UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
  avatarButton.frame = CGRectMake(0, 0, 35.0f, 35.0f);
  [avatarButton addTarget:self action:@selector(showLogout) forControlEvents:UIControlEventTouchUpInside];
  
  UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
  avatarImageView.frame = CGRectMake(0, 0, 35.0f, 35.0f);
  
  [wrapperView addSubview:avatarImageView];
  [avatarImageView release];
  [wrapperView addSubview:avatarButton];
  
  UIBarButtonItem *avatarBarButton = [[UIBarButtonItem alloc] initWithCustomView:wrapperView];
  [wrapperView release];
  
  [self.navBar.topItem performSelectorOnMainThread:@selector(setRightBarButtonItem:) withObject:avatarBarButton waitUntilDone:YES];
  [avatarBarButton release];
  
  [pool release];
}


- (void)initializeUI {
  [learnMoreButton setBackgroundImage:[[UIImage imageNamed:@"button-silver.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
  [getAppButton setBackgroundImage:[[UIImage imageNamed:@"button-blue.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
  Settings *settings = [Settings settings];
  if([settings user] == nil) {
    UIBarButtonItem *signInBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(presentLoginModal)];
    self.navBar.topItem.rightBarButtonItem = signInBarButton;
    [signInBarButton release];
  }
}

- (void)dismissSelf {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)learnMoreButtonClicked {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://developer.rdio.com"]];
}

- (void)getAppButtonClicked {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/rdio/id335060889?mt=8"]];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if(buttonIndex != [alertView cancelButtonIndex]) {
    [[Settings settings] reset];
    [[Settings settings] save];
    [[RDQuizAppDelegate rdioInstance] logout];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(presentLoginModal)];
    self.navBar.topItem.rightBarButtonItem = barButton;
    [barButton release];
  }
}

#pragma mark -
#pragma mark RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
  [super rdioDidAuthorizeUser:user withAccessToken:accessToken];
  
  [NSThread detachNewThreadSelector:@selector(loadAvatarURL:) toTarget:self withObject:[user objectForKey:@"icon"]];
  [self showAlertWithTitle:@"Connected" message:@"Your Rdio account has been connected!"];
}

@end
