//
//  AVCamViewController.m
//  CameraOverlay
//
//  Created by Baiqi Zhang on 5/14/15.
//  Copyright (c) 2015 Baiqi Zhang. All rights reserved.
//

#import "AVCamViewController.h"
#import <CoreMotion/CMMotionManager.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AVCamPreviewView.h"

#import "UIImage+Thumbnail.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Rotating.h"

#import "CopyCatSwift-Swift.h"


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface AVCamViewController ()

// For use in the storyboards.
@property (nonatomic, strong) AVCamPreviewView *previewView;
@property (strong,nonatomic) UIImageView *focusView;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *flashModeButton;
@property (nonatomic, strong) UIButton *luckyButton;
@property (nonatomic, strong) UIButton *setRefButton;


- (void)changeCamera:(id)sender;
- (void)snapStillImage:(id)sender;
- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer withFlag:(BOOL)flag;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) BOOL fliped;
@property (nonatomic) AVCaptureFlashMode flashMode;
@property (nonatomic) float zoomingScale;

// Rotation
@property(nonatomic,strong) CMMotionManager * motionManager;
@property(nonatomic) NSInteger orientation;



@property(nonatomic,strong) CCPickOverleyViewController * overlayPicker;

@end

@implementation AVCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

-(instancetype)initWithOverlayView:(UIView*)overlayView{
    self=[super init];
    if (self){
        self.overlayView=overlayView;
    }
    return self;
}

-(void)rotateUpright{
    if (self.orientation==0)
        return;
    
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];

    [UIView animateWithDuration:0.3 animations:^{
        self.libraryButton.transform=CGAffineTransformMakeRotation(0);
        self.cancelButton.transform=CGAffineTransformMakeRotation(0);
        self.flashModeButton.transform=CGAffineTransformMakeRotation(0);
        self.cameraButton.transform=CGAffineTransformMakeRotation(0);
        self.luckyButton.transform=CGAffineTransformMakeRotation(0);
        self.setRefButton.transform=CGAffineTransformMakeRotation(0);
        
        CCOverlayView * overlayView=self.overlayView;
        overlayView.transparencyButton.transform=CGAffineTransformMakeRotation(0);
        overlayView.swipeView.transform=CGAffineTransformMakeRotation(0);
        
        [self.overlayPicker rotateUpright];
    }];
    self.orientation=0;
}

-(void)rotateLeft{
    if (self.orientation==1)
        return;
    
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];

    [UIView animateWithDuration:0.3 animations:^{
        self.libraryButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        self.cancelButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        self.flashModeButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        self.cameraButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        self.luckyButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        self.setRefButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        
        CCOverlayView * overlayView=self.overlayView;
        overlayView.transparencyButton.transform=CGAffineTransformMakeRotation(-M_PI_2);
        overlayView.swipeView.transform=CGAffineTransformMakeRotation(-M_PI_2);
        
        [self.overlayPicker rotateLeft];
    }];
    self.orientation=1;
}

-(void)rotateRight{
    if (self.orientation==-1)
        return;
    
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];

    [UIView animateWithDuration:0.3 animations:^{
        self.libraryButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        self.cancelButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        self.flashModeButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        self.cameraButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        self.luckyButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        self.setRefButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        
        CCOverlayView * overlayView=self.overlayView;
        overlayView.transparencyButton.transform=CGAffineTransformMakeRotation(M_PI_2);
        overlayView.swipeView.transform=CGAffineTransformMakeRotation(M_PI_2);
        
        [self.overlayPicker rotateRight];
    }];
    self.orientation=-1;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    BOOL is1x=NO;
    if (self.view.frame.size.height==480)
        is1x=YES;
    
    // Rotation
    self.motionManager=[[CMMotionManager alloc]init];
    [self.motionManager setDeviceMotionUpdateInterval:0.5];
    self.orientation=0;

    self.fliped=NO;
    
    float height,width;
    CGRect frame_bg;
    if (is1x){
        height=self.view.frame.size.height,width=self.view.frame.size.width;
        frame_bg=CGRectMake(0,0,width,height);
    } else{
        height=self.view.frame.size.height-140,width=self.view.frame.size.width;
        frame_bg=CGRectMake(0,40,width,height);
    }

    self.previewView=[[AVCamPreviewView alloc]initWithFrame:frame_bg];//self.view.frame];
    self.zoomingScale=1;
    [self.view addSubview:self.previewView];

    self.focusView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"focus.png"]];
    self.focusView.alpha=0;
    [self.focusView setFrame:CGRectMake(100, 100, 70, 70)];
    [self.view addSubview:self.focusView];

    float alpha=1;
    if (is1x)
        alpha=0.45;
    
//    if (is1x){
//        UIImageView *test=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
//        [test setImage:[UIImage imageNamed:@"4_3.jpg"]];
//        [self.view addSubview:test];
//    }
    
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 40)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.13 alpha:alpha]];
    [self.view addSubview:bgView];
    bgView=[[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-100, width, 100)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.13 alpha:alpha]];
    [self.view addSubview:bgView];
    

    [self.view addSubview:self.overlayView];

    // upper portion Buttons
//    self.cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(0,-5, 50, 50)];//CGRectMake(40, self.view.frame.size.height-70, 40, 40)];
//    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
//    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"close_highlight.png"] forState:UIControlStateHighlighted];
//    [self.view addSubview:self.cancelButton];

    self.cameraButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-50, 1, 37, 37)];
    [self.cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"switchButton.png"] forState:UIControlStateNormal];
    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"switchButton_highlight.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.cameraButton];

    self.flashModeButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 0, 40, 40)];//CGRectMake(30, 10, 25, 25)];
    [self.flashModeButton addTarget:self action:@selector(switchFlashAction) forControlEvents:UIControlEventTouchUpInside];
    [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOff.png"] forState:UIControlStateNormal];
    [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOff_highlight.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.flashModeButton];
    
    self.luckyButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, 10, 22, 22)];
    [self.luckyButton addTarget:self action:@selector(feelLucky) forControlEvents:UIControlEventTouchUpInside];
    [self.luckyButton setBackgroundImage:[UIImage imageNamed:@"lucky.png"] forState:UIControlStateNormal];
    [self.luckyButton setBackgroundImage:[UIImage imageNamed:@"lucky.png"] forState:UIControlStateHighlighted];
//    [self.view addSubview:self.luckyButton];
    
    //lower portion Buttons
    self.stillButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-37, self.view.frame.size.height-85, 80, 80)];
    [self.stillButton addTarget:self action:@selector(snapStillImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.stillButton setBackgroundImage:[UIImage imageNamed:@"shutter.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.stillButton];

    self.libraryButton=[[UIButton alloc]initWithFrame:CGRectMake(30, self.view.frame.size.height-67.5, 45, 45)];
    [self.libraryButton addTarget:self action:@selector(showLibraryDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.libraryButton setBackgroundColor:[UIColor blackColor]];
//    [self.view addSubview:self.libraryButton];
    
    self.cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(25, self.view.frame.size.height-67.5, 80, 45)];
    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor hexStringToColor:@"#41AFFF"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.cancelButton];

    
    self.setRefButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 70, 60, 50)];
    [self.setRefButton addTarget:self action:@selector(setRefImage) forControlEvents:UIControlEventTouchUpInside];
    [self.setRefButton setTitleColor:[UIColor hexStringToColor:@"#41AFFF"] forState:UIControlStateHighlighted];
    [self.setRefButton setTitle:NSLocalizedString(@"Library", @"") forState:UIControlStateNormal];
    
    [self.view addSubview:self.setRefButton];
    
    self.overlayPicker = [[CCPickOverleyViewController alloc]init];
    
    self.flashMode=AVCaptureFlashModeOff;
    
    
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset=AVCaptureSessionPresetPhoto;
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];

			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
  
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}

		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
      CCOverlayView *overlayView=self.overlayView;
        if (motion.gravity.x<-0.5f) {
            if (![self.overlayView isInited]) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.overlayView initOverlay];
                    [self.overlayView prepareAnimation];
                });
            }
        }
      if (overlayView.refOrientation == -90){
        [self rotateRight];
      } else {
        [self rotateUpright];
      }
//        else if (motion.gravity.x>-0.45f&&motion.gravity.x<0.45f)
//            [self rotateUpright];
      
    }];
    
    
    NSArray *list = [CCCoreUtil categories];
    CCCategory *userCategory = list[0];
    if ([[userCategory photoList] count]!=0){
        NSArray *photoList = [userCategory photoList];
        CCPhoto *photo = photoList[photoList.count-1];
        NSString *path =[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),[photo photoURI]];
        UIImage *image=[[UIImage alloc]initWithContentsOfFile:path];
        [self.libraryButton setBackgroundImage:[image thumbnail] forState:UIControlStateNormal];
    } else {
        [self.libraryButton setBackgroundImage:nil forState:UIControlStateNormal];
    }

	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak AVCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			AVCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
			});
		}]];
		[[self session] startRunning];
	});
}

-(void)viewDidAppear:(BOOL)animated{
    CCOverlayView *overlayView=self.overlayView;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.motionManager stopDeviceMotionUpdates];
    
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
	});
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
//			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
				[[self stillButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
				[[self stillButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions
-(void)setRefImage{
    [self.overlayView setAlpha:0];
    [self.cancelButton setAlpha:0];
    
    //set default image
    CCOverlayView* overlayView = self.overlayView;
    self.overlayPicker.currentImage = overlayView.image;
    
    //present
    self.overlayPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.overlayPicker.delegate = self;
    
    
    [self presentViewController:self.overlayPicker animated:NO completion:^{
        if (self.orientation==1){
            [self.overlayPicker rotateLeft];
        }
        if (self.orientation==-1){
            [self.overlayPicker rotateRight];
        }
    }];
}

- (void)cameraZoom:(float)scale {
    CGAffineTransform transform = CGAffineTransformScale(self.previewView.transform, scale, scale);
    if (transform.a<1)
        transform=CGAffineTransformMakeScale(1, 1);
    if (transform.a>4)
        transform=CGAffineTransformMakeScale(4, 4);
    self.zoomingScale=transform.a;
    self.previewView.transform=transform;
}


-(void)showLibraryDetail{;
//    if ([self.libraryButton backgroundImageForState:UIControlStateNormal]==nil){
//        return;
//    }
//    CCCategory *userCategory = [CCCoreUtil categories][0];
//    CCPhotoBrowser *libVC=[[CCPhotoBrowser alloc]initWithPhotos:userCategory.photoList.array.mutableCopy currentIndex:[userCategory.photoList count]-1];
//    libVC.delegate=self;
//    libVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
//    libVC.category = userCategory;
//    [self presentViewController:libVC animated:YES completion:nil];
}


-(void)switchFlashAction{
    switch (self.flashMode) {
        case AVCaptureFlashModeAuto:
            self.flashMode=AVCaptureFlashModeOn;
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOn.png"] forState:UIControlStateNormal];
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOn_highlight.png"] forState:UIControlStateHighlighted];
            break;
        case AVCaptureFlashModeOn:
            self.flashMode=AVCaptureFlashModeOff;
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOff.png"] forState:UIControlStateNormal];
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashOff_highlight.png"] forState:UIControlStateHighlighted];
            break;
        case AVCaptureFlashModeOff:
            self.flashMode=AVCaptureFlashModeAuto;
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashAuto.png"] forState:UIControlStateNormal];
            [self.flashModeButton setBackgroundImage:[UIImage imageNamed:@"flashAuto_highlight.png"] forState:UIControlStateHighlighted];
            break;
            
            
        default:
            break;
    }
}


-(void)cancelAction{

    if (self.isInUserGuide) {
        self.isInUserGuide = false;
        [self presentViewController:[CCWelcomeViewController new] animated: true completion: NULL];
    } else {
        [self dismissViewControllerAnimated:YES completion: ^void () {
        }];
    }
}

- (void)changeCamera:(id)sender
{
	[[self cameraButton] setEnabled:NO];
	[[self stillButton] setEnabled:NO];
	
    self.fliped=!self.fliped;
    
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
//            MyOverlayView *view=self.overlayView;
			[[self stillButton] setEnabled:YES];
		});
	});
}

-(void)feelLucky{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [AVCamViewController setFlashMode:self.flashMode forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                
                image=[image fixOrientation];
              
                if (self.zoomingScale!=1)
                    image=[image zoomWithFactor:self.zoomingScale];
                
                
                CCOverlayView *overlayView=self.overlayView;
                
                [CCNetUtil feelLucky:image completion:^(NSString * _Nullable reply) {
                    NSLog(@"%@",reply);                    
                }];
            }
        }];
    });
}

- (void)snapStillImage:(id)sender
{
	dispatch_async([self sessionQueue], ^{
		// Update the orientation on the still image output video connection before capturing.
	 	[AVCamViewController setFlashMode:self.flashMode forDevice:[[self videoDeviceInput] device]];
		
		// Capture a still image.
		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
			if (imageDataSampleBuffer)
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				UIImage *image = [[UIImage alloc] initWithData:imageData];
        
                image=[image fixOrientation];
                
                if (self.fliped){
                    if (self.orientation != 0) {
                        image = [image rotateInDegrees:-90];
                    }
                    image = [image horizontalFlip];
                }

                if (self.zoomingScale!=1)
                    image=[image zoomWithFactor:self.zoomingScale];

                
                CCOverlayView *overlayView=self.overlayView;
                
                
                if ([CCCoreUtil isPreviewAfterPhotoTaken]){
                    CCOverlayView* ovlv = (CCOverlayView*) self.overlayView;
                    CCPreviewViewController *pvc=[[CCPreviewViewController alloc]initWithImage:image withReferenceImage:overlayView.image orientation:self.orientation refOrientation:ovlv.refOrientation];
                    if (_isShowPreviewGuide) {
                        pvc.delegate = self;
                        pvc.shouldShowHint = true;
                        _isShowPreviewGuide = false;
                    }
                    pvc.delegate=self;
                    if (self.fliped){
                        pvc.isSelfie = @YES;
                    }
                    [self presentViewController:pvc animated:NO completion:nil];

                } else{
                    self.libraryButton.enabled=NO;
                    self.stillButton.enabled=NO;
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        UIImage* newImage=image;
                        
                        UIImage* tmImage=[newImage thumbnailWithFactor:200];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.libraryButton setBackgroundImage:tmImage forState:UIControlStateNormal];
                        });
                        
                        if ([CCCoreUtil isSaveToCameraRoll])
                        {
                            [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[newImage CGImage] orientation:(ALAssetOrientation)[newImage imageOrientation] completionBlock:nil];
                            NSLog(@"Save to Camera Roll");
                        }
                        
                        [CCCoreUtil addUserPhoto:image refImage:overlayView.image];
                        

                        NSLog(@"Saved");
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.libraryButton.enabled=YES;
                            self.stillButton.enabled=YES	;
                        });
                    });
                }
			}
		}];
	});
}

- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer withFlag:(BOOL)flag
{
    CGPoint tmp=[gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint pos=CGPointMake(tmp.x, tmp.y+40);
    
    self.focusView.center=pos;
    
    self.focusView.alpha=0.0;
    [UIImageView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.focusView.alpha=1.0;}
                          completion:^(BOOL fin){
                              if (fin)
                                  [UIImageView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{self.focusView.alpha=0.3;} completion:nil];
                          }];

    
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    if (flag)
        devicePoint.y=1-devicePoint.y;
    NSLog(@"%f %f",devicePoint.x,devicePoint.y);
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
//    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

// TODO: Add CCCameraGuideView as subview
- (void)cameraGuide
{
}

@end
