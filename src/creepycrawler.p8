pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- creepy crawlers
-- by natalie garza
-- version 0.1

-- global vars
	allbutts={0,1,2,3,4,5}
 zbutt={4}
 xbutt={5}
  
 sound=true

function _init()
  splash_init()
end

function _update()
	update()
end

function _draw()
	draw()
end

function buttpress(butts,newstate)
	for i=1,#butts do
		if(btnp(butts[i])) newstate()
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

function play_init()
	update=play_update
 draw=play_draw
end

function play_update()
	buttpress(zbutt,end_init)
	buttpress(xbutt,togglesound)
end

function play_draw()
	cls()	
	print('play screen\n')
	print(sound)
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
