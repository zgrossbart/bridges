//
//  RiverNode.m
//  Cocos2DSimpleGame
//
//  Created by Zack Grossbart on 8/19/12.
//
//

#import "HouseNode.h"
#import "BridgeColors.h"

@interface HouseNode()
@property (readwrite, retain) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readwrite) bool visited;
@property (nonatomic, assign, readwrite) int color;
@property (readwrite) LayerMgr *layerMgr;
@property (nonatomic, assign, readwrite) int tag;
@end

@implementation HouseNode

-(id)initWithColor:(int) tag:(int) color:(LayerMgr*) layerMgr {
    if( (self=[super init] )) {
        self.layerMgr = layerMgr;
        self.tag = tag;
        self.visited = false;
        self.color = color;
        [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:[self getSpriteName]]];
    }
    
    return self;
}

-(NSString*)getSpriteName {
    if (self.color == RED) {
        return @"house_red.png";
    } else if (self.color == BLUE) {
        return @"house_blue.png";
    } else if (self.color == GREEN) {
        return @"house_green.png";
    } else if (self.color == ORANGE) {
        return @"house_orange.png";
    } else {
        return @"house.png";
    }
}

-(void)undo {
    if (self.isVisited) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        frame = [cache spriteFrameByName:[self getSpriteName]];
        [self.house setDisplayFrame:frame];
        self.visited = false;
    }
}

- (void) addSprite {
    [self.layerMgr addChildToSheet:self.house];
}

-(void)setHouseSprite:(CCSprite*)house {
    self.house = house;
    self.house.tag = [self tag];
}

-(void)position:(CGPoint)p {
    super.position = p;
    self.house.position = ccp(p.x, p.y);
}

-(void)visit {
    if (!self.visited) {
        CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame* frame;
        frame = [cache spriteFrameByName:@"house_gray.png"];
        [self.house setDisplayFrame:frame];
    }
    self.visited = true;
}

-(void)setHousePosition:(CGPoint)p {
    self.house.position = ccp(p.x, p.y);
}

-(CGPoint)getHousePosition {
    return self.house.position;
}

-(void)dealloc {
    
    [self.house dealloc];
    [super dealloc];
}

@end
