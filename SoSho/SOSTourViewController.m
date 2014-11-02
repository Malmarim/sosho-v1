//
//  SOSTourViewController.m
//  
//
//  Created by Mikko Malmari on 1.11.2014.
//
//

#import "SOSTourViewController.h"

@interface SOSTourViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tourImage;
@property (strong, nonatomic) NSArray *images;
@property (nonatomic) int index;

@end

@implementation SOSTourViewController

- (IBAction)setPrevious:(id)sender {
    if(self.index > 0){
        self.index--;
        [self setCurrentImage];
    }
}

- (IBAction)setNext:(id)sender {
    if(self.index < [self.images count]-1){
        self.index++;
        [self setCurrentImage];
    }else{
        [self performSegueWithIdentifier:@"tourtoitem" sender:self];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [NSArray arrayWithObjects:[UIImage imageNamed:@"tour1.jpg"], [UIImage imageNamed:@"tour2.jpg"], [UIImage imageNamed:@"tour3.jpg"], [UIImage imageNamed:@"tour4.jpg"], [UIImage imageNamed:@"tour5.jpg"], nil];
    
    self.index = 0;
    [self.tourImage setImage:[self.images objectAtIndex:self.index]];
    
    // Do any additional setup after loading the view.
}

- (void)setCurrentImage{
    [self.tourImage setImage:[self.images objectAtIndex:(NSUInteger)self.index]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
