//
//  YouWonViewController.m
//  bridges2
//
//  Created by Zack Grossbart on 9/8/12.
//
//

#import "YouWonViewController.h"
#import "LevelMgr.h"

@interface YouWonViewController ()

@end

@implementation YouWonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"YouWonViewiPad" bundle:nibBundleOrNil];
    } else {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    
    
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

- (IBAction)replayTapped:(id)sender {
    [self.layer refresh];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)nextTapped:(id)sender {
    int i = [[LevelMgr getLevelMgr].levelIds indexOfObject:self.currentLevel.levelId];
    
    if (i == [[LevelMgr getLevelMgr].levelIds count] - 1) {
        /* 
         * Then we're at the end and we just go back to the menu
         */
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSString *key = [[LevelMgr getLevelMgr].levelIds objectAtIndex:i + 1];
        [self.layer setLevel:[[LevelMgr getLevelMgr].levels objectForKey:key]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)menuTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
