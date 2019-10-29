/obj/item/wand_component/selfcast
	name = "selfcast wand component"
	desc = "Allows the wand to cast spells unto the caster."
	add_flags = list(WAND_COMP_SELFCAST = TRUE)



/obj/item/wand_component/otherscast
	name = "otherscast wand component"
	desc = "Allows the wand to cast spells unto others."
	add_flags = list(WAND_COMP_OTHERSCAST = TRUE)



/obj/item/wand_component/areacast
	name = "areacast wand component"
	desc = "Allows the wand to cast spells unto an area."
	add_flags = list(WAND_COMP_AREACAST = TRUE)



/obj/item/wand_component/passivecast
	name = "passivecast wand component"
	desc = "Allows the wand to cast passive spells."
	add_flags = list(WAND_COMP_PASSIVECAST = TRUE)



/obj/item/wand_component/reloadmove
	name = "reloadmove wand component"
	desc = "Allows the wand to reload on the go."
	add_flags = list(WAND_COMP_RELOADMOVE = TRUE)



/obj/item/wand_component/brawl
	name = "brawling wand component"
	desc = "Allows to be in close-quarters casting."
	add_flags = list(WAND_COMP_MELEEMAGICCAST = TRUE, WAND_COMP_RELOADMOVE = TRUE)
	color = "#ff0000"



/obj/item/wand_component/enchanting
	name = "enchanting wand component"
	desc = "Allows to be effective at enchanting stuff."
	add_flags = list(WAND_COMP_ENCHANTCAST = TRUE, WAND_COMP_SELFCAST = TRUE)
	color = "#00ffff"



/obj/item/wand_component/wizardry
	name = "wizardry wand component"
	desc = "Allows to be effective at long-range casting on the go."
	add_flags = list(WAND_COMP_OTHERSCAST = TRUE, WAND_COMP_RELOADMOVE = TRUE)
	color = "#0000ff"



/obj/item/wand_component/tomfoolery
	name = "tomfoolery wand component"
	desc = "Allows to be effective at doing nothing useless. Except buffing thyself, probably."
	add_flags = list(WAND_COMP_SELFCAST = TRUE, WAND_COMP_PASSIVECAST = TRUE, WAND_COMP_RELOADMOVE = TRUE)
	color = "#40e0d0"



/obj/item/wand_component/sorcery
	name = "sorcery wand component"
	desc = "Allows to be of great ranged support, with tricks and aerial denial."
	add_flags = list(WAND_COMP_AREACAST = TRUE)
	color = "#ffa500"
