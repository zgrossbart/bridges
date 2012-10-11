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

-(id)initWithFrame: (CGRect) frame: (NSMutableArray*) rivers: (BOOL) vert {

    if ((self=[super init] )) {
        self.frame = frame;
        self.rivers = rivers;
        self.vert = vert;
        
        [self createRiverImage];
    }
    
    return self;
}

-(void)createRiverImage {
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
    
    CCRenderTexture *renderer	= [CCRenderTexture renderTextureWithWidth:self.frame.size.width height:self.frame.size.height];
    
    ScreenShotLayer *scene = [[ScreenShotLayer alloc] init];
    
    [scene addChild:spriteSheet];
    
    CGPoint pos = ((CCSprite*) [self.rivers objectAtIndex:0]).position;
    
    for (CCSprite *river in self.rivers) {
        [layerMgr addChildToSheet:river];
        
        if (self.vert) {
            river.position = ccp((river.contentSize.width / 2) - 0.5, river.position.y + 1);
        } else {
            river.position = ccp(river.position.x + 1, (river.contentSize.height / 2) - 0.5);
        }
    }
    
    [renderer begin];
    [scene visit];
    [renderer end];
    
    UIImage *image = [renderer getUIImage];
    //[image imageByScalingAndCroppingForSize:self.frame.size];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"river_%@_%f_%f.png",
                                                                         self.vert ? @"v" : @"h",
                                                                         self.frame.size.width, self.frame.size.height]];
    
    //NSLog(@"path: %@", path);
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
    [spriteSheet release];
    [scene dealloc];
    
    [layerMgr release];
    
    [self.rivers removeAllObjects];
    
    CCSprite *sprite = [CCSprite spriteWithFile:path];
    if (self.vert) {
        sprite.position = ccp(pos.x, pos.y + (sprite.contentSize.height / 2));
    } else {
        sprite.position = ccp(pos.x + (sprite.contentSize.width / 2), pos.y);
    }
    
    [self.rivers addObject:sprite];
}

-(bool)contains: (CCSprite*) river {
    return [self.rivers containsObject:river];
}

@end
