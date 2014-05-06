//
//  RPInstantAlphaViewController.m
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPInstantAlphaViewController.h"

#import "RPInstantAlphaInstructionsWindowController.h"
#import "RPInstantAlphaImageView.h"
#import "RPThresholdLabelView.h"
#import "RPThresholdLabelWindow.h"

const CGFloat RPInstantAlphaThresholdLabelWidth = 50.0;
const CGFloat RPInstantAlphaThresholdLabelHeight = 25.0;
const CGFloat RPInstantAlphaThresholdLabelCornerRadius = 5.0;
const CGFloat RPInstantAlphaInstructionYPadding = 20.0;

@interface RPInstantAlphaViewController ()

@property (nonatomic, strong) RPInstantAlphaImageView *imageView;
@property (nonatomic, strong) RPInstantAlphaInstructionsWindowController *instructionsWindowController;
@property (nonatomic, strong) NSWindow *thresholdLabelWindow;

@property (nonatomic, strong) NSImage *originalImage;
@property (nonatomic, strong) NSImage *editedImage;

@property (nonatomic, copy) void(^completion)(NSImage *);

@property (nonatomic, strong) RPThresholdLabelView *labelView;
@end

@implementation RPInstantAlphaViewController

- (instancetype)initWithImage:(NSImage *)image completion:(void(^)(NSImage *))completion {
    self = [super init];
    if (!self) return nil;
    
    _originalImage = image;
    _editedImage = [image copy];
    
    _completion = completion;
    
    return self;
}

- (void)displayHUD {
    [self.instructionsWindowController.window orderFront:nil];
    NSRect instructionsFrame = ({
        CGRect instructionsFrame = self.instructionsWindowController.window.frame;
        CGRect windowFrame = self.view.window.frame;
        CGFloat x = CGRectGetMinX(windowFrame) + (CGRectGetWidth(self.view.frame) - CGRectGetWidth(instructionsFrame)) / 2;
        CGFloat y = CGRectGetMinY(windowFrame) - CGRectGetHeight(instructionsFrame) - RPInstantAlphaInstructionYPadding;
        instructionsFrame.origin = CGPointMake(x, y);
        instructionsFrame;
    });
    [self.instructionsWindowController.window setFrame:instructionsFrame display:YES];
}

- (void)loadView {
    self.view = [[NSView alloc] init];
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    __weak __typeof(self) weakSelf = self;
    self.instructionsWindowController = [[RPInstantAlphaInstructionsWindowController alloc] initWithReset:^{
        [weakSelf reset];
    } done:^{
        [weakSelf done];
    }];
    
    NSRect labelRect = NSMakeRect(0.0, 0.0, RPInstantAlphaThresholdLabelWidth, RPInstantAlphaThresholdLabelHeight);
    self.thresholdLabelWindow = [[RPThresholdLabelWindow alloc] initWithContentRect:labelRect];
    
    self.labelView = [[RPThresholdLabelView alloc] initWithFrame:NSInsetRect(labelRect, 1.0, 1.0) cornerRadius:RPInstantAlphaThresholdLabelCornerRadius];
    [self.thresholdLabelWindow setContentView:self.labelView];

    self.imageView = [[RPInstantAlphaImageView alloc] initWithFrame:self.view.bounds selectionStarted:^{
        [self.thresholdLabelWindow makeKeyAndOrderFront:nil];
    } selectionChanged:^(NSPoint mousePoint, CGFloat threshold) {
        NSPoint windowOrigin = weakSelf.view.window.frame.origin;
        NSPoint mouseRelativeToViewPoint = NSMakePoint(mousePoint.x + windowOrigin.x, mousePoint.y + windowOrigin.y);
        mouseRelativeToViewPoint.y -= RPInstantAlphaThresholdLabelHeight; // Align top-left corner to mouse instead of bottom-left (origin)
        [weakSelf.thresholdLabelWindow setFrameOrigin:mouseRelativeToViewPoint];
        weakSelf.labelView.threshold = threshold;
    } selectionEnded:^(NSImage *image) {
        [weakSelf.thresholdLabelWindow close];
        weakSelf.editedImage = image;
    }];
    
    self.imageView.image = _editedImage;
    self.imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:self.imageView];
}

- (void)reset {
    self.editedImage = [self.originalImage copy];
    self.imageView.image = self.editedImage;
}

- (void)done {
    if (self.completion) self.completion(self.editedImage);
}

@end
