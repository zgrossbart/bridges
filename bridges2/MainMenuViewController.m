//
//  MainMenuViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

@synthesize rootMenuViewController = _rootMenuViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)showBridgesTapped:(id)sender {
//    [self viewBridges:nil];
    printf("hey there...\n");
    
    if (_rootMenuViewController == nil) {
        self.rootMenuViewController = [[[RootMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
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
    [super dealloc];
}

@end
