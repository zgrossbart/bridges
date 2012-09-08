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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface Level : NSObject {

    
}

-(id) initWithJson:(NSString*) jsonString: (NSDate*) date;
-(void) addSprites: (LayerMgr*) layerMgr:(UIView*) view;
-(void) removeSprites:(LayerMgr*) layerMgr;
-(bool)hasWon;
-(NSArray*) controls;
-(bool)hasCoins;

@property (readonly) NSMutableArray *rivers;
@property (readonly) NSMutableArray *bridges;
@property (readonly) NSMutableArray *bridge4s;
@property (readonly) NSMutableArray *houses;
@property (readonly) NSMutableArray *labels;
@property (readonly, copy) NSDictionary *levelData;

@property (readonly) NSString *name;
@property (readonly) NSDate *date;
@property (readonly) NSString *levelId;
@property (readonly) CGPoint playerPos;

@property (readonly) LayerMgr *layerMgr;

@end


