//
//  MainSectionViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface MainSectionViewController : UIViewController {
    
}

- (id)initWithNibAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*)menuView index:(int)index;

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIButton *playBtn;
- (IBAction)playTapped:(id)sender;

@end
