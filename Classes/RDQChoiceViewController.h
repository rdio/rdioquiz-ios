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
#import <Rdio/Rdio.h>

#define RDQUIZ_CORRECT_USER_CHOICE_MADE @"RDQUIZ_CORRECT_USER_CHOICE_MADE"
#define RDQUIZ_INCORRECT_USER_CHOICE_MADE @"RDQUIZ_INCORRECT_USER_CHOICE_MADE"

@protocol RDQChoiceDelegate <NSObject>

@optional
-(void)choiceWasMade:(BOOL)isCorrect;
-(void)albumArtDidFinishLoading;

@end


@interface RDQChoiceViewController : UIViewController {
  IBOutlet UIImageView* noGlowImageView;
  IBOutlet UIImageView* glowImageView;
  IBOutlet UIImageView* albumArtworkImageView;
  IBOutlet UIImageView* wrongImageView;
  IBOutlet UILabel* artistNameLabel;
  IBOutlet UIActivityIndicatorView *activityIndicator;
  IBOutlet UIButton* button;
  IBOutlet UIImageView *calloutImageView;
  
  NSDictionary* albumInfo;
  BOOL isCorrect;
  id<RDQChoiceDelegate> delegate_;
}

-(void)makeRightJustified;
-(void)doWrongAnimation;
-(void)reset;
-(void)rotateAlbumArt:(NSInteger)degrees;
-(void)loadAlbumArt;
-(void)doGlowAnimation;
-(void)playRandomTrack;
-(void)setDelegate:(id<RDQChoiceDelegate>)delegate;
-(IBAction)wasClicked;

@property (assign) BOOL isCorrect;
@property (nonatomic, retain) NSDictionary *albumInfo;
@property (nonatomic, retain) UIImageView *noGlowImageView;
@property (nonatomic, retain) UIImageView *glowImageView;
@property (nonatomic, retain) UIImageView *albumArtworkImageView;
@property (nonatomic, retain) UIImageView *wrongImageView;
@property (nonatomic, retain) UILabel *artistNameLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIImageView *calloutImageView;
@end
