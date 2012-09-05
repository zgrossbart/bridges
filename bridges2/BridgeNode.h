#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"
#import "GameNode.h"

@interface BridgeNode : NSObject <GameNode> {
    int _tag;
    bool _vertical;
    
}

-(id)initWithOrient: (bool)vertical:(int) tag:(int) color:(LayerMgr*) layerMgr;

-(id)initWithOrientAndDir: (bool)vertical:(int)dir: (int) tag:(int) color:(LayerMgr*) layerMgr;

-(void)cross;
-(bool)isCrossed;
-(void)setBridgePosition:(CGPoint)p;
-(CGPoint)getBridgePosition;
-(int)tag;

@property (readonly) bool vertical;
@property (readonly) int direction;
@property (readonly, retain) CCSprite *bridge;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;
@property (readonly) LayerMgr *layerMgr;

@end