#import "MindColorKeeper.h"

@implementation MindColorKeeper : NSObject 

static bool mindColorOn;

+(bool)getMindColor
{
    return mindColorOn;
}

+(void)setMindColor: (bool)value
{
    mindColorOn = value;
}

@end