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

static PieceType pieceStack[kNUMBER_OF_ROW][kNUMBER_OF_COLUMN];

@interface GameController ()

@property (assign) NSInteger newPieceHeading;
@property (assign) NSInteger previousHeading;

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
    }
    return self;
}


#pragma mark - game play
- (void)startGame{
    //generate a random tetris piece

    //start the loop of game control and add piece into map when it reaches the bottom line in bitmap
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
    
    self.newPieceHeading = self.previousHeading;
    
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
            [self updateViewAtx:column andY:row withType:type];
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column+2 andY:row withType:type];
            [self updateViewAtx:column+3 andY:row withType:type];            
            break;
        case PieceTypeO:
            [self updateViewAtx:column andY:row withType:type];
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column andY:row+1 withType:type];
            [self updateViewAtx:column+1 andY:row+1 withType:type];
            break;
        case PieceTypeJ:
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column+1 andY:row+1 withType:type];
            [self updateViewAtx:column andY:row+2 withType:type];
            [self updateViewAtx:column+1 andY:row+2 withType:type];
            break;
        case PieceTypeL:
            [self updateViewAtx:column andY:row withType:type];
            [self updateViewAtx:column andY:row+1 withType:type];
            [self updateViewAtx:column andY:row+2 withType:type];
            [self updateViewAtx:column+1 andY:row+2 withType:type];
            break;
        case PieceTypeS:
            [self updateViewAtx:column andY:row+1 withType:type];
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column+1 andY:row+1 withType:type];
            [self updateViewAtx:column+2 andY:row withType:type];
            break;
        case PieceTypeT:
            [self updateViewAtx:column andY:row+1 withType:type];
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column+1 andY:row+1 withType:type];
            [self updateViewAtx:column+2 andY:row+1 withType:type];
            break;
        case PieceTypeZ:
            [self updateViewAtx:column andY:row withType:type];
            [self updateViewAtx:column+1 andY:row withType:type];
            [self updateViewAtx:column+1 andY:row+1 withType:type];
            [self updateViewAtx:column+2 andY:row+1 withType:type];
            break;
        default:
            break;
    }
    [self.delegate updateStackView];
}

- (PieceType)getTypeAtRow:(int)row andColumn:(int)column{
    return pieceStack[row][column];
}

- (void)updateViewAtx:(int)column andY: (int)row withType:(PieceType)type{
    pieceStack[row][column] = type;
    //update pieceStackView
//    [self.delegate recordRectAtx:column andY:row withType:type];
}

- (void)movePieceLeft{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x - kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)movePieceRight{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x + kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)didChangeHeading:(NSInteger)heading
{
    if (self.gameStatus == GameRunning) {
        NSLog(@"heading: %d", heading);
        NSInteger newColumnHeading = ((heading - self.newPieceHeading) / kDegreesPerColumn) % kNUMBER_OF_COLUMN;
        NSLog(@"column heading: %d", heading);
        // TODO: move view to new column
    }
    
    self.previousHeading = heading;
}

@end
