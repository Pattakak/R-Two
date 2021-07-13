#include "camera.h"
#include <stdio.h>

Camera::Camera() {
    *this = Camera(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, CAM_DEFAULT_FOV);
}

Camera::Camera(float x, float y, float z, float pitch, float yaw) {
    *this = Camera(x, y, z, pitch, yaw, 0.0f, CAM_DEFAULT_FOV);
}

Camera::Camera(float x, float y, float z, float pitch, float yaw, float roll, float fov) :
fov(fov), pitch(pitch), yaw(yaw), roll(roll) {
    this->pos = vec3(x, y, z);
    updateDirection();    
}

void Camera::updateDirection() {
    float dir_x = cos(yaw) * cos(pitch);
    float dir_y = sin(pitch);
    float dir_z = sin(yaw) * cos(pitch);

    dir = vec3(dir_x, dir_y, dir_z);

    float right_x = -sin(yaw) * cos(roll); 
    float right_y = sin(roll);
    float right_z = cos(yaw) * cos(roll);

    right = vec3(right_x, right_y, right_z);

    up = cross(right, dir); 
}

void Camera::moveDirection(float forward, float sideways, float vertical) {
    pos.x += forward * cos(yaw) + sideways * sin(yaw);
    pos.z += forward * sin(yaw) - sideways * cos(yaw);
    pos.y += vertical;

    #if 0
    printf("(x,y,z) = %f %f %f\n", pos.x, pos.y, pos.z);
    #endif 
}

void Camera::addOrient(float pitchdif, float yawdif, float rolldif) {
    pitch += pitchdif;
    if (pitch > M_PI_2) pitch = M_PI_2;
    else if (pitch < - M_PI_2) pitch = -M_PI_2;

    yaw += yawdif;
    roll += rolldif;

    updateDirection();
    #if 0
    printf("(p, y) = %f %f\n", this->pitch * 180.0f / M_PI, this->yaw * 180.0f / M_PI);
    printf("Dir: %f %f %f\n", dir.x, dir.y, dir.z);
    printf("Up : %f %f %f\n", up.x, up.y, up.z);
    printf("Rht: %f %f %f\n", right.x, right.y, right.z);
    printf("\n");
    #endif
    
}