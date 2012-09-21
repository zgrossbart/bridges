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
#import "LevelCell.h"

@interface MainMenuViewController() {
    bool _hasLoadedPicker;
    int _noOfSection;
    
}

@property (readwrite, retain) NSMutableArray *buttons;
@property (readwrite, retain) UIImage *checkImage;

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
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if (_checkImage == nil) {
        _checkImage = [UIImage imageNamed:@"green_check.png"];
    }
    
    _noOfSection = 3;
    
    self.buttons = [NSMutableArray arrayWithCapacity:25];
    
    [LevelMgr getLevelMgr];
    
    [self generateLevelImages];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    //    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];

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

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
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
        [imageView release];
    }

    cell.imageView.image = ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).screenshot;
    
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

-(void) detectOrientation {

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
    
    NSString *urlAddress = @"https://github.com/zgrossbart/bridges/blob/master/README.md#the-seven-bridges-of-k%C3%B6nigsberg";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
    _aboutNavItem.title = @"The Seven Bridges of Königsberg";
}

-(IBAction)playTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuCollectionView" owner:self options:nil];
        [self loadLevelPickerView];
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuViewController" owner:self options:nil];
    }
    
    _navItem.title = @"Select a level";
}

-(void)loadLevelPickerView {
    [self.collectionView registerClass:[LevelCell class] forCellWithReuseIdentifier:@"levelCell"];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) {
        _noOfSection = 3;
    } else {
        _noOfSection = 4;
    }
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(216, 144)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView reloadData];
}

-(IBAction)backToMainTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
}

-(IBAction)creditsTapped:(id)sender {
    [[NSBundle mainBundle] loadNibNamed:@"AboutViewiPad" owner:self options:nil];
    
    NSString *urlAddress = @"https://github.com/zgrossbart/bridges/commits/master";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
    _aboutNavItem.title = @"The Seven Bridges of Königsberg";
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([[LevelMgr getLevelMgr].levelIds count] % _noOfSection == 0) {
        return [[LevelMgr getLevelMgr].levelIds count] / _noOfSection;
    } else {
        return ([[LevelMgr getLevelMgr].levelIds count] / _noOfSection) + 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _noOfSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"levelCell";
    
    LevelCell *cell = (LevelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    int index = indexPath.section * _noOfSection + indexPath.row;
    
    if (index >= [[LevelMgr getLevelMgr].levelIds count]) {
        [cell.titleLabel setText:@""];
        [cell.screenshot setImage:nil];
        [cell.checkMark setImage:nil];
    } else {
        NSString *levelId = [[LevelMgr getLevelMgr].levelIds objectAtIndex:index];
        
        NSMutableString *name = [NSMutableString stringWithCapacity:10];
        [name appendString:levelId];
        [name appendString:@". "];
        [name appendString:((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).name];
        [cell.titleLabel setText:name];
        [cell.screenshot setImage:((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).screenshot];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", levelId]]) {
            [cell.checkMark setImage:_checkImage];
        } else {
            [cell.checkMark setImage:nil];
        }
    }
    
    // Return the cell
    return cell;
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        _noOfSection = 4;
    } else {
        _noOfSection = 3;
    }
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.section * _noOfSection + indexPath.row;
    [self selectLevel:[[LevelMgr getLevelMgr].levelIds objectAtIndex:index]];
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
