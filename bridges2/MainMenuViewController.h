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
#import "GameSceneViewController.h"

/**
 * The MainMenuViewController handles most of the user interactions.  It manages
 * the menu interactions for the iPhone and the iPad, handles the main window view, 
 * and transitions to the you won page.
 *
 */
@interface MainMenuViewController : UIViewController <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    GameSceneViewController *_GameSceneViewController;

    IBOutlet UITableView *_mainTable;
    IBOutlet UINavigationItem *_navItem;
    IBOutlet UIBarButtonItem *_resetBtn;
    IBOutlet UIWebView *_webView;
    
    IBOutlet UILabel *_levelSetLabel;
    IBOutlet UIButton *_playBtn;
    IBOutlet UIButton *_aboutBtn;
    IBOutlet UIButton *_backBtn;
    IBOutlet UILabel *_xOfY;
    IBOutlet UIButton *_soundBtn;
}

/**
 * The game scene holds the playable LevelLayer which handles
 * the game.
 */
@property (retain) GameSceneViewController *GameSceneViewController;

/**
 * The collection view shows the levels in a larger image in the
 * iPad.
 */
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 * The image for the level set which lets the player know which
 * set they've selected.
 */
@property (retain, nonatomic) IBOutlet UIImageView *levelSetImage;

/**
 *  The current index of the selected level set
 */
@property (nonatomic) int curIndex;

/**
 * Tapping the about button sends the user to the HTML view of the about screen loaded
 * from about.html.
 */
-(IBAction)aboutTapped:(id)sender;

/**
 * These two methods send the user back to the main view from the about and config screens.
 */
-(IBAction)backToMainTapped:(id)sender;

-(IBAction)backToPageViewTapped:(id)sender;

/**
 * Tapping the play button sends the user to the menu where they can choose a level to play.
 */
-(IBAction)playTapped:(id)sender;

/**
 * This method is called when the user toggles the game sounds on and off.
 */
-(IBAction)toggleSoundsTapped:(id)sender;

/**
 * Show the levels in the specified set.
 */
-(void)showLevels: (int)page;

/**
 * The player can swipe to go to the back of the level set view
 */
-(IBAction)handleSwipe:(id)sender;

@end
