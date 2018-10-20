pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- creepy crawlers
-- by natalie garza
-- version 0.2

function _init()
 allbutts={0,1,2,3,4,5}
 zbutt={4}
 xbutt={5}

 sound=true

 splash_init()
end

function _update()
	update()
end

function _draw()
	draw()
end

function buttpress(butts,dothis)
	for i=1,#butts do
		if(btnp(butts[i])) dothis()
	end
end

function togglesound()
	if(sound==true) then
		sound=false
	else sound=true end
end
-->8
-- splash screen state

function splash_init()
 update=splash_update
	draw=splash_draw
end

function splash_update()
	buttpress(allbutts,menu_init)
end

function splash_draw()
	cls()
	print('splash screen\n')
end
-->8
-- menu screen state

function menu_init()
 update=menu_update
	draw=menu_draw
end

function menu_update()
	buttpress(zbutt,play_init)
	buttpress(xbutt,togglesound)
end

function menu_draw()
	cls()
	print('menu screen\n')
	print(sound)
end

-->8
-- play game state

-- flags
-- wall:0
-- spawn spot:1
-- tunnel:2
-- enemyhead:3
-- enemybody:4
-- playerhead:5
-- playerbody:6


function play_init()
 update=play_update
 draw=play_draw

 centerX=108
 centerY=120

--left,right,up,down
 ways={}
 left={-1,0}
 right={1,0}
 up={0,-1}
 down={0,1}
 add(ways,left)
 add(ways,right)
 add(ways,up)
 add(ways,down)
 newWay=ways[1]

-- these are all the tiles where actors have to make_bug
-- a decision on where to turn {x,y}
 forks={{6,1},{21,1},{11,3},{16,3},{3,7},{24,7},{11,6},
  {15,6},{12,9},{15,9},{9,11},{12,11},{15,11},{18,11},
  {1,12},{4,12},{7,12},{20,12},{23,12},{26,12},{23,18},
  {20,16},{17,16},{15,16},{12,16},{10,16},{7,16},{4,18},
  {7,18},{4,18},{7,19},{10,19},{11,19},{16,19},{17,19},
  {20,19},{4,21},{23,21},{16,22},{11,22},{23,24},{18,24},
  {9,24},{4,24},{1,26},{4,26},{23,26},{26,26},{18,27},
  {12,27},{9,27},{4,29},{23,29},{20,18},{15,24},{12,24},{15,27}}

 cam={}
 cam.x=0
 cam.y=0
 cam.toX=0
 cam.toY=0

 crawlers={}
 bugs={}

-- timer
 t=0

 pl=make_crawler(112,152)
 pl.sprite=32

 -- start by going right
 change_dir(pl,-1,0)

 -- for development purposes
 -- delete later
 make_bug(112,128)
 change_dir(bugs[1],-1,0)
end

function play_update()
	buttpress(zbutt,end_init)
	buttpress(xbutt,togglesound)

  update_game()
	update_crawlers()
  update_bugs()
end

function play_draw()
	cls()
	map(0,0,0,0,28,31)

	draw_crawlers()
  draw_bugs()
  print(flr(rnd(4)+1),pl.x-16,pl.y)
  print(pl.x, pl.x-16,pl.y+8)
  print(pl.y, pl.x-16,pl.y+16)
end

-- [[ Make Methods For Play State ]]

function make_bug(x,y)
  local b={}
  b.x=x
  b.y=y
  b.speed=.8
  b.dx=0
  b.dy=0
  b.sprite=34
  -- bug updated 30/sec
  -- 20 secs default life
  b.lifecyle=600
  --states:
  --1=crawl/wander
  --2=evade
  b.state=1

  add(bugs,b)
end

function make_crawler(x,y)
	local c={}
	-- position
	c.x=x
	c.y=y
	-- movement
	c.speed=1
	c.dx=0
  c.dy=0
  -- animation
	c.sprite=16

  -- body
  c.length=0
  c.maxLength=10
  c.tail={}

  add(crawlers,c)
	return c
end

function tail_node(a,x,y,sp)
  local t={}
  t.x=x
  t.y=y
  t.node=a.length+1
  t.sprite=sp or 33

  add(a.tail,t)
end

-- [[ Update Methods For Play State ]]

function update_game()
  if(cam.toX<64) then
    cam.toX=64
  end
  if(cam.toX>160) then
    cam.toX=160
  end
  cam.x+=(cam.toX-cam.x)*0.14

  if(cam.toY<64) then
    cam.toY=64
  end
  if(cam.toY>160) then
    cam.toY=190
  end
  cam.y+=(cam.toY-cam.y)*0.14

  camera(cam.x-63,cam.y-63)

end

function update_crawlers()
  -- left
	if(btn(0)) then
		change_dir(pl,-1,0)
  -- right
	elseif(btn(1)) then
    change_dir(pl,1,0)
  -- up
	elseif(btn(2)) then
    change_dir(pl,0,-1)
  -- down
	elseif(btn(3)) then
    change_dir(pl,0,1)
	end

  t+=1
  for a in all(crawlers) do

    --bug collision and +1 tail node of same sprite
    for b in all(bugs) do
      if(bugColl(a,b))then
        -- add a node to beginning identical
        local newTail={}
        add(newTail,tail_node(a,a.x,a.y))
        -- add the rest so that the newTail goes:
        -- {head,first,second,...,last}
        for q in all(a.tail) do
          add(newTail,q)
        end
        a.tail=newTail
        a.length+=1
      end
    end

    -- if not colliding with wall update x and y accordingly
    if(wallColl(a)==false)then
      if(t>=8 and a.length!=0) then
        -- old head coordinates become first tail node
        tail_node(a,a.x,a.y,a.tail[1].sprite)
        -- delete position of last tail node
        del(a.tail,a.tail[1])
        t=0
      end
      a.x+=a.dx*a.speed
      a.y+=a.dy*a.speed
    -- if colliding with wall snap to grid
    else
      if(t>=8 and a.length!=0) then
        -- old head coordinates become first tail node
        tail_node(a,a.x,a.y,a.tail[1].sprite)
        -- delete position of last tail node
        del(a.tail,a.tail[1])
        t=0
      end
     a.x=flr((a.x+4)/8)*8
     a.y=flr((a.y+4)/8)*8
    end

    -- screen wrapping
    if(a.x>centerX*2-6)then
      a.x=0
    end
    if(a.x<-4)then
      a.x=centerX*2-6
    end
  end

  cam_player()
end

function update_bugs()
-- needs path choosing mechanism...
-- after path choosing implemented then
-- needs an algorithm for each state of the bug
-- then needs a spawning feature added.

  for b in all(bugs) do

    -- if not colliding with wall update x and y accordingly
    if(wallColl(b)==false and atFork(b)==false)then
      b.x+=b.dx*b.speed
      b.y+=b.dy*b.speed
    -- if colliding with wall or at a fork change_dir based on bug state
    else
     --b.x=flr((b.x+4)/8)*8
     --b.y=flr((b.y+4)/8)*8
      if(b.state==1) then -- crawl/wander
        -- randomly choose a direction
        while(wallColl(b)==true) do
          newWay=ways[flr(rnd(4)+1)]
          change_dir(b,newWay[1],newWay[2])
        end
        b.x+=b.dx*b.speed
        b.y+=b.dy*b.speed
      else -- state==2, evade

      end
    end

    -- screen wrapping
    if(b.x>centerX*2-6)then
      b.x=0
    end
    if(b.x<-4)then
      b.x=centerX*2-6
    end
  end
end

-- [[ Additional Methods For Play State ]]

-- follow player around map
function cam_player()
  cam.toX=centerX-(centerX-pl.x)*.9
  cam.toY=centerY-(centerY-pl.y)*.9
end

-- return true if colliding with wall
function wallColl(a,dx,dy,xs,ys)
  dx=dx or a.dx
  dy=dy or a.dy

  local x=a.x-(xs or 0)
  local y=a.y-(ys or 0)

  if(dy!=0) x=flr((x+4)/8)*8
  if(dx!=0) y=flr((y+4)/8)*8

  -- get tile ahead of crawler
  local xtile=flr((x+min(dx,0))/8)+max(dx,0)
  local ytile=flr((y+min(dy,0))/8)+max(dy,0)

  return(fget(mget(xtile,ytile), 0))
end

function atFork(b)
  local bugXTile=flr(b.x)
  local bugYTile=flr(b.y)

  for f in all(fork) do
    if(bugXTile==f[1] and bugYTile==f[2]) return true
  end

  return false
end

-- return true if crawler colliding with bug
function bugColl(a,b)
  local axTile=flr(a.x)
  local ayTile=flr(a.y)
  local bxTile=flr(b.x)
  local byTile=flr(b.y)

  if(axTile==bxTile and ayTile==byTile) return true
end

-- update crawler dx and dy if possible
function change_dir(a,dx,dy)
 if(wallColl(a,dx,dy)==false and
    wallColl(a,dx,dy,a.x*2,a.y*2)==false) then
   a.dx=dx or 0
   a.dy=dy or 0
  if(a.dy!=0) then
     a.x=flr((a.x+4)/8)*8
  elseif(a.dx!=0) then
     a.y=flr((a.y+4)/8)*8
  end
 end
end

-- [[ Draw Methods For Play State ]]

function draw_crawlers()
  local sx=0
  local sy=0

  for crawler in all(crawlers) do
    -- draw tail
    for node in all(crawler.tail) do
      sx=(node.x*8)/8
      sy=(node.y*8)/8
      spr(node.sprite,sx,sy)
    end
    -- draw head
    sx=(crawler.x*8)/8
    sy=(crawler.y*8)/8
    spr(crawler.sprite,sx,sy)
  end
end

function draw_bugs()
  local sx=0
  local sy=0

  for bug in all(bugs) do
    sx=(bug.x*8)/8
    sy=(bug.y*8)/8
    spr(bug.sprite,sx,sy)
  end
end

-->8
-- end of game state

function end_init()
	update=end_update
	draw=end_draw

end

function end_update()
		buttpress(allbutts,menu_init)
end

function end_draw()
	cls()
	print('end screen\n')
end
-->8
-- actors code





__gfx__
00000000333333330b3333330b3333b0333333b0000000000b333333333333b000000000000000000b3333b00b3333330b3333b00b333333333333b033333333
00000000333333330b333333b33333b0333333b0bbbbbbbb0b333333333333b0bbbbbb0000bbbbbb0b3333b00b3333330b33333b0b333333333333b033333333
00700700333333330b333333333333b0333333b0333333330b333333333333b033333bb00bb333330b3333b00b3333330b3333330b333333333333b033333333
00077000333333330b333333333333b0333333b0333333330b333333333333b0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00077000333333330b333333333333b0333333b0333333330b333333333333b0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00700700333333330b333333333333b0333333b0333333330bb3333333333bb0333333b00b3333330b3333b00b3333330b3333330b333333333333b033333333
00000000333333330b33333b333333b0b33333b0bbbbbbbb00bbbbbbbbbbbb00333333b00b3333330b3333b00b33333b0b3333330b333333333333b0bbbbbbbb
00000000333333330b3333b0333333b00b3333b0000000000000000000000000333333b00b3333330b3333b00b3333b00b3333330b333333333333b000000000
333333330b333333333333b033333333333333b00b3333330b3333b00b3333b000000000000000000b3333b0333333b00b3333b0000000000000000000000000
33333333b33333333333333b333333333333333bb33333330b33333bb33333b0bbbbbb0000bbbbbb0b33333b333333b0b33333b0bbbbbbbbbbbbbbbbbbbbbbbb
3333333333333333333333333333333333333333333333330b333333333333b033333bb00bb333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330b333333333333b0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330b333333333333b0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333333333333333333333333333333333333333333330bb3333333333bb0333333b00b3333330b333333333333b0333333b0333333333333333333333333
3333333b3333333333333333b3333333bbbbbbbbbbbbbbbb00bbbbbbbbbbbb00b33333b00b33333b0b333333b33333b0333333b033333333b33333333333333b
333333b033333333333333330b333333000000000000000000000000000000000b3333b00b3333b00b3333330b3333b0333333b0333333330b333333333333b0
005580000055d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d5600000d5555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5558000d55655550007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d655000d65555d5d0088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd55d55dd55555d0087880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd65555ddd655d6d0008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddd56d00dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dd6d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010101010101010101010101010101010101010101010101010101010101204080000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1905050505050505050505051e1d1d1f05050505050505050505051800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000d01010e00000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00091d1d0800091d1d0800060f0f0700091d1d0800091d1d08000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060f130e00060f130e0000000000000d100f07000d100f07000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000000d0e0000000d0e00091d1d08000d0e0000000d0e0000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1d08000d121d0800060700060f0f0700060700091d110e00091d1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0f0700060f0f07000000000000000000000000060f0f0700060f1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000091d1d0800090800091d1d08000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00090800090800060f130e000607000d100f07000908000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e000d0e0000000d0e000000000d0e0000000d0e000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e000d121d0800060700090800060700091d110e000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700060f0f07000000000d0e00000000060f0f07000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000000000000000000908000d0e0009080000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00091d1d1d0800091d110e000d0e000d121d0800091d1d1d08000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060f0f130e000d01010e000d0e000d01010e000d100f0f07000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000000000d0e00060f0f0700060700060f0f07000d0e000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1d1d08000d0e00000000000000000000000000000d0e00091d1d1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060f0f0700060700090800091d1d1d1d0800090800060700060f0f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000060700060f0f0f0f07000607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
091d1d080009080000000000000000000000000000090800091d1d0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0f0f0700060700091d0800091d1d0800091d0800060700060f0f1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000020f07000613100700060f04000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00090800091d1d03000000000d0e000000000c1d1d08000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e00060f0f0700090800060700090800060f0f07000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000d0e0000000000000d0e000000000d0e0000000000000d0e000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700091d1d08000d0e000908000d0e00091d1d08000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000000000d100f07000607000d0e00060700060f130e000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000908000d0e0000000000000d0e0000000000000d0e000908000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00060700060700091d1d0800060700091d1d08000607000607000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a000000000000000d01010e000000000d01010e000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1605050505050505150f0f1405050505150f0f14050505050505051700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
