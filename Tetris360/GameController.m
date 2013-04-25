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
    self.gameLevel = 4; //the higher the level, the faster the dropping speed

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
    CGRect potentialFrame = CGRectMake(self.currentPieceView.frame.origin.x, self.currentPieceView.frame.origin.y + kGridSize, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height);
    int column = potentialFrame.origin.x/kGridSize + self.columnOffset;
    int row = potentialFrame.origin.y/kGridSize;
    
    BOOL hittingTheFloor = !(self.currentPieceView.frame.origin.y < kGridSize*(kNUMBER_OF_ROW - self.currentPieceView.frame.size.height/kGridSize));
    BOOL hittingAPiece = NO;
    
    switch (self.currentPieceView.pieceType) {
        case PieceTypeI:
            if (pieceStack[row][column] != PieceTypeNone ||
                pieceStack[row][column + 1] != PieceTypeNone ||
                pieceStack[row][column + 2] != PieceTypeNone ||
                pieceStack[row][column + 3] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeO:
            if (pieceStack[row][column] != PieceTypeNone ||
                pieceStack[row][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column] != PieceTypeNone ||
                pieceStack[row + 1][column + 1] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeJ:
            if (pieceStack[row][column] != PieceTypeNone ||
                pieceStack[row + 1][column] != PieceTypeNone ||
                pieceStack[row + 1][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeL:
            if (pieceStack[row][column + 2] != PieceTypeNone ||
                pieceStack[row+1][column] != PieceTypeNone ||
                pieceStack[row+1][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeS:
            if (pieceStack[row][column] != PieceTypeNone ||
                pieceStack[row][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 1] != PieceTypeNone ||
                pieceStack[row][column + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeT:
            if (pieceStack[row + 1][column] != PieceTypeNone ||
                pieceStack[row][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeZ:
            if (pieceStack[row][column] != PieceTypeNone ||
                pieceStack[row][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 1] != PieceTypeNone ||
                pieceStack[row + 1][column + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeNone:
            break;
    }
    
    if (hittingAPiece || hittingTheFloor) {
        //remove the subview of this piece
        if([self.delegate respondsToSelector:@selector(removeCurrentPiece)])
            [self.delegate removeCurrentPiece];

        [self recordBitmapWithCurrenetPiece];

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
        self.currentPieceView.frame = potentialFrame;
    }
}


- (void)movePieceLeft{
    //check colision
    CGRect potentialFrame = CGRectMake(self.currentPieceView.frame.origin.x, self.currentPieceView.frame.origin.y + kGridSize, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height);
    int column = potentialFrame.origin.x/kGridSize + self.columnOffset;
    int row = potentialFrame.origin.y/kGridSize;

    BOOL hittingAPiece = NO;

    switch (self.currentPieceView.pieceType) {
        case PieceTypeI:
            if (pieceStack[row][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeO:
            if (pieceStack[row][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeJ:
            if (pieceStack[row][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeL:
            if (pieceStack[row + 1][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row][(column +1)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeS:
            if (pieceStack[row + 1][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row][column%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeT:
            if (pieceStack[row + 1][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row][column%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeZ:
            if (pieceStack[row][(column + kNUMBER_OF_COLUMN -1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][column%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeNone:
            break;
    }

    if (!hittingAPiece) {
        [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x - kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
    }
}



- (void)movePieceRight{
    //check colision
    CGRect potentialFrame = CGRectMake(self.currentPieceView.frame.origin.x, self.currentPieceView.frame.origin.y + kGridSize, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height);
    int column = potentialFrame.origin.x/kGridSize + self.columnOffset;
    int row = potentialFrame.origin.y/kGridSize;

    BOOL hittingAPiece = NO;

    switch (self.currentPieceView.pieceType) {
        case PieceTypeI:
            if (pieceStack[row][(column + 4)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeO:
            if (pieceStack[row][(column + 2)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + kNUMBER_OF_COLUMN  + 2)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeJ:
            if (pieceStack[row][(column + 1)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeL:
            if (pieceStack[row][(column + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeS:
            if (pieceStack[row][(column + kNUMBER_OF_COLUMN  + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + kNUMBER_OF_COLUMN  + 2)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeT:
            if (pieceStack[row][(column + 2)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeZ:
            if (pieceStack[row][(column + 2)%kNUMBER_OF_COLUMN] != PieceTypeNone ||
                pieceStack[row + 1][(column + 3)%kNUMBER_OF_COLUMN] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeNone:
            break;
    }

    if (!hittingAPiece) {
        [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x + kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
    }

}




- (void)recordBitmapWithCurrenetPiece{
    int column = self.currentPieceView.frame.origin.x/kGridSize + self.columnOffset;
    int row = self.currentPieceView.frame.origin.y/kGridSize;

    //TODO - consider rotation and fit the piece to bitmap accordingly
    int type = self.currentPieceView.pieceType;
    switch (type) {
        case PieceTypeI:
            [self updateViewAtColumn:column andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row withType:type];
            [self updateViewAtColumn:column+2 andRow:row withType:type];
            [self updateViewAtColumn:column+3 andRow:row withType:type];
            break;
        case PieceTypeO:
            [self updateViewAtColumn:column andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row withType:type];
            [self updateViewAtColumn:column andRow:row+1 withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            break;
        case PieceTypeJ:
            [self updateViewAtColumn:column andRow:row withType:type];
            [self updateViewAtColumn:column andRow:row+1 withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            [self updateViewAtColumn:column+2 andRow:row+1 withType:type];
            break;
        case PieceTypeL:
            [self updateViewAtColumn:column+2 andRow:row withType:type];
            [self updateViewAtColumn:column andRow:row+1 withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            [self updateViewAtColumn:column+2 andRow:row+1 withType:type];
            break;
        case PieceTypeS:
            [self updateViewAtColumn:column andRow:row+1 withType:type];
            [self updateViewAtColumn:column+1 andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            [self updateViewAtColumn:column+2 andRow:row withType:type];
            break;
        case PieceTypeT:
            [self updateViewAtColumn:column andRow:row+1 withType:type];
            [self updateViewAtColumn:column+1 andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            [self updateViewAtColumn:column+2 andRow:row+1 withType:type];
            break;
        case PieceTypeZ:
            [self updateViewAtColumn:column andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row withType:type];
            [self updateViewAtColumn:column+1 andRow:row+1 withType:type];
            [self updateViewAtColumn:column+2 andRow:row+1 withType:type];
            break;
        default:
            break;
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


- (void)moveToColumn:(NSInteger)column
{
    NSLog(@"Move to column : %d", column);
    if (column == self.columnOffset) {
        return;
    }
    
    if (column == 0) {
        // Recalibrate when passing through 0
        self.gameStartHeading = self.lastHeading;
    }
    
    if (column > 0 & column < kNUMBER_OF_COLUMN) {
        self.columnOffset = column;
        [self.delegate centerOnStackViewColumn:column];
    }
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
