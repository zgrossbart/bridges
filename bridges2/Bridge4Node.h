#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"
#import "GameNode.h"

@interface Bridge4Node : CCLayer <GameNode> {
    int _tag;
    
}

-(id)initWithTagAndColor: (int) tag:(int) color:(LayerMgr*) layerMgr;

-(void)cross;
-(bool)isCrossed;
-(void)setBridgePosition:(CGPoint)p;
-(CGPoint)getBridgePosition;
-(int)tag;

@property (readonly, retain) CCSprite *bridge;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;
@property (readonly) LayerMgr *layerMgr;

@end