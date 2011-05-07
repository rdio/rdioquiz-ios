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

#import "RDQIntroViewController.h"
#import "RDQChoicesViewController.h"
#import "RDQLaunchViewController.h"
#import "Settings.h"

@implementation RDQIntroViewController

@synthesize yourAlbumsButton;
@synthesize friendsAlbumsButton;
@synthesize topAlbumsButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Introduction";
  [self initializeUI];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = @"Introduction";
  self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  self.title = @"Intro";
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [yourAlbumsButton release];
  [friendsAlbumsButton release];
  [topAlbumsButton release];
  [super dealloc];
}

-(void)buttonClicked:(id)sender {
  UIButton* button = (UIButton*)sender;
  if(button.tag != -1) {
    RDQChoicesViewController* choicesController = [[RDQChoicesViewController alloc] initWithNibName:@"RDQChoicesViewController" bundle:nil];
    choicesController.albumsSourceType = button.tag;
    [self.navigationController pushViewController:choicesController animated:YES];
    [choicesController release];
  }
  else {
    [self presentLoginModal];
  }
}

#pragma mark -
#pragma mark Functions

- (void)initializeUI {
  [yourAlbumsButton setBackgroundImage:[[UIImage imageNamed:@"button-yellow.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
  [friendsAlbumsButton setBackgroundImage:[[UIImage imageNamed:@"button-yellow.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
  [topAlbumsButton setBackgroundImage:[[UIImage imageNamed:@"button-yellow.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
  yourAlbumsButton.alpha = 1.0f;
  friendsAlbumsButton.alpha = 1.0f;
  
  if([[Settings settings] user] == nil) {
    [yourAlbumsButton setBackgroundImage:[[UIImage imageNamed:@"button-silver.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    [friendsAlbumsButton setBackgroundImage:[[UIImage imageNamed:@"button-silver.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    yourAlbumsButton.alpha = 0.3f;
    friendsAlbumsButton.alpha = 0.3f;
    yourAlbumsButton.tag = -1; // not "enabled"
    friendsAlbumsButton.tag = -1;
  } else {
    yourAlbumsButton.tag = UserHeavyRotation;
    friendsAlbumsButton.tag = FriendsHeavyRotation;
  }
}

#pragma mark -
#pragma mark RdioDelegate methods

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
  [super rdioDidAuthorizeUser:user withAccessToken:accessToken];
  [self initializeUI];
}

@end
