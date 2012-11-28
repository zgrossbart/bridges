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

#import "YouWonViewController.h"
#import "LevelMgr.h"
#import "StyleUtil.h"

@interface YouWonViewController ()

@end

@implementation YouWonViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"YouWonViewiPad" bundle:nibBundleOrNil];
    } else {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
    
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self styleButtons];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_1024_768_River.png"]];
}

-(void)styleButtons {
    [StyleUtil styleMenuButton:_nextButton];
    [StyleUtil styleMenuButton:_menuButton];
    [StyleUtil styleMenuButton:_replayButton];
    
    _xOfY.text = [self getXofY];
    [StyleUtil styleLabel:_xOfY];
}

-(NSString*)getXofY {
    int x = 0;
    int y = [[LevelMgr getLevelSet:self.currentSet].levelIds count];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSString *levelId in [LevelMgr getLevelSet:self.currentSet].levelIds) {
        if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", [LevelMgr getLevel:self.currentSet :levelId].fileName]]) {
            x ++;
        }
    }
    
    return [NSString stringWithFormat:@"%d of %d", x, y];
}


-(void)viewDidUnload {
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewDidAppear:(BOOL)animated {
    [StyleUtil animateView:self.view];
}

-(void) viewWillAppear:(BOOL)animated {
    _xOfY.text = [self getXofY];
    self.view.alpha = 0;
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.5];
    self.view.alpha = 1;
    [UIView commitAnimations];
    
}


-(IBAction)replayTapped:(id)sender {
    [StyleUtil advance];
    [self.layer refresh];
    [self.navigationController popViewControllerAnimated:NO];
    
}

-(IBAction)nextTapped:(id)sender {
    [StyleUtil advance];
    int i = [[LevelMgr getLevelSet:self.currentSet].levelIds indexOfObject:self.currentLevel.levelId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (i == [[LevelMgr getLevelSet:self.currentSet].levelIds count] - 1) {
        /* 
         * Then we're at the end and we just go back to the menu
         */
        [self.navigationController popToRootViewControllerAnimated:NO];
        [LevelMgr getLevelMgr].showSetMenu = true;
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            /*
             * If we're on the iPhone then we want to advance to the
             * next menu section when the user presses next after winning
             * the last level.
             */
            [LevelMgr getLevelMgr].currentSet = self.currentSet + 1;
        }
        
        [defaults removeObjectForKey:@"currentLevelSet"];
        [defaults removeObjectForKey:@"currentLevelKey"];
        [defaults synchronize];
    } else {
        NSString *key = [[LevelMgr getLevelSet:self.currentSet].levelIds objectAtIndex:i + 1];
        [self.layer setLevel:[[LevelMgr getLevelSet:self.currentSet].levels objectForKey:key]];
        [self.navigationController popViewControllerAnimated:NO];
        
        [defaults setInteger:self.currentSet forKey:@"currentLevelSet"];
        [defaults setObject:key forKey:@"currentLevelKey"];
    }
    
}

-(IBAction)menuTapped:(id)sender {
    [StyleUtil regress];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)dealloc {
    [_nextButton release];
    [_replayButton release];
    [_menuButton release];
    [_xOfY release];
    [super dealloc];
}
@end
