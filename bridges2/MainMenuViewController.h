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

@interface MainMenuViewController : UIViewController <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    GameSceneViewController *_GameSceneViewController;
    
//    IBOutlet UITableView *_view;
    CGFloat  mFontSize;
    NSArray* mFontNames;
    IBOutlet UITableView *_mainTable;
    IBOutlet UINavigationItem *_navItem;
    IBOutlet UINavigationItem *_aboutNavItem;
    IBOutlet UIBarButtonItem *_resetBtn;
    IBOutlet UIWebView *_webView;
}

@property (retain) GameSceneViewController *GameSceneViewController;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) int curIndex;

-(IBAction)aboutTapped:(id)sender;

-(IBAction)backToGameTapped:(id)sender;

-(IBAction)backToMainTapped:(id)sender;

-(IBAction)playTapped:(id)sender;
-(IBAction)creditsTapped:(id)sender;


@end
