--------------------------------------------------
-- Level code
-- Created 1:11 2018-7-22
--------------------------------------------------

local chillpenguinAPI={};
local particles = API.load("particles");
local pNPC = API.load("pnpc");
local rng = API.load("rng");

local atkarray = 0;
local slidearray = 0;
local npchurtindex = 0;
local PARAM = {};

-------------------
--BEHAVIOUR STUFF--
-------------------
--The NPC ID for chill penguino
PARAM.PENGID = 1; --smb3 goomba
--The NPC ID for the ice ball
PARAM.ICEBALLID = 2; -- smb3 red goomba
--The NPC ID of the ice statue
PARAM.STATUEID = 27; --smb blue goomba
--The BGO ID of the pully for his blizzard attack
PARAM.PULLYID = 152;
--physics width
PARAM.WIDTH = 60;
--physics height
PARAM.HEIGHT = 68;
--The gravity of the npc
PARAM.GRAVITY = 1.25;
--The gravity of the npc in water
PARAM.GRAVITYW = 0.66;
--the friction of chill penguin on the ground
PARAM.FRICTION = 8;
--the friction of chill penguin when in water and on the ground
PARAM.FRICTIONWATER = 4;
--the friction of chill penguin when in the air
PARAM.FRICTIONAIR = 0.02;
--the friction of chill penguin when in water and in the air
PARAM.FRICTIONWATERAIR = 0.01;
--the friction of chill penguin when sliding on the ground
PARAM.FRICTIONSLIDE = 0.04;
--the friction of chill penguin when sliding on the ground in water
PARAM.FRICTIONSLIDEWATER = 0.01;
--controls if chill penguin is knocked backwards or in a random direction when flinching
--PARAM.HURTRNDDIR = {1, 0}
--1 = random direction when hurt
--0 = gets knocked backwards
PARAM.HURTRNDDIR = {0, 0};
--controls the ratio of which attacks chill penguin will use
-- 1 = jump
-- 2 = slide
-- 3 = iceball attack
-- 4 = ice breath attack
-- 5 = jumps for the pully to use the blizzard (if he can't find one he'll simply jump to the player)
PARAM.ATTACKRATIO = {1, 2, 3, 4, 5};
--The jump height used by its leap attack
PARAM.JUMPHEIGHT = -14;
--The jump height used by its leap attack in water
PARAM.JUMPHEIGHTW = -7;
--Controls how far chill penguin goes when jumping relative to where its trying to land
PARAM.JUMPDISTMULT = 0.015;
--Same as above but for when in water
PARAM.JUMPDISTMULTW = 0.01;
--the maximum distance chill penguin will search to find the player before jumping
--note 32 = 1 block
PARAM.JUMPSEARCHDIST = 640;
--the speed that chill penguin starts at when using its slide attack
PARAM.SLIDESPEED = 10;
--the speed that chill penguin starts at when using its slide attack under water
PARAM.SLIDESPEEDW = 5;
--once chill penguin's velocity is less than this it stops using its slide attack
PARAM.SLIDESTOP = 4;
--same as above but when in water
PARAM.SLIDESTOPW = 3;
--List of blocks that chill penguin can break when it runs into one during a slide
--  4 = smb3 brick
--  60 = smb blue brick
--  90 = smw turn block
-- 188 = smb brick
-- 226 = smb3 big brick
-- 293 = smb2 stone
PARAM.SLIDEBREAKER = {4, 60, 90, 188, 226, 293};
--the range of ice balls chill penguin can shoot
-- 2, 4 = shoots 2-4 ice balls when performing the attack before using its next attack
PARAM.ICEBALL = {4, 4};
--speed of the iceball
PARAM.ICEBALLSPDX = 5;
--speed of the iceball when it's on the ground
PARAM.ICEBALLSPDFLOORX = 4;
--the speed multiplier when the ice ball is in water
PARAM.ICEBALLWATERXMULT = 0.5;
--blizzard's push strength
PARAM.BLIZPOW = 0.4;
--how long the blizzard lasts for
PARAM.BLIZDUR = 180;
--how high up chill penguin will search for a pully
--32 = 1 block
PARAM.PULLSEARCHDISTY = 352;
--same as the above but for when in water
PARAM.PULLSEARCHDISTYW = 192;
--how long chill penguin holds the pully
PARAM.PULLYDUR = 100;
--how long chill penguin's ice breath lasts for
PARAM.ICEBREATHDUR = 122;
--ice statue's max hp
PARAM.STATUEMAXHP = 4;
--speed multiplier for statues when in water
PARAM.STATUEWATERXMULT = 0.5;
--If chill penguin gets frozen this is how long until it'll break out
PARAM.FROZENDUR = 198;
--determines if the health bar should be displayed
-- PARAM.USEHEALTHBAR = {0, 1};
-- 0 == disabled if not set to boss
-- 1 == enabled if set to boss
PARAM.USEHEALTHBAR = {0, 1};
--determines if chill penguin can despawn when off screen
-- PARAM.DESPAWN = {1 , 0};
-- 1 == can despawn if not set to boss
-- 0 == can't despawn if set to boss
PARAM.DESPAWN = {1 , 0};

----------------
--DAMAGE TABLE--
----------------

--the npcs total hp
--PARAM.MAXHP = {10, 32};
-- 10 hp when not set to boss
-- 32 hp when set to boss
PARAM.MAXHP = {10, 32};
--how long chill penguin is immune to damage when hurt
PARAM.IFRAMES = 30;
--if enabled chill penguin will have infinite iframes during its hurt sprite
--once it lands on the ground it's iframes will last as long as param.iframes
PARAM.AIRIFRAMES = true;

--PARAM.DMG_STOMP = {2, 0, 1, 2, 0, 1}
--this means it takes
--2 damage when jumped on in most situations
--0 damage when jumped on when sliding
--1 damage when using its ice breath attack
--the three values after it is the same except when it's set to boss in the editor

--PARAM.FLINCHDMG = {2, 3, 3, 2, -1, 3};
--flinches when taking 2 or more damage in most situations
--flinches when taking 3 or more damage while sliding
--flinches when taking 3 or more damage during its ice breath attack
--the three values after it is the same except when it's set to boss in the editor
-- -1 makes it never flinch from damage

--damage taken when stomped
PARAM.DMG_STOMP = {2, 0, 2, 2, 0, 2};
--damage taken when hit underneath by a block
PARAM.DMG_BUMP = {1, 0, 1, 0, 0, 0};
--damage taken when hit by a projectile
PARAM.DMG_PROJ = {2, 0, 2, 1, 0, 1};
--damage taken when this npc is thrown into another
PARAM.DMG_SELF = {4, 4, 4, 2, 2, 2};
--damage taken when this npc touches lava
PARAM.DMG_LAVA = {5, 2, 5, 3, 1, 3};
--damage taken when hit by a tanooki tail
PARAM.DMG_TAIL = {2, 0, 2, 1, 0, 1};
--damage taken when hit by a spin jump
PARAM.DMG_SPIN = {3, 0, 3, 2, 0, 2};
--damage taken by link's sword and sword beams
PARAM.DMG_SWORD = {3, 1, 3, 3, 0, 3};
--if an attack does this amount or more, make chill penguin flinch
PARAM.FLINCHDMG = {2, 3, 3, 2, -1, 3};

-------------------
--ANIMATION STUFF--
-------------------
--how many frames between each frame for the idle animation
PARAM.IDLESPD = 10;
--the frameno for when chill penguin is falling, uses the frame after it for when facing right
PARAM.FALLFRAME = 14;
--the frameno for when chill penguin is airborne going upwards, uses the frame after for facing right
PARAM.RISEFRAME = 12;
--the starting frame when chill penguin telegraphs his jump
--uses 2 frames
--4 in total if you count both direction frames
PARAM.JUMPFRAME = 8;
--the frameno of when chill penguin is hurt
PARAM.HURTFRAME = 16
--the starting frames when chill penguin telegraphs his slide, ice ball or ice breath attack
--uses 2 frames
--4 in total if you count both direction frames
PARAM.PREFRAME = 18;
--the frames used by chill penguin's slide attack
--the first frame is used when airborne
--second when on the ground
--4 in total if you count both direction frames
PARAM.SLIDEFRAME = 22;
--frames used when spiting and using ice breath
--uses 2 frames
--4 in total if you count both direction frames
PARAM.SPITFRAME = 26;
--frame to use when holding the pully
--the next frame is used when facing right
PARAM.PULLYFRAME = 30;
--offsets the pullyframe
---PARAM.PULLYOFFSET{10, 4}
-- 10 = moves sprite 10 to the direction its facing
-- 4 = moves sprite 4 downward
PARAM.PULLYOFFSET = {4, 48};

---------------
--ARRAY STUFF--
---------------
--controls the blizzard
local blizdur = 0;
local blizdir = 0;

--gets the npc uid of each npc
local npctable = {};
--confirms that each npc is registered
--0 = not registered/doesn't exist as far as the code knows
--1 = registered
--2 = registered and variables are setup for use
local npcregister = {};
--npc's x velocity
--this is so we can move the npc on our own terms
local npcxvel = {};
--npc's state
-- 0 = set to dontmove
-- 1 = standing
-- 2 = priming jump
-- 3 = priming other attacks
-- 4 = sliding
-- 5 = ice ball attack
-- 6 = ice breath attack
local npcstate = {};
--npc's direction
-- -1 = left
-- 	0 = none
-- 	1 = right
local npcdirection = {};
--npc's hit points
local npchealth = {};
-- contains the last x position of the npc
local npclastxpos = {};
--handles the time until the next frame in animations
local npctimeframe = {};
--holds the last frame number the npc used
local npclastframe = {};
--when this hits 0 while chill penguin is in state 1 he'll perform an action
local npctimeaction = {};
--timer that when it hits 0 during state2 makes chill penguin jump
local npcprimemove = {};
--a timer to manage hurt frames
local npchurt = {};
--used to figure out which attack chill penguin is using
--1 = slide
--2 = ice ball
--3 = ice breath
--4 = blizzard
local npcmovetype = {};
--the amount of ice balls chill penguin needs to shoot before going back to state 1
local npcballcount = {};
--timer for being frozen
local npcfrozentime = {};
--the pully being held
local npctouchedpully = {};
--the ice breath frame
local npcbreathframe = {};
--frame counter for ice breath
local npcbreathtime = {};
--ice breath duration
--when it hits 0 the breath effect starts to disapear
local npcbreathdur = {};
--the ice breath's location
local npcbreathlocx = {};
--the ice breath's location
local npcbreathlocy = {};
--the direction the ice breath is facing
local npcbreathdir = {};
--kills of the npc if true
local npcdead = {};

--gets the npc uid of projectile
local projtable = {};
--confirms that each proj is registered
--0 = not registered/doesn't exist as far as the code knows
--1 = registered
--2 = registered and variables are setup for use
local projregister = {};
--projectile's x velocity
local projxvel = {};
--contains the last x position of the proj
local projlastxpos = {};
--the hp of the projectile
local projhealth = {};
--projectile state
--0 = ice statue
--1 = upward iceball
--2 = forward iceball
local projstate = {};
--projectile's direction
-- -1 = left
--  0 = none
--  1 = right
local projdirection = {};
local projlastframe = {};
local projtimeframe = {};
--makes the projectile die if this is set to true
local projdead = {};

--the dimensions that makes up a frame
local fbframex= 196;
local fbframey = 34;
--hitbox data for the ice breath for each frame
local fbxone = {166, 134, 98, 64, 32, 0, 0, 0, 0, 0, 0, 0};
local fbxtwo = {0, 0, 0, 0, 0, 0, 0, -34, -64, -98, -132, -164};

local fbl = Graphics.loadImage("1ldeepbreath.gif");
local fbr = Graphics.loadImage("1rdeepbreath.gif");

local hpboarder = Graphics.loadImage("hpconchill.gif");
local hpfill = Graphics.loadImage("hpfillchill.gif");

function chillpenguinAPI.onInitAPI()
    registerEvent(chillpenguinAPI, "onStart", "onStart");
    registerEvent(chillpenguinAPI, "onTick", "onTick");
    registerEvent(chillpenguinAPI, "onCameraUpdate", "onCameraUpdate");
    registerEvent(chillpenguinAPI, "onNPCKill", "onNPCKill");
end

-- Run code on level start
function chillpenguinAPI.onStart()
	PARAM.GRAVITY = PARAM.GRAVITY - 1.0;
	PARAM.GRAVITYW = PARAM.GRAVITYW - 1.0;
	for index, val in pairs(PARAM.ATTACKRATIO) do
		if val ~= nil then
			atkarray = atkarray+1;
		end
	end
	for index, val in pairs(PARAM.SLIDEBREAKER) do
		if val ~= nil then
			slidearray = slidearray+1;
		end
	end
end

local blizzardl = particles.Emitter(0, 0, Misc.resolveFile("particles/p_blizzardl.ini"));
blizzardl:AttachToCamera(Camera.get()[1]);
local blizzardr = particles.Emitter(0, 0, Misc.resolveFile("particles/p_blizzardr.ini"));
blizzardr:AttachToCamera(Camera.get()[1]);

function chillpenguinAPI.onCameraUpdate()
	if Defines.levelFreeze == false then
		if blizdur >= 1 then
			if blizdir == -1 then
				blizzardl:Draw();
			elseif blizdir == 1 then
				blizzardr:Draw();
			end
		end
	end
end

function chillpenguinAPI.onTick()
	if npctable[npchurtindex] ~= nil and  npctable[npchurtindex].isValid then
		Graphics.drawImage(hpboarder, 740, 120);
		if npchealth[npchurtindex] >= 1 then
			local healthoffset = 126;
			if npctable[npchurtindex].legacyBoss then
				healthoffset = healthoffset-(126*(npchealth[npchurtindex]/PARAM.MAXHP[2]))
			else
				healthoffset = healthoffset-(126*(npchealth[npchurtindex]/PARAM.MAXHP[1]))
			end
			Graphics.drawImage(hpfill, 748, 128+healthoffset, 0, 0, 12, 126-healthoffset);
		end
	end
	for k, v in pairs(NPC.get({PARAM.ICEBALLID, PARAM.STATUEID}, player.section)) do
		if projisknown(v) == false and v:mem(0x64, FIELD_BOOL) == false and v:mem(0x40, FIELD_BOOL) == false then
			assignproj(v);
		end
	end
	for k, v in pairs(NPC.get(PARAM.PENGID, player.section)) do
		if npcisknown(v) == false and v:mem(0x64, FIELD_BOOL) == false and v:mem(0x40, FIELD_BOOL) == false then
			assignnpc(v);
		end
	end
	for index, npc in pairs(npctable) do
		if npc.isValid and npc:mem(0x64, FIELD_BOOL) == false and npc.id ~= 263 then
			if npcregister[index] ~= 2 then
				npcinitialize(index, npc);
			end
			------------------
			--BEHAVIOUR CODE--
			------------------
			if npc:mem(0x146, FIELD_WORD) == player.section then
				if npc.legacyBoss and PARAM.DESPAWN[2] == 0 then
					npc:mem(0x12A, FIELD_WORD, 180);
				elseif npc.legacyBoss == false and PARAM.DESPAWN[1] == 0 then
					npc:mem(0x12A, FIELD_WORD, 180);
				end
			end
			if npcbreathframe[index] <= 12 then
				icebreath(index, npc);
			end
			if Defines.levelFreeze == false then
				if npcdead[index] then
					npc:harm();
				else
					calcmomentum(index, npc);
					if npcstate[index] == 0 then --set to dontmove
						if npc.collidesBlockBottom then
							calcnpcdirection(index, npc);
						end
					elseif npcstate[index] == 1 then
						--grounded
						if npc.collidesBlockBottom then
							if npctimeaction[index] >= 1 then
								npctimeaction[index] = npctimeaction[index]-1;
							else
								local rand = rng.randomInt(1, atkarray);
								if PARAM.ATTACKRATIO[rand] == 1 then
									npcmovetype[index] = 0;
									setstate(index, npc, 2);
								elseif PARAM.ATTACKRATIO[rand] == 2 then
									npcmovetype[index] = 1;
									setstate(index, npc, 3);
								elseif PARAM.ATTACKRATIO[rand] == 3 then
									npcmovetype[index] = 2;
									npcballcount[index] = rng.randomInt(PARAM.ICEBALL[1], PARAM.ICEBALL[2]);
									setstate(index, npc, 3);
								elseif PARAM.ATTACKRATIO[rand] == 4 then
									npcmovetype[index] = 3;
									setstate(index, npc, 3);
								elseif PARAM.ATTACKRATIO[rand] == 5 then
									npcmovetype[index] = 4;
									setstate(index, npc, 2);
								end
								
							end
							calcnpcdirection(index, npc);
						--airborne
						else
							if npcmovetype[index] == 4 and (touchedpully(index, npc, false) ~= nil and npcprimemove[index] <= 0) or npcmovetype[index] == 4 and (touchedpully(index, npc, true) ~=nil and npcprimemove[index] >= 0) then
								if  npcprimemove[index] <= 0 then
									npcprimemove[index] = PARAM.PULLYDUR;
									blizdur = PARAM.BLIZDUR;
									blizdir = npcdirection[index];
								elseif npcprimemove[index] >= 1 then
									npcprimemove[index] = npcprimemove[index]-1;
									npcxvel[index] = 0;
									npc.speedY = 0;
									npctouchedpully[index] = touchedpully(index, npc, true);
									if npcdirection[index] == -1 then
										npc.x = npctouchedpully[index].x+PARAM.PULLYOFFSET[1];
									elseif npcdirection[index] == 1 then
										npc.x = (npctouchedpully[index].x-PARAM.WIDTH*0.45)-PARAM.PULLYOFFSET[1];
									end
									npc.y = npctouchedpully[index].y+PARAM.PULLYOFFSET[2];
									if npcprimemove[index] <= 0 then
										npcmovetype[index] = 0;
									end
								end
							end
						end
					elseif npcstate[index] == 2 then
						if npcprimemove[index] >= 2 then
							npcprimemove[index] = npcprimemove[index]-1;
						elseif npcprimemove[index] >= 0 then
							npcprimemove[index] = npcprimemove[index]-1;
							calcnpcleap(index, npc);
						else
							setstate(index, npc, 1);
						end
					elseif npcstate[index] == 3 then
						if npcprimemove[index] >= 0 then
							npcprimemove[index] = npcprimemove[index]-1;
						else
							if npcmovetype[index] == 1 then
								setstate(index, npc, 4);
							elseif npcmovetype[index] == 2  then
								setstate(index, npc, 5);
							elseif npcmovetype[index] == 3  then
								setstate(index, npc, 6);
							end
						end
					elseif npcstate[index] == 4 then
						if npc.collidesBlockBottom then
							local stopspeed = PARAM.SLIDESTOP;
							if npc.underwater then
								stopspeed = PARAM.SLIDESTOPW;
							end
							if npcdirection[index] == -1 and npcxvel[index] > stopspeed*-1 then
								setstate(index, npc, 1);
							elseif npcdirection[index] == 1 and npcxvel[index] < stopspeed then
								setstate(index, npc, 1);
							end
						end
					elseif npcstate[index] == 5 then
						if npc.collidesBlockBottom then
							if npcprimemove[index] >= 0 then
								npcprimemove[index] = npcprimemove[index]-1;
							end
							if npcprimemove[index] == 8 then
								shootprojectile(index, npc);
							end
							if npcprimemove[index] <= 0 then
								if npcballcount[index] >= 1 then
									setstate(index, npc, 3);
								else
									setstate(index, npc, 1);
								end
							end
						else
							npcballcount[index] = 0;
							setstate(index, npc, 1);
						end
					elseif npcstate[index] == 6 then
						if npc.collidesBlockBottom then
							if npcprimemove[index] >= 0 then
								npcprimemove[index] = npcprimemove[index]-1;
							end
							if npcprimemove[index] <= 0 then
								setstate(index, npc, 1);
							end
						else
							setstate(index, npc, 1);
						end
					end
					applyvel(index, npc);
					------------------
					--ANIMATION CODE--
					------------------
					if npcstate[index] == 1 or npcstate[index] == 0 then
						if npchurt[index] >= 0 then
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.HURTFRAME;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.HURTFRAME+1;
								npc.animationFrame = npclastframe[index];
							end
						else
							if npc.collidesBlockBottom then
								if npcdirection[index] == -1 and npctimeframe[index] <= 0 then
									if npclastframe[index] >= 3 or npclastframe[index] <= -1 then
										npclastframe[index] = -1;
									end
									npclastframe[index] = npclastframe[index]+1;
									npc.animationFrame = npclastframe[index];
									npctimeframe[index] = PARAM.IDLESPD;
								elseif npcdirection[index] == 1 and npctimeframe[index] <= 0 then
									if npclastframe[index] >= 7 or npclastframe[index] <= 3 then
										npclastframe[index] = 3;
									end
									npclastframe[index] = npclastframe[index]+1;
									npc.animationFrame = npclastframe[index];
									npctimeframe[index] = PARAM.IDLESPD;
								end
							else
								if npcmovetype[index] == 4 and npcprimemove[index] >= 0 then
									if npcdirection[index] == -1 then
										npclastframe[index] = PARAM.PULLYFRAME;
										npc.animationFrame = npclastframe[index];
									elseif npcdirection[index] == 1 then
										npclastframe[index] = PARAM.PULLYFRAME+1;
										npc.animationFrame = npclastframe[index];
									end
								elseif npc.speedY < 0 then
									if npcdirection[index] == -1 then
										npclastframe[index] = PARAM.RISEFRAME;
										npc.animationFrame = npclastframe[index];
									elseif npcdirection [index] == 1 then
										npclastframe[index] = PARAM.RISEFRAME+1;
										npc.animationFrame = npclastframe[index];
									end
								elseif npc.speedY > 0 then
									if npcdirection[index] == -1 then
										npclastframe[index] = PARAM.FALLFRAME;
										npc.animationFrame = npclastframe[index];
									elseif npcdirection [index] == 1 then
										npclastframe[index] = PARAM.FALLFRAME+1;
										npc.animationFrame = npclastframe[index];
									end
								end
							end
						end
					elseif npcstate[index] == 2 then
						if npctimeframe[index] <= 0 then
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.JUMPFRAME+1;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.JUMPFRAME+3;
								npc.animationFrame = npclastframe[index];
							end
						end
					elseif npcstate[index] == 3 then
						if npctimeframe[index] <= 0 then
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.PREFRAME+1;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.PREFRAME+3;
								npc.animationFrame = npclastframe[index];
							end
						end
					elseif npcstate[index] == 4 then
						if npc.collidesBlockBottom then
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.SLIDEFRAME+1;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.SLIDEFRAME+3;
								npc.animationFrame = npclastframe[index];
							end
						else
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.SLIDEFRAME;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.SLIDEFRAME+2;
								npc.animationFrame = npclastframe[index];
							end
						end
					elseif npcstate[index] == 5 then
						if npctimeframe[index] <= 0 then
							if npcdirection[index] == -1 then
								npclastframe[index] = PARAM.SPITFRAME+1;
								npc.animationFrame = npclastframe[index];
							elseif npcdirection[index] == 1 then
								npclastframe[index] = PARAM.SPITFRAME+3;
								npc.animationFrame = npclastframe[index];
							end
						end
					elseif npcstate[index] == 6 then
						if npctimeframe[index] <= 0 then
							if npcdirection[index] == -1 then
								if npclastframe[index] >= PARAM.SPITFRAME+1 or npclastframe[index] <= PARAM.SPITFRAME-1 then
									npclastframe[index] = PARAM.SPITFRAME-1;
								end
								npclastframe[index] = npclastframe[index]+1;
								npc.animationFrame = npclastframe[index];
								npctimeframe[index] = 5;
							elseif npcdirection[index] == 1 then
								if npclastframe[index] >= PARAM.SPITFRAME+3 or npclastframe[index] <= PARAM.SPITFRAME+1 then
									npclastframe[index] = PARAM.SPITFRAME+1;
								end
								npclastframe[index] = npclastframe[index]+1;
								npc.animationFrame = npclastframe[index];
								npctimeframe[index] = 5;
							end
						end
					end
					if npctimeframe[index] >= 1 then
						npctimeframe[index] = npctimeframe[index]-1;
					end
				end
			end
			npc.animationTimer = 0;
		elseif npc.isValid and (npc:mem(0x64, FIELD_BOOL) or npc.id == 263) then
			if npcregister[index] == 2 then
				if Defines.levelFreeze == false then
					if npc.id == 263 then
						if npcfrozentime[index] <= -1 then
							npcfrozentime[index] = PARAM.FROZENDUR;
						elseif npcfrozentime[index] >= 66 then
							npcfrozentime[index] = npcfrozentime[index]-1;
						elseif npcfrozentime[index] >= 1 then
							npcfrozentime[index] = npcfrozentime[index]-1;
							if npcfrozentime[index] % 2 == 0 then
								npc.x = npc.x+3;
							else
								npc.x = npc.x-3;
							end
						else
							npc.id = PARAM.PENGID;
							npcfrozentime[index] = -1;
						end
					end
				end
			end
		else
			npcunregister(index, npc);
		end
	end
	for index, proj in pairs(projtable) do
		if proj.isValid and proj.id ~= 263 then
			if projregister[index] ~= 2 then
				projinitialize(index, proj);
			end
			if Defines.levelFreeze == false then
			------------------
			--BEHAVIOUR CODE--
			------------------
				if projdead[index] then
					proj:harm();
				else
					if proj.id == PARAM.ICEBALLID then
						if projstate[index] == 1 then
							--upward
							if proj.collidesBlockBottom then
								if projdirection[index] == -1 then
									projxvel[index] = PARAM.ICEBALLSPDFLOORX*-1;
								elseif projdirection[index] == 1 then
									projxvel[index] = PARAM.ICEBALLSPDFLOORX;
								end
							else
								if projdirection[index] == -1 then
									projxvel[index] = PARAM.ICEBALLSPDX*-1;
								elseif projdirection[index] == 1 then
									projxvel[index] = PARAM.ICEBALLSPDX;
								end
							end
							if proj.underwater then
								projxvel[index] = projxvel[index]*PARAM.ICEBALLWATERXMULT;
							end
						elseif projstate[index] == 2 then
							--moving forward
							if projdirection[index] == -1 then
								projxvel[index] = PARAM.ICEBALLSPDX*-1;
							elseif projdirection[index] == 1 then
								projxvel[index] = PARAM.ICEBALLSPDX;
							end
							if proj.underwater then
								proj.speedY = -0.05;
								projxvel[index] = projxvel[index]*PARAM.ICEBALLWATERXMULT;
							else
								proj.speedY = -0.265;
							end
						end
					elseif proj.id == PARAM.STATUEID then
						if blizdur >= 1 then
							if blizdir == -1 then
								if proj.underwater then
									projxvel[index] = projxvel[index]-(PARAM.BLIZPOW*PARAM.STATUEWATERXMULT);
								else
									projxvel[index] = projxvel[index]-PARAM.BLIZPOW;
								end
							elseif blizdir == 1 then
								if proj.underwater then
									projxvel[index] = projxvel[index]+(PARAM.BLIZPOW*PARAM.STATUEWATERXMULT);
								else
									projxvel[index] = projxvel[index]+PARAM.BLIZPOW;
								end
							end
						else
							if projxvel[index] > 0 then
								projxvel[index] = projxvel[index]-0.05;
								if projxvel[index] < 0 then
									projxvel[index] = 0;
								end
							elseif projxvel[index] < 0 then
								projxvel[index] = projxvel[index]+0.05;
								if projxvel[index] > 0 then
									projxvel[index] = 0;
								end
							end
						end
						if projxvel[index] ~= 0 then
							if projstate[index] == 0 then
								proj.x = proj.x +1;
							end
							projstate[index] = 1;
						else
							projstate[index] = 0;
						end
						if proj.animationFrame == 2 then
						elseif proj.animationFrame == 5 then
						else
							if projtimeframe[index] >= 1 then
								projtimeframe[index] = projtimeframe[index]-1;
							else
								if projdirection[index] == -1 then
									projtimeframe[index] = 30;
									projlastframe[index] = projlastframe[index]+1;
									proj.animationFrame = projlastframe[index];
								elseif projdirection[index] == 1 then
									projtimeframe[index] = 30;
									projlastframe[index] = projlastframe[index]+1;
									proj.animationFrame = projlastframe[index];
								end
							end
						end
					end
					applyprojvel(index, proj);
					proj.animationTimer = 0;
				end
			end
		elseif proj.isValid and proj.id == 263 then
		else
			projunregister(index, proj);
		end
	end
	if Defines.levelFreeze == false then
		if blizdur >= 1 then
			blizdur = blizdur-1;
			local accel = 0.2;
			if player.runKeyPressing or player.altrunKeyPressing then
				accel = 0.35;
			end
			if blizdir == -1 then
				if player.speedX >= Defines.player_runspeed-PARAM.BLIZPOW then
					player.speedX = Defines.player_runspeed-PARAM.BLIZPOW;
				elseif player.rightKeyPressing then
					player.speedX	= player.speedX+(accel-PARAM.BLIZPOW);
				elseif player.leftKeyPressing then
					player.speedX	= player.speedX-(accel+PARAM.BLIZPOW);
				else
					if player.speedX == 0 then
						player.speedX = -0.5;
					end
					player.speedX = player.speedX-PARAM.BLIZPOW;
				end
			elseif blizdir == 1 then
				if player.speedX <= (Defines.player_runspeed*-1)+PARAM.BLIZPOW then
					player.speedX = (Defines.player_runspeed*-1)+PARAM.BLIZPOW;
				elseif player.rightKeyPressing then
					player.speedX	= player.speedX+(accel+PARAM.BLIZPOW);
				elseif player.leftKeyPressing then
					player.speedX	= player.speedX-(accel-PARAM.BLIZPOW);
				else
					if player.speedX == 0 then
						player.speedX = 0.5;
					end
					player.speedX = player.speedX+PARAM.BLIZPOW;
				end
			end
		end
	end
end

function chillpenguinAPI.onNPCKill(event, npc, reason)
	local index = getnpcindex(npc);
	if index ~= nil and index >= 0 then
		local hurtstate = npcstate[index];
		if hurtstate == 4 then
			hurtstate = 2;
		elseif hurtstate == 6 then
			hurtstate = 3;
		else
			hurtstate = 1;
		end
		if npc.legacyBoss then
			hurtstate = hurtstate+3;
		end
		local healthpost = npchealth[index]
		if reason == 1 then
			npchealth[index] = npchealth[index] - PARAM.DMG_STOMP[hurtstate];
		elseif reason == 2 then
			npchealth[index] = npchealth[index] - PARAM.DMG_BUMP[hurtstate];
		elseif reason == 3 or reason == 5 then
			npchealth[index] = npchealth[index] - PARAM.DMG_PROJ[hurtstate];
		elseif reason == 4 then
			npchealth[index] = npchealth[index] - PARAM.DMG_SELF[hurtstate];
		elseif reason == 6 then
			npchealth[index] = npchealth[index] - PARAM.DMG_LAVA[hurtstate];
		elseif reason == 7 then
			npchealth[index] = npchealth[index] - PARAM.DMG_TAIL[hurtstate];
		elseif reason == 8 then
			npchealth[index] = npchealth[index] - PARAM.DMG_SPIN[hurtstate];
		elseif reason == 10 then
			npchealth[index] = npchealth[index] - PARAM.DMG_SWORD[hurtstate];
		end
		if npc.legacyBoss and PARAM.USEHEALTHBAR[2] == 1 then
			npchurtindex = index;
		elseif npc.legacyBoss ==false and PARAM.USEHEALTHBAR[1] == 1 then
			npchurtindex = index;
		end
		if npchealth[index] >= 1 then
			event.cancelled = true;
			if npchealth[index] < healthpost then
				if PARAM.FLINCHDMG[hurtstate] >= 0 and (healthpost-npchealth[index]) >= PARAM.FLINCHDMG[hurtstate] then
					--play hurt animation if taken more than or equal to the flinch amount
					local throwdirection = 0
					if npc.legacyBoss then
						if PARAM.HURTRNDDIR[2] == 0 then
							throwdirection = npcdirection[index];
						elseif PARAM.HURTRNDDIR[2] == 1 then
							throwdirection = rng.randomInt(0, 1);
						end
					else
						if PARAM.HURTRNDDIR[1] == 0 then
							throwdirection = npcdirection[index];
						elseif PARAM.HURTRNDDIR[1] == 1 then
							throwdirection = rng.randomInt(0, 1);
						end
					end
					if throwdirection == -1 then
						throwdirection = 0;
					end
					if throwdirection == 0 then
						npcdirection[index] = -1;
						npcxvel[index] = 3;
						npc.speedY = -7;
					elseif throwdirection == 1 then
						npcdirection[index] = 1;
						npcxvel[index] = -3;
						npc.speedY = -7;
					end
					setstate(index, npc, 1);
					npcmovetype[index] = 0;
					npchurt[index] = 5;
					if PARAM.AIRIFRAMES then
						npc:mem(0x156, FIELD_WORD, 999);
					else
						npc:mem(0x156, FIELD_WORD, PARAM.IFRAMES);
					end
				else
					npc:mem(0x156, FIELD_WORD, PARAM.IFRAMES);
				end
			end
		elseif npcdead[index] == false then
			npcdead[index] = true;
			event.cancelled = true;
		end
	else
		index = getprojindex(npc);
		if index ~= nil and index >= 0 then
			projhealth[index] = projhealth[index]-1;
			if projhealth[index] >= 1 then
				event.cancelled = true;
			elseif projdead[index] == false then
				projdead[index] = true;
				event.cancelled = true;
			end
		end
	end
end

--applies momentum to chill penguin
function applyvel(index, npc)
	if npcstate[index] == 4 then --sliding
		local blocktable = Block.getIntersecting(npc.x-2, npc.y, npc.x+PARAM.WIDTH+2, npc.y+PARAM.HEIGHT);
		for k, v in pairs(blocktable) do
			--now we check if the block is whitelisted
			if v.isHidden == false then
				for arrayno, proj in pairs(PARAM.SLIDEBREAKER) do
					--if is then we break the block
					if v.id == PARAM.SLIDEBREAKER[arrayno] then
						hitblock = true;
						v:remove(true);
						break
					end
				end
			end
		end
		
		if npclastxpos[index] == npc.x then
			if npcdirection[index] == -1 then
				npcdirection[index] = 1;
				npcxvel[index] = npcxvel[index]*-1;
				npc.x = npc.x+1;
			elseif npcdirection[index] == 1 then
				npcdirection[index] = -1;
				npcxvel[index] = npcxvel[index]*-1;
				npc.x = npc.x-1;
			end
		end
		
		local statuetable = NPC.getIntersecting(npc.x-2, npc.y, npc.x+PARAM.WIDTH+2, npc.y+PARAM.HEIGHT);
		for k, v in pairs(statuetable) do
			if v.isHidden == false then
				if v.id == PARAM.STATUEID then
					local projindex = getprojindex(v);
					projhealth[projindex] = 0;
					v:harm();
				end
			end
		end
		
	end
	
	npclastxpos[index] = npc.x;
	npc.x = npc.x+npcxvel[index];
end


--applies momentum to chill penguin's projectile
function applyprojvel(index, proj)
	local stillvalid = true;
	if proj.id == PARAM.ICEBALLID then
		--probably hit a wall
		if projlastxpos[index] == proj.x then
			proj:harm();
			stillvalid = false;
		else
			local statuetable = NPC.getIntersecting(proj.x, proj.y, proj.x+24, proj.y+24);
			for k, v in pairs(statuetable) do
				if v.isHidden == false then
					if v.id == PARAM.STATUEID then
						proj:harm();
						stillvalid = false;
					end
				end
			end
		end
	elseif proj.id == PARAM.STATUEID and projstate[index] == 1 then
		--probably hit a wall
		if projlastxpos[index] == proj.x then
			projhealth[index] = 0;
			projdead[index] = true;
			proj:harm();
			stillvalid = false;
		end
	end
	if stillvalid then
		projlastxpos[index] = proj.x;
		proj.x = proj.x+projxvel[index];
	end
end

--calculates chill penguin's leap
function calcnpcleap(index, npc)
	local pullyx = nil;
	if npcmovetype[index] == 4 then
		pullyx = locatepully(index, npc);
	end
	if pullyx ~= nil then
		if npc.underwater then
			if npc.x - pullyx >= 1 then
				npcxvel[index] = (npc.x - pullyx)*-PARAM.JUMPDISTMULTW;
				npcdirection[index] = -1;
			elseif npc.x - pullyx <= 1 then
				npcxvel[index] = (npc.x - pullyx)*-PARAM.JUMPDISTMULTW;
				npcdirection[index] = 1;
			end
			npc.speedY = PARAM.JUMPHEIGHTW;
		else
			if npc.x - pullyx >= 1 then
				npcxvel[index] = (npc.x - pullyx)*-PARAM.JUMPDISTMULT;
				npcdirection[index] = -1;
			elseif npc.x - pullyx <= 1 then
				npcxvel[index] = (npc.x - pullyx)*-PARAM.JUMPDISTMULT;
				npcdirection[index] = 1;
			end
			npc.speedY = PARAM.JUMPHEIGHT;
		end
	elseif pullyx == nil then
		if npc.underwater then
			if npcdirection[index] == 1 then
				if npc.x+PARAM.WIDTH  - player.x >= 1 or npc.x+PARAM.WIDTH  - player.x < -PARAM.JUMPSEARCHDIST then
					npcxvel[index] = rng.randomInt(2,(PARAM.JUMPSEARCHDIST*PARAM.JUMPDISTMULTW));
				else
					npcxvel[index] = (npc.x - player.x)*-PARAM.JUMPDISTMULTW;
				end
			elseif npcdirection[index] == -1 then
				if npc.x - player.x <= -1 or npc.x - player.x > PARAM.JUMPSEARCHDIST then
					npcxvel[index] = rng.randomInt(-2,(PARAM.JUMPSEARCHDIST*-PARAM.JUMPDISTMULTW));
				else
					npcxvel[index] = (npc.x - player.x)*-PARAM.JUMPDISTMULTW;
				end
			end
			npc.speedY = PARAM.JUMPHEIGHTW;
		else
			if npcdirection[index] == 1 then
				if npc.x+PARAM.WIDTH - player.x >= 1 or npc.x+PARAM.WIDTH  - player.x < -PARAM.JUMPSEARCHDIST then
					npcxvel[index] = rng.randomInt(2,(PARAM.JUMPSEARCHDIST*PARAM.JUMPDISTMULT));
				else
					npcxvel[index] = (npc.x - player.x)*-PARAM.JUMPDISTMULT;
				end
			elseif npcdirection[index] == -1 then
				if npc.x - player.x <= -1 or npc.x - player.x > PARAM.JUMPSEARCHDIST then
					npcxvel[index] = rng.randomInt(-2,(PARAM.JUMPSEARCHDIST*-PARAM.JUMPDISTMULT));
				else
					npcxvel[index] = (npc.x - player.x)*-PARAM.JUMPDISTMULT;
				end
			end

			npc.speedY = PARAM.JUMPHEIGHT;
		end
	end
end

--calculates which direction chill penguin should face
function calcnpcdirection(index, npc)
	if npcdirection[index] == 1 then
		if npc.x - player.x >= 1 then
			npcdirection[index] = -1;
		end
	elseif npcdirection[index] == -1 then
		if npc.x+PARAM.WIDTH - player.x <= -1 then
			npcdirection[index] = 1;
		end
	end
	if npchurt[index] <= 0 and npchurt[index] ~= -2 then
		npchurt[index] = -2;
		if PARAM.AIRIFRAMES then
			npc:mem(0x156, FIELD_WORD, PARAM.IFRAMES);
		end
		npctimeaction[index] = 20;
	elseif npchurt[index] ~= -2 then
		npchurt[index] = npchurt[index] -1;
	end
end

--calculates chill penguin's velocity
function calcmomentum(index, npc)
	local veldir = 0;
	if npcxvel[index] > 0 then
		veldir = 1;
	elseif npcxvel[index] <0 then
		veldir = -1;
	end
	if npc.collidesBlockBottom and npchurt[index]<= 0 then
		if npcstate[index] == 4 then
			if npc.underwater then
				if veldir == -1 then
					npcxvel[index] = npcxvel[index]+PARAM.FRICTIONSLIDEWATER;
				elseif veldir == 1 then
					npcxvel[index] = npcxvel[index]-PARAM.FRICTIONSLIDEWATER;
				end
			else
				if veldir == -1 then
					npcxvel[index] = npcxvel[index]+PARAM.FRICTIONSLIDE;
				elseif veldir == 1 then
					npcxvel[index] = npcxvel[index]-PARAM.FRICTIONSLIDE;
				end
			end
		else
			if npc.underwater then
				if veldir == -1 then
					npcxvel[index] = npcxvel[index]+PARAM.FRICTIONWATER;
				elseif veldir == 1 then
					npcxvel[index] = npcxvel[index]-PARAM.FRICTIONWATER;
				end
			else
				if veldir == -1 then
					npcxvel[index] = npcxvel[index]+PARAM.FRICTION;
				elseif veldir == 1 then
					npcxvel[index] = npcxvel[index]-PARAM.FRICTION;
				end
			end
		end
	else
		if npc.underwater then
			if veldir == -1 then
				npcxvel[index] = npcxvel[index]+PARAM.FRICTIONWATERAIR;
			elseif veldir == 1 then
				npcxvel[index] = npcxvel[index]-PARAM.FRICTIONWATERAIR;
			end
			npc.speedY = npc.speedY+(PARAM.GRAVITYW*(Defines.npc_grav*0.25));
		else
			if veldir == -1 then
				npcxvel[index] = npcxvel[index]+PARAM.FRICTIONAIR;
			elseif veldir == 1 then
				npcxvel[index] = npcxvel[index]-PARAM.FRICTIONAIR;
			end
			npc.speedY = npc.speedY+(PARAM.GRAVITY*Defines.npc_grav);
		end
	end
	if veldir == 1 and npcxvel[index] < 0 then
		npcxvel[index] = 0;
	elseif veldir == -1 and npcxvel[index] > 0 then
		npcxvel[index] = 0;
	end
end

--makes chill penguin shoot an ice ball
function shootprojectile(index, npc)
	local numbah = rng.randomInt(1, 2);
	if npcdirection[index] == -1 then
		local iceball = NPC.spawn(PARAM.ICEBALLID, npc.x-2, npc.y+6, npc:mem(0x146, FIELD_WORD));
		iceball.direction = -1;
		if numbah == 1 then
			iceball.speedY = -2;
		else
			iceball.speedY = 0.1;
		end
	elseif npcdirection[index] == 1 then
		local iceball = NPC.spawn(PARAM.ICEBALLID, npc.x+PARAM.WIDTH+2, npc.y+6, npc:mem(0x146, FIELD_WORD));
		iceball.direction = 1;
		if numbah == 1 then
			iceball.speedY = -2;
		else
			iceball.speedY = 0.1;
		end
	end
	npcballcount[index] = npcballcount[index]-1;
end

--sets chill penguin's state
function setstate(index, npc, stateno)
	if stateno == 1 then --standing
		npcstate[index] = 1;
		npctimeaction[index] = rng.randomInt(66,100);
	elseif stateno == 2 then --priming jump
		npcstate[index] = 2;
		npcprimemove[index] = 30;
		npctimeframe[index] = 15;
		if npcdirection[index] == -1 then
			npc.animationFrame = PARAM.JUMPFRAME;
		elseif npcdirection[index] == 1 then
			npc.animationFrame = PARAM.JUMPFRAME+2;
		end
	elseif stateno == 3 then --priming attack
		npcstate[index] = 3;
		npcprimemove[index] = 30;
		npctimeframe[index] = 15;
		if npcdirection[index] == -1 then
			npc.animationFrame = PARAM.PREFRAME;
		elseif npcdirection[index] == 1 then
			npc.animationFrame = PARAM.PREFRAME+2;
		end
	elseif stateno == 4 then --slide attack
		npcstate[index] = 4;
		npctimeframe[index] = 15;
		if npc.underwater then
			npc.speedY = -1;
		else
			npc.speedY = -2;
		end
		if npcdirection[index] == -1 then
			npclastxpos[index] = npc.x + 1;
			npc.animationFrame = PARAM.SLIDEFRAME;
			if npc.underwater then
				npcxvel[index] = PARAM.SLIDESPEEDW*-1;
			else
				npcxvel[index] = PARAM.SLIDESPEED*-1;
			end
		elseif npcdirection[index] == 1 then
			npclastxpos[index] = npc.x - 1;
			npc.animationFrame = PARAM.SLIDEFRAME+2;
			npcxvel[index] = PARAM.SLIDESPEED;
			if npc.underwater then
				npcxvel[index] = PARAM.SLIDESPEEDW;
			else
				npcxvel[index] = PARAM.SLIDESPEED;
			end
		end
	elseif stateno == 5 then --ice ball attack
		npcstate[index] = 5;
		npcprimemove[index] = 20;
		npctimeframe[index] = 10;
		if npcdirection[index] == -1 then
			npc.animationFrame = PARAM.SPITFRAME;
		elseif npcdirection[index] == 1 then
			npc.animationFrame = PARAM.SPITFRAME+2;
		end
	elseif stateno == 6 then --ice breath
		npcstate[index] = 6;
		npcprimemove[index] = PARAM.ICEBREATHDUR;
		npcbreathdur[index] = PARAM.ICEBREATHDUR;
		npcbreathframe[index] = 1;
		npcbreathdir[index] = npcdirection[index];
		if npcdirection[index] == -1 then
			npcbreathlocx[index] = npc.x;
			npcbreathlocy[index] = npc.y+10;
		elseif npcdirection[index] == 1 then
			npcbreathlocx[index] = npc.x+PARAM.WIDTH;
			npcbreathlocy[index] = npc.y+10;
		end
		npctimeframe[index] = 10;
		if npcdirection[index] == -1 then
			npc.animationFrame = PARAM.SPITFRAME;
		elseif npcdirection[index] == 1 then
			npc.animationFrame = PARAM.SPITFRAME+2;
		end
	end
end

--finds and returns the location of a nearby pully
--returns nil if it can't find one
function locatepully(index, npc)
	local ysearch = PARAM.PULLSEARCHDISTY;
	if npc.underwater then
		ysearch = PARAM.PULLSEARCHDISTYW;
	end
	ysearch = ysearch - PARAM.HEIGHT;
	local blocktable = BGO.getIntersecting(npc.x-240, npc.y-ysearch, npc.x+PARAM.WIDTH+240, npc.y-PARAM.HEIGHT);
	for k, v in pairs(blocktable) do
		if v.isHidden == false then
			--we found it
			if v.id == PARAM.PULLYID then
				return v.x+(v.width*0.5);
			end
		end
	end
	return nil;
end

--checks if chill penguin's upper half is touching the pully
--returns the pully its touching
function touchedpully(index, npc, offsetcheck)
	local offsety = 0;
	if offsetcheck then
		offsety = PARAM.PULLYOFFSET[2];
	end
	local blocktable = BGO.getIntersecting(npc.x, npc.y+(offsety*-1), npc.x+PARAM.WIDTH, npc.y);
	for k, v in pairs(blocktable) do
		if v.isHidden == false then
			--we found it
			if v.id == PARAM.PULLYID then
				return v;
			end
		end
	end
	return nil;
end

--a function that controls chill penguin's ice breath
--because it's complicated/something I haven't done before
function icebreath(index, npc)
	if npc.collidesBlockBottom then
		if Defines.levelFreeze == false then
			if npcbreathdir[index] == -1 then
				npcbreathlocx[index] = npc.x;
				npcbreathlocy[index] = npc.y+10;
			elseif npcbreathdir[index] == 1 then
				npcbreathlocx[index] = npc.x+PARAM.WIDTH;
				npcbreathlocy[index] = npc.y+10;
			end
			if npcbreathdur[index] == PARAM.ICEBREATHDUR*0.5 then
				if npcbreathdir[index] == -1 then
					local icestatue = NPC.spawn(PARAM.STATUEID, npcbreathlocx[index]-160, npcbreathlocy[index], npc:mem(0x146, FIELD_WORD));
					icestatue.direction = npcbreathdir[index];
					icestatue = NPC.spawn(PARAM.STATUEID, npcbreathlocx[index]-80, npcbreathlocy[index], npc:mem(0x146, FIELD_WORD));
					icestatue.direction = npcbreathdir[index];
				elseif npcbreathdir[index] == 1 then
					local icestatue = NPC.spawn(PARAM.STATUEID, npcbreathlocx[index]+160, npcbreathlocy[index], npc:mem(0x146, FIELD_WORD));
					icestatue.direction = npcbreathdir[index];
					icestatue = NPC.spawn(PARAM.STATUEID, npcbreathlocx[index]+80, npcbreathlocy[index], npc:mem(0x146, FIELD_WORD));
					icestatue.direction = npcbreathdir[index];
				end
				
			end
			if npcbreathdur[index] >= 0 then
				npcbreathdur[index] = npcbreathdur[index] -1;
			end
			if npcbreathtime[index] <= 0 then
				if npcbreathdur[index] >= 1 then
					if npcbreathframe[index]+1 > 7 then
						npcbreathframe[index] = 5
					end
				end
				npcbreathframe[index] = npcbreathframe[index]+1;
				npcbreathtime[index] = 4;
			else
				npcbreathtime[index] = npcbreathtime[index] - 1;
			end
			if npcbreathdur[index]<= 0 and npcbreathtime[index] <= 0 and npcbreathframe[index] >= 12 then
			elseif npcbreathdir[index] == -1 then
				Graphics.drawImageToScene(fbl, npcbreathlocx[index]-196, npcbreathlocy[index], 0,((npcbreathframe[index]-1)*34),196,34);
			elseif npcbreathdir[index] == 1 then
				Graphics.drawImageToScene(fbr, npcbreathlocx[index], npcbreathlocy[index], 0,((npcbreathframe[index]-1)*34),196,34);
			end
			--hitbox data
			--fbxone[npcbreathframe[index]]
			if npcbreathframe[index] < 13 then
				if npcbreathdir[index] == -1 then
					local playertable = Player.getIntersecting(npcbreathlocx[index]-(192-fbxone[npcbreathframe[index]]), npcbreathlocy[index], npcbreathlocx[index]+fbxtwo[npcbreathframe[index]], npcbreathlocy[index]+fbframey);
					for index, v in pairs(playertable) do
						if index ~= nil then
							player:harm();
						end
					end
				elseif npcbreathdir[index] == 1 then
					local playertable = Player.getIntersecting(npcbreathlocx[index]-fbxtwo[npcbreathframe[index]], npcbreathlocy[index], npcbreathlocx[index]+(192-fbxone[npcbreathframe[index]]), npcbreathlocy[index]+fbframey);
					for index, v in pairs(playertable) do
						if index ~= nil then
							player:harm();
						end
					end
				end
			end
		else
			if npcbreathdur[index]<= 0 and npcbreathtime[index] <= 0 and npcbreathframe[index] >= 12 then
			elseif npcbreathdir[index] == -1 then
				Graphics.drawImageToScene(fbl, npcbreathlocx[index]-196, npcbreathlocy[index], 0,((npcbreathframe[index]-1)*34),196,34);
			elseif npcbreathdir[index] == 1 then
				Graphics.drawImageToScene(fbr, npcbreathlocx[index], npcbreathlocy[index], 0,((npcbreathframe[index]-1)*34),196,34);
			end
		end
		
	else
		npcbreathframe[index] = 13;
	end
end

--setups a registered npc
function npcinitialize(index, npc)
	if npc.dontMove then
		npcstate[index] = 0;
	else
		npcstate[index] = 1;
	end
	npc.dontMove = true;
	npcxvel[index] = 0;
	npclastxpos[index] = 0;
	npcdirection[index] = -1;
	npclastframe[index] = 0;
	npctimeframe[index] = 0;
	npcregister[index] = 2;
	npctimeaction[index] = 100;
	npcprimemove[index] = 0;
	if npc.legacyBoss then
		npchealth[index] = PARAM.MAXHP[2];
	else
		npchealth[index] = PARAM.MAXHP[1];
	end
	npchurt[index] = -2;
	npcmovetype[index] = 0;
	npcfrozentime[index] = -1;
	npctouchedpully[index] = -1;
	npcbreathframe[index] = 13;
	npcbreathtime[index] = 0;
	npcbreathdur[index] = 0;
	npcbreathlocx[index] = 0;
	npcbreathlocy[index] = 0;
	npcbreathdir[index] = 0;
	npcdead[index] = false;
end

--clears a npc's variables when it's no longer valid
--used when the code can no longer find an npc that belongs to a registered uid
function npcunregister(index, npc)
	npcregister[index] = -1;
	npcdead[index] = false;
end

--finds an array that was used but is now empty to assign the new chill penguins to
--this is mainly to reduce usage and because table.remove can break things
function assignnpc(npc)
	local foundspace = false;
	for index, var in pairs(npctable) do
		if npcregister[index] == -1 then
			npctable[index] = pNPC.wrap(npc)
			npcregister[index] = 1;
			foundspace = true;
			break;
		end
	end
	if foundspace == false then
		table.insert(npctable, pNPC.wrap(npc));
		table.insert(npcregister, 1);
	end
end

--setups a registered proj
function projinitialize(index, proj)
	projdead[index] = false;
	projlastframe[index] = 0;
	projtimeframe[index] = 30;
	if proj.id == PARAM.ICEBALLID then
		projdirection[index] = proj.direction;
		projhealth[index] = 1;
		if proj.speedY < 0 then
			projstate[index] = 1;
			projxvel[index]	= PARAM.ICEBALLSPDX*0.75;
		else
			projstate[index] = 2;
			projxvel[index]	= PARAM.ICEBALLSPDX;
		end
		projlastxpos[index] = 0;
		if projdirection[index] == -1 then
			projxvel[index] = projxvel[index]*-1;
		elseif projdirection[index] == 1 then
			projxvel[index] = projxvel[index]*1;
		end
		projhealth[index] = 0;
		projregister[index] = 2;
		proj.dontMove = true;
	elseif proj.id == PARAM.STATUEID then
		projstate[index] = 0;
		projdirection[index] = proj.direction;
		projxvel[index] = 0;
		projhealth[index] = PARAM.STATUEMAXHP;
		projlastxpos[index] = 0;
		proj.dontMove = true;
		projregister[index] = 2;
		if projdirection[index] == -1 then
			projlastframe[index] = 0;
			proj.animationFrame = projlastframe[index];
		elseif projdirection[index] == 1 then
			projlastframe[index] = 3;
			proj.animationFrame = projlastframe[index];
		end
	end
end

--clears a proj's variables when it's no longer valid
--used when the code can no longer find a proj that belongs to a registered uid
function projunregister(index, npc)
	projregister[index] = -1;
	projdead[index] = false;
end

--finds an array that was used but is now empty to assign the new projectiles to
--this is mainly to reduce usage
function assignproj(npc)
	local foundspace = false;
	for index, var in pairs(projtable) do
		if projregister[index] == -1 then
			projtable[index] = pNPC.wrap(npc)
			projregister[index] = 1;
			foundspace = true;
			break;
		end
	end
	if foundspace == false then
		table.insert(projtable, pNPC.wrap(npc));
		table.insert(projregister, 1);
	end
end

function npcisknown (npc)
	for index, v in pairs(npctable) do
		if pNPC.wrap(npc) == v then
			return true;
		end
	end
	return false;
end

function projisknown (npc)
	for index, v in pairs(projtable) do
		if pNPC.wrap(npc) == v then
			return true;
		end
	end
	return false;
end

function getnpcindex(npc)
	local index = -1;
	for k, v in pairs(npctable) do
		if v == pNPC.wrap(npc) then
			index = k;
			break
		end
	end
	return index;
end

function getprojindex(proj)
	local index = -1;
	for k, v in pairs(projtable) do
		if v == pNPC.wrap(proj) then
			index = k;
			break
		end
	end
	return index;
end

return chillpenguinAPI;