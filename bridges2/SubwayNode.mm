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

#import "SubwayNode.h"
#import "SimpleAudioEngine.h"

@interface SubwayNode()

@property (nonatomic, assign, readwrite) BridgeColor color;
@property (readwrite, assign) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@property (nonatomic, assign, readwrite) int coins;

@property (readwrite, retain) CCSprite *subway1;
@property (readwrite, retain) CCSprite *subway2;
@end

@implementation SubwayNode

-(id)initWithColor: (BridgeColor) color :(LayerMgr*) layerMgr {

    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = SUBWAY;
        self.color = color;
        [self setSubwaySprite1:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        [self setSubwaySprite2:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.subway1.scale = IPAD_SCALE_FACTOR;
            self.subway2.scale = IPAD_SCALE_FACTOR;
        }
    }
    
    return self;

}

-(void)setSubwaySprite1:(CCSprite*)subway {
    self.subway1 = subway;
    self.subway1.tag = [self tag];
}

-(void)setSubwaySprite2:(CCSprite*)subway {
    self.subway2 = subway;
    self.subway2.tag = [self tag];
}


-(NSString*)getSpriteName {
    if (self.color == cRed) {
        return @"subway_red.png";
    } else if (self.color == cBlue) {
        return @"subway_blue.png";
    } else if (self.color == cGreen) {
        return @"subway_green.png";
    } else if (self.color == cOrange) {
        return @"subway_orange.png";
    } else {
        return @"subway.png";
    }
}

-(void) addSprite {
    [self.layerMgr addChildToSheet:self.subway1];
    [self.layerMgr addChildToSheet:self.subway2];
}

-(NSArray*) controls {
    return [NSMutableArray arrayWithCapacity:0];
}

-(CCSprite*)ride: (CCSprite*) entry {
    [[SimpleAudioEngine sharedEngine] playEffect:@"RideSubway.m4a"];
    if (entry == self.subway1) {
        return self.subway2;
    } else if (entry == self.subway2) {
        return self.subway1;
    } else {
        [NSException raise:@"Invalid subway entry" format:@"The sprite %@ wasn't either side of this subway", entry];
        return nil;
    }
}

-(void) undo {
    /*
     * Nothing to do here
     */
}

-(void)dealloc {
    
    [self.subway1 release];
    [self.subway2 release];
    [super dealloc];
}


@end
