//
//  RPThresholdLabelView.h
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-05.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RPThresholdLabelView : NSView

@property (nonatomic, assign) CGFloat threshold;

/**
 *  Creates a new threshold label view
 *
 *  @param frameRect    The frame of the view
 *  @param cornerRadius The corner radius of the view
 *
 *  @return A new RPThresholdLabelView instance
 */
- (instancetype)initWithFrame:(NSRect)frameRect cornerRadius:(CGFloat)cornerRadius;

@end
