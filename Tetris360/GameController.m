//
//  GameController.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "GameController.h"
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import <CoreLocation/CoreLocation.h>

static PieceType pieceStack[kNUMBER_OF_ROW][kNUMBER_OF_COLUMN];

float nfmod(float a,float b)
{
    return a - b * floor(a / b);
}

@interface GameController () <CLLocationManagerDelegate, AVAudioPlayerDelegate>

@property CLLocationManager *locationManager;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *gameTimer;

@property (assign) float lastHeading;
@property (assign) float zeroColumnHeading;
@property (assign) int columnOffset;
@property (assign) BOOL isMovingScreen;
@property (assign) int puzzle;
@property (assign) BOOL canMove;

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
        
        self.puzzle = 1;
    }
    return self;
}

- (void)setupCompass
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.headingFilter = 1;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

#pragma mark - game play
- (void)startGame{
    
    // Read puzzle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%d", self.puzzle]
                                                         ofType:@"txt"];
    NSString *fileString = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
    
    //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        NSString *row = [lines objectAtIndex:row_index];
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            NSString *typeString = [row substringWithRange:NSMakeRange(column_index, 1)];
            int type = [typeString intValue];
            pieceStack[row_index][column_index] = type;
        }
    }
    
    //init game status
    self.gameStatus = GameRunning;
    self.gameLevel = 1; //the higher the level, the faster the dropping speed
    self.gameScore = 0;

    //start the loop of game control and add piece into map when it reaches the bottom line in bitmap
    self.zeroColumnHeading = self.lastHeading;

    //start background music
    [self.audioPlayer play];

    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [self.delegate refreshStackView];
}


- (void)pauseGame{
    //freeze piece and pause timer
    self.gameStatus = GamePaused;
    //once invalidated, the timer can't bereused
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    [self.audioPlayer pause];
}


- (void)resumeGame{
    //freeze piece and pause timer
    self.gameStatus = GameRunning;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];

    [self.audioPlayer play];
}


- (BOOL)checkClearLine{

    int numberOfClearLine = 0;
    //check from top to bottom
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        //check for one line
        BOOL thislineClear = YES;
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            if (pieceStack[row_index][column_index] == PieceTypeNone) {
                thislineClear = NO;
                break;
            }
        }
        if (thislineClear) {
            numberOfClearLine++;
            NSLog(@"One line %d is clear!!!!!", row_index);

            //move all the pieces above down one row
            for (int i = row_index; i > 0; i--) {
                for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
                    pieceStack[i][column_index] = pieceStack[i - 1][column_index];
                }
            }
        }
    }

    if (numberOfClearLine > 0) {
        //add score
        self.gameScore += 5 * numberOfClearLine;
        [self.delegate updateScore:self.gameScore];
        
    }
    
    //TODO - level up
    if (self.gameScore >= self.gameLevel * 10) {
        NSLog(@"Level up!!!!");
        self.gameLevel++;
        [self.delegate updateLevel:self.gameLevel];
    }

    return numberOfClearLine > 0;
}


- (void)gameOver{
    self.gameStatus = GameStopped;
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    self.gameScore = 0;
    self.gameLevel = 1;
    [self.delegate updateLevel:self.gameLevel];
    [self.delegate updateScore:self.gameScore];
    if([self.delegate respondsToSelector:@selector(removeCurrentPiece)])
        [self.delegate removeCurrentPiece];
    
    [self.delegate gameOver];

    //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            pieceStack[row_index][column_index] = 0;
        }
    }

    [self.audioPlayer stop];
    [self.audioPlayer setCurrentTime:0];
    [self.delegate updateStackView];
}

#pragma mark - control of pieces

- (PieceView *)generatePiece{
    self.canMove = YES;
    //generate a random tetris piece
    int randomNumber = arc4random() % 7 +1; //7 types of pieces
    self.currentPieceView = [[PieceView alloc] initWithPieceType:randomNumber pieceCenter:CGPointMake((self.columnOffset + 4)%kNUMBER_OF_COLUMN, 0)];
    
    return self.currentPieceView;
}

- (BOOL)movePieceDown {
    
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x, self.currentPieceView.center.y + kGridSize);
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x, self.currentPieceView.pieceCenter.y + 1);
    
    NSLog(@"%@", NSStringFromCGPoint(newLogicalCenter));

    NSArray *blocks = [self.currentPieceView blocksCenter];
    BOOL hittingAPiece = NO;
    BOOL hittingTheFloor = NO;
    for (NSValue *block in blocks) {
        CGPoint blockPoint = [block CGPointValue];
        if (pieceStack[(int)(newLogicalCenter.y+blockPoint.y)][(int)(newLogicalCenter.x+blockPoint.x)%kNUMBER_OF_COLUMN] != PieceTypeNone) {
            hittingAPiece = YES;
        }
        if ((newLogicalCenter.y + blockPoint.y) > kNUMBER_OF_ROW - 1) {
            hittingTheFloor = YES;
        }
    }

    if (self.canMove) {
        if (hittingAPiece || hittingTheFloor) {
            //stop moving pieces
            self.canMove = NO;

            //record this piece to bitmap and remove the subview of this piece
            [self recordBitmapWithCurrentPiece];
            if([self.delegate respondsToSelector:@selector(removeCurrentPiece)])
                [self.delegate removeCurrentPiece];

            //check whether we can clear a line
            [self checkClearLine];
            
            //check whether it's game over
            if (self.currentPieceView.frame.origin.y == 0) {
                [self gameOver];
            }
            else{
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
    
    [self.delegate updateStackView];
    
    return hittingAPiece || hittingTheFloor;
}

- (void)dropPiece
{
    while (![self movePieceDown] && self.canMove) {
        continue;
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
        if (
            (location.x + blockPoint.x*kGridSize) <= (kGridSize/2) ||
            (location.x + blockPoint.x*kGridSize) > ((kNUMBER_OF_COLUMN_PER_SCREEN+0.5) * kGridSize)) {
            hittingEdgeOfScreen = YES;
        }
    }
    return hittingEdgeOfScreen;
}

- (void)movePieceLeft{
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x - kGridSize, self.currentPieceView.center.y);
    CGPoint newLogicalCenter = CGPointMake(nfmod(self.currentPieceView.pieceCenter.x-1, kNUMBER_OF_COLUMN), self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newViewCenter] && ![self lateralCollisionForLocation:newLogicalCenter] && self.canMove) {
        self.currentPieceView.center = newViewCenter;
        self.currentPieceView.pieceCenter = newLogicalCenter;
//        NSLog(@"Current piece column  : %f", self.currentPieceView.pieceCenter.x);
    }
}

- (void)movePieceRight{
    CGPoint newViewCenter = CGPointMake(self.currentPieceView.center.x + kGridSize, self.currentPieceView.center.y);
    CGPoint newLogicalCenter = CGPointMake(self.currentPieceView.pieceCenter.x + 1, self.currentPieceView.pieceCenter.y);
    
    if (![self screenBorderCollisionForLocation:newViewCenter] && ![self lateralCollisionForLocation:newLogicalCenter] && self.canMove) {
        self.currentPieceView.center = newViewCenter;
        self.currentPieceView.pieceCenter = newLogicalCenter;
//        NSLog(@"Current piece column : %f", self.currentPieceView.pieceCenter.x);
    }
}


- (void)moveScreenLeft{
    CGPoint newLogicalCenter = CGPointMake(nfmod(self.currentPieceView.pieceCenter.x-1, kNUMBER_OF_COLUMN), self.currentPieceView.pieceCenter.y);
    
    NSLog(@"Move left %@", NSStringFromCGPoint(newLogicalCenter));

    if (![self lateralCollisionForLocation:newLogicalCenter] && self.canMove) {
        self.currentPieceView.pieceCenter = newLogicalCenter;
        self.columnOffset = nfmod((self.columnOffset+ kNUMBER_OF_COLUMN-1)%kNUMBER_OF_COLUMN, kNUMBER_OF_COLUMN);
//        NSLog(@"Current screen column : %d", self.columnOffset);
//        NSLog(@"Current piece column : %f", self.currentPieceView.pieceCenter.x);
    }
    
    [self.delegate refreshStackView];
}


- (void)moveScreenRight{
    CGPoint newLogicalCenter = CGPointMake(nfmod(self.currentPieceView.pieceCenter.x+1, kNUMBER_OF_COLUMN), self.currentPieceView.pieceCenter.y);
    
    NSLog(@"Move right %@", NSStringFromCGPoint(newLogicalCenter));
    
    if (![self lateralCollisionForLocation:newLogicalCenter] && self.canMove) {
        self.currentPieceView.pieceCenter = newLogicalCenter;
        self.columnOffset = nfmod((self.columnOffset+1)%kNUMBER_OF_COLUMN, kNUMBER_OF_COLUMN);
//        NSLog(@"Current screen column : %d", self.columnOffset);
//        NSLog(@"Current piece column : %f", self.currentPieceView.pieceCenter.x);
    }
    
    [self.delegate refreshStackView];
}

- (void)moveToColumn:(NSInteger)column
{
    if (column == self.columnOffset) {
        return;
    }
    
    self.isMovingScreen = YES;
    
    NSLog(@"Move to column: %d", column);
    
    if (column == 0) {
        // Recalibrate when passing through 0
        NSLog(@"Recalibrating");
        self.zeroColumnHeading = self.lastHeading;
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
                [self moveScreenLeft];
            }
        }
        else if (columnsToMove == columnsToMoveRight) {
            for (int i = abs(columnsToMove); i > 0; i--) {
                [self moveScreenRight];
            }
        }
    }
    
    self.isMovingScreen = NO;
}


- (void)recordBitmapWithCurrentPiece{
    NSLog(@"Recording: %@", NSStringFromCGPoint(self.currentPieceView.pieceCenter));
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
        float relativeHeading = newHeading.trueHeading - self.zeroColumnHeading;
        NSInteger column = nfmod((int)(relativeHeading / kDegreesPerColumn), kNUMBER_OF_COLUMN);
        [self moveToColumn:column];
    }
    
    self.lastHeading = newHeading.trueHeading;
    NSLog(@"heading %f", self.lastHeading);
}

@end
