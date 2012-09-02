//
//  Undoable.h
//  bridges2
//
//  Created by Zack Grossbart on 9/2/12.
//
//

#import <Foundation/Foundation.h>
#import "GameNode.h"

@interface Undoable : NSObject

-(id) initWithPosAndNode:(CGPoint) pos:(id<GameNode>) node: (int) color;

@property (readonly) CGPoint pos;
@property (readonly, assign) id<GameNode> node;
@property (readonly) int color;

@end
