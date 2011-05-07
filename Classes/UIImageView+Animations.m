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

#import "UIImageView+Animations.h"

@implementation UIImageView (Animations)
- (void)flyIn {
  self.alpha = 0;
  self.transform = CGAffineTransformScale(self.transform, UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR, UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR);
  [UIView beginAnimations:@"flyIn" context:nil];
  [UIView setAnimationDuration:0.3];
  self.transform = CGAffineTransformScale(self.transform, 1.0f / UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR, 1.0f / UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR);
  self.alpha = 1.0f;
  [UIView commitAnimations];
}

- (void)flyOut {
  [UIView beginAnimations:@"flyOut" context:nil];
  [UIView setAnimationDuration:0.3];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(flyOutDidStop)];
  self.transform = CGAffineTransformScale(self.transform, UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR, UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR);
  self.alpha = 0;
  [UIView commitAnimations];
}

- (void)flyOutDidStop {
  self.transform = CGAffineTransformScale(self.transform, 1.0f / UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR, 1.0f / UIIMAGEVIEW_FLYIN_SCALEUP_FACTOR);
}

- (void)bounce {
  [UIView beginAnimations:@"bounce" context:nil];
  [UIView setAnimationDuration:UIIMAGEVIEW_BOUNCE_TOTAL_DURATION/3];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bounceDidStop)];
  self.transform = CGAffineTransformScale(self.transform, UIIMAGEVIEW_BOUNCE_SCALEUP_FACTOR, UIIMAGEVIEW_BOUNCE_SCALEUP_FACTOR);
  [UIView commitAnimations];
}

- (void)bounceDidStop {
  [UIView beginAnimations:@"bounceDidStop" context:nil];
  [UIView setAnimationDuration:UIIMAGEVIEW_BOUNCE_TOTAL_DURATION/3];
  self.transform = CGAffineTransformScale(self.transform, 1.0f / UIIMAGEVIEW_BOUNCE_SCALEUP_FACTOR, 1.0f / UIIMAGEVIEW_BOUNCE_SCALEUP_FACTOR);
  [UIView commitAnimations];
}
@end