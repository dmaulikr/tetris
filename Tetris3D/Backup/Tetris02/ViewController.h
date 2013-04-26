//
//  ViewController.h
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class TetrisContainer;

typedef enum {
    TOUCH_GAME_SCENE,
    TOUCH_LEFT_JOYPAD,
    TOUCH_RIGHT_JOYPAD
} TOUCH_AREA;

@interface ViewController : GLKViewController {
    @public
    GLuint _program;
    
    // for gl rendering
    float mCameraYaw;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    // for touch handling
    CGSize mScreenSize;
    CGPoint mTouchDownPosition;
    CGPoint mTouchPosition;
    CGPoint mLastTouchPosition;
    CGPoint mTouchChange;
    CGPoint mTouchChangeDelta;
    
    // for game scene
    TetrisContainer *mTetrisGame;
    TOUCH_AREA mTouchArea;
    bool mIsJoypadActive;
    bool mFlaggedForUpdate;
    float mUpdateDeltaT;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end
