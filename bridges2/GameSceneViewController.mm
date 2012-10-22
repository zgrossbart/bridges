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

#import "GameSceneViewController.h"
#import "LevelLayer.h"
#import "BridgeColors.h"
#import "LevelMgr.h"
#import "StyleUtil.h"

@interface GameSceneViewController ()

@end

@implementation GameSceneViewController {
    LevelLayer *_layer;
}

@synthesize youWonController = _youWonController;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"GameSceneViewiPad" bundle:nibBundleOrNil];
    } else {
        self = [super initWithNibName:@"GameSceneView" bundle:nibBundleOrNil];
    }
    
    [StyleUtil styleLabel:_coinLabel];
    [StyleUtil styleLabel:_levelTitle];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setupCocos2D {
    
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
	
    
    // Create a Navigation Controller with the Director
    navController_ = [[UINavigationController alloc] initWithRootViewController:director];
    navController_.navigationBarHidden = YES;
    
    
    // set the Navigation Controller as the root view controller
    [window_ setRootViewController:navController_];
    
    // make main window visible
    [window_ makeKeyAndVisible];
    
    [self.view insertSubview:[LevelMgr getLevelMgr].glView atIndex:0];
    
    CCScene *scene = [LevelLayer scene];
    _layer = (LevelLayer*)[scene getChildByTag:LEVEL];
    _layer.undoBtn = _undoBtn;
    _layer.coinLbl = _coinLabel;
    _layer.coinImage = _coinImage;
    _layer.view = self.view;
    _layer.controller = self;
    
    
    //    [[CCDirector sharedDirector] setOpenGLView:glView];
    
    [[CCDirector sharedDirector] runWithScene:scene];
    
    _hasInit = true;
}

-(void)showLevel:(int) set: (Level*) level {
    
    if (!_hasInit) {
        [self setupCocos2D];
    }
    
    self.set = set;
    [_layer setLevel:level];
    [self showMessage:level.name];
}

-(void) showMessage: (NSString*) msg {
    _levelTitle.text = msg;
    
    [_levelTitle setAlpha:1.0];
    
    [UIView animateWithDuration:3
                          delay:1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [_levelTitle setAlpha:0.0];
                     }
                     completion:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [super viewWillAppear:animated];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    viewController.view.frame = CGRectZero;
    //[self presentModalViewController:viewController animated:NO];
    //[self dismissModalViewControllerAnimated:NO];
    [viewController release];
    
    _levelTitle.backgroundColor = [UIColor colorWithRed:(1.0 * 0) / 255 green:(1.0 * 0) / 255 blue:(1.0 * 0) / 255 alpha:0.8];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [_undoBtn setImage:[UIImage imageNamed:@"left_arrow.png"] forState:UIControlStateNormal];
    [_undoBtn setImage:[UIImage imageNamed:@"left_arrow_d.png"] forState:UIControlStateDisabled];
    _undoBtn.enabled = NO;
}

-(IBAction)goHomeTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)undoTapped:(id)sender {
    [_layer undo];
}

-(IBAction)refreshTapped:(id)sender {
    [_layer refresh];
}

-(void)viewDidUnload
{
    [_undoBtn release];
    _undoBtn = nil;
    [_coinLabel release];
    _coinLabel = nil;
    [_coinImage release];
    _coinImage = nil;
    [_levelTitle release];
    _levelTitle = nil;
    [super viewDidUnload];
    [[CCDirector sharedDirector] end];
}

/**
 * Check to see if the user has rated the app in the app store.  If they haven't then
 * we show the dialog reminding them every 20 times they run the game.
 */
-(void)checkForAppRating {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    bool hasRated = [prefs boolForKey:@"hasRated"];
    
    if (hasRated) {
        return;
    }
    
    NSInteger launchCount = [prefs integerForKey:@"launchCount"];
    launchCount++;
    [prefs setInteger:launchCount  forKey:@"launchCount"];
    
    if (launchCount == 20) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Like 7 Bridges?"
                                                        message:@"Please rate it on the App Store"
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles:@"Rate it on the App Store", nil];
        [alert addButtonWithTitle:@"Not Now"];
        [alert show];
        [alert release];
    }
}

/**
 * This method responds to the button clicks on the rate this app dialog
 */
-(void)alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (buttonIndex == 1) {
        [self rateGame];
    } else if (buttonIndex == 2) {
        [prefs setInteger:0 forKey:@"launchCount"];
    } else if (buttonIndex == 3) {
        [prefs setBool:true forKey:@"hasRated"];
    }
}

/**
 * Take the user to our page in the App store so they can rate the game.
 */
-(IBAction)rateGame {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=409954448"]];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void) won {
    if (self.youWonController == nil) {
        self.youWonController = [[[YouWonViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    self.youWonController.currentLevel = _layer.currentLevel;
    self.youWonController.currentSet = self.set;
    self.youWonController.layer = _layer;
    [self.navigationController pushViewController:self.youWonController animated:NO];
    
}

-(void)dealloc {
    
    [_layer release];
    [_undoBtn release];
    [_coinLabel release];
    [_coinImage release];
    [_levelTitle release];
    [super dealloc];
}

@end
