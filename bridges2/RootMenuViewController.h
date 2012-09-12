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
#import "cocos2d.h"
#import "Level.h"
#import "YouWonViewController.h"
#import "LevelController.h"

@interface RootMenuViewController : UIViewController<CCDirectorDelegate,LevelController> {
    UIWindow *window_;
	UINavigationController *navController_;
    
    bool _hasInit;
    IBOutlet UIButton *_undoBtn;
    IBOutlet UILabel *_coinLabel;
    IBOutlet UIImageView *_coinImage;

}

@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain) YouWonViewController *youWonController;

-(void)showLevel:(Level*) level;

-(IBAction)goHomeTapped:(id)sender;
-(IBAction)undoTapped:(id)sender;
-(IBAction)refreshTapped:(id)sender;


@end
