//
//  RPThresholdLabelWindow.m
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-05.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPThresholdLabelWindow.h"

@implementation RPThresholdLabelWindow

- (instancetype)initWithContentRect:(NSRect)contentRect {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (!self) return nil;
    
    [self setLevel:NSFloatingWindowLevel];
    self.hidesOnDeactivate = YES;
    [self setReleasedWhenClosed:NO];
    [self setOpaque:NO];
    
    return self;
}

@end
