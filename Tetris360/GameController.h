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
#define kDegreesPerColumn 36

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
- (void)updateStackView;
- (void)centerOnStackViewColumn:(NSInteger)column;
@end

@interface GameController : NSObject{
    
}

+ (id)shareManager;
// define delegate property
@property (nonatomic, assign) id<GameControllerDelegate> delegate;

@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, assign) GameStatus gameStatus;
@property (nonatomic, retain) PieceView *currentPieceView;

@property (nonatomic, assign) int gameLevel;
@property (nonatomic, assign) int pieceRotation;

@property NSInteger currentColumn;


//game control
- (void)startGame;
- (void)pauseGame;
- (void)resumeGame;

//piece control
- (PieceView *)generatePiece;
- (void)movePieceLeft;
- (void)movePieceRight;
- (PieceType)getTypeAtRow:(int)row andColumn:(int)column;

@end
