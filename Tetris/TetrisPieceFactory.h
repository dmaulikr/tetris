//
//  TetrisPieceFactory.h
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisContainer.h"

typedef enum {
    PIECE_L,
    PIECE_S,
    PIECE_O,
    PIECE_I,
    PIECE_T,
    PIECE_NUM,
    PIECE_P
} TETRIS_PIECE;

@interface TetrisPieceFactory : TetrisContainer

+ (void)setGameContainer:(TetrisContainer*)game;
+ (void)SpawnPiece;

@end
