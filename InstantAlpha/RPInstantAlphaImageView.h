//
//  RPInstantAlphaImageView.h
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@interface RPInstantAlphaImageView : NSImageView

- (instancetype)initWithFrame:(NSRect)frame selectionStarted:(void (^)())selectionStarted selectionChanged:(void (^)(NSPoint mousePoint, CGFloat threshold))selectionChanged selectionEnded:(void (^)(NSImage *))selectionEnded;

@end
