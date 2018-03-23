//
//  ImageCropView.h
//  Test
//
//  Created by Jack on 2018/3/16.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLImageCropView : UIControl

@property (nonatomic,strong) UIImage *img;

- (UIImage *)cropImage;

@end
