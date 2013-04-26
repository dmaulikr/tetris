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
@property (nonatomic, retain) IBOutlet UIButton *tutorialButton;

@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;


@property IBOutlet UIView *calibratingView;
@property IBOutlet UILabel *gameStatusLabel;
@property IBOutlet UIView *tutorialView;


- (IBAction)startGameClickeed:(id)sender;
- (IBAction)leftClicked:(id)sender;
- (IBAction)rightClicked:(id)sender;
- (IBAction)stopGame:(id)sender;
- (IBAction)showTutorial:(id)sender;

@end
