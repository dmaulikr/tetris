//
//  TetrisDrawable.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisDrawable.h"

GLint uniforms[NUM_UNIFORMS];
GLKMatrix4 mBaseViewMatrix;
GLKMatrix4 mProjectionMatrix;
cell ****Cells;

@implementation TetrisDrawable

@synthesize mLoose, mAlive;

- (id)init {
    self = [super init];
    
    mXp = mYp = mZp = 0;
    mXv = mYv = mZv = 0;
    mXr = mYr = mZr = 0;
    mXs = mYs = mZs = 1;
    mXpAdd = mYpAdd = mZpAdd = 0;
    mXrAdd = mYrAdd = mZrAdd = 0;
    mXa = mYa = mZa -1;
    mClearOffsetY = 0;
    
    if (Cells == nil) {
        Cells = (cell****)malloc(sizeof(cell***)*CONTAINER_DIM);
        for (int i = 0; i < CONTAINER_DIM; i++) {
            Cells[i] = (cell***)malloc(sizeof(cell**)*CONTAINER_DIM);
            for (int j = 0; j < CONTAINER_DIM; j++) {
                Cells[i][j] = (cell**)malloc(sizeof(cell*)*CONTAINER_HEIGHT);
                for (int k = 0; k < CONTAINER_HEIGHT; k++) {
                    Cells[i][j][k] = new cell();
                }
            }
        }
    }
    
    mColor = GLKVector4Make(1, 1, 1, 1);
    mAlpha = 1;
    
    mLoose = false;
    mAlive = true;
    
    return self;
}

- (void)setPosition:(float)x :(float)y :(float)z {
    mXp = x;
    mYp = y;
    mZp = z;
}

- (void)addPosition:(float)x :(float)y :(float)z {
    mXpAdd += x;
    mYpAdd += y;
    mZpAdd += z;
}

- (void)addRotation:(float)x :(float)y :(float)z {
    mXrAdd += x;
    mYrAdd += y;
    mZrAdd += z;
}

- (void)setColor:(GLKVector4)color {
    mColor = color;
}

- (void)onUpdate:(float)delaTime {
    // what the object should do on update
}

- (bool)isValidSpace {
    return ((mYn) >= 0) &&
           ((mXn) >= 0) && ((mXn) < CONTAINER_DIM) &&
           ((mZn) >= 0) && ((mZn) < CONTAINER_DIM) &&
           (!Cells[mXn][mZn][mYn]->mIsOccupied || Cells[mXn][mZn][mYn]->mParent == mParent);
}

- (void)updateOccupiedPosition {
    if (mXa > -1) {
        // unset occupancy for current position
        Cells[mXa][mZa][mYa]->mIsOccupied = false;
        Cells[mXa][mZa][mYa]->mParent = nil;
        Cells[mXa][mZa][mYa]->mBlock = nil;
    }
    
    // set occupancy for next position
    Cells[mXn][mZn][mYn]->mIsOccupied = true;
    Cells[mXn][mZn][mYn]->mParent = mParent;
    Cells[mXn][mZn][mYn]->mBlock = self;
    
    // update absolute positioning
    mXa = mXn;
    mYa = mYn;
    mZa = mZn;
}

- (void)computeAbsolutePosition:(GLKMatrix4)viewMatrix {
    // Compute the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, mXs, mYs, mZs);
    
    // extract absolute position information
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    modelViewMatrix.m31 += mClearOffsetY;
    mXn = roundf(modelViewMatrix.m30) + CONTAINER_OFFSET;
    mZn = roundf(modelViewMatrix.m32) + CONTAINER_OFFSET;
    mYn = roundf(modelViewMatrix.m31);
}

- (void)breakLoose {
    mXv = (arc4random()%600)/1000.0f - 0.3;
    mYv = (arc4random()%600)/1000.0f - 0.3;
    mZv = (arc4random()%600)/1000.0f - 0.3;
    mColor = GLKVector4Make((arc4random()%100)/100.0f,
                            (arc4random()%100)/100.0f,
                            (arc4random()%100)/100.0f, 1);
    mLoose = true;
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    if (mLoose) {
        mXp += mXv;
        mYp += mYv;
        mZp += mZv;
        mXv *= 0.95;
        mYv *= 0.95;
        mZv *= 0.95;
        mColor.a *= 0.92;
        if (mColor.a < 0.02) {
            mAlive = false;
        }
    }
    
    // Compute the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, mXs, mYs, mZs);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    modelViewMatrix.m31 += mClearOffsetY;
    
    // factor base view
    modelViewMatrix = GLKMatrix4Multiply(mBaseViewMatrix, modelViewMatrix);
    
    // calculate normal and MVP matrices
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(mProjectionMatrix, modelViewMatrix);
    
    // pass matrices to GL shaders
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform4f(uniforms[UNIFORM_COLOR_VECTOR], mColor.r, mColor.g, mColor.b, mColor.a);
    
    // draw
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (void)checkCellsForFullPlanes:(int)minIndexY :(int)maxIndexY {
    for (int h = maxIndexY; h >= minIndexY; h--) {
        bool isFull = true;
        for (int x = 0; x < CONTAINER_DIM; x++) {
            for (int z = 0; z < CONTAINER_DIM; z++) {
                if (!Cells[x][z][h]->mIsOccupied) {
                    isFull = false;
                    break;
                }
            }
            
            if (!isFull) {
                break;
            }
        }
        
        if (isFull) {
            // clear plane
            for (int x = 0; x < CONTAINER_DIM; x++) {
                for (int z = 0; z < CONTAINER_DIM; z++) {
                    [Cells[x][z][h]->mBlock breakLoose];
                    Cells[x][z][h]->mBlock = nil;
                    Cells[x][z][h]->mParent = nil;
                    Cells[x][z][h]->mIsOccupied = false;
                }
            }
            
            for (int c = h; c < CONTAINER_HEIGHT-1; c++) {
                for (int x = 0; x < CONTAINER_DIM; x++) {
                    for (int z = 0; z < CONTAINER_DIM; z++) {
                        Cells[x][z][c]->mBlock = Cells[x][z][c+1]->mBlock;
                        Cells[x][z][c]->mParent = Cells[x][z][c+1]->mParent;
                        Cells[x][z][c]->mIsOccupied = Cells[x][z][c+1]->mIsOccupied;
                        if (Cells[x][z][c]->mBlock != nil) {
                            Cells[x][z][c]->mBlock->mClearOffsetY -= 1;
                        }
                    }
                }
            }
        }
    }
}

@end
