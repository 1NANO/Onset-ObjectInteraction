-- All vehicles that can hold object in their back
-- Following this pattern: {ModelID, "ModelName", width, depth, height, offsetX, offsetY, offsetZ, trunkOffset, needTrunkOpen}
vehiclesList = {
    {17, "Cargo_Truck_01", 240, 480, 125, 30, -120, 160, -500, false},
    {18, "Cargo_Truck_02", 240, 480, 125, 30, -120, 160, -500, false},
    {22, "Light_Cargo_01", 180, 240, 600, -40, -90, 105, -300, false},
    {23, "Light_Cargo_02", 180, 240, 600, -40, -90, 105, -300, false},
    {2, "Sedan_01_Taxi", 100, 60, 40, -205, -50, 50, -270, true}
}

-- All objects that can be held by a player
-- Following this pattern: {ModelID, "AnimationSet", SizeX, SizeY, SizeZ}
-- Note: Object size need to be hard coded since the server doesn't know about the model size and we cannot trust the client.
objectsList = {
    {1677, "Medium", 52.390625, 32.5625, 49.53564453125},
    {1620, "Medium", 51.171875, 71.6875, 20.12890625},
    {1617, "Medium", 44.78125, 71.09375, 25.340087890625},
    {1544, "Medium", 79.328125, 88.78125, 53.374267578125},
    {1449, "Medium", 257.53125, 87.71875, 105.03857421875},
    {1443, "Medium", 66.84375, 44.875, 30.481201171875},
    {1406, "Medium", 56.40625, 81.375, 118.67724609375},
    {1405, "Medium", 108.375, 131.09375, 190.55151367188},
    {1402, "Medium", 108.375, 205.0, 169.4423828125},
    {1395, "Medium", 233.328125, 33.234375, 61.021728515625},
    {1394, "Medium", 33.328125, 33.234375, 61.021728515625},
    {1256, "Medium", 42.890625, 34.96875, 100.0},
    {1176, "Medium", 35.890625, 36.0625, 79.851318359375},
    {1140, "Medium", 59.28125, 73.921875, 119.41381835938},
    {1132, "Medium", 68.34375, 76.265625, 95.91748046875},
    {1121, "Medium", 23.125, 22.75, 43.85888671875},
    {1056, "Medium", 75.21875, 94.53125, 77.36181640625},
    {1047, "Medium", 121.1875, 24.953125, 32.58837890625},
    {951, "Medium", 43.96875, 77.125, 14.13671875},
    {879, "Big", 155.359375, 156.34375, 302.95336914063},
    {795, "Medium", 22.96875, 17.328125, 10.396240234375},
    {731, "Medium", 69.140625, 71.84375, 120.62890625},
    {718, "Medium", 56.0, 56.0, 120.7626953125},
    {717, "Medium", 16.625, 16.625, 110.58471679688},
    {624, "Medium", 51.90625, 51.90625, 71.60693359375},
    {623, "Medium", 74.875, 70.21875, 118.4140625},
    {619, "Medium", 50.78125, 88.0625, 32.748291015625},
    {585, "Medium", 55.71875, 55.703125, 91.440185546875},
    {560, "Big", 99.8125, 99.8125, 99.983154296875},
    {554, "Medium", 25.75, 25.75, 22.110107421875},
    {553, "Medium", 17.75, 21.21875, 54.276611328125},
    {551, "Medium", 72.84375, 25.546875, 34.365966796875},
    {544, "Medium", 46.921875, 46.921875, 52.5185546875},
    {538, "Medium", 40.25, 44.34375, 39.262451171875},
    {532, "Medium", 67.09375, 66.5, 105.0029296875},
    {524, "Medium", 65.921875, 123.109375, 172.2392578125},
    {518, "Medium", 43.234375, 51.1875, 106.56396484375},
    {514, "Medium", 52.25, 63.265625, 92.281494140625},
    {513, "Medium", 54.578125, 75.984375, 93.7802734375},
    {512, "Medium", 18.828125, 33.3125, 63.500732421875},
    {503, "Medium", 52.90625, 52.90625, 104.8681640625},
    {501, "Medium", 55.71875, 55.703125, 91.440185546875},
    {500, "Medium", 55.71875, 55.703125, 91.398193359375},
    {496, "Medium", 119.234375, 80.09375, 14.3388671875},
    {495, "Medium", 38.96875, 38.96875, 71.913330078125},
    {486, "Medium", 28.015625, 28.015625, 49.823974609375}
}

-- All Animation set related to object manipulation
-- Following this pattern: {"AnimationSet", AnimationNamePickingUp, AnimationNameIdle, AnimationNameDrop, AnimationAfterDrop}
animationSetsList = {
    {"Medium", "Drop", "IdleMedium", "Drop", "Stop"},
    {"Big", "Drop", "IdleBig", "DropBig", "Stop"}
}

-- Here you can modify the animation offset and bone for each animationName
-- AnimationName, AnimationID, offsetX, offsetY, offsetZ, offsetRx, offsetRy, offsetRz, playerBone}
animationName = {
    {"IdleMedium", "CARRY_IDLE", 60, -35, 0, -10, 90, 105, "hand_l"},
    {"IdleBig", "HANDSUP_STAND", -2, 5, -58, 87, -40, 160, "hand_l"},
    {"Drop", "CARRY_SETDOWN", 60, -35, 0, -10, 90, 105, "hand_l"},
    {"DropBig", "CARRY_SETDOWN", 60, -45, -50, -10, 90, 105, "hand_l"},
    {"Stop", "STOP", 0, 0, 0, 0, 0, 0, ""}
 }