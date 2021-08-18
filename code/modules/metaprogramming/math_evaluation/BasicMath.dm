/*AbyssDragon.BasicMath v1.1
  written by AbyssDragon (abyssdragon@,molotov.nu)
  http://www.molotov.nu

  (used to be AbyssDragon.AbyssLibrary)

  Feel free to modify/improve/destroy/steal/use any of this code however you see fit.
  A thanks or mention in your project would be nice, but neither are required.

  This is a library of procs to do some basic math and geometrical things.
  Many of the procs in the old version of this have been invalidated since then and have been removed.
  A lot of these procs may be duplicated in other BYOND libraries/demos.  However, all of this code
  was written by me, or was adapted from C libraries/tutorials by me.
*/
//Some nice and lengthy mathematical constants.  BYOND rounds them off, but I like to have 'em handy anyway.
var/const/pi = 3.1415926535897932384626433832795
var/const/sqrt2 = 1.4142135623730950488016887242097
var/const/e = 2.7182818284590452353602874713527



/proc/xrange(atom/center, range)
	var/startx = center.x - range
	var/starty = center.y - range
	var/endx = center.x + range
	var/endy = center.y + range
	if(startx < 1) startx = 1
	if(starty < 1) starty = 1
	if(endx > world.maxx) endx = world.maxx
	if(endy > world.maxy) endy=world.maxy
	var/contents[] = list()
	for(var/turf/T in block(locate(startx, starty, center.z), locate(endx, endy, center.z)))
		contents += T
		contents += T.contents
	return contents

/proc/get_steps(atom/ref,dir,num)
	var/x
	var/turf/T=ref:loc
	if(isturf(ref))
		T=ref
	for(x=0;x<num;x++)
		ref=get_step(ref,dir)
		if(!ref)break
		T=ref
	return T

/proc/allclear(turf/T)
	if(isturf(T))
		if(T.density) return 0
	var/mob/M
	for(M as mob|obj in T)
		if(M.density)
			return 0
	return 1

/proc/cardinal(atom/ref)
	return (list(get_step(ref,NORTH),get_step(ref,SOUTH),get_step(ref,EAST),get_step(ref,WEST)))

/proc/cardinal_stuff(atom/ref)
	var/turfs[]=list(get_step(ref,NORTH),get_step(ref,SOUTH),get_step(ref,EAST),get_step(ref,WEST))
	var/stuff[]=list()
	var/turf/T
	for(T in turfs)
		stuff+=T.contents
	return stuff

/proc/midpoint(atom/M,atom/N)
	var/turf/T = locate((N.x + M.x)/2, (N.y + M.y)/2, (N.z + M.z)/2)
	return T

/proc/distance(atom/M,atom/N)
	return sqrt((N.x-M.x)**2 + (N.y-M.y)**2)

/proc/getring(atom/M, radius)
	var/ring[] = list()
	var/turf/T
	for(T as turf in range(radius+1,M))
		if(abs(distance(T, M)-radius) < 0.5)//The < 0.5 check is to make sure the ring is smooth
			ring += T
	return ring

/proc/getcircle(atom/M, radius)
	var/list/circle = list()
	var/turf/T
	for(T as turf in range(radius+3,M))		//The < 0.5 check is to ensure it has the same shape as
		if(distance(T, M) < radius + 0.5) 	//a get_ring() of the same radius
			circle += T
	return circle
