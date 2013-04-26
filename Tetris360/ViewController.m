//
//  ViewController.m
//  Tetris360
//
//  Created by Liang Shi on 2013-04-21.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "StackView.h"

@interface ViewController ()

@property AVCaptureSession *captureSession;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property IBOutlet UIView *cameraView;

@property NSTimer *calibrationTimer;

@property (nonatomic, retain) PieceView *movingPieceView; //current dropping piece
@property (nonatomic, retain) StackView *pieceStackView; //60*15 grid view for pieces already dropped

@end

@implementation ViewController
@synthesize movingPieceView;

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setupCameraView];
    [self setupStackView];
    
    self.calibrationTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finishedCalibrating) userInfo:nil repeats:NO];
}

- (void)setupCameraView
{
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    [self.captureSession addInput:input];
    [self.captureSession setSessionPreset:@"AVCaptureSessionPresetPhoto"];
    [self.captureSession startRunning];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.frame;
    
    [self.cameraView.layer addSublayer:self.previewLayer];
}


- (void)setupStackView
{
    self.pieceStackView  = [[StackView alloc] initWithFrame:CGRectMake(0, 0, kGridSize * kNUMBER_OF_COLUMN, kGridSize * kNUMBER_OF_ROW)];
    [self.view addSubview:self.pieceStackView];
    [self.view bringSubviewToFront:self.startButton];
    [self.view bringSubviewToFront:self.leftButton];
    [self.view bringSubviewToFront:self.rightButton];
    [self.view bringSubviewToFront:self.calibratingView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGameClickeed:(id)sender{
    if ([[GameController shareManager] gameStatus] == GameRunning) { //pause game
        [[GameController shareManager] pauseGame];
        [self.startButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else if([[GameController shareManager] gameStatus] == GameStopped) { //start game
        [[GameController shareManager] startGame];
        [[GameController shareManager] setDelegate:self];
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
        movingPieceView = [[GameController shareManager] generatePiece];
        [self.view addSubview:movingPieceView];
    }
    else if([[GameController shareManager] gameStatus] == GamePaused) { //resume game
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
        [[GameController shareManager] resumeGame];
    }
}

- (void)updateStackView{
    //TODO - add offset from compass to draw only one section
    if ([[GameController shareManager] gameStatus] == GameStopped) {
        movingPieceView = nil;
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    [self.pieceStackView setNeedsDisplay];
}

- (void)dropNewPiece{
    movingPieceView = [[GameController shareManager] generatePiece];
    [self.view addSubview:movingPieceView];
}


- (void)removeCurrentPiece{
    [movingPieceView removeFromSuperview];
    movingPieceView = nil;
}

- (IBAction)leftClicked:(id)sender{
    [[GameController shareManager] movePieceLeft];
}


- (IBAction)rightClicked:(id)sender{
    [[GameController shareManager] movePieceRight];
}

- (IBAction)respondToScreenTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if (location.x < (self.view.frame.size.width/2)) {
        [self leftClicked:nil];
    }
    else {
        [self rightClicked:nil];
    }
    
}

- (IBAction)respondToSwipe:(UITapGestureRecognizer *)recognizer
{
    if ([[GameController shareManager] gameStatus]) {
        [[GameController shareManager] dropPiece];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.pieceStackView) {
        return NO;
    }
    
    return YES;
}

- (void)refreshStackView
{
    [self.pieceStackView setNeedsDisplay];
}

- (void)finishedCalibrating
{
    [self.calibratingView removeFromSuperview];
}

@end
