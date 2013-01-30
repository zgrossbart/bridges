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

#import "BridgeColors.h"
#import "RiverNode.h"
#import "ScreenShotLayer.h"
#import "LayerMgr.h"

@interface RiverNode()

@property (readwrite) CGRect frame;
@property (readwrite, retain) NSMutableArray *rivers;
@property (readwrite) BOOL vert;

@end

@implementation RiverNode

-(id)initWithFrame: (CGRect) frame rivers:(NSMutableArray*) rivers vert:(BOOL) vert side:(int) side {

    if ((self=[super init] )) {
        self.frame = frame;
        self.rivers = rivers;
        self.vert = vert;
    }
    
    return self;
}

-(bool)contains: (CCSprite*) river {
    return [self.rivers containsObject:river];
}

-(void)dealloc {
    
    self.rivers = nil;
    
    [super dealloc];
}

@end
