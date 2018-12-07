----------------
--draw methods--
----------------
function title_draw()
 cls()
 pal()
 palt()
 camera()

 --title logo draw
 local ty=7

 --top/bottom
 for i=0,11,1 do
  spr(141,16+i*8,ty)
  spr(141,16+i*8,24+ty,1,1,false,true)
 end

 --edges
 spr(156,8,8+ty)
 spr(156,8,16+ty,1,1,false,true)
 spr(156,112,8+ty,1,1,true)
 spr(156,112,16+ty,1,1,true,true)
 spr(140,8,0+ty)
 spr(140,8,24+ty,1,1,false,true)
 spr(140,112,0+ty,1,1,true)
 spr(140,112,24+ty,1,1,true,true)

 --middle
 spr(128,16,8+ty,12,2)

 --hi score
 print("hi-score "..hiscore..0,35,1,7)

 --ghosts
 print("character / nickname",30,40,7)

 local n=flr(title_timer/20)

 if(n>0)then
  spr(32,16,49)
 end
 if(n>1)then
  print('-chaser     "elroy"',30,50,8)
 end
 if(n>2)then
  spr(33,16,59)
 end
 if(n>3)then
  print('-trapper    "lexaloffle"',30,60,14)
 end
 if(n>4)then
  spr(34,16,69)
 end
 if(n>5)then
  print('-snapper    "zep"',30,70,12)
 end
 if(n>6)then
  spr(35,16,79)
 end
 if(n>7)then
  print('-pico       "siapran"',30,80,9)
 end

 if(n>8)then
  --scoring
  spr(12,25,103)
  print("10 pts",33,104,7)
  spr(13,63,103)
  print("50 pts",73,104,7)
 end

 if(n>9)then
  --pamco
  spr(176,39,112,6,1)
 end

 --credits
 print("credits  0",1,123,7)
 print("game by urbanmonk",60,123,5)

 for o in all(actors)do
  draw_actor(o)
 end

 if(pause_m==2)then
  palt(0,false)
  palt(1,true)
  spr(66+eat_c*2,pac.x-4,pac.y,2,1)
 end

end

function game_draw()
 cls()
 palt()

 --map color
 pal(12,map_c)
 --draw map
 map(msh,0,0,0,msh+19,21,0x1)
 pal()

 --draw dots
 for o in all(dots)do
  spr(di[o.t],o.x,o.y)
 end

 --draw fruit
 draw_fruit()

 --draw scared ghosts first
 for o in all(enes)do
  if(o.m==3)then
   draw_actor(o)
  end
 end

 --draw the player
 draw_actor(pac)

 --draw nonscared ghosts last
 for o in all(enes)do
  if(o.m!=3)then
   draw_actor(o)
  end
 end

 if(pause_m==1)then
  --ready
  spr(84,f_spawn.x-12,f_spawn.y,4,1)
 end

 if(pause_m==5)then
  --gameover
  spr(88,f_spawn.x-19,f_spawn.y,6,1)
 end

 if(map_id==0)then
  --warp area fades
  palt(0,false)
  palt(8,true)
  spr(14,0,72,2,1)
  spr(14,136,72,2,1,1)
  rectfill(-8,72,0,80,0)
  rectfill(152,72,160,80,0)
 end

 gui_draw()
end

function gui_draw()

 --draw the eat score
 if(pause_m==2)then
  palt(0,false)
  palt(1,true)
  local o=enes[eat_gid]
  local ex=o.x-5
  local ey=o.y
  local n=68+(eat_c-1)*2
 	spr(n,ex,ey,2,1)
 end

 camera()

 rectfill(0,0,127,6,0)

 if(mode==1)then
  print(score..0,100,1,7)
  print("hi  "..hiscore..0,3,1,8)

  rectfill(0,119,127,127,0)

  --lives display
  palt()
  for i=1,lives,1 do
   spr(2,(i-1)*9,120,1,1,1)
  end

  --level icons
  for i=0,min(level,10),1 do
   spr(112+i,120-i*9,120)
  end
 else
  print("demo",57,1,7)
 end
end

function draw_actor(o)

 --not hidden
 if(o.h==0)then
  --setup pal swap
  pal(1,o.c)
  --get animation frame
  local f=
   min(o.as+o.a+0.4,o.ae)
  --draw
  spr(f,o.x,o.y,1,1,o.fx,o.fy)
  pal() --reset pal swap
 end

 if(pause_a==0)then
  --animation
  o.a+=o.sa
  if(o.a>o.ae-o.as)then
   if(o.al==1)then
    o.a=0
   else
    o.a=o.ae-o.as
   end
  end
 end

 --draw ghost eyes
 if(o.i>0
  and o.sc!=1
  and eat_gid!=o.i)then
  --get direction
  local d=get_sdir(o)
  spr(80+d,o.x,o.y)
 end

end

function draw_fruit()
 if(f_spawn.h==0)then
  local n=112+(level%11)
  spr(n,f_spawn.x,f_spawn.y)
 elseif(f_spawn.h==2)then
  palt(0,false)
  palt(1,true)
  local n=160+min(level,8)*2
  local fx=f_spawn.x-4
  local fy=f_spawn.y
 	spr(n,fx,fy,2,1)
 end
end

--title screen
function title_update()
 title_timer+=1

 prc_pause()

 if(pause_m==0)then
  for o in all(actors)do
   o.x+=o.xm o.y+=o.ym
  end
 end

 if(title_timer==200)then
  for i=1,4,1 do
   local g=new_ghost(i)
   g.x=138+i*9
   g.y=91
   g.xm=-1.08
  end

  pdot=new_actor(10,91,13,13)
  pac=new_actor(127,91,0,4)
  pac.xm=-1
  pac.sa=1
  pac.fx=true
  eat_c=0
 end

 if(pac!=nil)then
  if(gdist(pac,pdot)<3)then
   del(actors,pdot)
   pac.xm=1
   pac.fx=false
   for o in all(enes)do
    o.as=64 o.ae=65 o.sc=1
    o.xm=0.5 o.s=0.5
   end
  end

  for o in all(enes)do
   if(gdist(pac,o)<3)then
    pause(30,2)
    pac.h=1
    eat_c+=1
    del(actors,o)
    del(enes,o)
   end
  end
 end

 if(title_timer>520)then
  game_init()
  mode=2
 end
end

--main game
function game_update()
 prc_pause()

 --not paused
 if(pause_m==0)then
  play_loop()

 --death animation
 elseif(pause_m==3)then
  if(pause_t==40)then
   for o in all(enes)do
    o.x=-1000
    o.y=-1000
   end
   pac.a=0
   pac.as=98
   pac.ae=107
   pac.sa=1
   pac.al=0
   pac.fx=false
   pac.fy=false
  elseif(pause_t==1)then
   if(mode==1)then
    if(lives>0)then
     new_round()
     lives-=1
    else
     gameover()
    end
   else
    title_init()
   end
  end

 --next level animation
 elseif(pause_m==4)then
  if(pause_t<80)then
   blink_map()
  end
  if(pause_t==80)then
   for o in all(enes)do
    o.x=-1000
    o.y=-1000
   end
   pac.h=1
  elseif(pause_t==1)then
   level+=1
   load_map()
  end

 --gameover
 elseif(pause_m==5)then
  if(pause_t==1)then
   title_init()
  end
 end

 --process the camera
 if(cam.reset==1)then
  cam.x=cam.tox
  cam.y=cam.toy
  cam.reset=0
 end

 cam.x+=(cam.tox-cam.x)*0.14
 cam.y+=(cam.toy-cam.y)*0.14
 camera(cam.x-63,cam.y-63)
end

--processes gameplay
function play_loop()
 if(mode==1)then
  --read user input
  if(btn(0))then--left
   new_dir(pac,-1,0)
  elseif(btn(1))then--right
   new_dir(pac,1,0)
  elseif(btn(2))then--up
   new_dir(pac,0,-1)
  elseif(btn(3))then--down
   new_dir(pac,0,1)
  end
 else
  --attract mode
  atr_mv(pac)
 end

 --ghost ai
 for o in all(enes)do
  pr_g(o)
 end

 --scared mode timer
 if(scared_timer>0)then
  scared_timer-=1
  if(scared_timer<80)then
   for i=1,4,1 do
    local o=enes[i]
    if(o.sc==1)then
     o.ae=67
    end
   end
  end
  if(scared_timer==1)then
   restore()
  end
 else
  --ai mode switching
  ai_mode_timer+=1
  if((ai_mode==0 and
   ai_mode_timer>30*7)
   or (ai_mode==1 and
   ai_mode_timer>30*20))then
    ai_mode=1-ai_mode
    ai_mode_timer=0
    for i=1,4,1 do
     local o=enes[i]
     if(o.m==2)then
      reverse(o)
     end
    end
  end
 end

 --actor control
 for o in all(actors) do
  --check for collisions
  if(col_ck(o)==false)then
   o.x+=o.xm*o.s
   o.y+=o.ym*o.s
   if(o==pac)then
    o.sa=1
   end
  else
   if(o==pac)then
    o.a=2 --pac animation freeze
    o.sa=0
   end
   o.it=0
   --snap to grid if colliding
   o.x=flr((o.x+4)/8)*8
   o.y=flr((o.y+4)/8)*8
  end

  --screen wrapping
  if(o.x>cx*2-6)then
   o.x=0
  end
  if(o.x<-4)then
   o.x=cx*2-6
  end
 end

 --set player speed
 pac.s=gv.ps

 --dots
 for o in all(dots)do
  --check dist from player
  if(gdist(o,pac)<3)then
   --slow player
   pac.s=gv.ps*0.5
   if(o.t==2)then
    power()
    score+=5
   else
    score+=1
   end
   del(dots,o)
   dot_c-=1

   --release ghosts from pen
   --based on the amount eatten
   local e=dot_sc-dot_c
   if(e>1)then
    release(enes[2])
   end
   if(e>30)then
    release(enes[3])
   end
   if(e>60)then
    release(enes[4])
   end
   --ghost speedup
   if(dot_c<gv.edl1)then
    enes[1].ss.s=gv.es1
   end
   if(dot_c<gv.edl2)then
    enes[1].ss.s=gv.es2
   end
   --spawn fruit
   if(e==120)then
    spawn_fruit()
   end
   --end of the round
   if(dot_c==0)then
    next_round()
   end
  end
 end

 --fruit eat
 if(f_spawn.h==0
  and gdist(f_spawn,pac)<3)then
  eat_fruit()
 end

 --process fruit
 prc_fruit()

 --ghost collisions
 for o in all(enes)do
  --check dist from player
  if(gdist(o,pac)<3)then
   --scared?
   if(o.sc==0)then
    die()
   elseif(o.sc==1)then
    eat(o)
   end
   break
  end
 end

 --update player animation
 if (pac.xm!=0)then
  pac.as=0 pac.ae=4
  pac.fx=(pac.xm<0)
 else
  pac.as=16 pac.ae=20
  pac.fy=(pac.ym<0)
 end

 --update hi score
 if(score>hiscore)then
  hiscore=score
 end

 --camera follow the player
 cam_player()
end
