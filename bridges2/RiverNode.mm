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

#import "BridgeColors.h"
#import "RiverNode.h"
#import "ScreenShotLayer.h"
#import "LayerMgr.h"
#import "UIImageExtras.h"

@interface RiverNode()

@property (readwrite) CGRect frame;
@property (readwrite, retain) NSMutableArray *rivers;
@property (readwrite) BOOL vert;

@end

@implementation RiverNode

-(id)initWithFrame: (CGRect) frame: (NSMutableArray*) rivers: (BOOL) vert: (int) side {

    if ((self=[super init] )) {
        self.frame = frame;
        self.rivers = rivers;
        self.vert = vert;
        
        //[self createRiverImage:side];
    }
    
    return self;
}

+(NSString*)getFullRiverFileName: (BOOL) vert: (int) side: (float) width: (float) height: (NSDate*) date {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[RiverNode getRiverFileName:vert:side:width:height]];
    NSError *error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
        
        if ([date compare:fileDate] == NSOrderedDescending) {
            return path;
        } else {
            return nil;
        }
    } else {
        return path;
    }
    
}

+(NSString*)getRiverFileName: (BOOL) vert: (int) side: (float) width: (float) height {
    return [NSString stringWithFormat:@"river_%@_%d_%f_%f.png", vert ? @"v" : @"h",
            side, width, height];
    
}

-(void)createRiverImage: (int) side {
    if ([self.rivers count] < 2) {
        /*
         * If there's only one sprite then there's nothing
         * to optimize.
         */
        return;
    }
    
    CCSpriteBatchNode *spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"bridgesprites.pvr.gz"
                                                                  capacity:200] retain];
    LayerMgr *layerMgr = [[LayerMgr alloc] initWithSpriteSheet:spriteSheet:nil];
    layerMgr.addBoxes = false;
    
    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:self.frame.size.width height:self.frame.size.height];
    
    ScreenShotLayer *scene = [[ScreenShotLayer alloc] init];
    
    [scene addChild:spriteSheet];
    
    CGPoint pos = ((CCSprite*) [self.rivers objectAtIndex:0]).position;
    CGSize size = ((CCSprite*) [self.rivers objectAtIndex:0]).contentSize;
    
    for (CCSprite *river in self.rivers) {
        [layerMgr addChildToSheet:river];
        
        if (self.vert) {
            river.position = ccp((river.contentSize.width / 2) - 0.5, (river.position.y - pos.y) + (river.contentSize.height / 2));
        } else {
            river.position = ccp((river.position.x - pos.x) + (river.contentSize.width / 2), (river.contentSize.height / 2) - 0.5);
        }
    }
    
    [renderer begin];
    [scene visit];
    [renderer end];
    
    UIImage *image = [renderer getUIImage];
    //[image imageByScalingAndCroppingForSize:self.frame.size];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[RiverNode getRiverFileName:self.vert:side:self.frame.size.width:self.frame.size.height]];
    
    //NSLog(@"path: %@", path);
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    [spriteSheet release];
    [scene dealloc];
    
    [layerMgr release];
    
    [self.rivers removeAllObjects];
    
    CCSprite *sprite = [CCSprite spriteWithFile:path];
    sprite.tag = RIVER;
    if (self.vert) {
        sprite.position = ccp(pos.x, (pos.y + (sprite.contentSize.height / 2)) - (size.height / 2));
    } else {
        sprite.position = ccp((pos.x + (sprite.contentSize.width / 2)) - (size.width / 2), pos.y);
    }
    
    [self.rivers addObject:sprite];
}

-(bool)contains: (CCSprite*) river {
    return [self.rivers containsObject:river];
}

@end
