-- Hide status bar
display.setStatusBar(display.HiddenStatusBar);

-- display a background image
--[[ block comment 
uses brackets --]]
local background = display.newImage("images/clouds.png");

-- Generate Physics Engine
local physics = require("physics");

-- 1. Enable drawing mode for testing, you can use "normal", "debug" or "hybrid"
physics.setDrawMode("normal");

-- 2. Enable multitouch so more than 1 balloon can be touched at a time
system.activate("multitouch");

-- 3. Find device display height and width
_H = display.contentHeight;
_W = display.contentWidth;

-- 4. Number of balloons variable
balloons = 0;

-- 5. How many balloons do we start with?
numBalloons = 50;

-- 6. Game time in seconds that we'll count down
startTime = 30;

-- 7. Total amount of time
totalTime = 30;

-- 8. Is there any time left?
timeLeft = true;

-- 9. Ready to play?
playerReady = false;

-- 10. Generate math equation for randomization 
Random = math.random;

-- 11. Load background music
local music = audio.loadStream("sounds/music.mp3");

-- 12. Load balloon pop sound effect
local balloonPop = audio.loadSound("sounds/gunshot.mp3")

local balloonsTable = {};
local bloodTable = {};


-- Create a new text field using native device font
local screenText = display.newText("...Loading leos...", 0, 0, native.systemFont, 16*2);
screenText.xScale = 0.5;
screenText.yScale = 0.5;
 
-- Change the center point to bottom left
screenText:setReferencePoint(display.BottomLeftReferencePoint);
 
-- Place the text on screen
screenText.x = _W / 2 - 210;
screenText.y = _H - 20;


-- Create a new text field to display the timer
local timeText = display.newText("Time: "..startTime, 0, 0, native.systemFont, 16*2);
timeText.xScale = 0.5;
timeText.yScale = 0.5;
timeText:setReferencePoint(display.BottomLeftReferencePoint);
timeText.x = _W / 2;
timeText.y = _H - 20;

-- Create a new text field to display number of balloons
local balloonText = display.newText("leos Left: "..balloons, 0, 0, native.systemFont, 16*2);
balloonText.xScale = 0.5;
balloonText.yScale = 0.5;
balloonText:setReferencePoint(display.BottomLeftReferencePoint);
balloonText.x = _W / 2 + 100;
balloonText.y = _H - 20;

local gameTimer;

local resetButton = display.newImageRect("images/reset.png", 25, 25);
resetButton:setReferencePoint(display.CenterReferencePoint);
resetButton.x = _W / 2;
resetButton.y = _H / 2;
resetButton.isVisible = false;

 
-- Did the player win or lose the game?
local function gameOver(condition)
	-- If the player pops all of the balloons they win
	if (condition == "winner") then
		screenText.text = "You killed leo!";
		resetButton.isVisible = true;
		function resetButton:touch(e)
			if (e.phase == "ended") then
				restartGame();
			end
		end

		resetButton:addEventListener("touch",resetButton);
	-- If the player pops 70 or more balloons they did okay
	elseif (condition == "notbad") then
		screenText.text = "Not too shabby."
	-- If the player pops less than 70 balloons they didn't do so well
	elseif (condition == "loser") then
		screenText.text = "You can do better.";
	end	
end 
 
-- Remove balloons when touched and free up the memory they once used
local function removeBalloons(obj)
	obj:removeSelf();
	-- Subtract a balloon for each pop
	balloons = balloons - 1;
 	balloonText.text = "leos left: "..balloons;

	-- If time isn't up then play the game
	if (timeLeft ~= false) then
		-- If all balloons were popped
		if (balloons == 0) then
			timer.cancel(gameTimer);
			gameOver("winner")
		elseif (balloons <= 25) then
			gameOver("notbad");
		elseif (balloons >=26) then
			gameOver("loser");
		end

	end
end




local function countDown(e)
	-- When the game loads, the player is ready to play
	if (startTime == totalTime) then
		-- Loop background music
		audio.play(music, {loops =- 1});
		playerReady = true;
		screenText.text = "Pop the leos!"
	end
	-- Subtract a second from start time
	startTime = startTime - 1;
	timeText.text = "Time: "..startTime;

	balloonText.text = "leos left: "..balloons;
 
	-- If remaining time is 0, then timeLeft is false 
	if (startTime == 0) then
		timeLeft = false;

		-- If time is 0, add a button to reset the game.
		resetButton.isVisible = true;
 


		function resetButton:touch(e)
			if (e.phase == "ended") then
				restartGame();
			end
		end

		resetButton:addEventListener("touch",resetButton);

	end
end




-- 1. Start the physics engine
physics.start()
 
-- 2. Set gravity to be inverted
physics.setGravity(0, -0.4)	
 

--[[ Create "walls" on the left, right and ceiling to keep balloon on screen
	display.newRect(x coordinate, y coordinate, x thickness, y thickness)
	So the walls will be 1 pixel thick and as tall as the stage
	The ceiling will be 1 pixel thick and as wide as the stage 
--]]
local leftWall = display.newRect (0, 0, 1, display.contentHeight);
local rightWall = display.newRect (display.contentWidth, 0, 1, display.contentHeight);
local ceiling = display.newRect (0, 0, display.contentWidth, 1);
 
-- Add physics to the walls. They will not move so they will be "static"
physics.addBody (leftWall, "static",  { bounce = 0.1 } );
physics.addBody (rightWall, "static", { bounce = 0.1 } );
physics.addBody (ceiling, "static",   { bounce = 0.1 } );

local function startGame()
	-- 3. Create a balloon, 25 pixels by 25 pixels
	local myBalloon = display.newImageRect("images/leo.png", 25, 41);
 
	-- 4. Set the reference point to the center of the image
	myBalloon:setReferencePoint(display.CenterReferencePoint);
 
	-- 5. Generate balloons randomly on the X-coordinate
	myBalloon.x = Random(50, _W-50);
 
	-- 6. Generate balloons 10 pixels off screen on the Y-Coordinate
	myBalloon.y = (_H+10);
 
	-- 7. Apply physics engine to the balloons, set density, friction, bounce and radius
	physics.addBody(myBalloon, "dynamic", {density=0.5, friction=0.0, bounce=0.9, radius=10});

	 -- Allow the user to touch the balloons
	function myBalloon:touch(e)
		-- If time isn't up then play the game
		if (timeLeft ~= false) then
			-- If the player is ready to play, then allow the balloons to be popped
			if (playerReady == true) then
				if (e.phase == "ended") then
					-- Play pop sound
					audio.play(balloonPop);
					-- Remove the balloons from screen and memory
					removeBalloons(self);
					--explosion(e.x, e.y, true)
					local bloodSplatter = display.newImageRect("images/bloodSplatter.png",32,25)
					bloodSplatter.x = e.x;
					bloodSplatter.y = e.y;
					transition.to( bloodSplatter, { time=1500, alpha=0} )
					table.insert(bloodTable, bloodSplatter)

					return true;
				end
			end
		end
	end
	-- Increment the balloons variable by 1 for each balloon created
	balloons = balloons + 1;
 
	-- Add event listener to balloon
	myBalloon:addEventListener("touch", myBalloon);

	table.insert(balloonsTable, myBalloon)


	-- If all balloons are present, start timer for totalTime (10 sec)
	if (balloons == numBalloons) then
		gameTimer = timer.performWithDelay(1000, countDown, totalTime);
	else
	-- Make sure timer won't start until all balloons are loaded
		playerReady = false;
	end
end

function restartGame()
	screenText.text = "Resetting";
	
	for i = 0, #balloonsTable do
        display.remove(balloonsTable[i]) -- remove all leftover balloons
    end
    balloonsTable = nil; -- empty balloonsTable
    balloonsTable = {};
    balloons = 0; -- reset number of balloons to 0

    for i = 0, #bloodTable do
        display.remove(bloodTable[i]) -- remove all blood splatters
    end
    bloodTable = nil;
    bloodTable = {};

    startTime = totalTime; -- reset timer
    timeLeft = true;
    playerReady = true;
    resetButton:removeEventListener("touch",resetButton);
    resetButton.isVisible = false;
	gameTimer = timer.performWithDelay(20, startGame, numBalloons);

end

--[[THE EXPLOSION FUNCTION
particles = {} -- particle table
function explosion (theX, theY, blood)  -- blood is BOOL
        particleCount = 20 -- number of particles per explosion 
        for  i = 1, particleCount do
                theParticle = {}
                theParticle.object = display.newRect(theX*math.random(1),theY*math.random(1),3,3)
                if blood == true then
                         theParticle.object:setFillColor(250,0,0)
                end
                theParticle.xMove = math.random (10) - 5
                theParticle.yMove = math.random (10) * - 1
                theParticle.gravity = 10.0
                table.insert(particles, theParticle)
        end
end
 
 
-- PARTICLES MOVING
function animation ()
        for i,val in pairs(particles) do
           -- move each particle
                        val.yMove = val.yMove + val.gravity
                        val.object.x = val.object.x + val.xMove
                        val.object.y = val.object.y + val.yMove
           
           -- remove particles that are out of bound                            
           if val.object.y > display.contentHeight or val.object.x > display.contentWidth or val.object.x < 0 then 
                        val.object:removeSelf();
                        particles [i] = nil
           end                            
        end
end--]]



--[[ 
8. Create a timer for the game at 20 milliseconds, 
spawn balloons up to the number we set in numBalloons 
--]]
gameTimer = timer.performWithDelay(20, startGame, numBalloons);



