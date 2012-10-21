//
//  MainSectionViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import "MainSectionViewController.h"
#import "MainMenuViewController.h"

@interface MainSectionViewController ()

@property (readwrite, retain) MainMenuViewController *menuView;

@end

@implementation MainSectionViewController

- (id)initWithNibAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*)menuView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.menuView = menuView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_label release];
    [self.menuView release];
    [super dealloc];
}

- (IBAction)playTapped:(id)sender {
    [self.menuView showLevels:-1];
    
}

@end
