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

#import "MainMenuViewController.h"
#import "LevelMgr.h"
#import "UIImageExtras.h"

@interface MainMenuViewController() {
    bool _hasLoadedPicker;
    
}

@property (readwrite, retain) NSMutableArray *buttons;
@property (retain) UIImage *checkImage;

@end

@implementation MainMenuViewController

@synthesize rootMenuViewController = _rootMenuViewController;
@synthesize checkImage = _checkImage;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        
        self.buttons = [NSMutableArray array];
        
    }
    return self;
}

-(void) awakeFromNib {
    
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    [self viewDidLoad];
    
    
    //    [super awakeFromNib];
    //    [self addSubview:self.view];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (_checkImage == nil) {
        _checkImage = [UIImage imageNamed:@"green_check.png"];
    }
    
    self.buttons = [NSMutableArray arrayWithCapacity:25];
    
    [LevelMgr getLevelMgr];
    
    [self generateLevelImages];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    //    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}

-(void)loadLevelPicker {
    if (_hasLoadedPicker) {
        [self.buttons removeAllObjects];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if([paths count] > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        for (int i = 0; i < [LevelMgr getLevelMgr].levelIds.count; i++) {
            NSString *levelId = [[LevelMgr getLevelMgr].levelIds objectAtIndex:i];
            Level *level = [[LevelMgr getLevelMgr].levels objectForKey:levelId];
            UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", levelId]]];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.buttons addObject:button];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button setTitle:level.name forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button.layer setCornerRadius:8.0f];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderWidth:1.0f];
            [button.layer setBorderColor:[[UIColor colorWithRed:(1.0 * 233) / 255 green:(1.0 * 233) / 255 blue:(1.0 * 233) / 255 alpha:1] CGColor]];
            
            [button setTitle:level.name forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.titleLabel.backgroundColor = [UIColor whiteColor];
            
            [button addTarget:self
                       action:@selector(levelSelected:)
             forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            
            if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", levelId]]) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:_checkImage];
                imageView.contentMode = UIViewContentModeCenter;
                imageView.backgroundColor = [UIColor clearColor];
                imageView.frame = CGRectMake(205, 5, 20, 20);
                
                [button addSubview:imageView];
                [_scrollView addSubview:button];
                
                [imageView release];
            } else {
                [_scrollView addSubview:button];
            }
            
            button.titleLabel.frame = CGRectMake(2, 2, button.titleLabel.frame.size.width, button.titleLabel.frame.size.height);
        }
    }
    
    _hasLoadedPicker = true;
}

-(void)levelSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
	int tag = button.tag;
    
    NSString* key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:tag];
    [self selectLevel:key];
    
}

-(void)selectLevel:(NSString*) key {
    if (_rootMenuViewController == nil) {
        self.rootMenuViewController = [[[RootMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    [self.rootMenuViewController showLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
    [self.navigationController pushViewController:_rootMenuViewController animated:YES];
    
}

-(void)viewDidUnload {
    [_navItem release];
    _navItem = nil;
    [_scrollView release];
    _scrollView = nil;
    [_mainTable release];
    _mainTable = nil;
    [_resetBtn release];
    _resetBtn = nil;
    
//    [self.buttons release];
    self.buttons = nil;
    
    [_webView release];
    _webView = nil;
    [_aboutNavItem release];
    _aboutNavItem = nil;
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;//UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// Customize the number of sections in the table view.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [LevelMgr getLevelMgr].levels.count;
}


// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    NSString *levelId = [[LevelMgr getLevelMgr].levelIds objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_checkImage];
        cell.accessoryView = imageView;
        //[imageView release];
    }

    if (((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).screenshot == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        if([paths count] > 0) {
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", levelId]]];
            ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).screenshot = image;
            cell.imageView.image = image;
            
        }
    } else {
        cell.imageView.image = ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).screenshot;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", levelId]]) {
        
        [((UIImageView*) cell.accessoryView) setImage:_checkImage];
    } else {
        ((UIImageView*) cell.accessoryView).image = nil;
    }
    
    cell.textLabel.text = ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.curIndex = indexPath.row;
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:false];
    
    NSString* key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:indexPath.row];
    [self selectLevel:key];
}

-(void)generateLevelImages {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    /*
     * Sometimes the screen will be in portrait mode at this point and
     * we always want to draw the screen shots in landscape so we create
     * a new bounding rect.
     */
    CGRect r = CGRectMake(screenRect.origin.x, screenRect.origin.y,
                          fmaxf(screenRect.size.width, screenRect.size.height),
                          fminf(screenRect.size.width, screenRect.size.height));
    
    [[LevelMgr getLevelMgr] drawLevels:r];
    
}

-(void)arrangeButtons {
    
    int row = 0;
    int column = 0;
    CGSize s = CGSizeMake(216, 144);
    int cols = 3;
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
        [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        cols = 2;
    }
    
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(column*(s.width + 30)+24, row*(s.height + 20)+10, s.width + 15, s.height);
        
        if (column == cols) {
            column = 0;
            row++;
        } else {
            column++;
        }
    }
    
    [_scrollView setNeedsDisplay];
    
}

-(void) detectOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self arrangeButtons];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [_mainTable reloadData];
}

-(IBAction)backToGameTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
}

-(IBAction)aboutTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"AboutViewiPad" owner:self options:nil];
    
    NSString *urlAddress = @"http://www.google.com";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
    _aboutNavItem.title = @"The Seven Bridges of Königsberg";
}

-(IBAction)playTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuViewiPad" owner:self options:nil];
        
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuViewController" owner:self options:nil];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self loadLevelPicker];
        [self arrangeButtons];
    }
    
    _navItem.title = @"Select a level";
}

-(IBAction)backToMainTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
}

-(IBAction)creditsTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"AboutViewiPad" owner:self options:nil];
    
    NSString *urlAddress = @"http://www.google.com";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
    _aboutNavItem.title = @"The Seven Bridges of Königsberg";
}

-(void)dealloc
{
    [_rootMenuViewController release];
    _rootMenuViewController = nil;
    
//    [self.buttons release];
    self.buttons = nil;
    
    [_checkImage release];
    
    //    [_view release];
    [_navItem release];
    [_scrollView release];
    [_mainTable release];
    [_resetBtn release];
    [_webView release];
    [_aboutNavItem release];
    [super dealloc];
}

@end
