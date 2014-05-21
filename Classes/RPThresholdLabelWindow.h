//
//  RPThresholdLabelWindow.h
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-05.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RPThresholdLabelWindow : NSWindow

/**
 *  Create a new threshold label window
 *
 *  @param contentRect Origin and size of the window’s content area in screen coordinates. Note that the window server limits window position coordinates to ±16,000 and sizes to 10,000.
 *
 *  @return A new RPThresholdLabelWindow instance
 */
- (instancetype)initWithContentRect:(NSRect)contentRect;

@end
