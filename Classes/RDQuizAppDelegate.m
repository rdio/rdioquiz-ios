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

#import "RDQuizAppDelegate.h"
#import "RDQLaunchViewController.h"
#import "Settings.h"

@implementation RDQuizAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rdio;

+ (Rdio*)rdioInstance {
  return [(RDQuizAppDelegate*)[[UIApplication sharedApplication] delegate] rdio];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  [self.window addSubview:self.navigationController.view];
  [self.window makeKeyAndVisible];
  
  // Get a key and secret from http://developer.rdio.com and set them here:
  NSString *developerKey = [NSString stringWithString: YOUR_DEVELOPER_KEY ];
  NSString *developerSecret = [NSString stringWithString: YOUR_DEVELOPER_SECRET];
  
  /**
   * Create an instance of the Rdio class with our Rdio API key and secret.
   */  
  rdio = [[Rdio alloc] initWithConsumerKey:developerKey andSecret:developerSecret delegate:nil];
  
  return YES;
}

- (void)dealloc {
  [navigationController release];
  [window release];
  [rdio release];
  [super dealloc];
}


@end
