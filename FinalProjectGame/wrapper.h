//
//  wrapper.h
//  FinalProjectGame
//
//  Created by Jared Earl on 4/28/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

#ifndef wrapper_h
#define wrapper_h
#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>




//objective c wrapper header for api
@interface API: NSObject

//functions
-(void)printHelloWorldFromCPP;
-(double)calcDistanceMoved:(double)timeElapsed :(double)speed;
-(bool)isCollision:(double)x1 :(double)y1 :(double)x2 :(double)y2 :(double)radius1 :(double)radius2;
-(NSMutableArray *)checkPlayerHits:(CGPoint)player :(CGPoint[])badGuys :(int)size;
-(NSMutableArray *)checkBullets:(CGPoint[])badGuys :(CGPoint[])bullets :(int)badGuySize :(int)bulletsSize;
-(NSMutableArray *)checkBadGuys:(CGPoint[])badGuys :(CGPoint[])bullets :(int)badGuySize :(int)bulletsSize;
-(int)calcHealth:(int)curHealth :(int)diff;
-(int)calcNewScore:(int)score :(int)diff;
-(NSMutableArray *)moveBullets:(CGPoint[])bullets :(int)size :(double)distance;
-(NSMutableArray *)moveBadGuys:(CGPoint[])badGuys : (int)size :(double)distance :(double)heightLimit :(double)widthLimit;
-(CGPoint)movePlayer:(CGPoint)player :(double)distance :(int)buttonPressed :(double)maxHeight :(double)maxWidth;

@end

#endif /* wrapper_h */
