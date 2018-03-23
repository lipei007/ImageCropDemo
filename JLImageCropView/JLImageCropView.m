//
//  ImageCropView.m
//  Test
//
//  Created by Jack on 2018/3/16.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import "JLImageCropView.h"

typedef enum : NSUInteger {
    LeftTop,
    LeftBottom,
    RightBottom,
    RightTop,
    None
} TouchLocation;

CGFloat lengthBetweenPoints(CGPoint p0,CGPoint p1) {
    return sqrt(pow(p0.x - p1.x, 2) + pow(p0.y - p1.y, 2));
}

CGFloat effectiveTouch = 20.f;

@interface JLImageCropView ()

@property (nonatomic,assign) CGRect cropRect;
@property (nonatomic,assign,readonly) CGPoint cropLT;
@property (nonatomic,assign,readonly) CGPoint cropLB;
@property (nonatomic,assign,readonly) CGPoint cropRT;
@property (nonatomic,assign,readonly) CGPoint cropRB;

@property (nonatomic,assign,readonly) CGSize imgScreenSize;
@property (nonatomic,assign,readonly) CGFloat minX;
@property (nonatomic,assign,readonly) CGFloat minY;
@property (nonatomic,assign,readonly) CGFloat maxX;
@property (nonatomic,assign,readonly) CGFloat maxY;

@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,strong) CAShapeLayer *cropLayer;
@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation JLImageCropView

- (CGPoint)cropLT {
    return CGPointMake(CGRectGetMinX(self.cropRect), CGRectGetMinY(self.cropRect));
}

- (CGPoint)cropLB {
    return CGPointMake(CGRectGetMinX(self.cropRect), CGRectGetMaxY(self.cropRect));
}

- (CGPoint)cropRT {
    return CGPointMake(CGRectGetMaxX(self.cropRect), CGRectGetMinY(self.cropRect));
}

- (CGPoint)cropRB {
    return CGPointMake(CGRectGetMaxX(self.cropRect), CGRectGetMaxY(self.cropRect));
}

- (CGRect)cropRect {
    if (CGRectEqualToRect(CGRectZero, _cropRect)) {
        _cropRect = self.bounds;
    }
    return _cropRect;
}

//- (void)setCropRect:(CGRect)cropRect {
//    _cropRect = cropRect;
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
//    UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:self.cropRect];
//    [path appendPath:subPath];
//
//    self.maskLayer.path = path.CGPath;
//    self.cropLayer.path = subPath.CGPath;
//}

- (CGSize)imgScreenSize {
    if (self.img == nil || CGRectEqualToRect(CGRectZero, self.bounds)) {
        return CGSizeZero;
    }
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat imgW = self.img.size.width;
    CGFloat imgH = self.img.size.height;
    
    if (width / height == imgW / imgH) {
        return self.bounds.size;
    } else if (width / height > imgW / imgH) {
        return CGSizeMake(imgW / imgH * height, height);
    } else {
        return CGSizeMake(width, width / imgW * imgH);
    }
    
    return CGSizeZero;
}

- (CGFloat)minX {
    CGFloat width = CGRectGetWidth(self.bounds);
    return (width - self.imgScreenSize.width) * 0.5;
}

- (CGFloat)minY {
    CGFloat height = CGRectGetHeight(self.bounds);
    return (height - self.imgScreenSize.height) * 0.5;
}

- (CGFloat)maxX {
    return self.minX + self.imgScreenSize.width;
}

- (CGFloat)maxY {
    return self.minY + self.imgScreenSize.height;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imgView];
        
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *lead = [NSLayoutConstraint constraintWithItem:_imgView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0f
                                                                 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imgView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0f
                                                                 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_imgView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0f
                                                                 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_imgView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0f
                                                                 constant:0];
        [self addConstraints:@[lead,top,width,height]];
    }
    return _imgView;
}

- (CAShapeLayer *)maskLayer {
    
    if (!_maskLayer) {
        
        CAShapeLayer *mask = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:self.cropRect];
        [path appendPath:subPath];
        
        mask.fillColor = [UIColor blackColor].CGColor;
        mask.opacity = 0.5;
        mask.path = path.CGPath;
        
        //    path.usesEvenOddFillRule = YES;
        mask.fillRule = kCAFillRuleEvenOdd;
        _maskLayer = mask;
    }
    return _maskLayer;
}

- (CAShapeLayer *)cropLayer {
    
    if (!_cropLayer) {
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:self.cropRect];
        shapeLayer.path = subPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 1.f;
        _cropLayer = shapeLayer;
    }
    return _cropLayer;
}

- (void)setImg:(UIImage *)img {
    _img = img;
    self.imgView.image = img;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGSize imgScreenSize = self.imgScreenSize;
    self.cropRect = CGRectMake((width - imgScreenSize.width) * 0.5, (height - imgScreenSize.height) * 0.5, imgScreenSize.width, imgScreenSize.height);
    
    [self.maskLayer addSublayer:self.cropLayer];
    [self.layer addSublayer:self.maskLayer];
    
    [self updateCropView];
}



- (void)drawRect:(CGRect)rect {
    
}

- (void)updateCropView {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:self.cropRect];
    [path appendPath:subPath];
    
    self.maskLayer.path = path.CGPath;
    self.cropLayer.path = subPath.CGPath;
}

- (void)updateCropRectByPoint:(CGPoint)point {
 
    TouchLocation location = [self touchLocationOfPoint:point];
    CGFloat width = self.cropRect.size.width;
    CGFloat height = self.cropRect.size.height;
    CGFloat x = self.cropRect.origin.x;
    CGFloat y = self.cropRect.origin.y;
    
    switch (location) {
        case LeftTop: {
            CGFloat wLen = x - point.x;
            CGFloat hLen = y - point.y;
            
            x = point.x;
            y = point.y;
            
            width += wLen;
            height += hLen;
            
        }
            break;
        case LeftBottom: {
            
            CGFloat wLen = x - point.x;
            height = point.y - y;
            width += wLen;
            x = point.x;
            
        }
            break;
        case RightTop: {
            
            CGFloat hLen = y - point.y;
            height += hLen;
            width = point.x - x;
            
            y = point.y;
            
        }
            break;
        case RightBottom: {
            
            width = point.x - x;
            height = point.y - y;
        }
            break;
            
        default:
            break;
    }
    
    
    if (width > 2 * effectiveTouch && height > 2 * effectiveTouch) {
        
        CGRect cropRect = CGRectMake(x, y, width, height);
        
//        CGFloat minX = CGRectGetMinX(cropRect), maxX = CGRectGetMaxX(cropRect);
//        CGFloat minY = CGRectGetMinY(cropRect), maxY = CGRectGetMaxY(cropRect);
//
//        BOOL xEffective = minX >= self.minX && minX < self.maxX && maxX > self.minX && maxX <= self.maxX && minX < maxX;
//        BOOL yEffective = minY >= self.minY && minY < self.maxY && maxY > self.minY && maxY <= self.maxY && minY < maxY;
        
        CGFloat myWidth = CGRectGetWidth(self.bounds);
        CGFloat myHeight = CGRectGetHeight(self.bounds);
        CGSize imgScreenSize = self.imgScreenSize;
        CGRect imgRect = CGRectMake((myWidth - imgScreenSize.width) * 0.5, (myHeight - imgScreenSize.height) * 0.5, imgScreenSize.width, imgScreenSize.height);
        
        if (/*xEffective && yEffective*/ CGRectContainsRect(imgRect, cropRect) || CGRectEqualToRect(imgRect, cropRect)) {
            
            self.cropRect = cropRect;
            
            [self updateCropView];
        }
    }
}

#pragma mark - Touch Tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    [self updateCropRectByPoint:lastPoint];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}

#pragma mark - Utils Method

- (TouchLocation)touchLocationOfPoint:(CGPoint)point {
    
    if (lengthBetweenPoints(point, self.cropLT) <= effectiveTouch) {
        return LeftTop;
    } else if (lengthBetweenPoints(point, self.cropLB) <= effectiveTouch) {
        return LeftBottom;
    } else if (lengthBetweenPoints(point, self.cropRB) <= effectiveTouch) {
        return RightBottom;
    } else if (lengthBetweenPoints(point, self.cropRT) <= effectiveTouch) {
        return RightTop;
    } else {
        return None;
    }
}

#pragma mark - Action

- (UIImage *)cropImage {
    
    CGFloat myWidth = CGRectGetWidth(self.bounds);
    CGFloat myHeight = CGRectGetHeight(self.bounds);
    CGSize imgScreenSize = self.imgScreenSize;
    CGRect imgRect = CGRectMake((myWidth - imgScreenSize.width) * 0.5, (myHeight - imgScreenSize.height) * 0.5, imgScreenSize.width, imgScreenSize.height);
    if (CGRectEqualToRect(self.cropRect, imgRect)) {
        return self.img;
    }
    
    CGFloat scale = imgScreenSize.width / self.img.size.width;
    
    
    CGRect destRect = CGRectMake((self.cropRect.origin.x - imgRect.origin.x) / scale, (self.cropRect.origin.y - imgRect.origin.y) / scale, self.cropRect.size.width / scale, self.cropRect.size.height / scale);
    
    return [self clipImage:self.img toRect:destRect];
}

/**
 * 裁剪的图像大小对应裁剪区域大小
 */
- (UIImage *)clipImage:(UIImage *)img toRect:(CGRect)rect {
    if (img == nil) {
        return img;
    }
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return img;
    }
    
    CGImageRef clipedImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *clipedImage = [UIImage imageWithCGImage:clipedImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(clipedImageRef);
    
    return clipedImage;
}

@end
