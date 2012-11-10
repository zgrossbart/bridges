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
#import "MainMenuViewController.h"

/**
 * This class handles the collection view we use to show the level groups in the 
 * iPad menu.
 */
@interface MainSectionCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/**
 * Create a new main section
 */
- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView;

/** 
 * Refresh the data in this view.
 */
-(void)refresh;

/**
 * The collection view contains all of the cells for this view.
 */
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 * The back button takes the user back to the main screen with
 * the play and about buttons.
 */
@property (retain, nonatomic) IBOutlet UIButton *backBtn;

/**
 * The user taps the back button takes the player back to the
 * main page.
 */
- (IBAction)backBtnTapped:(id)sender;

@end
