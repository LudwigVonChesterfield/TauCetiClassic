var/global/list/spell_word_by_hash = list()
var/global/list/spell_color_by_hash = list()
var/global/list/runes_by_spell_word = list()
var/global/list/color_to_approx_rune_color = list()

var/global/list/spell_types_by_spell_word = list()

var/global/list/letter_to_rune = list(
	"OTHER" = "voita",
	"NOREPEAT" = "jada",
	"NONE" = "aleph",
)

var/global/list/rune_to_letter = list(
	"voita" = "OTHER",
	"jada" = "NOREPEAT",
	"aleph" = "NONE",
)

var/global/list/rune_to_color = list(
	"voita" = COLOR_RED,
	"jada" = COLOR_BLUE,
	"aleph" = COLOR_BLACK,
)
var/global/list/color_to_runes = list(
	COLOR_RED = list("voita"),
	COLOR_BLUE = list("jada"),
	COLOR_BLACK = list("aleph"),
)

var/global/list/letters_to_convert = list(
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
)

// Runes list must always be bigger than letters_to_convert.
var/global/list/spell_runes_to_use = list(
	"algiz",
	"berkana",
	"carat",
	"dagaz",
	"eihwaz",
	"fehu",
	"gebo",
	"hagalaz",
	"isa",
	"jera",
	"kaunaz",
	"laguz",
	"mannaz",
	"naubiz",
	"opila",
	"perb",
	"quro",
	"raipo",
	"selva",
	"teiwaz",
	"uruz",
	"vuro",
	"wuiz",
	"xita",
	"yema",
	"zazeph",
)

var/list/spell_colors_to_use = list(
	COLOR_BLACK,
	COLOR_NAVY_BLUE,
	COLOR_GREEN,
	COLOR_DARK_GRAY,
	COLOR_MAROON,
	COLOR_PURPLE,
	COLOR_VIOLET,
	COLOR_OLIVE,
	COLOR_BROWN_ORANGE,
	COLOR_DARK_ORANGE,
	COLOR_SEDONA,
	COLOR_DARK_BROWN,
	COLOR_BLUE,
	COLOR_DEEP_SKY_BLUE,
	COLOR_LIME,
	COLOR_CYAN,
	COLOR_TEAL,
	COLOR_RED,
	COLOR_PINK,
	COLOR_ORANGE,
	COLOR_YELLOW,
	COLOR_GRAY,
	COLOR_RED_GRAY,
	COLOR_BROWN,
	COLOR_GREEN_GRAY,
	COLOR_BLUE_GRAY,
	COLOR_SUN,
	COLOR_PURPLE_GRAY,
	COLOR_BLUE_LIGHT,
	COLOR_RED_LIGHT,
	COLOR_BEIGE,
	COLOR_PALE_GREEN_GRAY,
	COLOR_PALE_RED_GRAY,
	COLOR_PALE_PURPLE_GRAY,
	COLOR_PALE_BLUE_GRAY,
	COLOR_LUMINOL,
	COLOR_BOTTLE_GREEN,
	COLOR_CHESTNUT,
	COLOR_WHEAT,
	COLOR_CYAN_BLUE,
	COLOR_LIGHT_CYAN,
	COLOR_AMBER,
	COLOR_PALE_ORANGE,
	COLOR_TITANIUM,
)

/proc/init_spell_runes()
	var/list/runes_to_use = list() + global.spell_runes_to_use
	if(runes_to_use.len != global.letters_to_convert.len)
		world.log << "SPELL RUNES ARRAY DOES NOT MATCH GIVEN LETTERS ARRAY IN LENGTH, PLEASE FIX."
	while(runes_to_use.len < global.letters_to_convert.len)
		var/copycat_rune = pick(global.spell_runes_to_use)
		runes_to_use += copycat_rune
	while(runes_to_use.len > global.letters_to_convert.len)
		var/remove_rune = pick(global.spell_runes_to_use)
		runes_to_use -= remove_rune

	var/list/cols_to_use = list() + global.spell_colors_to_use
	while(cols_to_use.len < global.letters_to_convert.len)
		var/copycat_col = pick(global.spell_colors_to_use)
		cols_to_use += copycat_col

	for(var/letter in global.letters_to_convert)
		var/rune = pick(runes_to_use)
		runes_to_use -= rune
		global.letter_to_rune[letter] = rune
		global.rune_to_letter[rune] = letter

		var/col = pick(cols_to_use)
		cols_to_use -= col
		global.rune_to_color[rune] = col
		if(!global.color_to_runes[col])
			global.color_to_runes[col] = list()
		global.color_to_runes[col] += rune
