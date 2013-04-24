//
//  GameController.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "GameController.h"
#import "ViewController.h"

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
        for (int i = 0; i < kNUMBER_OF_ROW; i++) {
            for (int j = 0; j < kNUMBER_OF_COLUMN; j++) {
                pieceStack[i][j] = 0;
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
    int randomNumber = rand() % 7; //7 types of pieces
    self.currentPieceView = [[PieceView alloc] initWithPieceType:randomNumber];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.gameLevel
                                                      target:self
                                                    selector:@selector(movePieceDown)
                                                    userInfo:nil
                                                     repeats:YES];
    return self.currentPieceView;
}

- (void)movePieceDown{

    //TODO - add checking bottom line from the pieceStack to stop dropping
    if (self.currentPieceView.frame.origin.y < kGridSize*(kNUMBER_OF_ROW - self.currentPieceView.frame.size.height/kGridSize)) {
        [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x, self.currentPieceView.frame.origin.y + kGridSize, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
    }
    else{
        //record the piece to bitmap with the piece position on screen + offset
        int xLocation = self.currentPieceView.frame.origin.x/kGridSize + self.offset;
        int yLocation = self.currentPieceView.frame.origin.y/kGridSize;
        
        //TODO - consider rotation and fit the piece to bitmap accordingly
        int colorCode = self.currentPieceView.pieceType;
        switch (colorCode) {
            case PieceTypeI:
                pieceStack[xLocation][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation+2][yLocation] = colorCode;
                pieceStack[xLocation+3][yLocation] = colorCode;
                break;
            case PieceTypeO:
                pieceStack[xLocation][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation][yLocation+1] = colorCode;
                pieceStack[xLocation+1][yLocation+1] = colorCode;
                break;
            case PieceTypeJ:
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation+1] = colorCode;
                pieceStack[xLocation][yLocation+2] = colorCode;
                pieceStack[xLocation+1][yLocation+2] = colorCode;
                break;
            case PieceTypeL:
                pieceStack[xLocation][yLocation] = colorCode;
                pieceStack[xLocation][yLocation+1] = colorCode;
                pieceStack[xLocation][yLocation+2] = colorCode;
                pieceStack[xLocation+1][yLocation+2] = colorCode;
                break;
            case PieceTypeS:
                pieceStack[xLocation][yLocation+1] = colorCode;
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation+1] = colorCode;
                pieceStack[xLocation+2][yLocation] = colorCode;
                break;
            case PieceTypeT:
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation][yLocation+1] = colorCode;
                pieceStack[xLocation+1][yLocation+1] = colorCode;
                pieceStack[xLocation+2][yLocation+1] = colorCode;
                break;
            case PieceTypeZ:
                pieceStack[xLocation][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation] = colorCode;
                pieceStack[xLocation+1][yLocation+1] = colorCode;
                pieceStack[xLocation+2][yLocation+1] = colorCode;
                break;
            default:
                break;
        }
        
        //update pieceStackView
        

        //remove the subview of this piece
        if([self.delegate respondsToSelector:@selector(removeCurrentPiece)])
            [self.delegate removeCurrentPiece];

        //drop a new piece
        if([self.delegate respondsToSelector:@selector(dropNewPiece)])
            [self.delegate dropNewPiece];
    }
}

- (void)movePieceLeft{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x - kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)movePieceRight{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x + kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}


@end
