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
    IBOutlet UINavigationItem *_aboutNavItem;
    IBOutlet UIBarButtonItem *_resetBtn;
    IBOutlet UIWebView *_webView;
}

@property (retain) GameSceneViewController *GameSceneViewController;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) int curIndex;

/**
 * Tapping the about button sends the user to the HTML view of the about screen loaded
 * from about.html.
 */
-(IBAction)aboutTapped:(id)sender;

/**
 * These two methods send the user back to the main view from the about and config screens.
 */
-(IBAction)backToGameTapped:(id)sender;
-(IBAction)backToMainTapped:(id)sender;

/**
 * Tapping the play button sends the user to the menu where they can choose a level to play.
 */
-(IBAction)playTapped:(id)sender;

/**
 * Send the user to the credits screen defined in credits.html.
 */
-(IBAction)creditsTapped:(id)sender;


@end
