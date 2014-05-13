//
//  RPThresholdLabelView.m
//  RPInstantAlpha
//
//  Created by Brandon Evans on 2014-05-05.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPThresholdLabelView.h"

@interface RPThresholdLabelView ()

@property (nonatomic, assign) CGFloat cornerRadius;

@end

@implementation RPThresholdLabelView

- (instancetype)initWithFrame:(NSRect)frameRect cornerRadius:(CGFloat)cornerRadius {
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    _cornerRadius = cornerRadius;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor clearColor] set];
    NSRectFill([self frame]);
    
    NSRect labelRect = self.bounds;
    
    NSBezierPath *labelPath = [NSBezierPath bezierPathWithRoundedRect:labelRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
    
    [[NSColor colorWithWhite:1.0 alpha:0.5] set];
    [labelPath stroke];
    
    [[NSColor colorWithWhite:0.0 alpha:0.7] set];
    [labelPath fill];
    
    NSString *labelText = [NSString stringWithFormat:@"%.0f%%", self.threshold * 100];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    NSMutableDictionary *attributes = [@{ NSFontAttributeName : [NSFont systemFontOfSize:14.0], NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : [NSColor whiteColor] } mutableCopy];
    CGFloat height = [labelText sizeWithAttributes:attributes].height;
    CGFloat y = (labelRect.size.height - height) / 2;
    NSRect textRect = NSOffsetRect(labelRect, 0.0, -(y - 1));
    [labelText drawInRect:textRect withAttributes:attributes];
}

- (void)setThreshold:(CGFloat)threshold {
    _threshold = threshold;
    [self setNeedsDisplay:YES];
}

@end
