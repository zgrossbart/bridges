//
//  MainMenuViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import "MainMenuViewController.h"
#import "LevelMgr.h"
#import "UIImageExtras.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

@synthesize rootMenuViewController = _rootMenuViewController;
@synthesize rootMenuViewControlleriPad = _rootMenuViewControlleriPad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LevelMgr getLevelMgr];
    
    [self generateLevelImages];
 //   [self loadLevelPicker];
    
    _navItem.title = @"Select a level";
//    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}

-(void)loadLevelPicker {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if([paths count] > 0)
    {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        int row = 0;
        int column = 0;
        CGSize s = CGSizeMake(96, 64);
        
        for (int i = 0; i < [LevelMgr getLevelMgr].levelIds.count; i++) {
            NSString *levelId = [[LevelMgr getLevelMgr].levelIds objectAtIndex:i];
            Level *level = [[LevelMgr getLevelMgr].levels objectForKey:levelId];
            UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", levelId]]];
            
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(column*(s.width + 15)+24, row*(s.height + 50)+10, s.width + 15, s.height);
            [button setImage:[image imageByScalingAndCroppingForSize:s] forState:UIControlStateNormal];
            [button setTitle:level.name forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(levelSelected:)
             forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [_scrollView addSubview:button];
            
            if (column == 10) {
                column = 0;
                row++;
            } else {
                column++;
            }
        }
            
        
    }
}

-(void)levelSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
	int tag = button.tag;
    
    NSString* key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:tag];
    [self selectLevel:key];
    
}

-(void)selectLevel:(NSString*) key {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (_rootMenuViewControlleriPad == nil) {
            self.rootMenuViewControlleriPad = [[[RootMenuViewControlleriPad alloc] initWithNibName:nil bundle:nil] autorelease];
        }
        
        [self.rootMenuViewControlleriPad showLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
        [self.navigationController pushViewController:_rootMenuViewControlleriPad animated:YES];
    } else {
        if (_rootMenuViewController == nil) {
            self.rootMenuViewController = [[[RootMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        }
        
        [self.rootMenuViewController showLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
        [self.navigationController pushViewController:_rootMenuViewController animated:YES];
    }
}

- (void)viewDidUnload
{
//    [_view release];
//    _view = nil;
    [_navItem release];
    _navItem = nil;
    [_scrollView release];
    _scrollView = nil;
    [_mainTable release];
    _mainTable = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;//UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)showBridgesTapped:(id)sender {
//    [self viewBridges:nil];
    
    
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [LevelMgr getLevelMgr].levels.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    NSString *levelId = [[LevelMgr getLevelMgr].levelIds objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if([paths count] > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        CGSize s = CGSizeMake(96, 64);
        UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", levelId]]];
        cell.imageView.image = [image imageByScalingAndCroppingForSize:s];
        
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:[NSString stringWithFormat:@"%@-won", levelId]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_check.png"]];
        cell.accessoryView = imageView;
        [imageView release];
    }
    
    cell.textLabel.text = ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:levelId]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.curIndex = indexPath.row;
    NSLog(@"Selected level: %@", [[[LevelMgr getLevelMgr].levels allValues] objectAtIndex:indexPath.row]);
    
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

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [_mainTable reloadData];
}

- (void)dealloc
{
    [_rootMenuViewController release];
    _rootMenuViewController = nil;
    
//    [_view release];
    [_navItem release];
    [_scrollView release];
    [_mainTable release];
    [super dealloc];
}

@end
