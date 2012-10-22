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
 * The MainPageViewController handles the scroll view and the page view we use
 * to select the set of levels on iPhone.
 */
@interface MainPageViewController : UIViewController <UIScrollViewDelegate> {
    
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIPageControl *_pageControl;
}

- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView;

/**
 * The back button takes the user back to the main window
 */
@property (retain, nonatomic) IBOutlet UIButton *backBtn;

/**
 * This method is called whenever the player scrolls the page view
 */
- (IBAction)pageChanged:(id)sender;

/**
 * Take the user back to the main window
 */
- (IBAction)backToMainTapped:(id)sender;

@end
