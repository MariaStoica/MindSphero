#import "SidebarViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)MindColorChanged:(id)sender
{
//    ViewController *vc = [[ViewController alloc] init];
//    vc.mindColorOn = self.mindColorSwitch.isOn;
//    NSLog(self.mindColorSwitch.isOn ? @"it's ON" : @"it's OFFFF");
//    [self.navigationController pushViewController:vc animated:NO];
    
    // pt metoda asta da pe side view controller editor > embed > navigation controller ca sa mearga
    // o sa deschida fereastra view controller in side view
    
    //[self performSegueWithIdentifier:@"mindColorSegue" sender:nil];
    
    [MindColorKeeper setMindColor:_mindColorSwitch.isOn];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSLog(@"prepareForSegue: %@", segue.identifier);
//    if([segue.identifier isEqualToString:@"mindColorSegue"]){
//        [segue.destinationViewController setMindColorOn:_mindColorSwitch.isOn];
//        
//        //ViewController *vc = [segue destinationViewController];
//        //vc.mindColorOn = _mindColorSwitch.isOn;
//        
//        //ViewController *vc = (ViewController *)[[navigationController viewControllers] objectAtIndex:0];
//
//    }
//}



@end