/*
	The possible ways of meme spreading.
*/
#define MEME_SPREAD_VERBALLY "meme_spread_verbally"         // Meme is spread by speaking it out loud.
	#define MEME_TEXT_ALLOW_CUSTOM "meme_text_allow_custom" // Whether the meme allows to write custom text when "sharing" it.
	#define MEME_TEXT_KEYWORD "meme_text_keyword"           // Whether the meme will search and replace all %meme% in the text with it's name.

#define MEME_SPREAD_INSPECTION "meme_spread_inspection"       // Meme is spread if object is examined.
	#define MEME_PREVENT_INSPECTION "meme_prevent_inspection" // This meme will prevent examination of the thing it is attached to.

#define MEME_SPREAD_READING "meme_spread_reading"             // Basically MEME_SPREAD_INSPECTION, but works only for /obj/item/weapon/paper
	#define MEME_STAR_TEXT "meme_jumble_text"                 // If meme is present, the text on paper will always appear starred(unreadable).

#define MEME_SPREAD_VISUAL     "meme_spread_visual"            // The photo of a meme is a meme.
	#define MEME_SPREAD_VISUAL_RECURSIVE "meme_spread_vis_rec" // The photo of a photo of a photo, and any degrees of seperation from meme - is still a meme.

/*
	Various meme categories that are displayed
	when the player browses known memes.
*/
#define MEME_CATEGORY_MEME "meme"
#define MEME_CATEGORY_MEMORY "memory"

/*
	How a meme stacks.
*/
#define MEME_STACK_KEEP_BOTH "keep_both" // Will not even call on_stack.
#define MEME_STACK_KEEP_OLD "keep_old" // Will try to stack old meme with new. Default behaviour will qdel the new meme.
#define MEME_STACK_KEEP_NEW "keep_new" // Will try to stack new meme with old. Default behaviour will qdel the old meme.
