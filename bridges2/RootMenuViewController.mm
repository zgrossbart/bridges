//
//  RootViewController.m
//  bridges
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import "RootMenuViewController.h"
#import "LevelLayer.h"
#import "BridgeColors.h"
#import "LevelMgr.h"

@interface RootMenuViewController ()

@end

@implementation RootMenuViewController {
    LevelLayer *_layer;
}

@synthesize youWonController = _youWonController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"RootMenuViewControlleriPad" bundle:nibBundleOrNil];
    } else {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupCocos2D {
    
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
	
    
    // Create a Navigation Controller with the Director
    navController_ = [[UINavigationController alloc] initWithRootViewController:director];
    navController_.navigationBarHidden = YES;
    
    // set the Navigation Controller as the root view controller
    //	[window_ addSubview:navController_.view];	// Generates flicker.
    [window_ setRootViewController:navController_];
    
    // make main window visible
    [window_ makeKeyAndVisible];
    
    [self.view insertSubview:[LevelMgr getLevelMgr].glView atIndex:0];
    
    CCScene *scene = [LevelLayer scene];
    _layer = (LevelLayer*)[scene getChildByTag:LEVEL];
    _layer.undoBtn = _undoBtn;
    _layer.coinLbl = _coinLabel;
    _layer.coinImage = _coinImage;
    _layer.view = self.view;
    _layer.controller = self;
    
    
    //    [[CCDirector sharedDirector] setOpenGLView:glView];
    
    [[CCDirector sharedDirector] runWithScene:scene];
    
    _hasInit = true;
}

-(void)showLevel:(Level*) level {
    
    if (!_hasInit) {
        [self setupCocos2D];
    }
    
    [_layer setLevel:level];
}

- (void) viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [super viewWillAppear:animated];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    viewController.view.frame = CGRectZero;
    [self presentModalViewController:viewController animated:NO];
    [self dismissModalViewControllerAnimated:NO];
    [viewController release];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *undoD = [UIImage imageNamed:@"left_arrow_d.png"];
    [_undoBtn setImage:undoD forState:UIControlStateNormal];
}

- (IBAction)goHomeTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)undoTapped:(id)sender {
    [_layer undo];
}

- (IBAction)refreshTapped:(id)sender {
    [_layer refresh];
}

- (void)viewDidUnload
{
    [_undoBtn release];
    _undoBtn = nil;
    [_coinLabel release];
    _coinLabel = nil;
    [_coinImage release];
    _coinImage = nil;
    [super viewDidUnload];
    [[CCDirector sharedDirector] end];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationLandscape);
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void) won {
    if (self.youWonController == nil) {
        self.youWonController = [[[YouWonViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    self.youWonController.currentLevel = _layer.currentLevel;
    self.youWonController.layer = _layer;
    [self.navigationController pushViewController:self.youWonController animated:NO];
    
}

-(void)dealloc {
    
    [_layer dealloc];
    [_undoBtn release];
    [_coinLabel release];
    [_coinImage release];
    [super dealloc];
}

@end
