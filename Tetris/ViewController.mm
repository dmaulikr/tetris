//
//  ViewController.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "ViewController.h"
#import "BaseCube.h"
#import "TetrisWall.h"
#import "TetrisPieceFactory.h"
#import "TetrisScene.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

float EYE_HEIGHT = 15;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    mCameraYaw = 0;
    mFlaggedForUpdate = false;
    
    UILabel *label = [[UILabel alloc] initWithFrame:
                      CGRectMake(0, 0, 200, 25)];
    //label.font = [UIFont fontWithName:m_fontType size:20];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    label.text = @"test";
    label.textColor = [UIColor orangeColor];
    [view addSubview:label];
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    [BaseCube setupBaseCubeVertexBuffer:self];
    
    [self createScene];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void)createScene {
    // set camera projection matrix
    mScreenSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    float aspect = fabsf(mScreenSize.width / mScreenSize.height);
    mProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.1f, 200.0f);
    
    // create scene container
    mTetrisGame = [TetrisScene new];
    [TetrisPieceFactory setGameContainer:mTetrisGame];
    TetrisWall *floor = [[TetrisWall alloc] initWithDimension:GLKVector3Make(CONTAINER_DIM, 0.14, CONTAINER_DIM)];
    [mTetrisGame add:floor];
    
    // initial first tetris piece
    [TetrisPieceFactory SpawnPiece];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    mFlaggedForUpdate = true;
    mUpdateDeltaT = self.timeSinceLastUpdate;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // update base view matrix
    float eyeHeight = 15 + sinf(atan((EYE_HEIGHT-15)/25)*2)*40;
    float radialDist = MAX(75 - EYE_HEIGHT*1.25, 1);
    float lookAtY = 19 - EYE_HEIGHT / 3;
    mBaseViewMatrix = GLKMatrix4MakeLookAt(
        sinf(mCameraYaw)*radialDist, eyeHeight, cosf(mCameraYaw)*radialDist,   // eye position
        0, lookAtY, 0,                                                         // look at point
        0, 1, 0                                                                // look up vector
    );
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(_vertexArray);

    // Render the object again with ES2
    glUseProgram(_program);
    
    [mTetrisGame onDraw:GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f)];
    
    if (mFlaggedForUpdate) {
        [mTetrisGame onUpdate:mUpdateDeltaT];
        mFlaggedForUpdate = false;
    }
}

- (CGPoint)getTouchPoint:(NSSet *)touches {
    UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
    return [touch locationInView:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [self getTouchPoint:touches];
    mLastTouchPosition = mTouchPosition = mTouchDownPosition = point;
    mTouchChange = CGPointMake(0, 0);
    mIsJoypadActive = true;
    
    int joypadDim = mScreenSize.width * 0.25;
    mTouchArea = TOUCH_GAME_SCENE;
    if (point.y > mScreenSize.height-joypadDim) {
        if (point.x < joypadDim) {
            mTouchArea = TOUCH_LEFT_JOYPAD;
            
        } else if (point.x > mScreenSize.width-joypadDim) {
            mTouchArea = TOUCH_RIGHT_JOYPAD;
            
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //CGPoint point = [self getTouchPoint:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [self getTouchPoint:touches];
    mLastTouchPosition = mTouchPosition;
    mTouchPosition = point;
    mTouchChangeDelta = CGPointMake(mTouchPosition.x-mLastTouchPosition.x, mLastTouchPosition.y-mTouchPosition.y);
    mTouchChange.x += mTouchChangeDelta.x;
    mTouchChange.y += mTouchChangeDelta.y;
    
    if (mTouchArea == TOUCH_GAME_SCENE) {
        mCameraYaw -= mTouchChangeDelta.x / 100;
        EYE_HEIGHT += mTouchChangeDelta.y / 25;
    } else {
        if (mIsJoypadActive && sqrtf(mTouchChange.x*mTouchChange.x + mTouchChange.y*mTouchChange.y) > 50) {
            if (fabsf(mTouchChange.x) > fabsf(mTouchChange.y)) {
                if (mTouchArea == TOUCH_LEFT_JOYPAD) {
                    [sCurrentTetrisPiece addPosition:(mTouchChange.x > 1) ? 1 : -1 :0 :0];
                } else {
                    [sCurrentTetrisPiece addRotation:0 :((mTouchChange.x > 1) ? 1 : -1)*M_PI/2 :0];
                }
            } else {
                if (mTouchArea == TOUCH_LEFT_JOYPAD) {
                    [sCurrentTetrisPiece addPosition:0 :0 :(mTouchChange.y > 1) ? -1 : 1];
                } else {
                    [sCurrentTetrisPiece addRotation:((mTouchChange.x > 1) ? -1 : 1)*M_PI/2 :0 :0];
                }
            }
            mIsJoypadActive = false;
        }
    }
}



#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_COLOR_VECTOR] = glGetUniformLocation(_program, "colorVector");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
