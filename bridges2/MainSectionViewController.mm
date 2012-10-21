//
//  MainSectionViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

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
    [StyleUtil styleMenuButton:self.playBtn];
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
