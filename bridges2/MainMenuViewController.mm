//
//  MainMenuViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import "MainMenuViewController.h"
#import "LevelMgr.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

@synthesize rootMenuViewController = _rootMenuViewController;

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
    
    _navItem.title = @"Select a level";
//    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}

- (void)viewDidUnload
{
//    [_view release];
//    _view = nil;
    [_navItem release];
    _navItem = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString* key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:indexPath.row];
    cell.textLabel.text = ((Level*)[[LevelMgr getLevelMgr].levels objectForKey:key]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.curIndex = indexPath.row;
    NSLog(@"Selected level: %@", [[[LevelMgr getLevelMgr].levels allValues] objectAtIndex:indexPath.row]);
    
    if (_rootMenuViewController == nil) {
        self.rootMenuViewController = [[[RootMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:false];
    
    NSString* key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:indexPath.row];
    [self.rootMenuViewController showLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
    [self.navigationController pushViewController:_rootMenuViewController animated:YES];
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
}

- (void)dealloc
{
    [_rootMenuViewController release];
    _rootMenuViewController = nil;
    
//    [_view release];
    [_navItem release];
    [super dealloc];
}

@end
