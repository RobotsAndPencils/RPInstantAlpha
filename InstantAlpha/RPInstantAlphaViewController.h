//
//  RPInstantAlphaViewController.h
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@class RPThresholdLabelView;

@interface RPInstantAlphaViewController : NSViewController

- (instancetype)initWithImage:(NSImage *)image completion:(void(^)(NSImage *))completion;
- (void)displayHUD; // Must be called after this controller's view is added to a view hierarchy

@end
