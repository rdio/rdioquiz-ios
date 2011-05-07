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

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Rdio/Rdio.h>
#import "RDQChoiceViewController.h"

typedef enum {
  TopCharts,
  UserHeavyRotation,
  FriendsHeavyRotation
} AlbumsSourceType;

@interface RDQChoicesViewController : UIViewController <RDAPIRequestDelegate, RDPlayerDelegate, RDQChoiceDelegate>{
  NSMutableArray *choiceControllers;
  NSMutableArray* albums;
  AlbumsSourceType albumsSourceType;
  RDQChoiceViewController *correctChoice;
  SystemSoundID correctSoundID;
  SystemSoundID incorrectSoundID;
  NSInteger pointsToAward;
  NSInteger curScore;
  NSInteger choicesLoadedCount;
  
  IBOutlet UIButton *correctButton;
  IBOutlet UIButton *wrongButton;
  IBOutlet UIImageView *scoreUnderlay;
  IBOutlet UILabel *scoreLabel;
  IBOutlet UIActivityIndicatorView *activityIndicator;
}

-(void)getAlbumList;
-(void)chooseCorrectAlbum;
-(void)loadAlbumChoices;
-(void)getTrackKeysForAlbums;
-(IBAction)resetChoices:(id)sender;
-(void)willEnterForeground;

@property (nonatomic, assign) AlbumsSourceType albumsSourceType;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIButton *wrongButton;
@property (nonatomic, retain) UIButton *correctButton;
@property (nonatomic, retain) UIImageView *scoreUnderlay;
@property (nonatomic, assign) NSInteger pointsToAward;
@property (nonatomic, assign) NSInteger curScore;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end
