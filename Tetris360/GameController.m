//
//  GameController.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "GameController.h"

#define kNUMBER_OF_ROW 15
#define kNUMBER_OF_COLUMN 60

@implementation GameController
@synthesize gameStatus;
@synthesize gameTimer;
@synthesize gridRows;

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
        self.gameStatus = GamePaused;
        //initialize map, number in each grid stands for different type of piece; 0 means the grid is empty
        gridRows = [[NSMutableArray alloc] initWithCapacity:kNUMBER_OF_ROW];
        for (int i = 0; i < kNUMBER_OF_ROW; i++) {
            NSMutableArray *oneColumn = [[NSMutableArray alloc] initWithCapacity:kNUMBER_OF_COLUMN];
            [gridRows insertObject:oneColumn atIndex:i];
        }
    }
    return self;
}


#pragma mark - game play
- (void)startGame{
    //initialize timer for generating pieces
    [self.gameTimer fire];
    //generate a random tetris piece
//    PieceView *onePieceView = [self generatePiece];

    //start the loop of game control and add piece into map when it reaches the bottom line
}


- (void)pauseGame{
    //freeze piece and pause timer
    [self.gameTimer invalidate];
}


#pragma mark - control of pieces

- (PieceView *)generatePiece{
    //generate a random tetris piece
    int randomNumber = rand() % 7; //7 types of pieces
    self.currentPieceView = [[PieceView alloc] initWithPieceType:randomNumber];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.6
                                     target:self
                                   selector:@selector(movePieceDown)
                                   userInfo:nil
                                    repeats:YES];
    return self.currentPieceView;
}

- (void)movePieceDown{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x, self.currentPieceView.frame.origin.y + kGridSize, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)movePieceLeft{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x - kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}

- (void)movePieceRight{
    [self.currentPieceView setFrame:CGRectMake(self.currentPieceView.frame.origin.x + kGridSize, self.currentPieceView.frame.origin.y, self.currentPieceView.frame.size.width, self.currentPieceView.frame.size.height)];
}


@end
