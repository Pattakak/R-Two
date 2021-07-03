#ifndef CAMERA_H
#define CAMERA_H

#include <glm/glm.hpp>
#include <math.h>

// Default fov, 90 deg
#define CAM_DEFAULT_FOV 90.0f
#define CAM_SENSITIVITY (.3f / 180.0f * M_PI)

using namespace glm;

// IMPORTANT: 
// The coordinates are done in a right hand system
// This means that we can see the x direction as right,
// y as up, and z as out of the screen
// Pitch being at 0 will make the camera direction perpendicular to the y axis
// Yaw being 0 means that it stares at the +x direction
// Increasing in yaw makes you turn right, so a yaw at 
// +90 degrees is looking towards the +z direction

class Camera {
    public:
    Camera();
    Camera(float x, float y, float z, float pitch, float yaw);
    Camera(float x, float y, float z, float pitch, float yaw, float roll, float fov);
    void updateDirection();
    void addOrient(float pitchdif, float yawdif);

    vec3 pos;  
    vec3 dir;
    vec3 up;
    vec3 right;
    float fov;
    float pitch, yaw, roll;
};

#endif 