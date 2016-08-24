//
//  AVCamViewController.h
//  CameraOverlay
//
//  Created by Baiqi Zhang on 5/14/15.
//  Copyright (c) 2015 Baiqi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCamViewController : UIViewController

@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *stillButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) id overlayView;
@property (nonatomic) BOOL isInUserGuide;

-(instancetype)initWithOverlayView:(UIView*)overlayView;
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer withFlag:(BOOL)flag;
- (void)cameraZoom:(float)scale;
- (void)setRefImage;
- (void)snapStillImage:(id)sender;
-(void)rotateUpright;
-(void)rotateRight;
@end
