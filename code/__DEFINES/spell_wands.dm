#define WAND_NOT_ENOUGH_MANA 0
#define WAND_NEEDS_RECHARGE 1
#define WAND_SUCCESS 8

// Wands with this queue type cast in an "orderly" fashion, one spell after another in a user-given order.
#define WAND_QUEUE_ORDER   "order"
// Wands with this queue type cast all the spells given to the wand, but in an arbitrary order.
#define WAND_QUEUE_SHUFFLE "shuffle"
// Wands with this queue type summon a random spell out of the given to this wand.
#define WAND_QUEUE_RANDOM  "random"

// Whether this wand can cast spells unto caster themself.
#define WAND_COMP_SELFCAST "selfcast"
// Whether this wand can cast spells unto others.
#define WAND_COMP_OTHERSCAST "otherscast"
// Whether this wand can cast the spell unto an area.
#define WAND_COMP_AREACAST "areacast"
// Whether this wand can cast in melee.
#define WAND_COMP_MELEECAST "meleecast"
// Whether this wand casts as if it's an enchanted item in melee.
#define WAND_COMP_MELEEMAGICCAST "meleemagiccast"
// Whether this wand can enchant other items.
#define WAND_COMP_ENCHANTCAST "enchantcast"
// Whether this wand can cast passively.
#define WAND_COMP_PASSIVECAST "passivecast"

// Whether this wand can reload on the move.
#define WAND_COMP_RELOADMOVE "reloadmove"

var/global/list/wand_comp_all = list(
	WAND_COMP_SELFCAST, WAND_COMP_OTHERSCAST, WAND_COMP_AREACAST, WAND_COMP_MELEECAST,
	WAND_COMP_MELEEMAGICCAST, WAND_COMP_ENCHANTCAST, WAND_COMP_PASSIVECAST,
	WAND_COMP_RELOADMOVE
	)

var/global/list/wand_comp_casttypes = list(
	WAND_COMP_SELFCAST, WAND_COMP_OTHERSCAST, WAND_COMP_AREACAST, WAND_COMP_MELEECAST,
	WAND_COMP_MELEEMAGICCAST, WAND_COMP_ENCHANTCAST
	)

var/global/list/wand_component_incompatible_flags = list(
	list(WAND_COMP_MELEECAST, WAND_COMP_MELEEMAGICCAST, WAND_COMP_ENCHANTCAST),
	list(WAND_COMP_OTHERSCAST, WAND_COMP_AREACAST),
	list(WAND_COMP_OTHERSCAST, WAND_COMP_ENCHANTCAST),
	list(WAND_COMP_MELEEMAGICCAST, WAND_COMP_AREACAST)
	)



#define MAX_RUNES 17



#define WAND_SPELL_TRIGGER_ON_IMPACT "trigger on impact"
#define WAND_SPELL_TRIGGER_ON_STEP   "trigger on step"
var/global/list/spell_pos_triggers = list(WAND_SPELL_TRIGGER_ON_IMPACT, WAND_SPELL_TRIGGER_ON_STEP)

#define WAND_SPELL_TIMER             "timer"
