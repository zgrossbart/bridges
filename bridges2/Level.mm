//
//  Level.m
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import "Level.h"
#import "BridgeColors.h"
#import "BridgeNode.h"
#import "HouseNode.h"

@interface Level()
@property (readwrite) NSMutableArray *rivers;
@property (readwrite) NSMutableArray *bridges;
@property (readwrite) NSMutableArray *houses;
@property (readwrite) LayerMgr *layerMgr;
@end

@implementation Level

-(id) initWithJson:(NSString*) jsonString: (LayerMgr*) layerMgr
{
    if( (self=[super init] )) {
        self.bridges = [[NSMutableArray alloc] init];
        self.rivers = [[NSMutableArray alloc] init];
        self.houses = [[NSMutableArray alloc] init];
        
        self.layerMgr = layerMgr;
    }
    
    return self;
    
}

- (CCSprite*)addRiver:(int) x:(int) y:(bool) vert {
    
    CCSprite *river;
    if (vert) {
        river = [CCSprite spriteWithSpriteFrameName:@"river_h.png"];
    } else {
        river = [CCSprite spriteWithSpriteFrameName:@"river_v.png"];
    }
    
    [self resizeSprite:river:1];
    CGPoint startPos = [self tileToPoint:x:y];
    
    printf("addingRiverTo (%f, %f)\n", startPos.x, startPos.y);
    
    river.position = startPos;
    river.tag = RIVER;
    
    [self.rivers addObject:river];
    
    return river;
    
}

- (BridgeNode*)addBridge:(int) x:(int) y:(bool) vertical:(int) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    BridgeNode *bridgeNode = [[BridgeNode alloc] initWithDir:vertical:BRIDGE:color:_layerMgr];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [bridgeNode setBridgePosition:startPos];
    
    [self.bridges addObject:bridgeNode];
    
    return bridgeNode;
    
}

-(HouseNode*)addHouse:(int) x:(int) y:(int) color {
    
    //   CCSprite *bridge = [CCSprite spriteWithSpriteFrameName:@"bridge_v.png"];
    
    HouseNode *houseNode = [[HouseNode alloc] initWithColor:HOUSE:color:_layerMgr];
    CGPoint startPos = [self tileToPoint:x:y];
    
    [houseNode setHousePosition:startPos];
    
    [self.houses addObject:houseNode];
    
    return houseNode;
    
}

-(CGSize)getWinSize {
    //CGRect r = [[UIScreen mainScreen] bounds];
    //return r.size;
    return [[CCDirector sharedDirector] winSize];
}

-(void)resizeSprite:(CCSprite*) sprite: (int) tiles {
    sprite.scale = self.layerMgr.tileSize.width/sprite.contentSize.width;
    sprite.contentSize = self.layerMgr.tileSize;
    
}

-(CGSize)winSizeTiles {
    CGSize winSize = [self getWinSize];
    return CGSizeMake(winSize.width / self.layerMgr.tileSize.width,
                      winSize.height / self.layerMgr.tileSize.height);
}

-(CGPoint)tileToPoint:(int) x: (int)y {
//    printf("tileToPoint (%i, %i)\n", x, y);
//    printf("tileSize (%f, %f)\n", self.layerMgr.tileSize.width, self.layerMgr.tileSize.height);
    return CGPointMake(x * self.layerMgr.tileSize.width,
                       y * self.layerMgr.tileSize.height);
}

-(void)dealloc {
    
    [_rivers release];
    _rivers = nil;
    
    [_bridges release];
    _bridges = nil;
    
    [_houses release];
    _houses = nil;
    
    [super dealloc];
}

@end
