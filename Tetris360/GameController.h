//
//  GameController.h
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieceView.h"

typedef enum{
    GameRunning = 0,
    GamePaused = 1
}GameStatus;

@interface GameController : NSObject{
    
}

@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, assign) GameStatus gameStatus;
@property (nonatomic, retain) NSMutableArray *gridRows;
@property (nonatomic, retain) PieceView *currentPieceView;
+ (id)shareManager;
- (void)startGame;
- (void)pauseGame;
- (PieceView *)generatePiece;
- (void)movePieceLeft;
- (void)movePieceRight;
@end
