version "4.0"

#include "zscript/libeye/projector.txt"
#include "zscript/libeye/projector gl.txt"
#include "zscript/libeye/projector planar.txt"
#include "zscript/libeye/viewport.txt"

#include "zscript/powersuit/suitcore.zs" //movement, interaction
#include "zscript/powersuit/suitweapons.zs" //weapon base actor, #includes other weapons
#include "zscript/powersuit/suitarmor.zs" //special armor class for powersuit
#include "zscript/powersuit/controller.zs" //interface for control; damage overriding
#include "zscript/powersuit/maintenance.zs" //suit maintenance interface
#include "zscript/powersuit/miscactors.zs" //misc actors
#include "zscript/powersuit/spawning.zs" //spawning powersuit and shit
#include "zscript/powersuit/libeyehandler.zs" //libeye thing
