/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import "LevelMgr.h"
#import "JSONKit.h"
#import "cocos2d.h"
#import "GLES-Render.h"
#import "LayerMgr.h"
#import "ScreenShotLayer.h"
#import "BridgeColors.h"
#import "LevelSet.h"

#define PTM_RATIO 32.0

@interface LevelMgr()
@property (readwrite,copy) NSArray *levelSets;
@property (readwrite) CCGLView *glView;
@end

@implementation LevelMgr

+ (LevelMgr*)getLevelMgr {
    static LevelMgr *levelMgr;
    
    @synchronized(self)
    {
        if (!levelMgr) {
            levelMgr = [[LevelMgr alloc] init];
            
            [levelMgr loadLevels];
            levelMgr.currentSet = -1;
        }
        
        return levelMgr;
    }
}

+(LevelSet*)getLevelSet: (int) index {
    return [[LevelMgr getLevelMgr].levelSets objectAtIndex:index];
}

+(Level*)getLevel: (int) set levelId:(NSString*) levelId {
    return [[LevelMgr getLevelSet:set].levels objectForKey:levelId];
}

-(void)loadLevels {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSError *error;
    
    NSDictionary *levels = [[NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:@"levels.json"] encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];
    
    if (levels == nil) {
        [NSException raise:@"Invalid levels definition" format:@"The levels definition file levels.json is invalid JSON"];
    }
    
    NSMutableArray *sets = [NSMutableArray arrayWithCapacity:[levels count]];
    for(id key in levels) {
        NSDictionary *set = [levels objectForKey:key];
        NSArray *setLevels = [set objectForKey:@"levels"];
        NSMutableArray *levelIds = [NSMutableArray arrayWithCapacity:[set count]];
        NSMutableDictionary *levelObjs = [NSMutableDictionary dictionaryWithCapacity:[set count]];
        for (int i = 0; i < [setLevels count]; i++) {
            NSString *file = [setLevels objectAtIndex:i];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:file]]) {
                [NSException raise:@"Invalid levels definition" format:@"The file %@ referenced from levels.json doesn't exist.", file];
            }
            NSString *jsonString = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
            NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
            
            Level *level = [[Level alloc] initWithJson:jsonString fileName:file fileDate:fileDate levelId:i];
            [levelObjs setObject:level forKey:level.levelId];
            [levelIds addObject:level.levelId];
        }
        
        [sets addObject:[[LevelSet alloc] initWithNameAndLevels:[set objectForKey:@"name"]
                                                       levelIds:[self sortLevelsInSet:levelIds]
                                                         levels:levelObjs
                                                          index:[[set objectForKey:@"index"] intValue]
                                                      imageName:[set objectForKey:@"image"]]];
    }
    
    self.levelSets = [self sortLevelSets:sets];
}

-(NSArray *)sortLevelSets: (NSArray*) sets {
    return [sets sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
        int i1 = ((LevelSet*)obj1).index;
        int i2 = ((LevelSet*)obj2).index;
        if (i1 > i2) {
            return NSOrderedDescending;
        } else if (i1 < i2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

-(NSArray *)sortLevelsInSet: (NSArray*) levels {
    return [levels sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
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

-(void)setupCocos2D: (CGRect) bounds {
    if (_hasInit) {
        return;
    }
    
    CCGLView *glView = [CCGLView viewWithFrame:bounds
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    glView_ = glView;
    self.glView = glView_;
    
	[glView setMultipleTouchEnabled:YES];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	[director_ setProjection:kCCDirectorProjection2D];
	
	if (![director_ enableRetinaDisplay:YES]) {
		CCLOG(@"Retina Display Not supported");
    }
	
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
    _hasInit = true;
}

/**
 * This method looks for the images for each level.  If the image is there and up to date
 * then we load the icon and set it as a field in the level.  If the image isn't there or 
 * is out of date then we add it to the array of level images to load and call the doDrawLevels
 * method.
 */
-(void)drawLevels:(CGRect) bounds {
    [self setupCocos2D:bounds];
    
    NSMutableArray *levels = [NSMutableArray arrayWithCapacity:20];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if([paths count] > 0) {
        for (LevelSet* set in self.levelSets) {
            for (NSString* levelId in set.levelIds) {
                Level *level = (Level*) [set.levels objectForKey:levelId];
                
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"level%@.png", level.levelId]];
                
                NSError *error;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                    NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
                    
                    if ([level.date compare:fileDate] == NSOrderedDescending) {
                        [levels addObject:level];
                    } else {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        
                        dispatch_async(queue, ^{
                            level.screenshot = [UIImage imageWithContentsOfFile:path];
                        });
                    }
                } else {
                    [levels addObject:level];
                }
            }
        }
    }

    if ([levels count] > 0) {
        /*
         * Then we have some levels that still need screenshots.  We'll draw
         * them in a different thread so we don't slow down the UI.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doDrawLevels:bounds levels:levels];
        });
        
    }
}

/**
 * This method actually draws the screen shots for each level as needed so it
 * can load show them in the menu screens.
 */
-(void)doDrawLevels:(CGRect) bounds levels:(NSMutableArray*) levels {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);        
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"bridgesprites.plist"];
    
    // Create our sprite sheet and frame cache
    CCSpriteBatchNode *spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"bridgesprites.pvr.gz"
                                       capacity:200] retain];
    
    LayerMgr *layerMgr = [[LayerMgr alloc] initWithSpriteSheet:spriteSheet world:nil];
    layerMgr.addBoxes = false;
    
    CGSize s = CGSizeMake(IPHONE_LEVEL_IMAGE_W, IPHONE_LEVEL_IMAGE_H);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        s = CGSizeMake(IPAD_LEVEL_IMAGE_W, IPAD_LEVEL_IMAGE_H);
    }
    
    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:s.width height:s.height];
    
    for (Level* level in levels) {
        ScreenShotLayer *scene = [[ScreenShotLayer alloc] init];
        
        [scene addChild:spriteSheet];
        
        layerMgr.tileSize = CGSizeMake(bounds.size.height / level.tileCount, bounds.size.height / level.tileCount);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", level.fileName]];
        
        /*
         * This is the place where we actually render the image using the screen shot
         * layer.  We need to be really careful here because there's a memory leak in
         * CCRenderTexture.  It should be releasing the memory after we're done with it,
         * but it never does.  This means we need to create a CCRenderTexture with the 
         * smallest bounds we can.  
         *
         * To make that work we create a renderable area the size of the thumbnail we
         * want to create and then we scale our scene down so that it fits that image.
         *
         * Bug 1439 has been logged for this memory leak: 
         * http://code.google.com/p/cocos2d-iphone/issues/detail?id=1439
         */
        [level addSprites:layerMgr view:nil];
        scene.scale = s.height/bounds.size.height;
        scene.position = ccp(0,0);
        scene.anchorPoint = ccp(0, 0);
        
        [renderer beginWithClear:0 g:0 b:0 a:0];
        [scene visit];
        [renderer end];
        
        UIImage *image = [renderer getUIImage];
        level.screenshot = image;
        [UIImagePNGRepresentation(level.screenshot) writeToFile:path atomically:NO];
        
        [level unloadSprites];
        [[CCTextureCache sharedTextureCache] removeUnusedTextures];
        
        [[CCDirector sharedDirector] purgeCachedData];
        
        [scene release];
    }
    
    [CCTextureCache purgeSharedTextureCache];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    
    [spriteSheet release];
    [layerMgr release];
}

-(void)dealloc {
    
    [self.levelSets release];
    self.levelSets = nil;
    
    [super dealloc];
    
}

@end
