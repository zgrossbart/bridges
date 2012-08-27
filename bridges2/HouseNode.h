#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface HouseNode : CCLayer {
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

@property (readonly) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readonly) bool visited;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, setter=position:) CGPoint position;

@end