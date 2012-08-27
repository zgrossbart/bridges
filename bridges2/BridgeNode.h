#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface BridgeNode : CCLayer {
    int _tag;
    bool _vertical;
    
}

-(id)initWithDir: (bool)vertical:(int) tag:(int) color:(LayerMgr*) layerMgr;

-(void)cross;
-(bool)isCrossed;
-(void)setBridgePosition:(CGPoint)p;
-(CGPoint)getBridgePosition;
-(int)tag;

@property (readonly) bool vertical;
@property (readonly) CCSprite *bridge;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;

@end