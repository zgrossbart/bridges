/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "Level.h"
#import "LevelLayer.h"

/**
 * The You Won screen shots up when you beat a level.  It gives you the chance to replay,
 * move to the next level, or jump back to the menu.
 */
@interface YouWonViewController : UIViewController {
    @private
    IBOutlet UIButton *_menuButton;
    IBOutlet UIButton *_replayButton;
    IBOutlet UIButton *_nextButton;
}

/**
 * Replay the current level
 */
-(IBAction)replayTapped:(id)sender;

/**
 * Jump to the next level
 */
-(IBAction)nextTapped:(id)sender;

/**
 * Go back to the menu to choose a different level
 */
-(IBAction)menuTapped:(id)sender;

/**
 * The current level the user just won.
 */
@property (nonatomic, retain) Level *currentLevel;

/**
 * The level layer gets messages to restart the level.
 */
@property (nonatomic, retain) LevelLayer *layer;

@end
