//
//  RPInstantAlphaInstructionsWindowController.m
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPInstantAlphaInstructionsWindowController.h"

@interface RPInstantAlphaInstructionsWindowController ()

@property (nonatomic, copy) void(^resetHandler)();
@property (nonatomic, copy) void(^doneHandler)();

@end

@implementation RPInstantAlphaInstructionsWindowController

- (instancetype)initWithReset:(void(^)())resetHandler done:(void(^)())doneHandler {
    self = [super initWithWindowNibName:@"RPInstantAlphaInstructionsWindow" owner:self];
    if (!self) return nil;
    
    _resetHandler = resetHandler;
    _doneHandler = doneHandler;
    
    return self;
}

- (void)loadWindow {
    [super loadWindow];
    
    // In order to match Keynote's behavior we want a window that floats on top (but not on top of other applications!) and doesn't become the key window
    [self.window setLevel:NSFloatingWindowLevel];
    self.window.hidesOnDeactivate = YES;
}

- (IBAction)reset:(id)sender {
    if (self.resetHandler) self.resetHandler();
}

- (IBAction)done:(id)sender {
    if (self.doneHandler) self.doneHandler();
}

@end
