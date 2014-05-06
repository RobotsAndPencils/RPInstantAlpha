//
//  RPInstantAlphaInstructionsWindowController.h
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@interface RPInstantAlphaInstructionsWindowController : NSWindowController

- (instancetype)initWithReset:(void(^)())resetHandler done:(void(^)())doneHandler;

@end
