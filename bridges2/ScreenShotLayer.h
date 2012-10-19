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

#import "cocos2d.h"

#define PTM_RATIO 32.0

/** 
 * The screen shot layer is a simple scene used when drawing
 * layer screen shots.  It's primary functions is to make sure 
 * our scene has a clear background.
 */
@interface ScreenShotLayer : CCNode {
    
@private
    
}

/** 
 * The size of the screen shot image to draw.
 */
@property (nonatomic, readwrite) CGRect bounds;


@end