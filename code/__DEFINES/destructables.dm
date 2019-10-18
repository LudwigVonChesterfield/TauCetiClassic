#define SOLID 1
#define LIQUID 2
#define GAS 3

#define HITZONE_UPPER "upper"
#define HITZONE_MIDDLE "middle"
#define HITZONE_LOWER "lower"

// A usually low hit-area hit, which requires edge = TRUE.
#define DEST_POKE "poke"
// A sharp = TRUE hit spreading across a large area, usually with wind-up.
#define DEST_SLASH "slash"
// A usually low hit-area blunt hit, which requires sharp = FALSE, edge = FALSE.
#define DEST_PRODE "prode"
// An sharp = FALSE, edge = FALSE hit spreading across a large area, usually with wind-up.
#define DEST_BLUNT "blunt"
