//
//  RPInstantAlphaInstructionsWindow.m
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-08.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPInstantAlphaInstructionsWindow.h"

@import QuartzCore.CAGradientLayer;

@interface RPInstantAlphaInstructionsWindow ()

@property (nonatomic, assign) NSPoint currentLocation;
@property (nonatomic, assign) NSPoint newOrigin;
@property (nonatomic, assign) NSInteger offsetX;
@property (nonatomic, assign) NSInteger offsetY;

@end

@implementation RPInstantAlphaInstructionsWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
    if (!self) {
        return nil;
    }
    
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];

    return self;
}

- (void)setContentView:(NSView *)aView {
    aView.frame = NSInsetRect(self.frame, -15, -15);
    CAGradientLayer *backgroundLayer = [[CAGradientLayer alloc] init];
    backgroundLayer.masksToBounds = NO;
    
    backgroundLayer.cornerRadius = 8.0;
    
    backgroundLayer.borderColor = [[NSColor colorWithCalibratedWhite:1.0 alpha:0.8] CGColor];
    backgroundLayer.borderWidth = 2.0;
    
    backgroundLayer.colors = @[ (id)[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] CGColor], (id)[[NSColor colorWithCalibratedWhite:0.1 alpha:0.7] CGColor] ];
    
    aView.wantsLayer = YES;
    aView.layer = backgroundLayer;
    
    [super setContentView:aView];
    
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    
    self.offsetX = self.currentLocation.x - [self frame].origin.x;
    self.offsetY = self.currentLocation.y - [self frame].origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    self.currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];

    self.newOrigin = NSMakePoint(self.currentLocation.x - self.offsetX, self.currentLocation.y - self.offsetY);

    [self setFrameOrigin:self.newOrigin];
}

@end
