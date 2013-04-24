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

@interface GameController () <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@property (assign) float lastHeading;
@property (assign) float gameStartHeading;
@property (assign) float columnOffset;

@end

@implementation GameController
@synthesize gameStatus = _gameStatus;
@synthesize gameTimer = _gameTimer;
@synthesize delegate = _delegate;


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
    self.gameLevel = 5; //the higher the level, the faster the dropping speed

    //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
    for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
        for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
            pieceStack[row_index][column_index] = 0;
        }
    }
    //start the loop of game control and add piece into map when it reaches the bottom line in bitmap
    self.gameStartHeading = self.lastHeading;
}


- (void)pauseGame{
    //freeze piece and pause timer
    self.gameStatus = GamePaused;
    [self.gameTimer invalidate];
}

- (void)resumeGame{
    //freeze piece and pause timer
    self.gameStatus = GameRunning;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.gameLevel
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];
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
        
        if (self.currentPieceView.frame.origin.y == 0) { //game over
            [self gameOver];
            //auto restart game for testing
//            [self startGame];
        }
        else{
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
    
    if (column > 0 & column < kNUMBER_OF_COLUMN) {
        [self.delegate centerOnStackViewColumn:column];
        self.columnOffset = column;
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (self.gameStatus == GameRunning) {
        float relativeHeading = newHeading.magneticHeading - self.gameStartHeading;
        NSInteger column = relativeHeading / kDegreesPerColumn;
        [self moveToColumn:column];
    }
    
    self.lastHeading = newHeading.magneticHeading;
}

@end
