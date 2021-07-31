/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/asteroid/mine/biome/asteroids/explored
	name = "Mine"
	icon_state = "explored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)


/area/asteroid/mine/biome/asteroids/unexplored
	name = "Mine"
	icon_state = "unexplored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)

/area/asteroid/mine/biome/asteroids/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/asteroid/mine/biome/asteroids/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/asteroid/mine/biome/asteroids/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/asteroid/mine/biome/asteroids/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/asteroid/mine/biome/asteroids/maintenance
	name = "Mining Station Communications"

/area/asteroid/mine/biome/asteroids/west_outpost
	name = "West Mining Outpost"

/area/asteroid/mine/biome/asteroids/dwarf
	name = "Dwarf"
	icon_state = "dwarf"



/area/asteroid/mine/biome
	var/basetype_turf = /turf/simulated/floor/plating/airless/asteroid
	var/cave_chance = 2
	var/cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave

	var/enforce_air = FALSE

/turf/simulated/floor/plating/airless/asteroid/cave/ironsand
	basetype = /turf/simulated/floor/plating/ironsand

/area/asteroid/mine/biome/normal
	name = "Normal"
	icon_state = "ast-normal-biome"

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/fungal
	name = "Fungal"
	icon_state = "ast-fungal-biome"

	cave_chance = 3

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/glow_cave
	name = "Glow Cave"
	icon_state = "ast-glow_cave-biome"

	cave_chance = 3

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/dark_horror
	name = "Dark Horror"
	icon_state = "ast-dark_horror-biome"

/area/asteroid/mine/biome/ice
	name = "Ice"
	icon_state = "ast-ice-biome"

	cave_chance = 4

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/lor
	name = "Lots of Resources"
	icon_state = "ast-resources-biome"

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/hollow_horror
	name = "Hollow Horror"
	icon_state = "ast-hollow_horror-biome"


	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/asteroids
	name = "Asteroids"
	icon_state = "ast-asteroids-biome"

/area/asteroid/mine/biome/ruins
	name = "Ruins"
	icon_state = "ast-ruins-biome"

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/flesh
	name = "Flesh"
	icon_state = "ast-flesh-biome"

	cave_chance = 3

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE

/area/asteroid/mine/biome/boney_creaks
	name = "Boney Creaks"
	icon_state = "ast-boney_hills-biome"

	cave_chance = 4

	basetype_turf = /turf/simulated/floor/plating/ironsand
	cave_turf = /turf/simulated/floor/plating/airless/asteroid/cave/ironsand

	enforce_air = TRUE
