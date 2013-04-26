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
                int containerHeight = CONTAINER_DIM*3 + 3;
                Cells[i][j] = (cell**)malloc(sizeof(cell*)*containerHeight);
                for (int k = 0; k < containerHeight; k++) {
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
    return ((mYa) >= 0) &&
           ((mXa) >= 0) && ((mXa) < CONTAINER_DIM) &&
           ((mZa) >= 0) && ((mZa) < CONTAINER_DIM) &&
           (!Cells[mXa][mZa][mYa]->isOccupied || Cells[mXa][mZa][mYa]->mWho == self);
}

- (bool)isFallable {
    return ((mYa-1) >= 0) &&
           (!Cells[mXa][mZa][mYa-1]->isOccupied || Cells[mXa][mZa][mYa]->mWho == self);
}

- (void)updateOccupiedPosition:(bool)flag {
    // set occupancy for current position
    Cells[mXa][mZa][mYa]->isOccupied = flag;
    Cells[mXa][mZa][mYa]->mWho = flag ? self : nil;
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    // Compute the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, mXs, mYs, mZs);
    
    // extract absolute position information
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    mXa = roundf(modelViewMatrix.m30) + CONTAINER_OFFSET;
    mZa = roundf(modelViewMatrix.m32) + CONTAINER_OFFSET;
    mYa = roundf(modelViewMatrix.m31);
    
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

@end
