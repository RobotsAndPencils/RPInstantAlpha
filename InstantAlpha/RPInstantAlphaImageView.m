//
//  RPInstantAlphaImageView.m
//  InstantAlpha
//
//  Created by Brandon Evans on 2014-05-02.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPInstantAlphaImageView.h"

const CGFloat RPInstantAlphaThresholdMaxRadius = 200.0;

CGFloat map(CGFloat inMin, CGFloat inMax, CGFloat outMin, CGFloat outMax, CGFloat value) {
    return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

@interface RPInstantAlphaImageView ()

@property (nonatomic, strong) NSImage *maskedImage;
@property (nonatomic, assign) NSPoint startPoint;
@property (nonatomic, assign) NSPoint currentPoint;
@property (nonatomic, strong) NSColor *pickedColor;
@property (nonatomic, assign) BOOL hasFinishedDragging;

@property (nonatomic, copy) void (^selectionStarted)();
@property (nonatomic, copy) void (^selectionChanged)(NSPoint mousePoint, CGFloat threshold);
@property (nonatomic, copy) void (^selectionEnded)(NSImage *image);

@property (nonatomic, strong) NSColor *minColor;
@property (nonatomic, strong) NSColor *maxColor;
@property (nonatomic) double threshold;

@end

@implementation RPInstantAlphaImageView

- (instancetype)initWithFrame:(NSRect)frame selectionStarted:(void (^)())selectionStarted selectionChanged:(void (^)(NSPoint mousePoint, CGFloat threshold))selectionChanged selectionEnded:(void (^)(NSImage *))selectionEnded {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    _selectionStarted = selectionStarted;
    _selectionChanged = selectionChanged;
    _selectionEnded = selectionEnded;

    _hasFinishedDragging = YES;

    // Setup mouse handlers with a local monitor so they are fired even if the mouse is outside this view
    [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask handler:^NSEvent *(NSEvent *event) {
        NSPoint mousePoint = [self convertPoint:[event locationInWindow] toView:self];
        CGFloat threshold = fmax(fmin([self distanceFromStart:mousePoint] / RPInstantAlphaThresholdMaxRadius, 1.0), 0.0);

        if (NSEqualPoints(self.currentPoint, mousePoint) || self.threshold == threshold) return event;

        self.currentPoint = mousePoint;
        self.threshold = threshold;

        [self updateThresholdColors];
        [self setNeedsDisplay];

        if (self.selectionChanged) self.selectionChanged(self.currentPoint, self.threshold);

        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseUpMask handler:^(NSEvent *event) {
        if (self.hasFinishedDragging) return event;

        self.hasFinishedDragging = YES;
        [self setNeedsDisplay];

        [self.undoManager registerUndoWithTarget:self selector:@selector(setImage:) object:self.image];
        self.image = [self.maskedImage copy];

        [NSCursor unhide];

        if (self.selectionEnded) self.selectionEnded(self.maskedImage);

        return event;
    }];

    return self;
}

- (void)setImage:(NSImage *)newImage {
    [super setImage:newImage];
    self.maskedImage = newImage;
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    if (self.hasFinishedDragging) {
        [self drawMaskedImage];
    }
    else {
        [self drawHighlightedImage];
    }
    [self drawThresholdCircle];
}

- (void)drawMaskedImage {
    NSRect actualImageRect = [self imageFrame];
    [self.maskedImage drawInRect:actualImageRect fromRect:NSMakeRect(0.0, 0.0, self.image.size.width, self.image.size.height) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

- (void)drawHighlightedImage {
    if (!self.pickedColor) return;

    NSRect actualImageRect = [self imageFrame];
    NSRect bounds = self.bounds;

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);

    // Draw the original image first
    [self.maskedImage drawInRect:actualImageRect fromRect:NSMakeRect(0.0, 0.0, self.image.size.width, self.image.size.height) operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil];

    // Get the source image
    CGImageRef imageRef = [self.image CGImageForProposedRect:&bounds context:[NSGraphicsContext currentContext] hints:nil];

    // Draw it in an alpha-less context so we can use CGImageCreateWithMaskingColors
    CGImageRef imageRefWithoutAlpha = [self newCGImageWithoutAlphaFromCGImage:imageRef];

    // Mask the original image based on the min/max colors
    CGFloat *colorMasking = [self newColorMaskingArrayWithStartColor:self.minColor endColor:self.maxColor];
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(imageRefWithoutAlpha, colorMasking);

    // Draw the masked image in a context *with* alpha now, so that when we pass it back it will be transparent
    CGImageRef imageRefWithAlpha = [self newCGImageWithAlphaFromCGImage:imageRefWithoutAlpha];

    // Create a transparent image for drawing when done dragging
    self.maskedImage = [[NSImage alloc] initWithCGImage:maskedImageRef size:self.image.size];
//    self.maskedImage = [self maskedImage:maskedImageRef FromAlphaOfImage:maskedImageRef];

    // Draw the translucent highlight overlay and then draw the color-masked image overtop
    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.5);
    CGContextFillRect(context, actualImageRect);
    CGContextDrawImage(context, actualImageRect, maskedImageRef);

    // Cleanup
    CGContextRestoreGState(context);

    CGImageRelease(imageRefWithoutAlpha);
    CGImageRelease(imageRefWithAlpha);
    CGImageRelease(maskedImageRef);
    free(colorMasking);
}

- (void)drawThresholdCircle {
    if (self.hasFinishedDragging) return;

    CGFloat radius = [self distanceFromStart:self.currentPoint];
    NSRect thresholdRect = NSMakeRect(self.startPoint.x - radius, self.startPoint.y - radius, radius * 2.0, radius * 2.0);
    NSBezierPath *thresholdCircle = [NSBezierPath bezierPathWithOvalInRect:thresholdRect];

    [[NSColor colorWithWhite:1.0 alpha:0.5] set];
    [thresholdCircle stroke];
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] toView:self];
    BOOL mouseInPhoto = CGRectContainsPoint([self imageFrame], mousePoint);
    if (!mouseInPhoto) return;

    self.hasFinishedDragging = NO;

    self.startPoint = mousePoint;
    self.currentPoint = mousePoint;
    self.threshold = 0.0;

    // In order to get the color at the mouse coordinate, we need to scale the mouse point to the point in the original image rect
    NSRect imageRect = [self imageFrame];
    CGFloat imageXScale = imageRect.size.width / self.image.size.width;
    CGFloat imageYScale = imageRect.size.height / self.image.size.height;
    mousePoint = NSMakePoint((mousePoint.x - imageRect.origin.x) / imageXScale, (mousePoint.y - imageRect.origin.y) / imageYScale);
    self.pickedColor = [self sampleColorAtPoint:mousePoint];

    [self updateThresholdColors];
    [self setNeedsDisplay];

    [NSCursor hide];

    if (self.selectionStarted) self.selectionStarted();
}

#pragma mark - Helpers

// Calculate the min/max colors with the threshold
// 100% threshold should cover 0.0f - 255.0f for all components
- (void)updateThresholdColors {
    CGFloat red, green, blue;
    [self.pickedColor getRed:&red green:&green blue:&blue alpha:NULL];

    self.minColor = [self colorWithComponentsBetweenRed:red green:green blue:blue bound:0.0];
    self.maxColor = [self colorWithComponentsBetweenRed:red green:green blue:blue bound:1.0];
}

- (NSColor *)sampleColorAtPoint:(NSPoint)point {
    NSBitmapImageRep *imageRepresentation = [[NSBitmapImageRep alloc] initWithData:[self.image TIFFRepresentation]];
    // Not exactly sure why we need to flip the coordinates as this isn't a flipped view
    point.y = imageRepresentation.size.height - point.y;
    NSColor *color = [imageRepresentation colorAtX:(NSInteger)point.x y:(NSInteger)point.y];
    return color;
}
                               
- (CGFloat)distanceFromStart:(NSPoint)point {
   CGFloat distance = sqrt(pow(point.x - self.startPoint.x, 2.0) + pow(point.y - self.startPoint.y, 2.0));
    return distance;
}

- (CGFloat)imageScale {
    NSSize size = [[self image] size];
    NSRect iFrame = [self bounds];
    if (NSWidth(iFrame) > size.width && NSHeight(iFrame) > size.height) {
        return 1.0;
    }
    else {
        CGFloat xRatio = NSWidth(iFrame)/size.width;
        CGFloat yRatio = NSHeight(iFrame)/size.height;
        return fmin(xRatio, yRatio);
    }
}

- (NSRect)imageFrame {
    NSSize size = [[self image] size];
    NSRect bounds = [self bounds];
    CGFloat scale = [self imageScale];
    NSRect imageRect;
    imageRect.size.width = floor(size.width * scale + 0.5);
    imageRect.size.height = floor(size.height * scale + 0.5);
    imageRect.origin.x = floor((bounds.size.width - imageRect.size.width) / 2.0 + 0.5);
    imageRect.origin.y = floor((bounds.size.height - imageRect.size.height) / 2.0 + 0.5);
    return imageRect;
}

- (NSImage *)maskedImage:(CGImageRef)imageRef withMaskImageRef:(CGImageRef)maskImageRef {
    CGImageRef maskedImage = CGImageCreateWithMask(imageRef, maskImageRef);
	NSImage *result = [[NSImage alloc] initWithCGImage:maskedImage size:NSMakeSize(CGImageGetWidth(maskedImage), CGImageGetHeight(maskedImage))];
    return result;
}

- (CGImageRef)maskImageRefFromAlphaOfImage:(CGImageRef)maskImageRef {
    // Original RGBA image
    float width = CGImageGetWidth(maskImageRef);
    float height = CGImageGetHeight(maskImageRef);
    
    // Make a bitmap context that's only 1 alpha channel
    NSInteger bytesPerRow = CGImageGetBytesPerRow(maskImageRef) / 4;
    unsigned char *alphaData = calloc(bytesPerRow * height, sizeof(unsigned char));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData, width, height, 8, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaOnly);
    
    // Draw the RGBA image into the alpha-only context.
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), maskImageRef);
    
    // Walk the pixels and invert the alpha value. This lets you colorize the opaque shapes in the original image.
    // If you want to do a traditional mask (where the opaque values block) just get rid of these loops.
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = alphaData[y * bytesPerRow + x];
            val = 255 - val;
            alphaData[y * bytesPerRow + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    // Make a mask
    CGImageRef finalMaskImage = CGImageMaskCreate(width, height, CGImageGetBitsPerComponent(alphaMaskImage), CGImageGetBitsPerPixel(alphaMaskImage), CGImageGetBytesPerRow(alphaMaskImage), CGImageGetDataProvider(alphaMaskImage), NULL, YES);
    CGImageRelease(alphaMaskImage);
    
    CFAutorelease(finalMaskImage);
    return finalMaskImage;
}

- (NSColor *)colorWithComponentsBetweenRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue bound:(CGFloat)bound {
    NSAssert1(bound >= 0.0 && bound <= 1.0, @"Bound argument should be between 0.0 and 1.0 inclusively, was %f", bound);

    CGFloat adjustedRed, adjustedGreen, adjustedBlue;

    adjustedRed = map(0.0, 1.0, red, bound, self.threshold);
    adjustedGreen = map(0.0, 1.0, green, bound, self.threshold);
    adjustedBlue = map(0.0, 1.0, blue, bound, self.threshold);

    NSColor *adjustedColor = [NSColor colorWithDeviceRed:adjustedRed green:adjustedGreen blue:adjustedBlue alpha:1.0];
    return adjustedColor;
}

- (CGImageRef)newCGImageWithoutAlphaFromCGImage:(CGImageRef)imageRef {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);

    CGContextRef alphalessContext = CGBitmapContextCreate(NULL, (size_t)width, (size_t)height, 8, (size_t)width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(alphalessContext, CGRectMake(0.0, 0.0, width, height), imageRef);
    CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(alphalessContext);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(alphalessContext);

    return imageRefWithoutAlpha;
}

- (CGImageRef)newCGImageWithAlphaFromCGImage:(CGImageRef)imageRef {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);

    CGContextRef alphaContext = CGBitmapContextCreate(NULL, (size_t)width, (size_t)height, 8, (size_t)width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(alphaContext, CGRectMake(0.0, 0.0, width, height), imageRef);
    CGImageRef ImageRefWithAlpha = CGBitmapContextCreateImage(alphaContext);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(alphaContext);

    return ImageRefWithAlpha;
}

- (CGFloat *)newColorMaskingArrayWithStartColor:(NSColor *)startColor endColor:(NSColor *)endColor {
    NSAssert1([startColor numberOfComponents], @"startColor must be an RGBA color with 4 components, had %ld components", (long)[startColor numberOfComponents]);
    NSAssert1([endColor numberOfComponents], @"endColor must be an RGBA color with 4 components, had %ld components", (long)[endColor numberOfComponents]);

    NSArray *colours = @[ startColor, endColor ];
    NSInteger colorCount = [colours count];
    NSInteger componentCount = [startColor numberOfComponents] - 1; // Skip alpha

    CGFloat *colorMasking = malloc((size_t)(colorCount * componentCount * sizeof(CGFloat)));
    CGFloat *components = malloc((size_t)(componentCount * sizeof(CGFloat)));
    for (NSUInteger componentIndex = 0; componentIndex < componentCount; componentIndex += 1) {
        for (NSUInteger colorIndex = 0; colorIndex < colorCount; colorIndex += 1) {
            [colours[colorIndex] getComponents:components];
            CGFloat value = components[componentIndex];
            value *= 255.0;
            colorMasking[componentIndex * colorCount + colorIndex] = value;
        }
    }
    free(components);

    return colorMasking;
}

@end
