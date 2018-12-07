--------------------
--gameplay methods--
--------------------
function gameover()
 pause(100,5)
 pac.h=1
 f_spawn.h=1
 for o in all(enes)do
  o.x=-999
  o.y=-999
 end
end

function next_round()
 pause(100,4)
end

function new_round()
 --reset gameplay values
 ai_mode=0
 ai_mode_timer=0
 scared_timer=0
 pause_t=0
 pause_m=0
 eat_gid=0
 eat_c=0
 release_flag=0
 f_spawn.h=1

 --place the player
 pac.x=p_spawn.x
 pac.y=p_spawn.y
 pac.h=0--not hidden
 pac.a=0--reset animation
 pac.xm=1--reset direction
 pac.ym=0

 --player animation
 pac.as=0
 pac.al=1--loop
 pac.sa=1

 --reset the camera
 cam.reset=1
 cam_player()

 --place the pen ghosts
 for p in all(pen)do
  local o=enes[pen_o[p.i]]
  o.x=p.x
  o.y=p.y
  o.m=1
  o.t=p.i%2
  o.xm=1
  o.ym=0
  o.r=0
 end

 --place the spawn ghosts
 for s in all(g_spawn)do
  local o=enes[s.gid]
  o.x=s.x
  o.y=s.y
  --set to roam mode
  o.m=2
  --set direction
  o.xm=1
  o.ym=0
 end

 restore(1)

 --start of game ready
 pause(50,1,1)
end

function power()
 for i=1,4,1 do
  local o=enes[i]
  --not eatten
  if(o.sc!=2)then
   o.sc=1
   o.c=1
   o.a=0
   o.as=64
   o.ae=65
   reverse(o)
  end
 end
 scared_timer=gv.gft
end

function eat(o)
 o.m=4
 o.sc=2
 o.c=0
 o.h=1
 eat_gid=o.i
 score+=20*pow(2,eat_c)
 eat_c=min(eat_c+1,4)
 pac.h=1
 pause(30,2)
end

function restore_anim(o)
 --get ghost color
 col=ghost_cols[o.i]
 o.c=col
 o.as=96
 o.ae=97
 o.h=0
end

function restore(f)
 local f=f or 0
 eat_c=0
 scared_timer=0
 for i=1,4,1 do
  local o=enes[i]
  --is scared?
  if(o.sc==1 or f==1)then
   o.sc=0
   restore_anim(o)
   if(f==0)then
    reverse(o)
   end
  end
 end
end

function reverse(o)
 o.r=1
end

function release(o)
 if(release_flag==1)then
  return
 end
 if(o.sc==0 and o.m==1)then
  o.m=5
  release_flag=1
 end
end

function pause(t,m,a)
 pause_t=t or 10
 pause_m=m or 0
 pause_a=a or 0
end

function prc_pause()
 if(pause_t>0)then
  if(pause_t==1)then
   pause_a=0
   pause_m=0
   eat_gid=0
   pac.h=0
  end
  pause_t-=1
 end
end

function prc_fruit()
 if(f_spawn.h!=1)then
  f_spawn.t-=1
  if(f_spawn.t<=0)then
   f_spawn.h=1
  end
 end
end

--pacman dies
function die()
 pause(60,3)
end

function blink_map()
 map_blink+=1
 if(map_blink==12)then
  map_c=7
 elseif(map_blink==24)then
  map_c=map_color()
  map_blink=0
 end
end

function map_color()
 return map_cs[(level%8)+1]
end

function spawn_fruit()
 f_spawn.h=0
 f_spawn.t=300
end

function eat_fruit()
 f_spawn.h=2
 f_spawn.t=100
 local n=min(level+1,8)
 score+=f_bonus[n]
end

function cam_player()
 --follow the player
 cam.tox=cx-(cx-pac.x)*0.3
 cam.toy=cy-(cy-pac.y)*0.5
end

--gets the game values
--for the current level
function set_level_values()
 sm=1.3
 gv={}
 --player speed
 local ps=
  {80,90,90,90,100,100,100,90}
 --player frightened speed
 local pfs=
  {90,95,95,95,100,100,100,100}

 --ghost speed
 local gs=
  {75,85,85,85,95}
 --ghost tunnel speed
 local gts=
  {40,45,45,45,50}
 --ghost frightened speed
 local gfs=
  {50,55,55,55,60}

 --ghost frightned timer
 local gft=
  {6,5,4,3,2,5,2,2,1,5,2,1}

 --red speedup speeds
 local es1=
  {80,90,90,100,100}
 local es2=
  {85,95,95,95,105}

 local n=min(level+1,8)
 gv.ps=ps[n]*0.01*sm
 gv.pfs=pfs[n]*0.01*sm

 n=min(n,5)
 gv.gs=gs[n]*0.01*sm
 gv.gts=gts[n]*0.01*sm
 gv.gfs=gfs[n]*0.01*sm

 n=min(level+1,12)
 gv.gft=gft[n]*30

 n=min(n,5)
 gv.es1=es1[n]*0.01*sm
 gv.es2=es2[n]*0.01*sm

 gv.edl1=min(20+(level*10),120)
 gv.edl2=flr(gv.edl1/2)
end

function play_snd(i)
 sfx(i,i)
end

function stop_snd(i)
 sfx(-1,i)
end
