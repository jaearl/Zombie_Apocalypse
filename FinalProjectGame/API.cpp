//
//  API.cpp
//  FinalProjectGame
//
//  Created by Jared Earl on 4/28/18.
//  Copyright © 2018 Jared Earl. All rights reserved.
//

#include "API.hpp"



/**
 This is the implementation for the CAPI
 */
void CAPI::printHelloWorld() {
    std::cout << "Hello World I work!!.\n";
}

//calculates the distance moved
double CAPI::calcDistanceMoved(double timeElapsed, double speed) {
    return timeElapsed * speed;
}

//checks for a collision
bool CAPI::isCollision(double x1, double y1, double x2, double y2, double radius1, double radius2) {
    double distance = sqrt(((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)));
    double sum = radius1 + radius2;
    
    return distance < sum;
}

//given the information checks player hits and returns
vector<CPoint> CAPI::checkPlayerHits(CPoint player, vector<CPoint> badGuys) {

    vector<CPoint> newBadGuys;
    for(int i = 0; i < badGuys.size(); i++){
        if(!isCollision(badGuys[i].x, badGuys[i].y, player.x, player.y,playerRadius, badGuyRadius)) {
            newBadGuys.push_back(badGuys[i]);
        }
    }
    
    return newBadGuys;
}

//calculates the new health based on the current health and the difference in bad guys
int CAPI::calcHealth(int curHealth, int diff) {
    
    for(int i = 0; i < diff; i++) {
        if (curHealth > 0) {
            curHealth -= 20;
        }
    }

    return curHealth;
}

//returns a new set of bullets after checking for collisions
vector<CPoint> CAPI::checkBullets(vector<CPoint> badGuys, vector<CPoint> bullets) {
    vector<CPoint> newBullets = bullets;
    vector<CPoint> bulletsToBeDeleted;
    for(int i = 0; i < bullets.size(); i++){
        for(int j = 0; j < badGuys.size(); j++){
            if(isCollision(badGuys[j].x, badGuys[j].y, bullets[i].x, bullets[i].y, bulletRadius, badGuyRadius)) {
                bulletsToBeDeleted.push_back(bullets[i]);
            }
        }
    }
    
    for(int i = 0; i < bulletsToBeDeleted.size(); i++){
        CPoint point = bulletsToBeDeleted[i];
        for(int j = 0; j < newBullets.size(); j++){
            if(point == newBullets[j]) {
                newBullets.erase(newBullets.begin() + j);
                break;
            }
        }
    }
    
    return newBullets;
}

//returns a new set of bad guys after checking for collisions
vector<CPoint> CAPI::checkBadGuys(vector<CPoint> badGuys, vector<CPoint> bullets) {
    vector<CPoint> newBadGuys = badGuys;
    vector<CPoint> badGuysToBeDeleted;
    for(int i = 0; i < bullets.size(); i++){
        for(int j = 0; j < badGuys.size(); j++){
            if(isCollision(badGuys[j].x, badGuys[j].y, bullets[i].x, bullets[i].y, bulletRadius, badGuyRadius)) {
                badGuysToBeDeleted.push_back(badGuys[j]);
            }
        }
    }
    
    for(int i = 0; i < badGuysToBeDeleted.size(); i++){
        CPoint point = badGuysToBeDeleted[i];
        for(int j = 0; j < newBadGuys.size(); j++){
            if(point == newBadGuys[j]) {
                newBadGuys.erase(newBadGuys.begin() + j);
                break;
            }
        }
    }
    return newBadGuys;
}

//calculates a new score based on the current score and difference
int CAPI::calcNewScore(int score, int diff) {
    return score + diff;
}

//moves the given bullets the given distance
vector<CPoint> CAPI::moveBullets(vector<CPoint> bullets, double distance) {
    vector<CPoint> newBullets;
    
    for(int i = 0; i < bullets.size(); i++){
        bullets[i].y -= 2;
        if (bullets[i].y > 0) {
            newBullets.push_back(bullets[i]);
        }
    }
    
    return newBullets;
}

//moves the given bad guys the given distance
vector<CPoint> CAPI::moveBadGuys(vector<CPoint> badGuys, double distance, double heightLimit, double widthLimit) {
    
    vector<CPoint> newBadGuys;
    
    for(int i = 0; i < badGuys.size(); i++){
        if(i%2 == 0) {
            badGuys[i].x -= distance/2.0;
        }
        else if(i%3 == 0) {
            badGuys[i].x += distance/2.0;
        }
        badGuys[i].y += distance;
        
        if(badGuys[i].y < heightLimit && badGuys[i].x > 0 && badGuys[i].x < widthLimit) {
            newBadGuys.push_back(badGuys[i]);
        }
    }
    
    return newBadGuys;
}


//moves the player the given distance in the direction of the button pressed
//1 = up, 2 = down, 3 = left, 4 = right, 5 = fire, 6 = none
CPoint CAPI::movePlayer(CPoint player, double distance, int buttonPressed, double maxHeight, double maxWidth) {
    
    if (buttonPressed != 6 && buttonPressed != 5){
        if (buttonPressed == 2) {
            if (player.y + distance < maxHeight){
                player.y += distance;
            }
        }
        else if (buttonPressed == 1){
            if (player.y - distance > 0) {
                player.y -= distance;
            }
        }
        else if (buttonPressed == 3) {
            if (player.x - distance > 0) {
                player.x -= distance;
            }
        }
        else if (buttonPressed == 4) {
            if (player.x + distance < maxWidth) {
                player.x += distance;
            }
        }
        else {
            printf("something went wrong with moving the player");
        }
    }
    
    return player;
}


































