//
//  LevelMgr.m
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import "LevelMgr.h"
#import "JSONKit.h"
#import "cocos2d.h"
#import "GLES-Render.h"
#import "LayerMgr.h"
#import "ScreenShotLayer.h"

#define PTM_RATIO 32.0

@interface LevelMgr()
@property (readwrite) NSMutableDictionary *levels;
@property (readwrite,copy) NSArray *levelIds;
@property (readwrite) CCGLView *glView;
@end

@implementation LevelMgr

+ (LevelMgr*)getLevelMgr {
    static LevelMgr *levelMgr;
    
    @synchronized(self)
    {
        if (!levelMgr) {
            levelMgr = [[LevelMgr alloc] init];
            levelMgr.levels = [[NSMutableDictionary alloc] init];
            
            [levelMgr loadLevels];
        }
        
        return levelMgr;
    }
}

-(void)loadLevels {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    for (NSString *file in directoryContents) {
        if ([file hasPrefix:@"level"] &&
            [file hasSuffix:@".json"]) {
            NSString *jsonString = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
            NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
            
            Level *level = [[Level alloc] initWithJson:jsonString: fileDate];
            [self.levels setObject:level forKey:level.levelId];
        }
    }
    
    self.levelIds = [self sortLevels];
    
//    NSLog(@"levels ====== %@",self.levels);
}

- (NSArray *)sortLevels {
    return [[self.levels allKeys] sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
        int i1 = [obj1 integerValue];
        int i2 = [obj2 integerValue];
        if (i1 > i2) {
            return NSOrderedDescending;
        } else if (i1 < i2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)setupCocos2D: (CGRect) bounds {
    CCGLView *glView = [CCGLView viewWithFrame:bounds
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    glView_ = glView;
    self.glView = glView_;
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
    director_.displayStats = FALSE;
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	//[director_ setDelegate:self];
	
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
	
    _hasInit = true;
}

-(void)drawLevels:(CGRect) bounds {
    if (!_hasInit) {
        [self setupCocos2D:bounds];
    }
    
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    bool doSleep = false;
    b2World *world = new b2World(gravity);
    world->SetAllowSleeping(doSleep);
    
    // Enable debug draw
    GLESDebugDraw *debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(debugDraw);
    
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    debugDraw->SetFlags(flags);
    
    // Create our sprite sheet and frame cache
    CCSpriteBatchNode *spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"octosprite.png"
                                                capacity:2] retain];
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"octosprite.plist"];
    
    LayerMgr *layerMgr = [[LayerMgr alloc] initWithSpriteSheet:spriteSheet:world];
    layerMgr.tileSize = CGSizeMake(bounds.size.height / 28, bounds.size.height / 28);
    
    CCRenderTexture *renderer	= [CCRenderTexture renderTextureWithWidth:bounds.size.width height:bounds.size.height];
    
    ScreenShotLayer *scene = [[ScreenShotLayer alloc] init];
    [scene addChild:spriteSheet];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (NSString* levelId in self.levelIds) {
        
        Level *level = (Level*) [self.levels objectForKey:levelId];
        if([paths count] > 0) {
            NSString *documentsDirectory = [paths objectAtIndex:0];

            NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", level.levelId]];
                
            NSError *error;
                
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:path] error:&error];
                NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
                
                if ([fileDate compare:level.date] == NSOrderedDescending) {
                    /*
                     * Then the image is more recent than the file
                     * and there's no need to regenerate it.
                     */
                    continue;
                }
            }
        }
        
        [level addSprites:layerMgr:nil];
        
        [renderer begin];
        [scene visit];
        [renderer end];
        
        //	return [renderer getUIImageFromBuffer];
        
        BOOL success = [renderer saveToFile: [NSString stringWithFormat:@"level%@.png", level.levelId] format:kCCImageFormatPNG];
        
        [layerMgr removeAll];
        
        NSLog(@"success: %c", success);
        
    }
    
    delete world;
    delete debugDraw;
    
    [spriteSheet release];
    [scene dealloc];
    
}

-(void)dealloc {
    
    [_levels release];
    _levels = nil;
    
    [_levelIds release];
    _levelIds = nil;
    
    [super dealloc];
    
}

@end
