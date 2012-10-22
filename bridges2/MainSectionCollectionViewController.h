//
//  MainSectionCollectionViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 10/22/12.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface MainSectionCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (id)initWithNibNameAndMenuView:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menu:(MainMenuViewController*) menuView;

@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) IBOutlet UIButton *backBtn;
- (IBAction)backBtnTapped:(id)sender;

@end
