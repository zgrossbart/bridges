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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupCocos2D {
    /*CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    glView_ = glView;
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	//[director_ pushScene: [IntroLayer scene]];*/
    
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
    
    //    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[LevelLayer scene] withColor:ccWHITE]];
    //[[CCDirector sharedDirector] replaceScene:[LevelLayer scene]];
    
    /*[self.view insertSubview:glView atIndex:0];
    //    [[CCDirector sharedDirector] setOpenGLView:glView];
    CCScene *scene = [LevelLayer scene];
    LevelLayer *layer = (LevelLayer*)[scene getChildByTag:LEVEL];
    layer.currentLevelPath = self.currentLevelPath;
    [[CCDirector sharedDirector] runWithScene:scene];*/
    
    CCScene *scene = [LevelLayer scene];
    _layer = (LevelLayer*)[scene getChildByTag:LEVEL];
    _layer.undoBtn = _undoBtn;
    _layer.view = self.view;
    
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
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
    [super viewDidUnload];
    [[CCDirector sharedDirector] end];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc {
    
    [_layer dealloc];
    [_undoBtn release];
    [super dealloc];
}

@end
