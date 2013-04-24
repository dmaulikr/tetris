//
//  GameController.h
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieceView.h"

#define kNUMBER_OF_ROW 15
#define kNUMBER_OF_COLUMN 60

typedef enum{
    GameStopped,
    GameRunning,
    GamePaused
} GameStatus;

@class GameController;

@protocol GameControllerDelegate <NSObject>
@required
- (void)dropNewPiece;
- (void)removeCurrentPiece;
@end

@interface GameController : NSObject{
    int pieceStack[kNUMBER_OF_ROW][kNUMBER_OF_COLUMN];
}

+ (id)shareManager;
// define delegate property
@property (nonatomic, assign) id<GameControllerDelegate> delegate;

@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, assign) GameStatus gameStatus;
@property (nonatomic, retain) PieceView *currentPieceView;

@property (nonatomic, assign) int gameLevel;
@property (nonatomic, assign) int offset; //offset from compass direction
@property (nonatomic, assign) int pieceRotation;


//game control
- (void)startGame;
- (void)pauseGame;
- (void)resumeGame;

//piece control
- (PieceView *)generatePiece;
- (void)movePieceLeft;
- (void)movePieceRight;

- (void)didChangeColumnHeading:(NSInteger)columnHeading;

@end
