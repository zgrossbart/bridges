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

#import "ScreenShotLayer.h"

@implementation ScreenShotLayer

-(id)init {
    
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
    }
    
    return self;
}

-(void)draw {
    
    [super draw];
    
    ccDrawSolidRect( ccp(0, 0), ccp(self.bounds.size.width, self.bounds.size.height), ccc4f(255, 255, 255, 255) );
}
@end
