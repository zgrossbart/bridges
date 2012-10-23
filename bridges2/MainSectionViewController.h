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
 * This class handles the sections or pages in the iPhone view of the level set
 * menu.  It's used by MainPageViewController.
 */
@interface MainSectionViewController : UIViewController {
    
}

/**
 * Create a new section view 
 *  
 */
-(id)initWithNibAndMenuView:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil menu:(MainMenuViewController*)menuView index:(int)index;

/**
 * The checkmark image shows up if the player has won all of
 * the levels in the set.
 */
@property (retain, nonatomic) IBOutlet UIImageView *checkMark;

/**
 * The label with the name of the level set.
 */
@property (retain, nonatomic) IBOutlet UILabel *label;

/**
 * The play button shows the image for the level set and handles
 * the tap when the user wants to play the set.
 */
@property (retain, nonatomic) IBOutlet UIButton *playBtn;

/**
 * The player taps the button to access the levels in the level
 * set.
 */
-(IBAction)playTapped:(id)sender;

@end
