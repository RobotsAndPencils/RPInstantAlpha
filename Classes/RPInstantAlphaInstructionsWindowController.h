//
//  RPInstantAlphaInstructionsWindowController.h
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@interface RPInstantAlphaInstructionsWindowController : NSWindowController

/**
 *  Creates a new instruction window controller
 *
 *  @param resetHandler Block called when the reset button is pressed
 *  @param doneHandler  Block called when the done button is pressed
 *
 *  @return A new RPInstantAlphaInstructionsWindowController instance
 */
- (instancetype)initWithReset:(void(^)())resetHandler done:(void(^)())doneHandler;

@end
