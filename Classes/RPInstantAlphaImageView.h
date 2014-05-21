//
//  RPInstantAlphaImageView.h
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

@interface RPInstantAlphaImageView : NSImageView

/**
 *  Creates a new instant alpha view
 *
 *  @param frame            The frame for the view
 *  @param selectionStarted Block called when the threshold selection is started with the location of the mouse relative to this view
 *  @param selectionChanged Block called when the threshold selection changes with the location of the mouse relative to this view and the current threshold
 *  @param selectionEnded   Block called when the threshold selection is started with modified image
 *
 *  @return A new RPInstantAlphaImageView instance
 */
- (instancetype)initWithFrame:(NSRect)frame selectionStarted:(void (^)(NSPoint mousePoint))selectionStarted selectionChanged:(void (^)(NSPoint mousePoint, CGFloat threshold))selectionChanged selectionEnded:(void (^)(NSImage *))selectionEnded;

@end
