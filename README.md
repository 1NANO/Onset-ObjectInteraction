# Onset-ObjectInteraction
![alt text](https://i.ytimg.com/vi/uMztSGMqQF0/maxresdefault.jpg)

Video about the package:
https://www.youtube.com/watch?v=uMztSGMqQF0&

Hello everyone, this is the first Onset package that I made. Object Interaction is a package that lets you pick objects in order to move them around. You can also store them into your vehicle. Here are some of the functionalities:

* Fully customizable library *
The Object Interaction package was coded in a way that let you use some of its functions for your own package. You will be able to create new ways to play the game. It is also simple to configure and easy to add numerous new element, such as new object, new vehicle, new animation and more.

* Permission system *
The package has a built in way to deal with permission in a way that you can choose who has the right to interact with an object or a vehicle.

* Despawn system *
A despawn system has also been created to deal with the multiple object that might be abandoned on the ground. You will be able to configure the time that an object takes to despawn.

* Advanced interaction *
The "Advanced interaction system" is a system that only lets you do the action that are possible. Instead of having a menu with the all the possible action, it will automatically do the best action based around your surrounding. This can also be disabled or integrated into your own menu system.

* And more *
This is only the beginning of this package. I think there is a lot of possibilities for the future, as well as optimisation.

# Installation

Simply drag and drop the "ObjectInteraction" folder inside your server "packages" folder and update your server_config.json.

# !!!NOTE!!!
This package currently use dialogui in order to spawn random object and vehicle for testing purposes.

# Configuration and how to use of the package

### objectSettings.lua ###
This file let you configure all objects, vehicles and animations. Read the comments inside the file in order to know how to add new stuff.

### serverSettings.lua ###
This file let you configure a couple of option let the minimum distance needed to interact with an object or a vehicle aswell as the despawn system.

### clientSettings.lua ###
This file let you configure a couple of option for the client.

### exportedFunctions.lua ###
This file contains all the exported functions that can be used for other package.

### client.lua ###
Make sure to remove everything that is under the "ADMIN COMMAND" aswell as all the (TEMPORARY) stuff if the server is public

### server.lua ###
Make sure to remove everything that is under the "ADMIN COMMAND" if the server is public

# Admin command
These following function/command are inside the package only to add/modify object, vehicle and animation. You will see plenty of useless stuff aswell as command to directly change the position of the attached object. Use those command in order to add new stuff then delete all the lines that are in the "ADMIN COMMAND" section.

### How to add a new object ###
Get into the server, spawn the object and type /dim while being close to it in order to receive the size of that object. The value will be pasted into your server console so you will be able to copy and paste it into the objectSettings.lua file.

### How to add a new vehicle ###
Get into the server, spawn the vehicle and play with the following chat command:
/vw to change the width of the trunk
/vd to change the depth of the trunk
/vx to change the x offset of the trunk
/vy to change the y offset of the trunk
/vz to change the z offset of the trunk
/fill to fill the trunk with coca cola cans
/empty to empty the trunk

You will be able to copy and paste the value from the server console to the objectSettings.lua file

### How to add a new animation ###
Get into the server, spawn an object and pick it up. You can then play with these command:
/loopanim "animation" in order to loop an animation
/loopstop in order to stop the animation looping
/ox to change the object x offset
/oy to change the object y offset
/oz to change the object z offset
/orx to change the object rx rotation
/ory to change the object ry rotation
/orz to change the object rz rotation
/bone to change the bone that the object is attached to

You will be able to copy and paste the value from the server console to the objectSettings.lua file

# The futur of this package #
There is still a bunch of things that need more polishing in this package. If you have any ideas or things that could be better about the package, bugs or anything else, feel free to contact me on discord at NANO#9346.
