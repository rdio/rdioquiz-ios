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

#import "RDQChoiceViewController.h"
#import "RDQConstants.h"
#import "RDQuizAppDelegate.h"
#import "UIImageView+Animations.h"
#import <Rdio/Rdio.h>

@implementation RDQChoiceViewController

@synthesize noGlowImageView;
@synthesize glowImageView;
@synthesize albumArtworkImageView;
@synthesize wrongImageView;
@synthesize artistNameLabel;
@synthesize albumInfo;
@synthesize isCorrect;
@synthesize activityIndicator;
@synthesize button;
@synthesize calloutImageView;

- (void)viewDidLoad {
  [super viewDidLoad];
  [self doGlowAnimation];
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
  [noGlowImageView release];
  [glowImageView release];
  glowImageView = nil;
  [albumArtworkImageView release];
  [wrongImageView release];
  [artistNameLabel release];
  [albumInfo release];
  [activityIndicator release];
  [button release];
  [calloutImageView release];
  [[[RDQuizAppDelegate rdioInstance] player] stop];
  [super dealloc];
}

- (void)makeRightJustified {
  CGRect newFrame = CGRectMake(self.view.frame.size.width - noGlowImageView.frame.size.width - 15, noGlowImageView.frame.origin.y, noGlowImageView.frame.size.width, noGlowImageView.frame.size.height);
  noGlowImageView.frame = newFrame;
  glowImageView.frame = newFrame;
  newFrame = CGRectOffset(newFrame, 10, 10);
  newFrame.size.width = albumArtworkImageView.frame.size.width;
  newFrame.size.height = albumArtworkImageView.frame.size.height;
  albumArtworkImageView.frame = newFrame;
  wrongImageView.frame = newFrame;
  button.frame = newFrame;
  activityIndicator.frame = CGRectMake(newFrame.origin.x + ((newFrame.size.width / 2.0f) - (activityIndicator.frame.size.width / 2.0f)), 
                                       activityIndicator.frame.origin.y, 
                                       activityIndicator.frame.size.width, 
                                       activityIndicator.frame.size.height);
  newFrame = CGRectMake(noGlowImageView.frame.origin.x - artistNameLabel.frame.size.width - 15.0f, artistNameLabel.frame.origin.y, artistNameLabel.frame.size.width, artistNameLabel.frame.size.height);
  artistNameLabel.frame = CGRectOffset(newFrame, -10.0f, 0);
  artistNameLabel.textAlignment = UITextAlignmentRight;
  
  calloutImageView.image = [UIImage imageNamed:@"left-callout.png"];
}

- (void)rotateAlbumArt:(NSInteger)degrees {
  CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
  noGlowImageView.transform = rotationTransform;
  glowImageView.transform = rotationTransform;
  albumArtworkImageView.transform = rotationTransform;
  wrongImageView.transform = rotationTransform;
}

- (void)loadAlbumArt {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  // see if the image exists on disk
  NSString *albumArtCachedName = [NSString stringWithFormat:@"%@.png", [albumInfo objectForKey:@"key"]];
  NSString *albumArtCachedFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] 
                                      stringByAppendingPathComponent:albumArtCachedName];
  UIImage *image = nil;
  if([[NSFileManager defaultManager] fileExistsAtPath:albumArtCachedFullPath]) {
    image = [UIImage imageWithContentsOfFile:albumArtCachedFullPath];
  }
  else {
    NSString *artUrl = [albumInfo objectForKey:@"icon"];
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:artUrl]]];
    // save it to disk
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    [imageData writeToFile:albumArtCachedFullPath atomically:YES];
  }
  
  
  [albumArtworkImageView performSelectorOnMainThread:@selector(setImage:) 
                                          withObject:image 
                                       waitUntilDone:YES];
  [activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
  
  albumArtworkImageView.hidden = NO;
  
  if(delegate_ != nil && [delegate_ respondsToSelector:@selector(albumArtDidFinishLoading)]) {
    [delegate_ albumArtDidFinishLoading];
  }
  [pool release];
}

- (void)doGlowAnimation {
  if(glowImageView == nil) {
    return;
  }
  
  [UIView beginAnimations:@"glowPulse" context:nil];
  [UIView setAnimationDuration:1.0];
  [UIView setAnimationDelegate:self];
  if(glowImageView.alpha == 1.0) {
    glowImageView.alpha = 0;
  } else {
    glowImageView.alpha = 1.0;
  }
  [UIView commitAnimations];
}

- (void)doWrongAnimation {
  wrongImageView.hidden = NO;
  [wrongImageView flyIn];
}

- (void)setAlbumInfo:(NSDictionary *)value {
  albumInfo = value;
  [albumInfo retain];
  artistNameLabel.text = [albumInfo objectForKey:@"artist"];
  [activityIndicator startAnimating];
  [NSThread detachNewThreadSelector:@selector(loadAlbumArt) toTarget:self withObject:nil];
  [self reset];
}

- (void)reset {
  albumArtworkImageView.hidden = YES;
  isCorrect = NO;
  button.enabled = YES;
  [wrongImageView flyOut];
}

- (void)playRandomTrack {
  NSArray* trackKeys = [albumInfo objectForKey:@"trackKeys"];
  NSInteger randTrackIndex = arc4random() % [trackKeys count];
  NSString* trackKey = [trackKeys objectAtIndex:randTrackIndex];
  [[[RDQuizAppDelegate rdioInstance] player] playSource:trackKey];
}

- (void)wasClicked {
  if(delegate_ != nil && [delegate_ respondsToSelector:@selector(choiceWasMade:)]) {
    [delegate_ choiceWasMade:isCorrect];
  }
  if(isCorrect) {
    [albumArtworkImageView bounce];
    [glowImageView bounce];
    [noGlowImageView bounce];
  }
  button.enabled = NO;
  [[[RDQuizAppDelegate rdioInstance] player] stop];
}

- (void)setDelegate:(id<RDQChoiceDelegate>)delegate {
  delegate_ = delegate;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.nextResponder touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark Animation Delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  [self doGlowAnimation];
}												  

@end
