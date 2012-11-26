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
#import "LevelCell.h"
#import "StyleUtil.h"
#import "MainPageViewController.h"
#import "MainSectionCollectionViewController.h"
#import "SimpleAudioEngine.h"

@interface MainMenuViewController() {
    int _noOfSection;
    
}
@property (readwrite, retain) UIImage *checkImage;
@property (readwrite) int currentSet;
@property (readwrite, retain) MainPageViewController *pageViewController;
@property (readwrite, retain) MainSectionCollectionViewController *sectionViewController;

@end

@implementation MainMenuViewController

@synthesize GameSceneViewController = _GameSceneViewController;
@synthesize checkImage = _checkImage;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        
    }
    return self;
}

-(void) awakeFromNib {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainViewiPad" owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    }
    [self viewDidLoad];
    [self styleButtons];
}

-(void)styleButtons {
    [StyleUtil styleMenuButton:_playBtn];
    [StyleUtil styleMenuButton:_aboutBtn];
    [StyleUtil styleMenuButton:_backBtn];
    [self updateSoundButtonImage];
}

/**
 * Each sound file takes a little while to load and it will slow down
 * the game if we load them for the first time when we want to play them.
 * This method preloads all of our sound effects so they're ready when
 * we need them.
 */
-(void)preloadSounds {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSError *error;
    NSArray *sounds = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    for (NSString *file in sounds) {
        if ([file hasSuffix:@".m4a"]) {
            [[SimpleAudioEngine sharedEngine] preloadEffect:path];
        }
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if (_checkImage == nil) {
        _checkImage = [UIImage imageNamed:@"green_check.png"];
    }
    
    [self preloadSounds];
    
    _noOfSection = 4;
    
    [LevelMgr getLevelMgr];
    
    [self generateLevelImages];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    _xOfY.text = [self getXofY];
    [StyleUtil styleLabel:_xOfY];
    [self updateSoundButtonImage];
}

-(void)selectLevel:(NSString*) key {
    [StyleUtil advance];
    if (_GameSceneViewController == nil) {
        self.GameSceneViewController = [[[GameSceneViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.currentSet forKey:@"currentLevelSet"];
    [defaults setObject:key forKey:@"currentLevelKey"];
    
    [defaults synchronize];
    [self.GameSceneViewController showLevel:self.currentSet: [LevelMgr getLevel:self.currentSet :key]];
    [self.navigationController pushViewController:_GameSceneViewController animated:NO];
}

-(void)viewDidUnload {
    [_navItem release];
    _navItem = nil;
    [_mainTable release];
    _mainTable = nil;
    [_resetBtn release];
    _resetBtn = nil;
    
    [_webView release];
    _webView = nil;
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return TRUE;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return [LevelMgr getLevelSet:self.currentSet].levels.count;
}

-(UITableViewCell*)tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    NSString *levelId = [[LevelMgr getLevelSet:self.currentSet].levelIds objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_checkImage];
        cell.accessoryView = imageView;
        [imageView release];
    }

    cell.imageView.image = [LevelMgr getLevel:self.currentSet :levelId].screenshot;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", [LevelMgr getLevel:self.currentSet :levelId].fileName]]) {
        
        [((UIImageView*) cell.accessoryView) setImage:_checkImage];
    } else {
        ((UIImageView*) cell.accessoryView).image = nil;
    }
    
    NSMutableString *name = [NSString stringWithFormat:@"%d. %@", [levelId intValue] + 1, [LevelMgr getLevel:self.currentSet :levelId].name];
    
    cell.textLabel.text = name;
    
    if ([levelId isEqualToString:[defaults objectForKey:@"currentLevelKey"]] &&
        self.currentSet == [defaults integerForKey:@"currentLevelSet"]) {
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16];
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16];
    }
    
    return cell;
}

-(void)tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    self.curIndex = indexPath.row;
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:false];
    
    NSString* key = [[LevelMgr getLevelSet:self.currentSet].levelIds objectAtIndex:indexPath.row];
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
    [_collectionView reloadData];
    _xOfY.text = [self getXofY];
    
    if ([LevelMgr getLevelMgr].showSetMenu) {
        [LevelMgr getLevelMgr].showSetMenu = false;
        [self playTapped:nil];
    }
    
    
    [self.sectionViewController refresh];
    [self.pageViewController refresh];
    [self updateSoundButtonImage];
    
    [StyleUtil animateView:self.view];
}

-(IBAction)backToGameTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainViewiPad" owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    }
    
    [self updateSoundButtonImage];
    [self styleButtons];
}

-(IBAction)backToPageViewTapped:(id)sender {
    [self backToSectionView:false];
}

-(IBAction)aboutTapped:(id)sender {
    [StyleUtil advance];
    [[NSBundle mainBundle] loadNibNamed:@"AboutViewiPad" owner:self options:nil];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@".html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self styleButtons];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(IBAction)playTapped:(id)sender {
    [self backToSectionView:true];
}

-(void)backToSectionView: (bool) advance {
    if (advance) {
        [StyleUtil advance];
    } else {
        [StyleUtil regress];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.sectionViewController == nil) {
            self.sectionViewController = [[[MainSectionCollectionViewController alloc] initWithNibNameAndMenuView:nil bundle:nil menu:self] autorelease];
        }
        
        [self.navigationController pushViewController:self.sectionViewController animated:NO];
    } else {
        if (self.pageViewController == nil) {
            self.pageViewController = [[[MainPageViewController alloc] initWithNibNameAndMenuView:nil bundle:nil menu:self] autorelease];
        }
        
        [self.navigationController pushViewController:self.pageViewController animated:NO];
    }
}

-(void)updateSoundButtonImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"noSounds"]) {
        [_soundBtn setImage:[UIImage imageNamed:@"soundoff.png"] forState:UIControlStateNormal];
        [SimpleAudioEngine sharedEngine].effectsVolume = 0;
    } else {
        [_soundBtn setImage:[UIImage imageNamed:@"soundon.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)toggleSoundsTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"noSounds"]) {
        [defaults setBool:false forKey:@"noSounds"];
        [_soundBtn setImage:[UIImage imageNamed:@"soundon.png"] forState:UIControlStateNormal];
        [SimpleAudioEngine sharedEngine].effectsVolume = 1;
        [StyleUtil advance];
    } else {
        [defaults setBool:true forKey:@"noSounds"];
        [_soundBtn setImage:[UIImage imageNamed:@"soundoff.png"] forState:UIControlStateNormal];
        [SimpleAudioEngine sharedEngine].effectsVolume = 0;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)showLevels: (int)page {
    self.currentSet = page;
    [self.navigationController popViewControllerAnimated:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuCollectionView" owner:self options:nil];
        [self.levelSetImage setImage:[UIImage imageNamed: [LevelMgr getLevelSet:page].imageName]];
        [self loadLevelPickerView];
        _levelSetLabel.text = [LevelMgr getLevelSet:page].name;
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuViewController" owner:self options:nil];
        _navItem.title = [LevelMgr getLevelSet:page].name;
    }
    [self styleButtons];
    _xOfY.text = [self getXofY];
    
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer {
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self backToPageViewTapped:nil];
    }
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

-(void)loadLevelPickerView {
    [self.collectionView registerClass:[LevelCell class] forCellWithReuseIdentifier:@"levelCell"];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) {
        _noOfSection = 4;
    } else {
        _noOfSection = 4;
    }
    
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    
    CGSize s = CGSizeMake(IPAD_LEVEL_IMAGE_W + 30, IPAD_LEVEL_IMAGE_H + 20);
    
    [flowLayout setItemSize:s];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setFooterReferenceSize:CGSizeMake(0, 0)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView reloadData];
}

-(IBAction)backToMainTapped:(id)sender {
    [StyleUtil regress];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"MainViewiPad" owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    }
    
    [self styleButtons];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*) collectionView {
    if ([[LevelMgr getLevelSet:self.currentSet].levelIds count] % _noOfSection == 0) {
        return [[LevelMgr getLevelSet:self.currentSet].levelIds count] / _noOfSection;
    } else {
        return ([[LevelMgr getLevelSet:self.currentSet].levelIds count] / _noOfSection) + 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _noOfSection;
}

/**
 * Create each cell in the collection view that we use to select levels on the iPad
 */
-(UICollectionViewCell*) collectionView:(UICollectionView*) collectionView cellForItemAtIndexPath:(NSIndexPath*) indexPath {
    NSString *cellIdentifier = @"levelCell";
    
    LevelCell *cell = (LevelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    int index = indexPath.section * _noOfSection + indexPath.row;
    
    if (index >= [[LevelMgr getLevelSet:self.currentSet].levelIds count]) {
        [cell.titleLabel setText:@""];
        [cell.screenshot setImage:nil];
        [cell.checkMark setImage:nil];
        [cell setBorderVisible:false];
    } else {
        NSString *levelId = [[LevelMgr getLevelSet:self.currentSet].levelIds objectAtIndex:index];
        
        NSMutableString *name = [NSString stringWithFormat:@"%d. %@", [levelId intValue] + 1, [LevelMgr getLevel:self.currentSet :levelId].name];
        
        [cell.titleLabel setText:name];
        [cell.screenshot setImage:[LevelMgr getLevel:self.currentSet :levelId].screenshot];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", [LevelMgr getLevel:self.currentSet :levelId].fileName]]) {
            [cell.checkMark setImage:_checkImage];
        } else {
            [cell.checkMark setImage:nil];
        }
        [cell setBorderVisible:true];
        
        if ([levelId isEqualToString:[defaults objectForKey:@"currentLevelKey"]] &&
            self.currentSet == [defaults integerForKey:@"currentLevelSet"]) {
            cell.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16];
        } else {
            cell.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16];
        }
    }
    
    // Return the cell
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout*) collectionViewLayout referenceSizeForHeaderInSection:(NSInteger) section {
    return CGSizeMake(0, 0);
}

-(UIEdgeInsets)collectionView:(UICollectionView*) collectionView layout:(UICollectionViewLayout*) collectionViewLayout insetForSectionAtIndex:(NSInteger) section {
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
}

/**
 * This method gets called when the device roates.  We aren't using this right now since
 * we're only supporting landscape orientation.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        _noOfSection = 3;
    } else {
        _noOfSection = 3;
    }
    [self.collectionView reloadData];
}

/**
 * This method gets called when the user taps on a cell in the collection view.
 */
- (void)collectionView:(UICollectionView*) collectionView didSelectItemAtIndexPath:(NSIndexPath*) indexPath {
    int index = indexPath.section * _noOfSection + indexPath.row;
    if (index < [[LevelMgr getLevelSet:self.currentSet].levelIds count]) {
        [self selectLevel:[[LevelMgr getLevelSet:self.currentSet].levelIds objectAtIndex:index]];
    }
}

-(void)dealloc
{
    [_GameSceneViewController release];
    _GameSceneViewController = nil;
    [self.pageViewController release];
    [self.sectionViewController release];
    
    [_checkImage release];

    [_navItem release];
    [_mainTable release];
    [_resetBtn release];
    [_webView release];
    [_playBtn release];
    [_aboutBtn release];
    [_backBtn release];
    [_xOfY release];
    [_levelSetImage release];
    [_levelSetLabel release];
    [_soundBtn release];
    [_soundBtn release];
    [super dealloc];
}

@end
