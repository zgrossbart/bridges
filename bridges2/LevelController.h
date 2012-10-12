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

/** 
 * The level control protocol defines the controller which interacts
 * with the level layer.
 */
@protocol LevelController <NSObject>
@required

/**
 * Called when the user has won the level.  This method hides the level
 * scene and takes the user to the you won view.
 */
-(void) won;

/**
 * Shows a message at the bottom of the screen.  These messages are mostly 
 * used for warnings when you try to interact with an object in a way that's
 * against the rules.
 */
-(void) showMessage: (NSString*) msg;

@end