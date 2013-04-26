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

- (id)init {
    self = [super init];
    
    mXp = mYp = mZp = 0;
    mXr = mYr = mZr = 0;
    mXs = mYs = mZs = 1;
    mColor = GLKVector4Make(1, 1, 1, 1);
    mXpAdd = mYpAdd = mZpAdd = 0;
    mXrAdd = mYrAdd = mZrAdd = 0;
    
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
    // unset occupancy for current position
    Cells[mXa][mZa][mYa]->mIsOccupied = false;
    Cells[mXa][mZa][mYa]->mParent = nil;
    Cells[mXa][mZa][mYa]->mBlock = nil;
    
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
    mXn = roundf(modelViewMatrix.m30) + CONTAINER_OFFSET;
    mZn = roundf(modelViewMatrix.m32) + CONTAINER_OFFSET;
    mYn = roundf(modelViewMatrix.m31);
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    // Compute the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, mXs, mYs, mZs);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    
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
    for (int h = minIndexY; h <= maxIndexY; h++) {
        bool isFull = true;
        for (int x = 0; x <= CONTAINER_DIM; x++) {
            for (int z = 0; z <= CONTAINER_DIM; z++) {
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
            NSLog(@"plane full");
        }
    }
}

@end
