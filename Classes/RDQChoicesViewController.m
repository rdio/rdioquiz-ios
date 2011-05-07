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

#import "RDQChoicesViewController.h"
#import <Rdio/Rdio.h>
#import "NSMutableArray+Randomize.h"
#import "Settings.h"
#import "RDQuizAppDelegate.h"


@implementation RDQChoicesViewController

@synthesize correctButton;
@synthesize wrongButton;
@synthesize scoreUnderlay;
@synthesize scoreLabel;
@synthesize albumsSourceType;
@synthesize pointsToAward;
@synthesize curScore;
@synthesize activityIndicator;

- (void)viewDidLoad {
  [super viewDidLoad];
  // setup key-value observer on the player so we know the position as it updates
  RDPlayer *player = [[RDQuizAppDelegate rdioInstance] player];
  [player addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:nil];
  player.delegate = self;
  // load sound fx
  CFURLRef urlRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("correct"), CFSTR("wav"), NULL);
  AudioServicesCreateSystemSoundID(urlRef, &correctSoundID);
  CFRelease(urlRef);
  urlRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("incorrect"), CFSTR("wav"), NULL);
  AudioServicesCreateSystemSoundID(urlRef, &incorrectSoundID);
  CFRelease(urlRef);
  // register to be notified when app is brought back into foreground
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
  
  choiceControllers = [[NSMutableArray alloc] init];
  for(int i = 0; i < 3; i++) {
    RDQChoiceViewController* choiceController = [[RDQChoiceViewController alloc] initWithNibName:@"RDQChoiceViewController" bundle:nil];
    [self.view addSubview:choiceController.view];
    [choiceController setDelegate:self];
    choiceController.view.frame = CGRectMake(0, 10 + (i * (choiceController.view.frame.size.height/2 + 30.0f)), choiceController.view.frame.size.width, choiceController.view.frame.size.height);
    if(i == 1) {
      [choiceController makeRightJustified];
      [choiceController rotateAlbumArt:3];
    } 
    else {
      [choiceController rotateAlbumArt:-4];
    }
    [choiceControllers addObject:choiceController];
    [choiceController release];
  }
  self.title = @"Score: 0";
  scoreLabel.hidden = YES;
  [activityIndicator startAnimating];
  [self getAlbumList];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  correctButton = nil;
  wrongButton = nil;
  scoreLabel = nil;
  scoreUnderlay = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  for(RDQChoiceViewController *c in choiceControllers) {
    [c.view removeFromSuperview];
  }
}

- (void)willEnterForeground {
  if([scoreLabel.text intValue] == 1) {
    [self choiceWasMade:NO];
  }
}

- (void)dealloc {
  RDPlayer* player = [[RDQuizAppDelegate rdioInstance] player];
  [player removeObserver:self forKeyPath:@"position"];
  [player stop];
  
  [choiceControllers release];
  [correctButton release];
  [wrongButton release];
  [albums release];
  [scoreUnderlay release];
  [scoreLabel release];
  [activityIndicator release];
  [super dealloc];
}

- (void)getAlbumList {
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"albums", @"type", @"30", @"limit", nil];
  
  if(albumsSourceType == UserHeavyRotation || albumsSourceType == FriendsHeavyRotation) {
    [params setObject:[[Settings settings] userKey] forKey:@"user"];
    if(albumsSourceType == FriendsHeavyRotation) {
      [params setObject:@"True" forKey:@"friends"];
    }
  }
  
  [[RDQuizAppDelegate rdioInstance] callAPIMethod:@"getHeavyRotation" withParameters:params delegate:self];
}

- (void)chooseCorrectAlbum {
  correctChoice = [choiceControllers objectAtIndex:arc4random() % 3];
  correctChoice.isCorrect = YES;
}

-(void)getTrackKeysForAlbums {
  NSMutableString *albumKeys = [[[NSMutableString alloc] init] autorelease];
  for(NSDictionary *album in albums) {
    [albumKeys appendFormat:@"%@,", [album objectForKey:@"key"]];
  }
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:albumKeys, @"keys", @"trackKeys", @"extras", nil];
  [[RDQuizAppDelegate rdioInstance] callAPIMethod:@"get" withParameters:params delegate:self];
}


- (void)resetChoices:(id)sender {
  wrongButton.hidden = YES;
  correctButton.hidden = YES;
  scoreUnderlay.hidden = NO;
  scoreLabel.text = @"30";
  scoreLabel.hidden = YES;
  [activityIndicator startAnimating];
  [self loadAlbumChoices];
}

- (void)loadAlbumChoices {
  [albums randomize];
  
  int i = 0;
  for(RDQChoiceViewController *c in choiceControllers) {
    c.albumInfo = [albums objectAtIndex:i];
    i++;
  }
  
  [self chooseCorrectAlbum];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  RDPlayer *player = [[RDQuizAppDelegate rdioInstance] player];
  if([keyPath isEqualToString:@"position"]) {
    if(player.position > 0 && scoreLabel.hidden) {
      scoreLabel.hidden = NO;
      [activityIndicator stopAnimating];
    }
    if(player.position >= 29.8) {
      // don't let the player go beyond 30 seconds
      [self choiceWasMade:NO];
    }
    scoreLabel.text = [NSString stringWithFormat:@"%d", 30 - (int)player.position];
  }
}

#pragma mark -
#pragma mark RDAPIRequestDelegate
/**
 * Our API call has returned successfully.
 * the data parameter can be an NSDictionary, NSArray, or NSData 
 * depending on the call we made.
 *
 * Here we will inspect the parameters property of the returned RDAPIRequest
 * to see what method has returned.
 */
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
  NSString *method = [request.parameters objectForKey:@"method"];
  if([method isEqualToString:@"getHeavyRotation"]) {
    if(albums != nil) {
      [albums release];
      albums = nil;
    }
    albums = [[NSMutableArray alloc] initWithArray:data];
    [self getTrackKeysForAlbums];
  }
  else if([method isEqualToString:@"get"]) {
    // we are returned a dictionary but it will be easier to work with an array
    // for our needs
    [albums release];
    albums = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for(NSString *key in [data allKeys]) {
      [albums addObject:[data objectForKey:key]];
    }
    [self loadAlbumChoices];
  }
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
  
}

#pragma mark -
#pragma mark RDPlayerDelegate
- (void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState {
  NSLog(@"*** Player changed from state: %d toState: %d", oldState, newState);
}

- (BOOL)rdioIsPlayingElsewhere {
  return NO;
}

#pragma mark -
#pragma mark RDQChoiceDelegate

- (void)choiceWasMade:(BOOL)isCorrect {
  scoreUnderlay.hidden = YES;
  scoreLabel.hidden = YES;
  
  for(RDQChoiceViewController *c in choiceControllers) {
    if(!c.isCorrect) {
      c.button.enabled = NO;
      [c doWrongAnimation];
    }
  }
  
  SystemSoundID soundIDToPlay;
  
  if(isCorrect) {
    soundIDToPlay = correctSoundID;
    correctButton.hidden = NO;
    curScore += [scoreLabel.text intValue];
  } else {
    soundIDToPlay = incorrectSoundID;
    wrongButton.hidden = NO;
    curScore -= 30;
  }
  [[[RDQuizAppDelegate rdioInstance] player] stop];
  AudioServicesPlaySystemSound(soundIDToPlay);
  self.title = [NSString stringWithFormat:@"Score: %d", self.curScore];
}

- (void) albumArtDidFinishLoading {
  choicesLoadedCount++;
  if(choicesLoadedCount == 3) {
    [correctChoice performSelectorOnMainThread:@selector(playRandomTrack) withObject:nil waitUntilDone:NO];
    choicesLoadedCount = 0;
  }
}

@end
