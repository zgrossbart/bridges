#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"
#import "GameNode.h"

@interface HouseNode : NSObject <GameNode> {
@private
    int _tag;
    LayerMgr *_manager;
    
}

-(id)initWithColor:(int) tag:(int) color:(LayerMgr*) layerMgr;

-(void)visit;
-(bool)isVisited;
-(void)setHousePosition:(CGPoint)p;
-(CGPoint)getHousePosition;
-(int)tag;

@property (readonly, retain) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readonly) bool visited;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, setter=position:) CGPoint position;
@property (readonly) LayerMgr *layerMgr;

@end