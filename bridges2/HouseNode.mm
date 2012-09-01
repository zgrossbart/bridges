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
@property (readwrite) CCSprite *house;
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
        if (color == RED) {
            [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:@"house_red.png"]];
        } else if (color == BLUE) {
            [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:@"house_blue.png"]];
        } else if (color == GREEN) {
            [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:@"house_green.png"]];
        } else if (color == BLACK) {
            [self setHouseSprite:[CCSprite spriteWithSpriteFrameName:@"house.png"]];
        }
    }
    
    return self;
}

- (void) addSprite {
    [self.layerMgr addChildToSheet:self.house];
}

-(void)setHouseSprite:(CCSprite*)house {
    self.house = house;
    self.contentSize = CGSizeMake(self.house.contentSize.width,
                                  self.house.contentSize.height);
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
