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

#import "MainSectionViewController.h"
#import "MainMenuViewController.h"
#import "StyleUtil.h"

@interface MainSectionViewController ()

@property (readwrite, retain) MainMenuViewController *menuView;
@property (readwrite) int index;

@end

@implementation MainSectionViewController

- (id)initWithNibAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*)menuView index:(int)index {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.menuView = menuView;
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[StyleUtil styleMenuButton:self.playBtn];
    
    [self.playBtn.layer setCornerRadius:8.0f];
    [self.playBtn.layer setMasksToBounds:YES];
    self.playBtn.layer.borderColor = [UIColor colorWithRed:(1.0 * 170) / 255 green:(1.0 * 170) / 255 blue:(1.0 * 170) / 255 alpha:0.5].CGColor;
    self.playBtn.layer.borderWidth = 2.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_label release];
    [self.menuView release];
    [_playBtn release];
    [super dealloc];
}

- (IBAction)playTapped:(id)sender {
    [self.menuView showLevels:self.index];
    
}

@end
