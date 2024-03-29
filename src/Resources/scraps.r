

resource 'DLOG' (201, "Fit Options") {
	{64, 82, 230, 454},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	28445,
	"New Dialog"
};

resource 'DLOG' (202, "Working...") {
	{44, 90, 100, 386},
	altDBoxProc,
	invisible,
	noGoAway,
	0x0,
	11291,
	"EasyFit Working..."
};

resource 'DLOG' (203, "Model") {
	{48, 14, 320, 494},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	20406,
	"Choose Model"
};

resource 'DLOG' (204, "More Iterations?") {
	{68, 76, 256, 458},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	5860,
	"New Dialog"
};

resource 'DLOG' (207, "Data Plot") {
	{34, 92, 332, 440},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	207,
	""
};

resource 'DLOG' (206, "Std. Residuals") {
	{48, 34, 304, 482},
	dBoxProc,
	visible,
	noGoAway,
	0x0,
	206,
	""
};

resource 'DLOG' (208, "Save changes", purgeable) {
	{80, 110, 208, 390},
	dBoxProc,
	visible,
	goAway,
	0x0,
	1100,
	""
};

resource 'DITL' (128) {
	{	/* array DITLarray: 1 elements */
		/* [1] */
		{0, 0, 233, 431},
		Picture {
			enabled,
			128
		}
	}
};

resource 'DITL' (28915) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{18, 22, 34, 389},
		StaticText {
			enabled,
			"Mario Negri Institute for Pharmacologic "
			"Research"
		},
		/* [2] */
		{47, 36, 64, 146},
		StaticText {
			enabled,
			"via Eritrea, 62"
		},
		/* [3] */
		{69, 36, 88, 202},
		StaticText {
			enabled,
			"20157 Milano, Italy"
		}
	}
};

resource 'DITL' (28445) {
	{	/* array DITLarray: 12 elements */
		/* [1] */
		{136, 304, 156, 364},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{136, 224, 156, 284},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{0, 120, 16, 232},
		StaticText {
			enabled,
			"Fitting Options"
		},
		/* [4] */
		{24, 8, 48, 144},
		CheckBox {
			enabled,
			"<Button Unused>"
		},
		/* [5] */
		{24, 168, 48, 304},
		CheckBox {
			enabled,
			"Work unattended"
		},
		/* [6] */
		{48, 8, 72, 160},
		CheckBox {
			enabled,
			"Produce Full Output"
		},
		/* [7] */
		{48, 168, 72, 360},
		CheckBox {
			enabled,
			"< unused, too. >"
		},
		/* [8] */
		{104, 8, 120, 128},
		StaticText {
			enabled,
			"Starting Lambda:"
		},
		/* [9] */
		{104, 136, 120, 201},
		EditText {
			enabled,
			""
		},
		/* [10] */
		{136, 16, 152, 128},
		StaticText {
			enabled,
			"Max Iterations:"
		},
		/* [11] */
		{136, 136, 152, 201},
		EditText {
			enabled,
			""
		},
		/* [12] */
		{72, 8, 96, 264},
		CheckBox {
			enabled,
			"Automatic \"Peeling\" of Parameters"
		}
	}
};

resource 'DITL' (11291) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{32, 216, 48, 288},
		Button {
			enabled,
			"Cancel"
		},
		/* [2] */
		{8, 8, 24, 288},
		StaticText {
			disabled,
			""
		},
		/* [3] */
		{32, 8, 48, 208},
		UserItem {
			disabled
		}
	}
};

resource 'DITL' (20406) {
	{	/* array DITLarray: 9 elements */
		/* [1] */
		{240, 408, 260, 468},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{240, 336, 260, 396},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{0, 160, 20, 297},
		StaticText {
			disabled,
			"Choose the Model:"
		},
		/* [4] */
		{28, 19, 50, 39},
		RadioButton {
			enabled,
			""
		},
		/* [5] */
		{24, 40, 235, 423},
		Picture {
			disabled,
			129
		},
		/* [6] */
		{63, 18, 85, 38},
		RadioButton {
			enabled,
			""
		},
		/* [7] */
		{102, 18, 124, 38},
		RadioButton {
			enabled,
			""
		},
		/* [8] */
		{137, 17, 159, 37},
		RadioButton {
			enabled,
			""
		},
		/* [9] */
		{175, 17, 197, 37},
		RadioButton {
			enabled,
			""
		}
	}
};

resource 'DITL' (259) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{90, 13, 110, 83},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{90, 267, 110, 337},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{10, 60, 70, 350},
		StaticText {
			disabled,
			"Are you sure you want to go back to the "
			"old version of this file?  You will lose"
			" any changes that you have made."
		}
	}
};

resource 'DITL' (454) {
	{	/* array DITLarray: 2 elements */
		/* [1] */
		{87, 322, 107, 382},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{7, 75, 83, 384},
		StaticText {
			disabled,
			"^0"
		}
	}
};

resource 'DITL' (5860) {
	{	/* array DITLarray: 6 elements */
		/* [1] */
		{144, 288, 168, 368},
		Button {
			enabled,
			"Continue"
		},
		/* [2] */
		{144, 208, 168, 280},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{10, 82, 82, 362},
		StaticText {
			disabled,
			"I have done the number of iterations req"
			"uested, still the sum doesn't converge. "
			" If you want me to do more iterations, c"
			"lick on \"Continue\"."
		},
		/* [4] */
		{88, 240, 104, 296},
		EditText {
			disabled,
			""
		},
		/* [5] */
		{88, 88, 104, 232},
		StaticText {
			disabled,
			"How many iterations:"
		},
		/* [6] */
		{24, 24, 56, 56},
		Icon {
			disabled,
			1
		}
	}
};

resource 'DITL' (207) {
	{	/* array DITLarray: 20 elements */
		/* [1] */
		{272, 280, 292, 340},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{272, 208, 292, 268},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{0, 96, 19, 213},
		StaticText {
			disabled,
			"Data Plot Options"
		},
		/* [4] */
		{32, 8, 52, 111},
		CheckBox {
			enabled,
			"Semilog Plot"
		},
		/* [5] */
		{144, 8, 160, 72},
		StaticText {
			disabled,
			"Time Min:"
		},
		/* [6] */
		{176, 6, 193, 75},
		StaticText {
			disabled,
			"Conc. Min:"
		},
		/* [7] */
		{144, 168, 160, 240},
		StaticText {
			disabled,
			"Time Max:"
		},
		/* [8] */
		{176, 168, 192, 240},
		StaticText {
			disabled,
			"Conc. Max:"
		},
		/* [9] */
		{144, 80, 163, 160},
		EditText {
			enabled,
			""
		},
		/* [10] */
		{208, 192, 224, 248},
		EditText {
			enabled,
			""
		},
		/* [11] */
		{208, 9, 225, 187},
		StaticText {
			disabled,
			"Number of Time Intervals:"
		},
		/* [12] */
		{232, 8, 251, 188},
		StaticText {
			disabled,
			"Number of Conc. Intervals:"
		},
		/* [13] */
		{80, 8, 100, 234},
		RadioButton {
			enabled,
			"Automatic (subject by subject)"
		},
		/* [14] */
		{99, 8, 118, 228},
		RadioButton {
			enabled,
			"Automatic (over all subjects)"
		},
		/* [15] */
		{119, 8, 136, 194},
		RadioButton {
			enabled,
			"User defined"
		},
		/* [16] */
		{64, 24, 80, 157},
		StaticText {
			disabled,
			"Domain of the plot:"
		},
		/* [17] */
		{232, 192, 248, 248},
		EditText {
			enabled,
			""
		},
		/* [18] */
		{176, 80, 195, 160},
		EditText {
			enabled,
			""
		},
		/* [19] */
		{144, 248, 163, 328},
		EditText {
			enabled,
			""
		},
		/* [20] */
		{176, 248, 195, 328},
		EditText {
			enabled,
			""
		}
	}
};

resource 'DITL' (205) {
	{	/* array DITLarray: 15 elements */
		/* [1] */
		{136, 224, 156, 284},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{136, 152, 156, 212},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{4, 37, 28, 229},
		StaticText {
			disabled,
			"Data & Function Plot Options"
		},
		/* [4] */
		{32, 8, 56, 120},
		CheckBox {
			enabled,
			"Semilog Plot"
		},
		/* [5] */
		{128, 8, 152, 72},
		StaticText {
			disabled,
			"Accuracy:"
		},
		/* [6] */
		{72, 8, 88, 72},
		StaticText {
			disabled,
			"Time Min:"
		},
		/* [7] */
		{104, 8, 120, 80},
		StaticText {
			disabled,
			"Conc. Min:"
		},
		/* [8] */
		{72, 152, 88, 224},
		StaticText {
			disabled,
			"Time Max:"
		},
		/* [9] */
		{104, 152, 120, 224},
		StaticText {
			disabled,
			"Conc. Max:"
		},
		/* [10] */
		{128, 80, 144, 136},
		EditText {
			enabled,
			""
		},
		/* [11] */
		{72, 80, 88, 136},
		EditText {
			enabled,
			""
		},
		/* [12] */
		{104, 80, 120, 136},
		EditText {
			enabled,
			""
		},
		/* [13] */
		{72, 230, 88, 286},
		EditText {
			enabled,
			""
		},
		/* [14] */
		{104, 230, 120, 286},
		EditText {
			enabled,
			""
		},
		/* [15] */
		{32, 152, 53, 280},
		CheckBox {
			enabled,
			"Default Settings"
		}
	}
};

resource 'DITL' (206, "Std Residuals") {
	{	/* array DITLarray: 23 elements */
		/* [1] */
		{232, 384, 252, 444},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{232, 320, 252, 380},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{11, 101, 29, 318},
		StaticText {
			disabled,
			"Standard residuals plot options:"
		},
		/* [4] */
		{144, 8, 160, 72},
		StaticText {
			disabled,
			"X min:"
		},
		/* [5] */
		{176, 6, 193, 75},
		StaticText {
			disabled,
			"Y min:"
		},
		/* [6] */
		{144, 168, 160, 240},
		StaticText {
			disabled,
			"X max:"
		},
		/* [7] */
		{176, 168, 192, 240},
		StaticText {
			disabled,
			"Y max:"
		},
		/* [8] */
		{144, 80, 163, 160},
		EditText {
			enabled,
			""
		},
		/* [9] */
		{208, 192, 224, 248},
		EditText {
			enabled,
			""
		},
		/* [10] */
		{208, 9, 225, 187},
		StaticText {
			disabled,
			"Number of X intervals:"
		},
		/* [11] */
		{232, 8, 251, 188},
		StaticText {
			disabled,
			"Number of Y intervals:"
		},
		/* [12] */
		{80, 8, 100, 234},
		RadioButton {
			enabled,
			"Automatic (subject by subject)"
		},
		/* [13] */
		{99, 8, 118, 228},
		RadioButton {
			enabled,
			"Automatic (over all subjects)"
		},
		/* [14] */
		{119, 8, 136, 194},
		RadioButton {
			enabled,
			"User defined"
		},
		/* [15] */
		{64, 24, 80, 157},
		StaticText {
			disabled,
			"Domain of the plot:"
		},
		/* [16] */
		{232, 192, 248, 248},
		EditText {
			enabled,
			""
		},
		/* [17] */
		{176, 80, 195, 160},
		StaticText {
			disabled,
			""
		},
		/* [18] */
		{144, 248, 163, 328},
		EditText {
			enabled,
			""
		},
		/* [19] */
		{176, 248, 195, 328},
		EditText {
			enabled,
			""
		},
		/* [20] */
		{82, 256, 99, 323},
		RadioButton {
			enabled,
			"Time"
		},
		/* [21] */
		{101, 256, 117, 440},
		RadioButton {
			enabled,
			"Observed concentrations"
		},
		/* [22] */
		{119, 256, 135, 448},
		RadioButton {
			enabled,
			"Estimated concentrations"
		},
		/* [23] */
		{61, 258, 79, 442},
		StaticText {
			disabled,
			"Plot std. residuals against:"
		}
	}
};

resource 'DITL' (1100, purgeable) {
	{	/* array DITLarray: 5 elements */
		/* [1] */
		{60, 20, 80, 90},
		Button {
			enabled,
			"Yes"
		},
		/* [2] */
		{92, 20, 112, 90},
		Button {
			enabled,
			"No"
		},
		/* [3] */
		{92, 200, 112, 270},
		Button {
			enabled,
			"Cancel"
		},
		/* [4] */
		{6, 60, 54, 270},
		StaticText {
			disabled,
			"Save changes to �^0�?"
		},
		/* [5] */
		{10, 20, 42, 52},
		Icon {
			disabled,
			0
		}
	}
};



---------------------

resource 'ICN#' (129, "Document Icon", purgeable, preload) {
	{	/* array: 2 elements */
		/* [1] */
		$"0F FF FE 00 08 00 03 00 08 00 02 80 08 00 02 40"
		$"08 00 02 20 08 00 02 10 08 00 03 F8 08 00 00 08"
		$"0B DE F7 C8 0A 10 81 08 0A 10 81 08 0B 9E E1 08"
		$"0A 02 81 08 0A 02 81 08 0A 02 81 08 0B DE 81 08"
		$"08 00 00 08 08 00 00 08 08 00 00 08 08 3C 5E 08"
		$"08 08 84 08 08 01 80 08 08 01 00 88 08 01 00 48"
		$"08 03 E1 48 08 18 02 48 08 0E 06 08 08 01 F8 08"
		$"08 00 00 08 08 00 00 08 08 00 00 08 0F FF FF F8",
		/* [2] */
		$"0F FF FE 00 0F FF FF 00 0F FF FF 80 0F FF FF C0"
		$"0F FF FF E0 0F FF FF F0 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
		$"0F FF FF F8 0F FF FF F8 0F FF FF F8 0F FF FF F8"
	}
};

-----------------------------
resource 'ALRT' (129, "Revert", purgeable) {
	{60, 81, 180, 431},
	259,
	{	/* array: 4 elements */
		/* [1] */
		Cancel, visible, silent,
		/* [2] */
		Cancel, visible, silent,
		/* [3] */
		Cancel, visible, silent,
		/* [4] */
		Cancel, visible, silent
	}
};

resource 'ALRT' (300, "Generic") {
	{62, 70, 178, 458},
	454,
	{	/* array: 4 elements */
		/* [1] */
		OK, visible, sound1,
		/* [2] */
		OK, visible, sound1,
		/* [3] */
		OK, visible, sound1,
		/* [4] */
		OK, visible, sound1
	}
};

----------------------------------------------

resource 'ICON' (257, "1/y2 normalizz.") {
	$"00 01 00 00 00 03 00 00 00 01 00 00 00 01 00 00"
	$"00 03 80 00 00 00 00 00 00 1F F8 00 00 00 00 00"
	$"00 09 60 00 00 09 50 00 00 06 20 00 00 04 70 00"
	$"00 04 00 00 00 04 00 00 00 00 00 00 0F FF FF E0"
	$"00 00 00 00 03 FF 88 00 01 00 98 00 00 80 08 00"
	$"00 40 1C 00 00 20 00 00 00 10 FF C0 00 08 00 00"
	$"00 18 01 80 00 30 25 40 00 60 24 80 00 C0 19 C0"
	$"01 80 90 00 03 FF 90 00 00 00 10"
};

resource 'ICON' (3722, "ae^x") {
	$"00 00 00 00 00 00 00 00 00 00 07 70 00 00 02 20"
	$"00 00 01 40 00 00 00 80 00 00 00 80 1F 03 C1 40"
	$"31 86 62 20 21 8C 37 70 03 8C 30 00 0D 8F F0 00"
	$"19 8C 00 00 31 8C 00 00 31 8C 10 00 33 A6 20 00"
	$"1C C3 C0"
};

resource 'ICON' (261, "Function plot") {
	$"00 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00"
	$"80 03 80 E0 80 0C 61 11 80 78 12 0A 81 FC 0C 04"
	$"83 8E 00 00 83 3E 00 00 86 63 00 00 86 C3 00 00"
	$"86 83 00 00 87 86 00 00 8F 8E 3F 00 89 FF 40 80"
	$"98 73 C0 40 90 01 F0 20 90 01 F8 10 B0 02 78 0F"
	$"A0 02 38 07 A0 01 00 07 A0 00 80 07 A0 00 60 07"
	$"A0 00 3F E7 A0 00 00 1F FF FF FF C7"
};

resource 'ICON' (260, "data plot") {
	$"00 00 00 00 80 00 00 00 80 00 04 00 80 00 04 00"
	$"80 00 1F 00 80 00 04 00 80 78 44 00 81 FC 40 00"
	$"83 8F F0 00 83 46 40 00 8E 43 40 00 87 F3 00 00"
	$"86 43 00 00 86 46 00 00 83 8E 3F 00 81 FF 40 80"
	$"80 73 C0 40 84 01 F0 20 84 01 F8 10 9F 02 78 0F"
	$"84 02 38 07 84 01 00 07 80 00 80 07 80 00 60 07"
	$"80 00 3F E7 80 00 00 1F FF FF FF C7"
};

resource 'ICON' (259, "r/w data window") {
	$"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
	$"00 00 00 00 00 00 00 00 07 FF FF C0 04 21 08 60"
	$"07 FF FF E0 04 21 08 60 04 21 08 60 06 B5 AD 60"
	$"04 21 08 60 04 21 08 60 06 B5 BF 60 04 21 40 A0"
	$"04 20 80 40 06 B5 30 20 04 21 C8 10 04 2E 7F 8F"
	$"06 A2 30 07 04 35 00 07 04 20 80 07 07 FF 60 07"
	$"03 FF 9F E7 00 00 00 1F 00 00 00 07"
};

resource 'ICON' (258, "r. only data window") {
	$"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
	$"00 00 00 00 00 00 00 00 07 FF FF C0 04 21 08 60"
	$"07 FF FF E0 04 21 08 60 04 21 08 60 06 B5 AD 60"
	$"04 21 08 60 04 21 08 60 06 B5 AD 60 04 21 08 60"
	$"04 21 08 60 06 B5 AD 60 04 21 08 60 04 21 08 60"
	$"06 B5 AD 60 04 21 08 60 04 21 08 60 07 FF FF E0"
	$"03 FF FF E0"
};

resource 'ICON' (262, "r. only text window") {
	$"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
	$"00 00 00 00 00 00 00 00 07 FF FF C0 04 00 00 60"
	$"07 FF FF E0 04 00 00 60 04 FF C0 60 04 00 00 60"
	$"04 E0 00 60 04 00 00 60 04 E0 00 60 04 00 00 60"
	$"04 FF FC 60 04 00 00 60 04 FE 00 60 04 00 00 60"
	$"04 FF F8 60 04 00 00 60 04 FF C0 60 04 00 00 60"
	$"07 FF FF E0 03 FF FF E0"
};

