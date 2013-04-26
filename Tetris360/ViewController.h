//
//  ViewController.h
//  Tetris360
//
//  Created by Liang Shi on 2013-04-21.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieceView.h"
#import "GameController.h"


@interface ViewController : UIViewController <GameControllerDelegate>


@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *leftButton;
@property (nonatomic, retain) IBOutlet UIButton *rightButton;
@property IBOutlet UIView *calibratingView;

- (IBAction)startGameClickeed:(id)sender;
- (IBAction)leftClicked:(id)sender;
- (IBAction)rightClicked:(id)sender;
- (IBAction)stopGame:(id)sender;

@end
