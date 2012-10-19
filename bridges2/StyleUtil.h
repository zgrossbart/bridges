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

/**
 * Style util is a simple class with utilities for styling
 * various UI controls.
 */
@interface StyleUtil : NSObject

/**
 * Style a button in the application.
 *
 * @param button the button to style
 */
+(void)styleButton:(UIButton*) button;

/**
 * Style a button in the application that's used as a navigation button
 * on one of the main game screens.
 *
 * @param button the button to style
 */
+(void)styleMenuButton:(UIButton*) button;

/**
 * Style a label that shows extra information about a node.
 *
 * @param label the label to style
 */
+(void)styleNodeLabel:(UILabel*) label;

@end
