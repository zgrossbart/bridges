//
//  YouWonViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 9/8/12.
//
//

#import <UIKit/UIKit.h>
#import "Level.h"
#import "LevelLayer.h"

@interface YouWonViewController : UIViewController

- (IBAction)replayTapped:(id)sender;
- (IBAction)nextTapped:(id)sender;
- (IBAction)menuTapped:(id)sender;

@property (nonatomic, retain) Level *currentLevel;
@property (nonatomic, retain) LevelLayer *layer;

@end
