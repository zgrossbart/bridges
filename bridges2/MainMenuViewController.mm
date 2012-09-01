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

    // Get the list of font family names and from that
    // build the list of all font names in tempFontNames
    NSArray* familyNames = [UIFont familyNames];
    NSMutableArray* tempFontNames = [[NSMutableArray alloc] init];
    for(NSString* familyName in familyNames)
    {
        [tempFontNames addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
    }
    self.fontNames = tempFontNames;
    [tempFontNames release];
    // Match the system font
    self.fontSize = [UIFont systemFontSize];
    
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
    self.fontNames = nil;
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
//    NSAssert(self.fontNames, @"Illegal nil self.familyNames");
    return [LevelMgr getLevelMgr].levels.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
//    NSAssert(self.fontNames, @"Illegal nil self.familyNames");
    NSString* key = [[[LevelMgr getLevelMgr].levels allKeys] objectAtIndex:indexPath.row];
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
    
    NSString *key = [[[LevelMgr getLevelMgr].levels allKeys] objectAtIndex:self.curIndex];
    [self.rootMenuViewController showLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
    [self.navigationController pushViewController:_rootMenuViewController animated:YES];
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
    
    [mFontNames release];
    
//    [_view release];
    [_navItem release];
    [super dealloc];
}

@end
