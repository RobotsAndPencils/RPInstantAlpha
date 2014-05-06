//
//  RPInstantAlphaViewController.h
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

// TODO:
//
// [X] Should be able to create with an image and callback
// [X] Should display provided image
// [X] Should display instructions with reset and done buttons
// [ ] Should display loupe that follows cursor when inside view
// [X] Should allow clicking to select the target color
// [X] Should highlight the target color range
// [X] Should allow dragging the selection to set a threshold
// [X] Should draw with masked colors when mouse is released

@class RPThresholdLabelView;

@interface RPInstantAlphaViewController : NSViewController

- (instancetype)initWithImage:(NSImage *)image completion:(void(^)(NSImage *))completion;
- (void)displayHUD; // Must be called after this controller's view is added to a view hierarchy

@end
