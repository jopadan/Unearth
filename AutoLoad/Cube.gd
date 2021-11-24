extends Node

enum {
	RED = 0
	BLUE = 1
	GREEN = 2
	YELLOW = 3
	WHITE = 4
	NONE = 5
}
const ownedCube = [
	[192,193,194,195,199,198], # FLOOR_MARKER
	[67,68,69,70,71,4], # WALL_MARKER
	[382,422,423,424,426,425], # PORTAL_MARKER
	[382,422,423,424,426,425], # HEART_MARKER
	[393,427,428,429,431,430], # BARRACKS_FLAG
	[160,410,413,416,419,77], # BANNER_LEFT
	[161,411,414,417,420,77], # BANNER_MIDDLE
	[162,412,415,418,421,77], # BANNER_RIGHT
]
enum {
	FLOOR_MARKER = 0
	WALL_MARKER = 1
	PORTAL_MARKER = 2
	HEART_MARKER = 3
	BARRACKS_FLAG = 4
	BANNER_LEFT = 5
	BANNER_MIDDLE = 6
	BANNER_RIGHT = 7
}

enum {
	SIDE_NORTH = 0,
	SIDE_EAST = 1,
	SIDE_SOUTH = 2,
	SIDE_WEST = 3,
	SIDE_TOP = 4,
	SIDE_BOTTOM = 5,
}

const tex = [
	[  0,   0,   0,   0,   0,   0],
	[  2,   2,   2,   2,   5,   2],
	[  3,   3,   3,   3,   5,   3],
	[  4,   4,   4,   4,   5,   4],
	[  8,   8,   6,   6,   5,   2],
	[  7,   7,   7,   7,   5,   2],
	[  6,   6,   8,   8,   5,   3],
	[ 10,  10,   9,   9,   2,   2],
	[  9,   9,  10,  10,   2,   2],
	[ 13,  13,  11,  11,   5,   3],
	[ 12,  12,  12,  12,   5,   2],
	[ 11,  11,  13,  13,   5,   2],
	[ 14,  14,  14,  14,   3,   3],
	[ 15,  15,  15,  15,   3,   3],
	[ 17,  17,  17,  17,  15,  15],
	[ 16,  16,  16,  16,   4,   4],
	[ 20,  20,  18,  18, 115,   3],
	[ 19,  19,  19,  19, 115,   2],
	[ 18,  18,  20,  20, 115,   2],
	[ 21,  21,  21,  21,   3,   2],
	[ 22,  22,  22,  22,   5,   3],
	[ 25,  25,  23,  23,   5,   2],
	[ 24,  24,  24,  24,   5,   2],
	[ 23,  23,  25,  25,   5,   2],
	[ 26,  26,  26,  26,   5,   2],
	[ 76,  76,  76,  76,  27,  27],
	[ 76,  76,  76,  76,  28,  28],
	[ 76,  76,  76,  76,  29,  27],
	[ 76,  76,  76,  76,  30,  27],
	[ 76,  76,  76,  76,  31,  27],
	[ 77,  27,  27,  77,  32,  28],
	[ 77,  28,  28,  28,  33,  28],
	[ 77,  77,  27,  27,  34,  27],
	[ 27,  27,  27,  77,  35,  27],
	[ 28,  77,  28,  28,  36,  28],
	[ 28,  28,  77,  77,  37,  27],
	[ 27,  27,  77,  27,  38,  27],
	[ 28,  77,  77,  28,  39,  28],
	[544, 544, 544, 544, 544,   2],
	[545, 545, 545, 545, 545, 545],
	[546, 546, 546, 546, 546, 546],
	[547, 547, 547, 547, 547, 547],
	[ 72,  72,  72,  72,   5,   2],
	[ 73,  73,  73,  73,  74,  74],
	[ 74,  74,  74,  74,  74,  74],
	[ 75,  75,  75,  75,  74,  74],
	[ 77,  77,  77,  77,  29,   0],
	[ 78,  78,  78,  78,  28,   0],
	[ 79,  79,  79,  79,   5,  79],
	[548, 548, 548, 548, 548, 548],
	[549, 549, 549, 549, 549, 549],
	[550, 550, 550, 550, 550, 550],
	[552, 552, 552, 552, 548, 552],
	[553, 553, 553, 553, 549, 553],
	[554, 554, 554, 554, 550, 554],
	[  0,   0,   0,   0, 206,   0],
	[ 96,  96,  96,  96, 104, 104],
	[ 97,  97,  97,  97, 104, 104],
	[ 98,  98,  98,  98, 104, 104],
	[101, 101,  99,  99, 104, 104],
	[100, 100, 100, 100, 104, 104],
	[ 99,  99, 101, 101, 104, 104],
	[102, 102, 102, 102, 104, 104],
	[103, 103, 103, 103, 104, 104],
	[104, 104, 104, 104, 104, 104],
	[105, 105, 105, 105, 104, 104],
	[106, 106, 115, 106, 106, 106],
	[  7,   7,   7,   7, 107,   3],
	[  7,   7,   7,   7, 108,   0],
	[  7,   7,   7,   7, 109,   0],
	[  7,   7,   7,   7, 110,   0],
	[  7,   7,   7,   7, 111,   0],
	[112, 112, 112, 112, 112, 112],
	[113, 113, 113, 113, 113, 113],
	[114, 114, 114, 114, 114, 114],
	[115, 115, 115, 115, 115, 115],
	[118, 118, 116, 116, 115, 112],
	[117, 117, 117, 117, 115, 112],
	[116, 116, 118, 118, 115, 115],
	[120, 120, 119, 119, 112, 112],
	[119, 119, 120, 120, 112, 112],
	[123, 123, 121, 121, 112, 112],
	[122, 122, 122, 122, 113, 113],
	[121, 121, 123, 123, 114, 114],
	[126, 126, 124, 124, 115, 113],
	[125, 125, 125, 125, 115, 112],
	[124, 124, 126, 126, 115, 113],
	[129, 129, 127, 127, 113, 113],
	[128, 128, 128, 128, 113, 113],
	[127, 127, 129, 129, 113, 113],
	[132, 132, 130, 130, 112, 112],
	[131, 131, 131, 131, 112, 112],
	[130, 130, 132, 132, 112, 112],
	[135, 135, 133, 133, 112, 112],
	[134, 134, 134, 134, 113, 113],
	[133, 133, 135, 135, 113, 113],
	[138, 138, 136, 136, 115, 113],
	[137, 137, 137, 137, 115, 113],
	[136, 136, 138, 138, 115, 113],
	[141, 141, 139, 139, 112, 112],
	[140, 140, 140, 140, 113, 113],
	[139, 139, 141, 141, 112, 112],
	[144, 144, 142, 142, 112, 112],
	[143, 143, 143, 143, 112, 112],
	[142, 142, 144, 144, 112, 112],
	[150, 150, 148, 148, 115, 113],
	[149, 149, 149, 149, 115, 113],
	[148, 148, 150, 150, 115, 114],
	[153, 153, 151, 151, 113, 113],
	[152, 152, 152, 152, 113, 113],
	[151, 151, 153, 153, 113, 113],
	[156, 156, 154, 154, 112, 112],
	[155, 155, 155, 155, 112, 112],
	[154, 154, 156, 156, 113, 113],
	[159, 159, 157, 157, 113, 113],
	[158, 158, 158, 158, 113, 113],
	[157, 157, 159, 159, 113, 113],
	[551, 551, 551, 551, 551, 113],
	[168, 168, 168, 168, 113, 113],
	[169, 169, 169, 169, 113, 113],
	[172, 172, 170, 170, 113, 113],
	[171, 171, 171, 171, 113, 113],
	[170, 170, 172, 172, 113, 113],
	[175, 175, 173, 173, 113, 113],
	[174, 174, 174, 174, 114, 114],
	[173, 173, 175, 175, 113, 113],
	[188, 188, 188, 188, 176,   0],
	[188, 188, 188, 188, 177,   0],
	[188, 188, 188, 188, 178,   0],
	[ 27, 188, 188,  27, 179,   0],
	[ 27, 188, 188, 188, 180,   0],
	[ 27,  27, 188, 188, 181,   0],
	[188, 188, 188,  27, 182,   0],
	[188,  27, 188, 188, 183,   0],
	[188, 188,  27,  27, 184,   0],
	[188, 188,  27, 188, 185,   0],
	[188,  27,  27, 188, 186,   0],
	[188, 188, 188, 188, 191, 197],
	[188, 188, 188, 188, 192, 198],
	[188, 188, 188, 188, 193, 199],
	[188, 188, 188, 188, 194, 194],
	[207, 207, 207, 207, 207, 207],
	[188, 188, 188, 188, 196, 196],
	[188, 188, 188, 188, 197, 191],
	[188, 188, 188, 188, 198, 192],
	[188, 188, 188, 188, 199, 193],
	[187, 187, 187, 187, 177,   0],
	[189, 189, 189, 189, 177,   0],
	[190, 190, 190, 190, 177,   0],
	[200, 200, 200, 200, 106, 202],
	[201, 201, 201, 201, 201, 201],
	[202, 202, 202, 202, 202, 202],
	[203, 203, 203, 203, 203, 203],
	[212, 212, 210, 210, 112, 112],
	[211, 211, 211, 211, 112, 112],
	[210, 210, 212, 212, 112, 112],
	[215, 215, 213, 213, 112, 112],
	[214, 214, 214, 214, 112, 112],
	[213, 213, 215, 215, 112, 112],
	[209, 209, 209, 209, 208,   0],
	[218, 218, 216, 216, 115, 499],
	[217, 217, 217, 217, 115, 499],
	[216, 216, 218, 218, 115, 499],
	[219, 219, 219, 219, 208,   0],
	[220, 220, 220, 220, 208,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[557, 557, 555, 555, 113, 113],
	[556, 556, 556, 556, 113, 113],
	[555, 555, 557, 557, 113, 113],
	[560, 560, 558, 558, 113, 113],
	[559, 559, 559, 559, 113, 113],
	[558, 558, 560, 560, 113, 113],
	[265, 265, 265, 265, 248,   0],
	[265, 265, 265, 265, 249,   0],
	[257, 257, 255, 255, 250, 250],
	[256, 256, 256, 256, 251, 251],
	[255, 255, 257, 257, 252, 252],
	[260, 260, 258, 258, 250, 250],
	[259, 259, 259, 259, 251, 251],
	[258, 258, 260, 260, 252, 252],
	[261, 261, 261, 261, 106,   0],
	[262, 262, 262, 262, 262, 262],
	[263, 263, 263, 263, 263, 263],
	[264, 264, 264, 264, 263, 263],
	[266, 266, 266, 266, 248,   0],
	[267, 267, 267, 267, 249,   0],
	[268, 268, 268, 268, 268, 268],
	[269, 269, 269, 269, 269, 269],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[188, 188, 188, 188, 272,   0],
	[188, 188, 188, 188, 273,   0],
	[188, 188, 188, 188, 274,   0],
	[188, 188, 188, 188, 275,   0],
	[188, 188, 188, 188, 276,   0],
	[188, 188, 188, 188, 277,   0],
	[188, 188, 188, 188, 278,   0],
	[188, 188, 188, 188, 279,   0],
	[280, 280, 280, 280, 280,   0],
	[281, 280, 280, 281, 284,   0],
	[281, 280, 280, 280, 285,   0],
	[281, 281, 280, 280, 286,   0],
	[280, 280, 280, 281, 287,   0],
	[280, 281, 280, 280, 288,   0],
	[280, 280, 281, 281, 289,   0],
	[280, 280, 281, 280, 290,   0],
	[280, 281, 281, 280, 291,   0],
	[282,  78,  78, 282, 284,   0],
	[282,  78,  78,  78, 285,   0],
	[282, 282,  78,  78, 286,   0],
	[ 78,  78,  78, 282, 287,   0],
	[ 78, 282,  78,  78, 288,   0],
	[ 78,  78, 282, 282, 289,   0],
	[ 78,  78, 282,  78, 290,   0],
	[ 78, 282, 282,  78, 291,   0],
	[283,   0,   0, 283, 284,   0],
	[283,   0,   0,   0, 285,   0],
	[283, 283,   0,   0, 286,   0],
	[  0,   0,   0, 283, 287,   0],
	[  0, 283,   0,   0, 288,   0],
	[  0,   0, 283, 283, 289,   0],
	[  0,   0, 283,   0, 290,   0],
	[512, 283, 283, 512, 291,   0],
	[294, 294, 292, 292, 112, 112],
	[293, 293, 293, 293, 112, 112],
	[292, 292, 294, 294, 112, 112],
	[297, 297, 295, 295, 112, 112],
	[296, 296, 296, 296, 112, 112],
	[295, 295, 297, 297, 112, 112],
	[280, 280, 280, 280, 298,   0],
	[301, 301, 299, 299, 115,   0],
	[300, 300, 300, 300, 115,   0],
	[299, 299, 301, 301, 115,   0],
	[304, 304, 302, 302,   0,   0],
	[303, 303, 303, 303,   0,   0],
	[302, 302, 304, 304,   0,   0],
	[307, 307, 305, 305,   0,   0],
	[306, 306, 306, 306,   0,   0],
	[305, 305, 307, 307,   0,   0],
	[308, 308, 308, 308, 106,   0],
	[311, 311, 309, 309, 112, 112],
	[310, 310, 310, 310, 315, 315],
	[309, 309, 311, 311, 112, 112],
	[314, 314, 312, 312, 113, 113],
	[313, 313, 313, 313, 315, 315],
	[312, 312, 314, 314, 113, 113],
	[312, 312, 314, 314, 113, 113],
	[315, 315, 315, 315, 315, 315],
	[316, 316, 316, 316, 315, 315],
	[317, 317, 317, 317, 315, 315],
	[319, 319, 319, 319, 318,   0],
	[320, 320, 320, 320, 318,   0],
	[321, 321, 321, 321, 318,   0],
	[563, 563, 561, 561, 112, 112],
	[562, 562, 562, 562, 112, 112],
	[561, 561, 563, 563, 112, 112],
	[566, 566, 564, 564, 112, 112],
	[565, 565, 565, 565, 112, 112],
	[564, 564, 566, 566, 112, 112],
	[346, 346, 346, 346, 346, 346],
	[347, 347, 347, 347, 346, 346],
	[348, 348, 348, 348, 346,   0],
	[349, 349, 349, 349, 346,   0],
	[350, 350, 350, 350, 346,   0],
	[351, 351, 351, 351, 106, 346],
	[352, 352, 352, 352, 106,   0],
	[353, 353, 353, 353, 268, 268],
	[354, 354, 354, 354, 268, 268],
	[355, 355, 355, 355, 268, 268],
	[358, 358, 356, 356, 112, 112],
	[567, 567, 567, 567, 112, 112],
	[356, 356, 358, 358, 112, 112],
	[361, 361, 359, 359, 112, 112],
	[568, 568, 568, 568, 112, 112],
	[359, 359, 361, 361, 112, 112],
	[366, 366, 366, 366, 106, 367],
	[367, 367, 367, 367, 367, 367],
	[368, 368, 368, 368, 368, 368],
	[369, 369, 369, 369, 368,   0],
	[372, 372, 372, 372, 371,   0],
	[373, 373, 373, 373, 371,   0],
	[374, 374, 374, 374, 371,   0],
	[372, 372, 372, 372, 370,   0],
	[375, 375, 375, 375, 375, 375],
	[376, 376, 376, 376, 375, 375],
	[377, 377, 377, 377, 375, 375],
	[378, 378, 378, 378, 375, 378],
	[380, 380, 380, 380, 379, 377],
	[380, 380, 380, 380, 375,   0],
	[381, 381, 381, 381, 382,   0],
	[383, 383, 383, 383, 382,   0],
	[  0,   0,   0,   0,   0,   0],
	[571, 569, 569, 571, 569,   0],
	[570, 570, 570, 570, 570,   0],
	[569, 571, 571, 569, 571,   0],
	[574, 572, 572, 574, 572,   0],
	[573, 573, 573, 573, 573,   0],
	[572, 574, 574, 572, 574,   0],
	[577, 575, 575, 577, 575,   0],
	[576, 576, 576, 576, 576,   0],
	[575, 577, 577, 575, 577,   0],
	[422, 422, 420, 420, 115,   0],
	[421, 421, 421, 421, 378,   0],
	[420, 420, 422, 422, 115,   0],
	[425, 425, 423, 423,   0,   0],
	[424, 424, 424, 424, 424,   0],
	[423, 423, 425, 425,   0,   0],
	[428, 428, 426, 426,   0,   0],
	[427, 427, 427, 427,   0,   0],
	[426, 426, 428, 428,   0,   0],
	[429, 429, 429, 429, 115, 548],
	[430, 430, 430, 430, 431, 430],
	[431, 431, 431, 431, 431, 431],
	[432, 432, 432, 432, 115,   0],
	[429, 429, 433, 433, 115,   0],
	[433, 433, 429, 429, 115,   0],
	[429, 429, 434, 434, 115,   0],
	[434, 434, 429, 429, 115,   0],
	[435, 435, 435, 435, 431,   0],
	[436, 436, 436, 436, 431,   0],
	[ 76,  12,  76,  76, 437,   0],
	[ 76,  76,  76,  76, 438,   0],
	[ 76,  76,  76,  76, 439,   0],
	[ 76,  76,  76,  76, 440,   0],
	[ 76,  76,  76,  76, 441,   0],
	[ 76,  76,  76,  76, 442,   0],
	[ 76,  76,  76,  76, 443,   0],
	[ 76,  76,  76,  76, 444,   0],
	[ 76,  76,  76,  76, 445,   0],
	[257, 253, 255, 253, 250,   0],
	[255, 253, 257,   0, 252,   0],
	[260,   0, 258, 253,   0,   0],
	[258, 253, 260,   0,   0,   0],
	[478, 478, 476, 476,   0,   0],
	[477, 477, 477, 477,   0,   0],
	[476, 476, 478, 478,   0,   0],
	[481, 481, 479, 479,   0,   0],
	[480, 480, 480, 480,   0,   0],
	[479, 479, 481, 481,   0,   0],
	[484, 484, 482, 482,   0,   0],
	[483, 483, 483, 483,   0,   0],
	[482, 482, 484, 484,   0,   0],
	[485, 485, 485, 485, 485, 485],
	[486, 486, 486, 486, 115,   0],
	[487, 487, 487, 487, 115,   0],
	[488, 488, 488, 488, 485,   0],
	[487, 487, 489, 489, 115,   0],
	[489, 489, 487, 487, 115,   0],
	[489, 489, 489, 489, 115,   0],
	[433, 433, 433, 433, 346,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[451, 451, 449, 449,   0,   0],
	[450, 450, 450, 450,   0,   0],
	[449, 449, 451, 451,   0,   0],
	[454, 454, 452, 452,   0,   0],
	[453, 453, 453, 453,   0,   0],
	[452, 452, 454, 454,   0,   0],
	[457, 457, 455, 455,   0, 251],
	[456, 456, 456, 456,   0, 251],
	[455, 455, 457, 457,   0, 251],
	[460, 460, 458, 458,   0,   0],
	[459, 459, 459, 459,   0,   0],
	[458, 458, 460, 460,   0,   0],
	[463, 463, 461, 461,   0,   0],
	[462, 462, 462, 462,   0,   0],
	[461, 461, 463, 463,   0,   0],
	[466, 466, 464, 464,   0, 471],
	[465, 465, 465, 465,   0, 471],
	[464, 464, 466, 466,   0, 471],
	[469, 469, 467, 467,   0,   0],
	[468, 468, 468, 468,   0,   0],
	[467, 467, 469, 469,   0,   0],
	[472, 472, 470, 470,   0,   0],
	[471, 471, 471, 471,   0,   0],
	[470, 470, 472, 472,   0,   0],
	[475, 475, 473, 473,   0, 471],
	[474, 474, 474, 474,   0, 471],
	[473, 473, 475, 475,   0, 471],
	[222, 222, 222, 222, 221, 221],
	[223, 223, 223, 223,   0,   0],
	[204, 204, 204, 204, 205,   0],
	[188, 188, 188, 188, 495,   0],
	[189, 189, 189, 189, 495,   0],
	[190, 190, 190, 190, 495,   0],
	[491, 491, 491, 491, 491, 491],
	[531, 531, 529, 529, 115,   0],
	[530, 530, 530, 530, 115,   0],
	[529, 529, 531, 531, 115,   0],
	[534, 534, 532, 532,   0,   0],
	[533, 533, 533, 533, 533, 533],
	[532, 532, 534, 534,   0,   0],
	[537, 537, 535, 535,   0,   0],
	[536, 536, 536, 536,   0,   0],
	[535, 535, 537, 537,   0,   0],
	[492, 492, 492, 492, 494, 491],
	[493, 493, 493, 493, 491, 491],
	[494, 494, 494, 494, 494, 494],
	[190, 190, 190, 190, 490,   0],
	[496, 496, 496, 496, 115,   0],
	[497, 497, 497, 497,   0,   0],
	[498, 498, 498, 498, 490,   0],
	[147, 147, 145, 145, 499,   0],
	[146, 146, 146, 146,   0,   0],
	[145, 145, 147, 147,   0,   0],
	[220, 220, 220, 220, 367,   0],
	[219, 219, 219, 219, 368,   0],
	[514, 514, 512, 512, 115, 499],
	[513, 513, 513, 513, 115, 499],
	[512, 512, 514, 514, 115, 499],
	[517, 517, 515, 515, 115, 499],
	[516, 516, 516, 516, 115, 499],
	[515, 515, 517, 517, 115, 499],
	[520, 520, 518, 518, 115, 499],
	[519, 519, 519, 519, 115, 499],
	[518, 518, 520, 520, 115, 499],
	[523, 523, 521, 521, 115, 499],
	[522, 522, 522, 522, 115, 499],
	[521, 521, 523, 523, 115, 499],
	[222, 222, 222, 222, 524, 524],
	[222, 222, 222, 222, 525, 525],
	[222, 222, 222, 222, 526, 526],
	[222, 222, 222, 222, 581, 581],
	[222, 222, 222, 222, 528, 528],
	[538, 538, 538, 538,   0,   0],
	[539, 539, 539, 539,   0,   0],
	[540, 540, 540, 540,   0,   0],
	[541, 541, 541, 541,   0,   0],
	[542, 542, 542, 542,   0,   0],
	[533, 201, 533, 201, 202, 202],
	[271, 271, 271, 271, 271, 436],
	[446, 446, 446, 446, 113, 113],
	[447, 447, 447, 447, 113, 113],
	[500, 502, 500, 502, 499,   0],
	[502, 500, 502, 500, 499,   0],
	[501, 501, 501, 501, 499,   0],
	[189, 189, 189, 189, 499,   0],
	[190, 190, 190, 190, 499,   0],
	[582, 582, 582, 582, 582, 582],
	[583, 583, 583, 583, 583, 583],
	[584, 584, 584, 584, 584, 584],
	[585, 585, 585, 585, 585, 585],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
	[  0,   0,   0,   0,   0,   0],
]

const texAnim = [ # 544 - 585
	40, 41, 42, 43, 44, 45, 46, 47,
	48, 49, 50, 51, 52, 53, 54, 55,
	56, 57, 58, 59, 60, 61, 62, 63,
	64, 65, 66, 67, 68, 69, 70, 71,
	80, 80, 81, 81, 82, 82, 83, 83,
	84, 85, 85, 86, 86, 87, 87, 84,
	88, 88, 89, 89, 90, 90, 91, 91,
	160, 161, 162, 163, 164, 165, 166, 167,
	92, 92, 93, 93, 94, 94, 95, 95,
	94, 95, 95, 92, 92, 93, 93, 94,
	93, 93, 94, 94, 95, 95, 92, 92,
	224, 224, 230, 230, 236, 236, 242, 242,
	225, 225, 231, 231, 237, 237, 243, 243,
	226, 226, 232, 232, 238, 238, 244, 244,
	227, 227, 233, 233, 239, 239, 245, 245,
	228, 228, 234, 234, 240, 240, 246, 246,
	229, 229, 235, 235, 241, 241, 247, 247,
	322, 322, 328, 328, 334, 334, 340, 340,
	323, 323, 329, 329, 335, 335, 341, 341,
	324, 324, 330, 330, 336, 336, 342, 342,
	325, 325, 331, 331, 337, 337, 343, 343,
	326, 326, 332, 332, 338, 338, 344, 344,
	327, 327, 333, 333, 339, 339, 345, 345,
	357, 357, 357, 357, 362, 364, 364, 362,
	360, 360, 360, 360, 363, 365, 365, 363,
	384, 393, 402, 411, 384, 393, 402, 411,
	385, 394, 403, 412, 385, 394, 403, 412,
	386, 395, 404, 413, 404, 395, 404, 413,
	387, 396, 405, 414, 387, 396, 405, 414,
	388, 397, 406, 415, 388, 397, 406, 415,
	389, 398, 407, 416, 389, 398, 407, 416,
	390, 399, 408, 417, 390, 399, 408, 417,
	391, 400, 409, 418, 391, 400, 409, 418,
	392, 401, 419, 401, 392, 401, 410, 419,
	504, 505, 506, 507, 504, 505, 506, 507,
	508, 509, 510, 511, 508, 509, 510, 511,
	441, 441, 442, 442, 443, 443, 444, 444,
	527, 195, 527, 524, 527, 525, 527, 526,
	276, 276, 277, 277, 503, 503, 543, 543,
	543, 543, 276, 276, 277, 277, 503, 503,
	503, 503, 543, 543, 276, 276, 277, 277,
	277, 277, 503, 503, 543, 543, 276, 276,
]

#var texAnim = {
#	544: [40, 41, 42, 43, 44, 45, 46, 47],
#	545: [48, 49, 50, 51, 52, 53, 54, 55],
#	546: [56, 57, 58, 59, 60, 61, 62, 63],
#	547: [64, 65, 66, 67, 68, 69, 70, 71],
#	548: [80, 80, 81, 81, 82, 82, 83, 83],
#	549: [84, 85, 85, 86, 86, 87, 87, 84],
#	550: [88, 88, 89, 89, 90, 90, 91, 91],
#	551: [160, 161, 162, 163, 164, 165, 166, 167],
#	552: [92, 92, 93, 93, 94, 94, 95, 95],
#	553: [94, 95, 95, 92, 92, 93, 93, 94],
#	554: [93, 93, 94, 94, 95, 95, 92, 92],
#	555: [224, 224, 230, 230, 236, 236, 242, 242],
#	556: [225, 225, 231, 231, 237, 237, 243, 243],
#	557: [226, 226, 232, 232, 238, 238, 244, 244],
#	558: [227, 227, 233, 233, 239, 239, 245, 245],
#	559: [228, 228, 234, 234, 240, 240, 246, 246],
#	560: [229, 229, 235, 235, 241, 241, 247, 247],
#	561: [322, 322, 328, 328, 334, 334, 340, 340],
#	562: [323, 323, 329, 329, 335, 335, 341, 341],
#	563: [324, 324, 330, 330, 336, 336, 342, 342],
#	564: [325, 325, 331, 331, 337, 337, 343, 343],
#	565: [326, 326, 332, 332, 338, 338, 344, 344],
#	566: [327, 327, 333, 333, 339, 339, 345, 345],
#	567: [357, 357, 357, 357, 362, 364, 364, 362],
#	568: [360, 360, 360, 360, 363, 365, 365, 363],
#	569: [384, 393, 402, 411, 384, 393, 402, 411],
#	570: [385, 394, 403, 412, 385, 394, 403, 412],
#	571: [386, 395, 404, 413, 404, 395, 404, 413],
#	572: [387, 396, 405, 414, 387, 396, 405, 414],
#	573: [388, 397, 406, 415, 388, 397, 406, 415],
#	574: [389, 398, 407, 416, 389, 398, 407, 416],
#	575: [390, 399, 408, 417, 390, 399, 408, 417],
#	576: [391, 400, 409, 418, 391, 400, 409, 418],
#	577: [392, 401, 419, 401, 392, 401, 410, 419],
#	578: [504, 505, 506, 507, 504, 505, 506, 507],
#	579: [508, 509, 510, 511, 508, 509, 510, 511],
#	580: [441, 441, 442, 442, 443, 443, 444, 444],
#	581: [527, 195, 527, 524, 527, 525, 527, 526],
#	582: [276, 276, 277, 277, 503, 503, 543, 543],
#	583: [543, 543, 276, 276, 277, 277, 503, 503],
#	584: [503, 503, 543, 543, 276, 276, 277, 277],
#	585: [277, 277, 503, 503, 543, 543, 276, 276],
#}
