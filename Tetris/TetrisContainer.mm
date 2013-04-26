//
//  TetrisDrawableContainer.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisContainer.h"
#import "TetrisPieceFactory.h"

TetrisContainer *sCurrentTetrisPiece;

@implementation TetrisContainer

- (id)init {
    self = [super init];
    
    mContainer = [[NSMutableArray alloc] init];
    mTimeSinceLastMove = 0;
    
    return self;
}

- (void)onUpdate:(float)delaTime {
    if (self == sCurrentTetrisPiece) {
        mTimeSinceLastMove += delaTime;
        if (mTimeSinceLastMove > FALL_RATE) {
            mTimeSinceLastMove = 0;
            mYpAdd -= 1;
        }
    }
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    bool isFalling = (self == sCurrentTetrisPiece);
    
    // update offsets
    mXp += mXpAdd;
    mZp += mZpAdd;
    mXr += mXrAdd;
    mYr += mYrAdd;
    mZr += mZrAdd;
    
    // perform model view transformation
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, mXs, mYs, mZs);
    modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelViewMatrix);
    
    bool isValid = true;
    if (isFalling) {
        for (TetrisDrawable *drawableObject in mContainer) {
            [drawableObject computeAbsolutePosition:modelViewMatrix];
            isValid = isValid && [drawableObject isValidSpace];
        }
        
        // check motion translation and rotation into new space
        if (!isValid) {
            // undo moves
            mXp -= mXpAdd;
            mZp -= mZpAdd;
            mXr -= mXrAdd;
            mYr -= mYrAdd;
            mZr -= mZrAdd;
        } else {
            for (TetrisDrawable *block in mContainer) {
                if (block.mLoose) {
                    continue;
                }
                [block updateOccupiedPosition];
            }
        }
        
        if (mYpAdd < 0) {
            mYp += mYpAdd;
            
            // check falling into new space
            GLKMatrix4 rotateScale = GLKMatrix4MakeRotation(mXr, 1.0f, 0.0f, 0.0f);
            rotateScale = GLKMatrix4Rotate(rotateScale, mYr, 0.0f, 1.0f, 0.0f);
            rotateScale = GLKMatrix4Rotate(rotateScale, mZr, 0.0f, 0.0f, 1.0f);
            rotateScale = GLKMatrix4Scale(rotateScale, mXs, mYs, mZs);
            modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(mXp, mYp, mZp), rotateScale);
            modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelViewMatrix);
            
            for (TetrisDrawable *block in mContainer) {
                if (block.mLoose) {
                    continue;
                }
                [block computeAbsolutePosition:modelViewMatrix];
                isFalling = isFalling && [block isValidSpace];
            }
            
            if (!isFalling) {
                mYp -= mYpAdd;
                modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(mXp, mYp, mZp), rotateScale);
                modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelViewMatrix);
                
                // reached bottom...
                // inspect whether any planes require clearing
                int minIndexY = CONTAINER_HEIGHT, maxIndexY = 0;
                for (TetrisDrawable *block in mContainer) {
                    if (block.mLoose) {
                        continue;
                    }
                    minIndexY = MIN(minIndexY, block->mYa);
                    maxIndexY = MAX(maxIndexY, block->mYa);
                }
                [self checkCellsForFullPlanes:minIndexY :maxIndexY];
                
                // spawn new piece
                [TetrisPieceFactory SpawnPiece];
            } else {
                for (TetrisDrawable *block in mContainer) {
                    if (block.mLoose) {
                        continue;
                    }
                    [block updateOccupiedPosition];
                }
            }
        }
    }
    
    // draw
    for (TetrisDrawable *block in mContainer) {
        if (block.mAlive) {
            [block onDraw:modelViewMatrix];
        }
    }

    mXpAdd = mYpAdd = mZpAdd = 0;
    mXrAdd = mYrAdd = mZrAdd = 0;
}

- (void)add:(TetrisDrawable *)drawableObject {
    [mContainer addObject:drawableObject];
    drawableObject->mParent = self;
}

@end
