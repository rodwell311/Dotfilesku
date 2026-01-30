/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x0d151fff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc2c4c7ff, 0x0d151fff, 0x5c6571ff },
	[SchemeSel]  = { 0xc2c4c7ff, 0x68778bff, 0x54687eff },
	[SchemeUrg]  = { 0xc2c4c7ff, 0x54687eff, 0x68778bff },
};
