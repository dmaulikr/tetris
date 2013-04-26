//
//  TetrisPieceFactory.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisPieceFactory.h"

#import "TetrisPlane.h"
#import "TetrisL.h"
#import "TetrisS.h"
#import "TetrisO.h"
#import "TetrisI.h"
#import "TetrisT.h"

static TetrisContainer *sGameContainer;

@implementation TetrisPieceFactory

+ (void)setGameContainer:(TetrisContainer*)game {
    sGameContainer = game;
}

+ (void)SpawnPiece {
    TetrisContainer *piece;
#if RUN_TEST
    int piece_type = PIECE_P;
#else
    int piece_type = (arc4random()%PIECE_NUM);
#endif
    switch (piece_type) {
        case PIECE_P:
            piece = [TetrisPlane new];
            break;
        case PIECE_I:
            piece = [TetrisI new];
            break;
        
        case PIECE_S:
            piece = [TetrisS new];
            break;
        
        case PIECE_O:
            piece = [TetrisO new];
            break;
            
        case PIECE_L:
            piece = [TetrisL new];
            break;
            
        case PIECE_T:
            piece = [TetrisT new];
            break;
            
        default:
            break;
    }
    
    if (sGameContainer != nil && piece != nil) {
        [piece setPosition:0 :30 :0];
        [sGameContainer add:piece];
        sCurrentTetrisPiece = piece;
    };
}

@end
