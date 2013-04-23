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


@interface ViewController : UIViewController


@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) PieceView *movingPieceView;

- (IBAction)startGameClickeed:(id)sender;
- (IBAction)leftClicked:(id)sender;
- (IBAction)rightClicked:(id)sender;

@end
