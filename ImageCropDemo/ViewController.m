//
//  ViewController.m
//  ImageCropDemo
//
//  Created by Jack on 2018/3/23.
//  Copyright © 2018年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "JLImageCropView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet JLImageCropView *cropView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.cropView.img = [UIImage imageNamed:@"blackeye.jpg"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cropClick:(id)sender {
    self.cropView.img = [self.cropView cropImage];
}

@end
