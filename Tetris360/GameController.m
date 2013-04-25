//
//  GameController.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "GameController.h"
#import "ViewController.h"
#import "PieceView.h"
#import <CoreLocation/CoreLocation.h>

static PieceType pieceStack[kNUMBER_OF_ROW][kNUMBER_OF_COLUMN];

float nfmod(float a,float b)
{
    return a - b * floor(a / b);
}

@interface GameController () <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@property (assign) float lastHeading;
@property (assign) float gameStartHeading;
@property (assign) int columnOffset;

@end

@implementation GameController
@synthesize gameStatus = _gameStatus;
@synthesize gameTimer = _gameTimer;
@synthesize delegate = _delegate;
@synthesize audioPlayer = _audioPlayer;

//game manager singleton
+ (id)shareManager{
    static GameController *sharedGameManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameManager = [[self alloc] init];
    });
    return sharedGameManager;
}

- (id)init {
    if (self = [super init]) { 
        [self setupCompass];
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"TetrisTheme" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        self.audioPlayer.delegate = self;
        self.audioPlayer.numberOfLoops = -1; //infinite
    }
    return self;
}

- (void)setupCompass
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.headingFilter = 5;
    [self.locationManager startUpdatingHeading];
}

#pragma mark - game play
- (void)startGame{
    //init game status
    self.gameStatus = GameRunning;
    self.gameLevel = 1; //the higher the level, the faster the dropping speed

    //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            pieceStack[row_index][column_index] = 0;
        }
    }
    //start the loop of game control and add piece into map when it reaches the bottom line in bitmap
    self.gameStartHeading = self.lastHeading;

    //start background music
    [self.audioPlayer play];
}


- (void)pauseGame{
    //freeze piece and pause timer
    self.gameStatus = GamePaused;
    [self.gameTimer invalidate];
    [self.audioPlayer pause];
}

- (void)resumeGame{
    //freeze piece and pause timer
    self.gameStatus = GameRunning;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.gameLevel
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];

    [self.audioPlayer play];
}


- (BOOL)checkClearLine{
    for (int row_index = kNUMBER_OF_ROW; row_index >= 0; row_index--) {
        //check for one line
        BOOL isLineClear = YES;
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            if (pieceStack[row_index][column_index] == PieceTypeNone) {
                isLineClear = NO;
                break;
            }
        }
        if (isLineClear) {
            [self pauseGame];
            NSLog(@"One line %d is clear!!!!!", row_index);
            [self clearALine:row_index];
        }
    }

    return NO;
}

//remove the line after
- (void)clearALine: (int)row{
    for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
        pieceStack[row][column_index] = PieceTypeNone;
    }

    //move all the pieces above down one row
    for (int row_index = row; row_index > 0; row_index--) {
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            pieceStack[row_index][column_index] = pieceStack[row_index - 1][column_index];
        }
    }
    [self resumeGame];
}


- (void)gameOver{
    self.gameStatus = GameStopped;
    [self.gameTimer invalidate];
    self.gameTimer = nil;

    //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            pieceStack[row_index][column_index] = 0;
        }
    }

    [self.audioPlayer stop];
    [self.delegate updateStackView];
}

#pragma mark - control of pieces

- (PieceView *)generatePiece{
    [self.gameTimer invalidate];
    //generate a random tetris piece
    int randomNumber = rand() % 7 +1; //7 types of pieces
    self.currentPieceView = [[PieceView alloc] initWithPieceType:randomNumber];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.gameLevel
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];
    
    return self.currentPieceView;
}

- (void)movePieceDown {
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x, self.currentPieceView.center.y + kGridSize);
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x, self.currentPieceView.pieceCenter.y + 1);
    
    NSArray *blocks = [self.currentPieceView blocksCenter];
    BOOL hittingAPiece = NO;
    BOOL hittingTheFloor = NO;
    for (NSValue *block in blocks) {
        CGPoint blockPoint = [block CGPointValue];
        if (pieceStack[(int)(newLogicalCenter.y+blockPoint.y)][(int)(newLogicalCenter.x+blockPoint.x)] != PieceTypeNone) {
            hittingAPiece = YES;
        }
        if (blockPoint.y == kNUMBER_OF_ROW - 1) {
            hittingTheFloor = YES;
        }
    }
    
    if (hittingAPiece || hittingTheFloor) {
        //remove the subview of this piece
        if([self.delegate respondsToSelector:@selector(removeCurrentPiece)])
            [self.delegate removeCurrentPiece];

        [self recordBitmapWithCurrentPiece];

        //check whether we can clear a line
        BOOL hasLineClear = [self checkClearLine];

        if (self.currentPieceView.frame.origin.y == 0) { //game over
            [self gameOver];
            //auto restart game for testing
//            [self startGame];
        }
        else if(!hasLineClear){
            //drop a new piece
            if([self.delegate respondsToSelector:@selector(dropNewPiece)])
                [self.delegate dropNewPiece];
        }
    }
    else{
        self.currentPieceView.center = newViewCenter;
        self.currentPieceView.pieceCenter = newLogicalCenter;
    }
}

- (BOOL)lateralCollisionForLocation:(CGPoint)location
{
    NSArray *blocks = [self.currentPieceView blocksCenter];
    BOOL hittingAPiece = NO;
    for (NSValue *block in blocks) {
        CGPoint blockPoint = [block CGPointValue];
        if (pieceStack[(int)(location.y+blockPoint.y)][(int)(location.x+blockPoint.x)] != PieceTypeNone) {
            hittingAPiece = YES;
        }
    }
    return hittingAPiece;
}

- (BOOL)screenBorderCollisionForLocation:(CGPoint)location
{
    NSArray *blocks = [self.currentPieceView blocksCenter];
    BOOL hittingEdgeOfScreen = NO;
    for (NSValue *block in blocks) {
        CGPoint blockPoint = [block CGPointValue];
        if (blockPoint.x < 0 || blockPoint.x > (kNUMBER_OF_COLUMN_PER_SCREEN - 1)) {
            hittingEdgeOfScreen = YES;
        }
    }
    return hittingEdgeOfScreen;
}

- (void)movePieceLeft{
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x - kGridSize, self.currentPieceView.center.y);
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x - 1, self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newLogicalCenter] && ![self lateralCollisionForLocation:newLogicalCenter]) {
        self.currentPieceView.center = newViewCenter;
        self.currentPieceView.pieceCenter = newLogicalCenter;
        NSLog(@"Move piece left to column : %f", self.currentPieceView.pieceCenter.x);
    }
}

- (void)movePieceRight{
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x + kGridSize, self.currentPieceView.center.y);
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x + 1, self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newLogicalCenter] && ![self lateralCollisionForLocation:newLogicalCenter]) {
        self.currentPieceView.center = newViewCenter;
        self.currentPieceView.pieceCenter = newLogicalCenter;
        NSLog(@"Move piece left to column : %f", self.currentPieceView.pieceCenter.x);
    }
}


- (void)moveScreenLeft{
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x - 1, self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newLogicalCenter]) {
        self.currentPieceView.pieceCenter = newLogicalCenter;
        self.columnOffset = self.currentPieceView.pieceCenter.x;
        NSLog(@"Move left to column : %f", self.currentPieceView.pieceCenter.x);
    }
    
    [self.delegate refreshStackView];
}


- (void)moveScreenRight{
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x + 1, self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newLogicalCenter]) {
        self.currentPieceView.pieceCenter = newLogicalCenter;
        self.columnOffset = self.currentPieceView.pieceCenter.x;
        NSLog(@"Move left to column : %f", self.currentPieceView.pieceCenter.x);
    }
    
    [self.delegate refreshStackView];
}

- (void)moveToColumn:(NSInteger)column
{
    if (column == self.columnOffset) {
        return;
    }
    
    if (column == 0) {
        // Recalibrate when passing through 0
        self.gameStartHeading = self.lastHeading;
    }
    
    if (column >= 0 & column < kNUMBER_OF_COLUMN) {
        
        NSInteger columnsToMoveLeft;
        NSInteger columnsToMoveRight;
        
        if (column < self.columnOffset) {
            columnsToMoveLeft = abs(self.columnOffset - column);
            columnsToMoveRight = kNUMBER_OF_COLUMN - columnsToMoveLeft;
        }
        else {
            columnsToMoveRight = abs(self.columnOffset - column);
            columnsToMoveLeft = kNUMBER_OF_COLUMN - columnsToMoveRight;
        }
        
        NSInteger columnsToMove = MIN(columnsToMoveLeft, columnsToMoveRight);
        
        if (columnsToMove == columnsToMoveLeft) {
            for (int i = columnsToMove; i > 0; i--) {
                NSLog(@"%d", i);
                [self moveScreenLeft];
            }
        }
        else if (columnsToMove == columnsToMoveRight) {
            for (int i = abs(columnsToMove); i > 0; i--) {
                NSLog(@"%d", i);
                [self moveScreenRight];
            }
        }
    }
}


- (void)recordBitmapWithCurrentPiece{
    NSArray *blocks = [self.currentPieceView blocksCenter];
    for (NSValue *block in blocks) {
        CGPoint blockPoint = [block CGPointValue];
        NSInteger column = (int)(self.currentPieceView.pieceCenter.x + blockPoint.x) % kNUMBER_OF_COLUMN;
        NSInteger row = (int)(self.currentPieceView.pieceCenter.y + blockPoint.y);
        [self updateViewAtColumn:column andRow:row withType:self.currentPieceView.pieceType];
    }

    [self.delegate updateStackView];
}

- (PieceType)getTypeAtRow:(int)row andColumn:(int)column{
    return pieceStack[row][column];
}

- (NSInteger)columnForScreenColumn:(NSInteger)column
{
    int realColumn = (self.columnOffset + column) % kNUMBER_OF_COLUMN;
    return realColumn;
}

- (void)updateViewAtColumn:(int)column andRow: (int)row withType:(PieceType)type{
    pieceStack[row][column] = type;
    //update pieceStackView
    //    [self.delegate recordRectAtx:column andRow:row withType:type];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (self.gameStatus == GameRunning) {
        float relativeHeading = newHeading.magneticHeading - self.gameStartHeading;
        NSInteger column = nfmod((int)(relativeHeading / kDegreesPerColumn), kNUMBER_OF_COLUMN);
        [self moveToColumn:column];
    }
    
    self.lastHeading = newHeading.magneticHeading;
}

@end
