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
    [self loadLevelPicker];
    
    _navItem.title = @"Select a level";
//    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
}

-(void)loadLevelPicker {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *documentArray;
    if([paths count] > 0)
    {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error = nil;
        documentArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if(error) {
            NSLog(@"Could not get list of documents in directory, error = %@",error);
        } else {
            int row = 0;
            int column = 0;
            CGSize s = CGSizeMake(96, 64);
            
            for (NSString *file in documentArray) {
                if ([file hasPrefix:@"level"] &&
                    [file hasSuffix:@".png"]) {
                    UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:file]];
                    
                    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(column*(s.width + 15)+24, row*s.height+10, s.width + 15, s.height);
                    [button setImage:[image imageByScalingAndCroppingForSize:s] forState:UIControlStateNormal];
                    [button addTarget:self
                               action:@selector(levelSelected:)
                     forControlEvents:UIControlEventTouchUpInside];
                    button.tag = [[self getLevelId:file] integerValue];
                    [_scrollView addSubview:button];
                    
                    if (column == 3) {
                        column = 0;
                        row++;
                    } else {
                        column++;
                    }
                }
                
            }
        }
    }
    
}

-(void)addButton:(NSString*) file: (NSString*) documentsDirectory {
    
}

-(NSString*)getLevelId:(NSString*) file {
    /*
     * Level images have names like level5.png.
     * We want the number after the word level
     * and before the dot.
     */
    
    NSMutableString *levelId = [[NSMutableString alloc]initWithCapacity:3];
    
    for (int i = 5; i < file.length; i++) {
        if ([file characterAtIndex:i] == '.') {
            break;
        } else {
            [levelId appendString: [NSString stringWithFormat:@"%c" , [file characterAtIndex:i]]];
        }
    }
    
    NSLog(@"levelId: %@", levelId);
    
    return levelId;
}

-(void)levelSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
	int tag = button.tag;
    
}

- (void)viewDidUnload
{
//    [_view release];
//    _view = nil;
    [_navItem release];
    _navItem = nil;
    [_scrollView release];
    _scrollView = nil;
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
    [_scrollView release];
    [super dealloc];
}

@end
