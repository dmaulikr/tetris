//
//  GameController.h
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "PieceView.h"

#define kNUMBER_OF_ROW 15
#define kNUMBER_OF_COLUMN 30
#define kNUMBER_OF_COLUMN_PER_SCREEN 10
#define kDegreesPerColumn 12

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
- (void)refreshStackView;
- (void)finishedCalibrating;
@end

@interface GameController : NSObject <AVAudioPlayerDelegate>{
    
}

+ (id)shareManager;
// define delegate property
@property (nonatomic, assign) id<GameControllerDelegate> delegate;

@property (nonatomic, retain) NSTimer *gameTimer;
@property (nonatomic, assign) GameStatus gameStatus;
@property (nonatomic, retain) PieceView *currentPieceView;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@property (nonatomic, assign) int gameLevel;
@property (nonatomic, assign) int pieceRotation;


//game control
- (void)startGame;
- (void)pauseGame;
- (void)resumeGame;
- (void)gameOver;

//piece control
- (PieceView *)generatePiece;
- (void)dropPiece;
- (void)movePieceLeft;
- (void)movePieceRight;
- (void)moveScreenLeft;
- (void)moveScreenRight;
- (PieceType)getTypeAtRow:(int)row andColumn:(int)column;
- (NSInteger)columnForScreenColumn:(NSInteger)column;

@end
