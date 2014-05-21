//
//  RPInstantAlphaViewController.h
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@class RPThresholdLabelView;
@class RPInstantAlphaImageView;

@interface RPInstantAlphaViewController : NSViewController

/**
 *  Creates a new instant alpha view controller
 *
 *  @param image      The original image
 *  @param completion Block called when the user completes or cancels modifications. Arguments are the modified image (nil if the modifications were cancelled) and whether the modifications were cancelled or not.
 *
 *  @return A new RPInstantAlphaViewController instance
 */
- (instancetype)initWithImage:(NSImage *)image completion:(void(^)(NSImage *, BOOL))completion;

/**
 *  Shows the instructions HUD window. Must be called after this controller's view is added to a view hierarchy.
 */
- (void)showHUD;

/**
 *  Dismisses the instructions HUD window. Call this when the user cancels or completes the modifications.s
 */
- (void)dismissHUD;

@end
