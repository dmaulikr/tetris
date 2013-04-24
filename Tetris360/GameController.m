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
        //game status
        self.gameStatus = GameStopped;
        self.gameLevel = 12; //the higher the level, the faster the dropping speed
        
        //initialize bitmap for current stack, number in each grid stands for different type of piece; 0 means the grid is empty
        for (int row_index = 0; row_index < kNUMBER_OF_ROW; row_index++) {
            for (int column_index = 0; column_index < kNUMBER_OF_COLUMN; column_index++) {
                pieceStack[row_index][column_index] = 0;
            }
        }
        
        [self setupCompass];
    }
    return self;
}

- (void)setupCompass
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.headingFilter = 10;
    [self.locationManager startUpdatingHeading];
}

#pragma mark - game play
- (void)startGame{
    //generate a random tetris piece

    //start the loop of game control and add piece into map when it reaches the bottom line in bitmap
    self.gameStartHeading = self.lastHeading;
}


- (void)pauseGame{
    //freeze piece and pause timer
    [self.gameTimer invalidate];
}

- (void)resumeGame{
    //freeze piece and pause timer
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.gameLevel
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];
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
    int column = potentialFrame.origin.x/kGridSize + self.offset;
    int row = potentialFrame.origin.y/kGridSize;
    
    BOOL hittingTheFloor = !(self.currentPieceView.frame.origin.y < kGridSize*(kNUMBER_OF_ROW - self.currentPieceView.frame.size.height/kGridSize));
    BOOL hittingAPiece = NO;
    
    switch (self.currentPieceView.pieceType) {
        case PieceTypeI:
            if (pieceStack[column][row] != PieceTypeNone ||
                pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column + 2][row] != PieceTypeNone ||
                pieceStack[column + 3][row] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeO:
            if (pieceStack[column][row] != PieceTypeNone ||
                pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column][row + 1] != PieceTypeNone ||
                pieceStack[column + 1][row + 1] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeJ:
            if (pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column + 1][row + 1] != PieceTypeNone ||
                pieceStack[column][row + 2] != PieceTypeNone ||
                pieceStack[column + 1][row + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeL:
            if (pieceStack[column][row] != PieceTypeNone ||
                pieceStack[column][row + 1] != PieceTypeNone ||
                pieceStack[column][row + 2] != PieceTypeNone ||
                pieceStack[column + 1][row + 2] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeS:
            if (pieceStack[column][row + 1] != PieceTypeNone ||
                pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column + 1][row + 1] != PieceTypeNone ||
                pieceStack[column + 2][row] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeT:
            if (pieceStack[column][row + 1] != PieceTypeNone ||
                pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column + 1][row + 1] != PieceTypeNone ||
                pieceStack[column + 2][row + 1] != PieceTypeNone)
            {
                hittingAPiece = YES;
            }
            break;
        case PieceTypeZ:
            if (pieceStack[column][row] != PieceTypeNone ||
                pieceStack[column + 1][row] != PieceTypeNone ||
                pieceStack[column + 1][row + 1] != PieceTypeNone ||
                pieceStack[column + 2][row + 1] != PieceTypeNone)
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
        
        //drop a new piece
        if([self.delegate respondsToSelector:@selector(dropNewPiece)])
            [self.delegate dropNewPiece];
    }
    else{
        self.currentPieceView.frame = potentialFrame;
    }
}

- (void)recordBitmapWithCurrenetPiece{
    int column = self.currentPieceView.frame.origin.x/kGridSize + self.offset;
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

- (void)movePieceLeft{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x - kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)movePieceRight{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x + kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)moveToColumn:(NSInteger)column
{
    if (column > 0 & column < kNUMBER_OF_COLUMN) {
        [self.delegate centerOnStackViewColumn:column];
        self.columnOffset = column;
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    
    if (self.gameStatus == GameRunning) {
        NSInteger relativeHeading = newHeading.magneticHeading - self.gameStartHeading;
        NSInteger column = relativeHeading / kDegreesPerColumn;
        [self moveToColumn:column];
    }
    
    self.lastHeading = newHeading.magneticHeading;
}

@end
