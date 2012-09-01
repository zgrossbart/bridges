//
//  RootMenuViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface RootMenuViewController : UIViewController<CCDirectorDelegate> {
    UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction)goHomeTapped:(id)sender;

@property (nonatomic, retain) NSString *currentLevelPath;

@end
