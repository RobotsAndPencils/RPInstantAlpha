//
//  RPAppDelegate.m
//  RPInstantAlphaDemo
//
//  Created by Brandon Evans on 2014-05-13.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPAppDelegate.h"

#import <RPInstantAlpha/RPInstantAlphaViewController.h>

@interface RPAppDelegate ()

@property (nonatomic, weak) IBOutlet NSView *contentView;
@property (nonatomic, strong) RPInstantAlphaViewController *instantAlphaViewController;

@end

@implementation RPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSImage *image = [NSImage imageNamed:@"grass"];
    self.instantAlphaViewController = [[RPInstantAlphaViewController alloc] initWithImage:image completion:^(NSImage *image, BOOL cancelled) {
        NSLog(@"Edited image: %@", image);
    }];
    CGRect imageRect = NSMakeRect(0.0f, 0.0f, image.size.width, image.size.height);
    [self.window setFrame:NSOffsetRect(imageRect, 200.0f, 200.0f) display:YES];
    self.instantAlphaViewController.view.frame = imageRect;
    self.instantAlphaViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.contentView addSubview:self.instantAlphaViewController.view];
    [self.instantAlphaViewController showHUD];
}

@end
