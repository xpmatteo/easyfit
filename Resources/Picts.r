/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintoshª.
	
	Copyright © 1989 Matteo Vaccari & Mario Negri Institute
*/

/* Include the requirements for this source */
#include "Pict.r"

/* include my definitions */
#include "Declarations.r"


data 'PICT' (kSplashPict, 
#if qNames
"About App",
#endif
purgeable) {
	$"1015 0000 0000 00A0 01AE 1101 A000 82A0"            /* ....... .®.. .  */
	$"008E 0100 0A00 0000 0002 F002 4098 0036"            /* ...........@.6 */
	$"0000 0000 00A0 01B0 0000 0000 00A0 01AE"            /* ..... .°..... .® */
	$"0000 0000 00A0 01AE 0001 0501 00F0 CD00"            /* ..... .®......Í. */
	$"0501 00F0 CD00 0501 00F0 CD00 0501 00F0"            /* ....Í.....Í..... */
	$"CD00 0804 00F0 0000 F0D0 0008 0400 F000"            /* Í........Ð...... */
	$"00F0 D000 0804 00F0 0000 F0D0 0008 0400"            /* ..Ð........Ð.... */
	$"F000 00F0 D000 0804 0FFF 000F FFD0 0008"            /* ....Ð........Ð.. */
	$"040F FF00 0FFF D000 0804 0FFF 000F FFD0"            /* ......Ð........Ð */
	$"0008 040F FF00 0FFF D000 0D09 FFFF F000"            /* ........Ð.ÂÆ.... */
	$"F00F FF00 00F0 D500 0D09 FFFF F000 F00F"            /* ......Õ.ÂÆ...... */
	$"FF00 00F0 D500 0D09 FFFF F000 F00F FF00"            /* ....Õ.ÂÆ........ */
	$"00F0 D500 0D09 FFFF F000 F00F FF00 00F0"            /* ..Õ.ÂÆ.......... */
	$"D500 0D01 00F0 FE00 04F0 00F0 0FFF D500"            /* Õ.Â...........Õ. */
	$"0D01 00F0 FE00 04F0 00F0 0FFF D500 0D01"            /* Â...........Õ.Â. */
	$"00F0 FE00 04F0 00F0 0FFF D500 0D01 00F0"            /* ..........Õ.Â... */
	$"FE00 04F0 00F0 0FFF D500 0D09 00F0 0000"            /* ........Õ.ÂÆ.... */
	$"0F00 000F 00F0 D500 0D09 00F0 0000 0F00"            /* ......Õ.ÂÆ...... */
	$"000F 00F0 D500 0D09 00F0 0000 0F00 000F"            /* ....Õ.ÂÆ........ */
	$"00F0 D500 0D09 00F0 0000 0F00 000F 00F0"            /* ..Õ.ÂÆ.......... */
	$"D500 0901 00F0 FC00 000F D300 1601 00F0"            /* Õ.Æ.......Ó..... */
	$"FC00 000F F800 0203 FF80 FC00 033F F80C"            /* ............?.. */
	$"03E8 0014 0100 F0FC 0000 0FF8 0000 03FA"            /* ................ */
	$"0003 3000 0C03 E800 1401 00F0 FC00 000F"            /* ..0............. */
	$"F800 0003 FA00 0330 0000 03E8 0016 0200"            /* .......0........ */
	$"F00F FDFF 01F0 F0F9 0000 03FA 0003 3000"            /* ..............0. */
	$"0003 E800 1B02 00F0 0FFD FF01 F0F0 F900"            /* ................ */
	$"0C03 0000 FC03 F830 0C30 003C 0FF0 E900"            /* .......0.0.<.... */
	$"1A02 00F0 0FFD FF01 F0F0 F900 0B03 0003"            /* ................ */
	$"8606 0C30 0C30 000C 03E8 001A 0200 F00F"            /* ..0.0.......... */
	$"FDFF 01F0 F0F9 000B 0300 0603 0C06 1818"            /* ................ */
	$"3000 0C03 E800 1B03 00F0 00F0 FE00 01F0"            /* 0............... */
	$"F0F9 000B 0300 0003 0C00 1818 3000 0C03"            /* ............0... */
	$"E800 1B03 00F0 00F0 FE00 01F0 F0F9 000B"            /* ................ */
	$"03FE 0007 0C00 1818 3FE0 0C03 E800 1B03"            /* ........?....... */
	$"00F0 00F0 FE00 01F0 F0F9 000B 0300 001F"            /* ................ */
	$"0600 0C30 3000 0C03 E800 1B03 00F0 00F0"            /* ...00........... */
	$"FE00 01F0 F0F9 000B 0300 0073 03F8 0C30"            /* ...........s...0 */
	$"3000 0C03 E800 1B03 00F0 000F FE00 01F0"            /* 0............... */
	$"F0F9 000B 0300 01C3 000C 0660 3000 0C03"            /* .......Ã...`0... */
	$"E800 1B03 00F0 000F FE00 01F0 F0F9 000B"            /* ................ */
	$"0300 0303 0006 0660 3000 0C03 E800 1B03"            /* .......`0....... */
	$"00F0 000F FE00 01F0 F0F9 000B 0300 0603"            /* ................ */
	$"0006 0660 3000 0C03 E800 1B03 00F0 000F"            /* ...`0........... */
	$"FE00 01F0 F0F9 000B 0300 0603 0006 03C0"            /* ...............À */
	$"3000 0C03 E800 1B03 00F0 000F FE00 01F0"            /* 0............... */
	$"F0F9 000B 0300 0607 0C06 03C0 3000 0C03"            /* ...........À0... */
	$"E800 1C03 00F0 000F FE00 01F0 F0F9 000C"            /* ................ */
	$"0300 031F 060C 0180 3000 0C01 98E9 001C"            /* .......0...... */
	$"0300 F000 0FFE 0001 F0F0 F900 0C03 FF81"            /* ............... */
	$"F303 F801 8030 000C 00F0 E900 1003 00F0"            /* ....0.......... */
	$"000F FE00 01F0 F0F3 0000 03E3 001B 0300"            /* ................ */
	$"F000 0FFE 0003 F00F 000F FB00 000F FCFF"            /* ................ */
	$"01F3 7FFD FF00 FEE9 0012 0300 F000 0FFE"            /* ................ */
	$"0003 F00F 000F F500 0006 E300 1203 00F0"            /* ................ */
	$"000F FE00 03F0 0F00 0FF5 0000 06E3 0012"            /* ................ */
	$"0300 F000 0FFE 0003 F00F 000F F500 000C"            /* ................ */
	$"E300 130B 00F0 000F 000F FFF0 0F00 FFF0"            /* ................ */
	$"F600 000C E300 0F0B 00F0 000F 000F FFF0"            /* ................ */
	$"0F00 FFF0 D700 0F0B 00F0 000F 000F FFF0"            /* ....×........... */
	$"0F00 FFF0 D700 0F0B 00F0 000F 000F FFF0"            /* ....×........... */
	$"0F00 FFF0 D700 0E03 00F0 000F FE00 03F0"            /* ....×........... */
	$"0F00 0FD6 001E 0300 F000 0FFE 0003 F00F"            /* ...Ö............ */
	$"000F FA00 0040 FE00 0106 10FD 0003 0621"            /* .....@.........! */
	$"0204 EB00 1C03 00F0 000F FE00 03F0 0F00"            /* ................ */
	$"0FFA 0000 40FE 0000 02FC 0002 0801 02EA"            /* ....@........... */
	$"001C 0300 F000 0FFE 0003 F00F 000F FA00"            /* ................ */
	$"0040 FE00 0002 FC00 0208 0102 EA00 2808"            /* .@............(. */
	$"00F0 000F 0000 FFF0 0FF8 0018 A00B 8385"            /* ............ . */
	$"C231 7070 78B8 1E63 C78C 5C1D 02E1 70E0"            /* Â1ppx¸.cÇ\...p. */
	$"74B8 F173 80F6 0028 0800 F000 0F00 00FF"            /* t¸.s..(........ */
	$"F00F F800 18A0 0C44 4622 1188 8884 C408"            /* ..... .DF".Ä. */
	$"2102 0462 2303 1189 108C C509 8C40 F600"            /* !..b#...ÅÆ@.. */
	$"2908 00F0 000F 0000 FFF0 0FF9 0019 0110"            /* )............... */
	$"0848 2422 1109 043C 8008 2102 0442 4102"            /* .H$".Æ.<.!..BA. */
	$"0902 0904 8079 0840 F600 2908 00F0 000F"            /* Æ.Æ.y.@..)..... */
	$"0000 FFF0 0FF9 0019 0110 0848 2422 1109"            /* ...........H$".Æ */
	$"FC44 8008 2102 0442 4102 0902 0904 8089"            /* .D.!..BA.Æ.Æ. */
	$"0840 F600 2A03 00F0 000F FE00 02F0 00F0"            /* .@..*........... */
	$"FA00 1903 F808 4824 2211 0900 8480 0821"            /* ......H$".Æ..! */
	$"0204 4241 0209 0209 0481 0908 40F6 002A"            /* ..BA.Æ.Æ.Æ.@..* */
	$"0300 F000 0FFE 0002 F000 F0FA 0019 0208"            /* ................ */
	$"0848 2422 1109 0084 8008 2102 0442 4102"            /* .H$".Æ..!..BA. */
	$"0902 0904 8109 0840 F600 2A03 00F0 000F"            /* Æ.Æ.Æ.@..*..... */
	$"FE00 02F0 00F0 FA00 1904 0408 4444 2211"            /* ............DD". */
	$"0888 8C80 0821 2244 4223 0311 0110 8C81"            /* ..!"DB#.... */
	$"1908 40F6 002A 0300 F000 0FFE 0002 F000"            /* ..@..*.......... */
	$"F0FA 0019 0404 0843 8422 1108 7074 8008"            /* .......C"..pt. */
	$"20C1 8442 1D02 E100 E074 80E9 0840 F600"            /*  ÁB.....t..@.. */
	$"1609 00F0 000F 0000 FFF0 00F0 EA00 0101"            /* .Æ.............. */
	$"02FE 0000 04F2 0016 0900 F000 0F00 00FF"            /* ........Æ....... */
	$"F000 F0EA 0001 0202 FE00 0008 F200 1609"            /* ...............Æ */
	$"00F0 000F 0000 FFF0 00F0 EA00 011C 02FE"            /* ................ */
	$"0000 70F2 000D 0900 F000 0F00 00FF F000"            /* ..p..ÂÆ......... */
	$"F0D5 000D 0300 F000 0FFE 0002 F000 F0D5"            /* .Õ.Â...........Õ */
	$"000D 0300 F000 0FFE 0002 F000 F0D5 000D"            /* .Â...........Õ.Â */
	$"0300 F000 0FFE 0002 F000 F0D5 000D 0300"            /* ...........Õ.Â.. */
	$"F000 0FFE 0002 F000 F0D5 0032 0900 F000"            /* .........Õ.2Æ... */
	$"0F00 00FF F000 0FFA 0006 0400 0010 1001"            /* ................ */
	$"02FE 0001 2020 FD00 0C04 0180 0808 0000"            /* ....  ......... */
	$"0100 0800 07C0 FE00 0480 0020 4080 2E09"            /* .....À.... @.Æ */
	$"00F0 000F 0000 FFF0 000F FA00 0604 0000"            /* ................ */
	$"1830 0102 FE00 0120 20FC 0003 0240 0C18"            /* .0.....  ....@.. */
	$"FB00 0104 20FE 0004 8000 2040 002E 0900"            /* .... .... @..Æ. */
	$"F000 0F00 00FF F000 0FFA 0006 0400 0014"            /* ................ */
	$"5001 02FE 0001 1040 FC00 0302 400A 28FB"            /* P......@....@.(. */
	$"0001 0410 FE00 0480 0020 4000 3309 00F0"            /* ........ @.3Æ.. */
	$"000F 0000 FFF0 000F FA00 2405 C208 1291"            /* ..........$.Â.. */
	$"E3C7 8381 C010 43C1 C1C3 C5CC 0280 0948"            /* .ÇÀ.CÁÁÃÅÌ.ÆH */
	$"F109 731F 9838 0410 7038 38B8 3878 F180"            /* .Æs.8..p88¸8x. */
	$"3303 00F0 000F FE00 02F0 000F FA00 2406"            /* 3.............$. */
	$"2208 1112 1102 0442 2008 8422 2224 2624"            /* "......B .""$&$ */
	$"0100 0889 0909 8900 8844 0410 8844 44C4"            /* ...ÆÆ.D..DDÄ */
	$"4420 4080 3303 00F0 000F FE00 02F0 000F"            /* D @3........... */
	$"FA00 0104 11FE 101F F102 0824 1008 81E4"            /* ...........$... */
	$"0401 E404 0280 0808 7909 0101 0882 0421"            /* .......yÆ....! */
	$"0480 8084 8220 4080 3303 00F0 000F FE00"            /* . @3....... */
	$"02F0 000F FA00 2404 1110 1011 1102 0FE4"            /* ......$......... */
	$"1005 0224 0402 2404 0448 0808 8909 0102"            /* ...$..$..H..Æ.. */
	$"0882 07C1 0480 8084 FE20 4080 3303 00F0"            /* ..Á.. @3... */
	$"000F FE00 02F0 000F FA00 1304 10A0 1012"            /* ............. .. */
	$"1102 0804 1005 0424 0404 2404 0428 08FE"            /* .......$..$..(.. */
	$"090D 0104 0882 0441 0480 8084 8020 4080"            /* ÆÂ....A. @ */
	$"370D 00F0 000F 000F FFF0 0000 F000 00F0"            /* 7Â.............. */
	$"FE00 1304 10A0 1012 1102 0804 1002 0424"            /* ..... .........$ */
	$"0404 2404 0410 08FE 090D 0108 0882 0421"            /* ..$.....ÆÂ....! */
	$"0480 8084 8020 4080 370D 00F0 000F 000F"            /* . @7Â...... */
	$"FFF0 0000 F000 00F0 FE00 2406 2040 1012"            /* ..........$. @.. */
	$"3122 4442 2002 0462 2224 6404 0228 0809"            /* 1"DB ..b"$d..(.Æ */
	$"1919 0110 0844 0410 8844 4484 4424 4880"            /* .....D..DDD$H */
	$"370D 00F0 000F 000F FFF0 0000 F000 00F0"            /* 7Â.............. */
	$"FE00 2405 C040 1011 D0C1 8381 C002 03A1"            /* ..$.À@..ÐÁÀ..¡ */
	$"C1C3 A404 01C4 0808 E8E9 011F 8838 0408"            /* ÁÃ¤..Ä......8.. */
	$"7038 3884 3818 3084 170D 00F0 000F 000F"            /* p888.0.Â...... */
	$"FFF0 0000 F000 00F0 FC00 0080 E000 0004"            /* ............... */
	$"1703 00F0 000F FE00 06F0 0000 0F00 0FFF"            /* ................ */
	$"FC00 0080 E000 0004 1703 00F0 000F FE00"            /* ............... */
	$"06F0 0000 0F00 0FFF FD00 0001 DF00 0008"            /* ................ */
	$"1503 00F0 000F FE00 06F0 0000 0F00 0FFF"            /* ................ */
	$"FD00 0001 DE00 1103 00F0 000F FE00 06F0"            /* ................ */
	$"0000 0F00 0FFF D900 110D 00F0 000F 0000"            /* .........Â...... */
	$"FFF0 0000 0F00 00F0 D900 110D 00F0 000F"            /* ...........Â.... */
	$"0000 FFF0 0000 0F00 00F0 D900 110D 00F0"            /* .............Â.. */
	$"000F 0000 FFF0 0000 0F00 00F0 D900 260D"            /* ..............&Â */
	$"00F0 000F 0000 FFF0 0000 0F00 00F0 FE00"            /* ................ */
	$"1104 0400 0080 0060 8000 0004 0200 0010"            /* ......`....... */
	$"2100 02EE 0023 0300 F000 0FFE 0004 F000"            /* !....#.......... */
	$"0F00 FFFC 0001 060C FD00 0160 80FE 0006"            /* ...........`... */
	$"0200 0010 0100 02EE 0023 0300 F000 0FFE"            /* .........#...... */
	$"0004 F000 0F00 FFFC 0001 0514 FD00 0150"            /* ...............P */
	$"80FE 0006 0200 0010 0100 02EE 0026 0300"            /* ............&.. */
	$"F000 0FFE 0004 F000 0F00 FFFC 0013 04A4"            /* ...............¤ */
	$"78B9 8380 5087 03A5 CC02 2E1E 3C63 C427"            /* x¹P.¥Ì...<cÄ' */
	$"8380 F000 2603 00F0 000F FE00 04F0 000F"            /* ..&........... */
	$"00FF FC00 1304 4484 C484 4048 8884 6624"            /* ......DÄ@Hf$ */
	$"0231 2110 2104 2204 40F0 0027 0C00 F000"            /* .1!.!.".@..'.... */
	$"0F00 00FF F000 FFF0 00FF FD00 1304 043C"            /* ...............< */
	$"8088 2044 9048 2404 0221 2010 2104 2208"            /*  DH$..! .!.". */
	$"20F0 0027 0C00 F000 0F00 00FF F000 FFF0"            /*  ..'............ */
	$"00FF FD00 1304 0444 8088 2044 9FC8 2404"            /* .......D DÈ$. */
	$"0221 1E10 2104 220F E0F0 0026 0C00 F000"            /* .!..!."....&.... */
	$"0F00 00FF F000 FFF0 00FF FD00 1204 0484"            /* ............... */
	$"8088 2042 9008 2404 0221 0110 2104 2208"            /*  B.$..!..!.". */
	$"EF00 260C 00F0 000F 0000 FFF0 00FF F000"            /* ..&............. */
	$"FFFD 0012 0404 8480 8820 4190 0824 0402"            /* ...... A.$.. */
	$"2101 1021 0422 08EF 0028 0300 F000 0FFE"            /* !..!."...(...... */
	$"0002 F000 0FFE 0000 0FFE 0013 0404 8C80"            /* .............. */
	$"8440 4188 8464 0402 2121 1221 2462 4440"            /* @Ad..!!.!$bD@ */
	$"F000 2803 00F0 000F FE00 02F0 000F FE00"            /* ..(............. */
	$"000F FE00 1304 0474 8083 8040 8703 A404"            /* .......t@.¤. */
	$"0221 1E0C 20C3 A183 84F0 0015 0300 F000"            /* .!.. Ã¡....... */
	$"0FFE 0002 F000 0FFE 0000 0FF5 0000 20E6"            /* .............. . */
	$"0015 0300 F000 0FFE 0002 F000 0FFE 0000"            /* ................ */
	$"0FF5 0000 40E6 0015 0700 F000 0F00 00FF"            /* ....@........... */
	$"F0FC 0001 0FF0 F700 0103 80E6 0010 0700"            /* ............... */
	$"F000 0F00 00FF F0FC 0001 0FF0 DA00 1007"            /* ................ */
	$"00F0 000F 0000 FFF0 FC00 010F F0DA 0010"            /* ................ */
	$"0700 F000 0F00 00FF F0FC 0001 0FF0 DA00"            /* ................ */
	$"0F03 00FF FF0F FE00 00F0 FAFF 00F0 DB00"            /* ................ */
	$"0F03 00FF FF0F FE00 00F0 FAFF 00F0 DB00"            /* ................ */
	$"0F03 00FF FF0F FE00 00F0 FAFF 00F0 DB00"            /* ................ */
	$"0F03 00FF FF0F FE00 00F0 FAFF 00F0 DB00"            /* ................ */
	$"0FFE 0000 0FFE 0000 F0FC 0001 0FF0 DA00"            /* ................ */
	$"0FFE 0000 0FFE 0000 F0FC 0001 0FF0 DA00"            /* ................ */
	$"0FFE 0000 0FFE 0000 F0FC 0001 0FF0 DA00"            /* ................ */
	$"0FFE 0000 0FFE 0000 F0FC 0001 0FF0 DA00"            /* ................ */
	$"0CFD 0002 F000 0FFB 0000 0FD9 000C FD00"            /* ................ */
	$"02F0 000F FB00 000F D900 0CFD 0002 F000"            /* ................ */
	$"0FFB 0000 0FD9 000C FD00 02F0 000F FB00"            /* ................ */
	$"000F D900 08FD 0002 0FFF F0D2 0008 FD00"            /* ...........Ò.... */
	$"020F FFF0 D200 08FD 0002 0FFF F0D2 0008"            /* ....Ò........Ò.. */
	$"FD00 020F FFF0 D200 02CB 0002 CB00 02CB"            /* ......Ò..Ë..Ë..Ë */
	$"0002 CB00 02CB 0002 CB00 02CB 0002 CB00"            /* ..Ë..Ë..Ë..Ë..Ë. */
	$"02CB 0002 CB00 02CB 0035 0200 0780 FE00"            /* .Ë..Ë..Ë.5..... */
	$"0580 1010 0000 04FE 1E0C 0008 3C3C 0804"            /* ...........<<.. */
	$"1002 0800 0010 40FE 0012 0100 C008 2000"            /* ......@.....À. . */
	$"1000 3100 0001 0080 0010 4200 10FD 0032"            /* ..1......B....2 */
	$"0200 0840 FD00 0410 1003 C00C FE21 0C00"            /* ...@......À..!.. */
	$"1842 4218 0630 0208 0000 1040 FD00 0301"            /* .BB..0.....@.... */
	$"200C 60FE 0000 31FD 0005 8000 1002 0010"            /*  .`...1........ */
	$"FD00 360B 0008 071E 225D 8796 3804 2004"            /* ..6....."]8. . */
	$"FE21 2300 0842 4208 0551 C71C 3870 1047"            /* .!#..BB..QÇ.8p.G */
	$"0E1C 38BB 0140 0AA3 8BB0 E029 1C3C BB00"            /* ..8».@.£°.).<». */
	$"8B0E 38C7 1138 70FE 0036 3200 0808 9122"            /* .8Ç.8p..62..." */
	$"6088 9910 0990 0421 1E21 0008 4242 0804"            /* `.Æ.!.!..BB.. */
	$"9222 0844 8808 8891 2244 C100 8009 244C"            /* ".D."DÁ.Æ$L */
	$"1110 2922 44C1 008C 9110 4211 1088 FE00"            /* ..)"DÁ..B.... */
	$"360B 0008 0891 2240 8891 100A 1004 FE21"            /* 6...."@.....! */
	$"233E 0842 4208 0411 E208 4488 0887 9020"            /* #>.BB.....D.  */
	$"3C81 0140 0823 C811 1025 2244 8100 8890"            /* <.@.#È..%"D. */
	$"1042 1110 88FE 0036 3200 0808 9122 4088"            /* .B....62..."@ */
	$"9110 0A10 041F 211F 0008 3E3E 0804 1222"            /* .....!...>>..." */
	$"087C 8805 0890 2044 8102 2808 2448 1110"            /* .|.. D.(.$H.. */
	$"253E 4481 0088 8E10 4211 10F8 FE00 3632"            /* %>D..B.....62 */
	$"0008 0891 2240 8891 1009 9004 0121 0100"            /* ..."@.Æ..!.. */
	$"0802 0208 0412 2208 4088 0508 9020 4481"            /* ......".@.. D */
	$"0210 0824 4811 1023 2044 8100 8881 1042"            /* ...$H..# D..B */
	$"1110 80FE 0036 3200 0848 9122 4088 9110"            /* ....62..H"@. */
	$"0420 0402 2102 0008 0404 0804 1222 0844"            /* . ..!........".D */
	$"8802 0891 2244 8102 2808 2448 1110 2322"            /* .."D.(.$H..#" */
	$"4481 0088 9110 4213 1088 FE00 3632 0007"            /* D..B....62.. */
	$"871E 1E40 8791 0C03 C004 1C1E 1C00 0838"            /* ..@..À......8 */
	$"3808 0411 E186 3870 0207 8E1C 3C81 01C4"            /* 8....8p...<.Ä */
	$"0823 C810 E021 1C3C 8100 888E 0C41 8D0C"            /* .#È..!.<..A. */
	$"70FE 000E FE00 0410 0200 0080 E000 0004"            /* p.............. */
	$"F500 0EFE 0004 1022 0008 80E0 0000 44F5"            /* .......".....D. */
	$"000C FD00 021C 0007 DF00 0038 F500 02CB"            /* ...........8...Ë */
	$"0002 CB00 02CB 002D 0300 07C8 20F7 0001"            /* ..Ë..Ë.-...È ... */
	$"0222 FE00 1D88 8041 0004 0000 F000 1E00"            /* ."...A........ */
	$"8387 1F00 1070 E1C0 4000 6003 8000 0002"            /* ...p.À@.`.... */
	$"0000 08FC 002B 0200 0108 F500 0022 FE00"            /* .....+.......".. */
	$"1D08 8063 0004 0001 0800 2101 8448 9000"            /* ..c......!.H. */
	$"3089 1220 4000 2004 4000 0002 0000 08FC"            /* 0. @. .@....... */
	$"0035 3100 010E 6303 8B31 CB31 D820 98C1"            /* .51...c.1Ë1Ø Á */
	$"04B6 7731 C105 9CE0 5531 8A38 E2E4 004C"            /* .¶w1Á..U18...L */
	$"8084 4890 0010 8912 20A3 8E23 040C 7638"            /* H... £#..v8 */
	$"9731 6008 E3FD 0036 3200 0109 2482 4C4A"            /* 1`....62..Æ$LJ */
	$"4C49 2420 A521 04C2 2249 2104 8890 494A"            /* LI$ ¥!.Â"I!.IJ */
	$"4A24 9294 1050 8084 471E 0010 8912 20A2"            /* J$.PG.... ¢ */
	$"4924 8412 4924 9249 8008 9480 FE00 3531"            /* I$.I$I...51 */
	$"0001 0923 0248 4A48 3924 151C C0A8 8222"            /* ..Æ#.HJH9$..À¨" */
	$"7920 A888 9041 3A11 2492 E400 5080 83C8"            /* y ¨A:.$..PÈ */
	$"813C 1078 F221 1249 2784 1249 2492 7900"            /* <.x.!.I'.I$y. */
	$"0894 FD00 3531 0001 0920 8248 4A48 4924"            /* ...51..Æ HJHI$ */
	$"1524 20A8 8222 4120 A888 9041 4A1F 2492"            /* .$ ¨"A ¨AJ.$ */
	$"9400 4C80 8048 8100 1008 1221 F249 2404"            /* .LH....!.I$. */
	$"1249 2492 4100 0894 FD00 3632 0001 0924"            /* .I$A....62..Æ$ */
	$"8248 4A48 4924 0A25 2050 8222 4920 5088"            /* HJHI$.% P"I P */
	$"9041 4A51 2491 0800 2100 8088 9100 1010"            /* AJQ$..!.... */
	$"2221 1249 2484 5249 2492 4900 0894 80FE"            /* "!.I$RI$I... */
	$"0036 3200 0109 2303 8831 C839 240A 1CC0"            /* .62..Æ#.1È9$..À */
	$"5082 1131 2050 8490 4139 9138 E0F0 101E"            /* P.1 PA98.... */
	$"0083 070E 0010 60C1 C113 8E23 038C 4938"            /* .....`ÁÁ.#.I8 */
	$"7131 0208 9310 FE00 1AFD 0003 0200 0040"            /* q1............@ */
	$"F100 0120 80F5 0001 0208 FD00 0320 0000"            /* ... ........ .. */
	$"02FB 001A FD00 0302 0001 80F1 0001 2080"            /* .............  */
	$"F500 0102 08FD 0003 2000 0004 FB00 A000"            /* ........ ..... . */
	$"8FA0 0083 FF"                                       /*  .. */
};


resource 'PICT' (kAboutMarioNegriPict,
#if qNames
"About Mario Negri",
#endif
purgeable) {
	{0, 0, 128, 416},
	VersionOne {
		{	/* array OpCodes: 6 elements */
			/* [1] */
			shortComment {
				130
			},
			/* [2] */
			shortComment {
				142
			},
			/* [3] */
			clipRgn {
				{0, 0, 752, 576},
				$""
			},
			/* [4] */
			packBitsRect {
				52,
				{0, 0, 128, 416},
				{0, 0, 128, 416},
				{0, 0, 128, 416},
				srcOr,
				$"02 CD 00 02 CD 00 02 CD 00 02 CD 00 2F 0C 00 3F"
				$"F3 00 00 0E 01 C0 00 30 00 07 07 FE 00 04 60 1E"
				$"00 00 03 FD 00 05 0E 00 00 0F C1 80 FB 00 06 06"
				$"00 00 0C 00 07 E0 FC 00 02 01 80 00 2F 0C 00 33"
				$"37 00 00 07 03 80 00 30 00 03 82 FE 00 04 60 0C"
				$"00 00 03 FD 00 05 19 00 00 06 33 80 FB 00 06 0E"
				$"00 00 0C 00 03 18 FC 00 02 03 80 00 2E 07 00 23"
				$"13 00 00 07 03 80 FE 00 01 03 82 FD 00 0D 0C 00"
				$"00 20 08 00 20 00 18 00 00 06 19 80 FB 00 00 06"
				$"FD 00 01 03 0C FC 00 02 01 80 00 2E 07 00 03 03"
				$"00 00 05 85 80 FE 00 01 02 C2 FD 00 0D 0C 00 00"
				$"60 18 00 60 00 18 00 00 06 19 80 FB 00 00 06 FD"
				$"00 01 03 0C FC 00 02 01 80 00 35 33 00 03 03 70"
				$"E0 05 85 8F 0B B0 F0 02 62 1C 1F 57 60 0C 2E 3C"
				$"F3 3D CE F1 C0 3E 3C 2E 06 19 B8 F0 B9 73 8F 07"
				$"87 86 1E 0F AC 3C 03 0C 1C 3C 38 78 5C F1 B8 00"
				$"35 33 00 03 03 99 10 04 C9 99 9D F1 98 02 72 22"
				$"33 BB E0 0C F3 66 67 18 C6 62 20 18 66 76 06 31"
				$"CD 99 DF 9C D9 8C CC C6 33 19 DC 66 03 18 22 66"
				$"44 CC ED 99 CC 00 35 33 00 03 03 1B 18 04 C9 91"
				$"8C 33 0C 02 32 63 31 98 60 0C 63 72 63 18 C6 66"
				$"30 18 C3 30 07 C1 8D 18 C3 18 D1 98 D8 66 61 98"
				$"CC C6 03 E0 63 72 C6 8C 63 19 8C 00 35 33 00 03"
				$"03 1B F8 04 D1 83 8C 33 0C 02 1A 7F 31 98 60 0C"
				$"63 38 63 18 C6 67 F0 18 C3 30 06 01 8C 38 C3 18"
				$"C3 98 18 66 61 98 CC C0 03 60 7F 38 FE 1C 63 01"
				$"8C 00 35 33 00 03 03 1B 00 04 71 8D 8C 33 0C 02"
				$"0E 60 39 98 60 0C 63 1C 63 18 C6 66 00 18 C3 30"
				$"06 01 8C D8 C3 18 CD 98 18 66 61 9C CC C0 03 30"
				$"60 1C C0 6C 63 01 8C 00 35 33 00 03 03 1B 88 04"
				$"71 99 8C 33 0C 02 0E 71 1F 18 60 0C 63 4E 63 18"
				$"C6 67 10 18 C3 30 06 01 8D 98 C3 18 D9 98 58 66"
				$"61 8F 8C C2 03 18 71 4E E2 CC 63 09 8C 00 35 33"
				$"00 03 03 19 F0 04 21 9B AC 31 98 02 06 3E 20 18"
				$"60 0C 63 66 6B 1A CF 6B E0 18 66 30 06 01 8D BA"
				$"C3 18 DB AC CC C6 33 10 0C 66 03 0E 3E 66 7C DD"
				$"61 99 8C 00 35 33 00 07 87 BC E0 0E 23 CC DE 78"
				$"F0 07 02 1C 3F 3C F0 1E F7 BC 37 8C 76 31 C0 3C"
				$"3C 78 0F 03 DE CD E7 BD EC C7 87 8F 1E 1F 9E 3C"
				$"07 C7 1C 3C 38 66 F0 F3 DE 00 0C F3 00 01 1F 80"
				$"EA 00 01 0F C0 F6 00 0C F3 00 01 61 80 EA 00 01"
				$"30 C0 F6 00 0B F3 00 00 61 E9 00 01 30 80 F6 00"
				$"0A F3 00 00 3E E9 00 00 1F F5 00 02 CD 00 02 CD"
				$"00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00"
				$"02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02"
				$"CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD"
				$"00 0F EC 00 04 01 00 0F E0 10 FE 00 01 03 0E EC"
				$"00 0D EA 00 02 04 20 01 FE 00 01 0C 11 EC 00 0D"
				$"EA 00 02 04 00 01 FE 00 01 08 21 EC 00 10 ED 00"
				$"0A 01 DD 1C 04 8D 93 B6 71 C0 16 01 EC 00 0F EC"
				$"00 09 8B 22 07 86 B1 1A 8A 20 19 02 EC 00 0F EC"
				$"00 09 89 0E 04 84 11 10 88 E0 10 84 EC 00 0F EC"
				$"00 09 51 12 04 04 11 10 F9 20 10 88 EC 00 0F EC"
				$"00 09 51 22 04 04 11 10 82 20 10 90 EC 00 0F EC"
				$"00 09 21 26 04 24 11 50 8A 60 09 21 EC 00 0F EC"
				$"00 09 23 9B 0F EE 38 B8 71 B4 06 3E EC 00 06 E5"
				$"00 00 04 EA 00 06 E5 00 00 04 EA 00 06 E5 00 00"
				$"08 EA 00 02 CD 00 02 CD 00 0C EC 00 06 70 E0 87"
				$"CF 86 03 22 E9 00 0C EC 00 06 89 11 84 10 82 02"
				$"06 E9 00 0D ED 00 07 01 09 10 84 01 03 06 02 E9"
				$"00 0F EC 00 09 09 10 87 01 03 06 22 39 B0 C0 EC"
				$"00 0F EC 00 09 11 10 80 82 02 8A 62 44 C9 20 EC"
				$"00 0F EC 00 09 21 10 80 42 02 8A 22 1C 8A 10 EC"
				$"00 0F EC 00 09 41 10 80 44 02 52 22 24 8A 10 EC"
				$"00 0F EC 00 09 81 10 80 44 02 52 22 44 8A 10 EC"
				$"00 10 ED 00 0A 01 09 10 84 88 02 22 22 4C 89 20"
				$"EC 00 10 ED 00 0A 01 F0 E1 C3 08 07 27 77 37 DC"
				$"C2 EC 00 06 E3 00 00 02 EC 00 06 E3 00 00 02 EC"
				$"00 06 E3 00 00 04 EC 00 02 CD 00 02 CD 00 0B EA"
				$"00 05 0E 7F 04 0E 0E 38 EA 00 0B EA 00 01 04 49"
				$"FE 04 00 10 EA 00 0B EA 00 05 04 08 0A 04 02 20"
				$"EA 00 0B EA 00 05 04 08 0A 04 02 20 EA 00 0B EA"
				$"00 05 04 08 11 04 01 40 EA 00 0B EA 00 05 04 08"
				$"11 04 01 40 EA 00 0B EA 00 05 04 08 1F 04 00 80"
				$"EA 00 0B EA 00 05 04 08 20 84 00 80 EA 00 0B EA"
				$"00 05 04 08 20 84 20 80 EA 00 0B EA 00 05 0E 1C"
				$"71 CF E1 C0 EA 00 02 CD 00 02 CD 00 02 CD 00 02"
				$"CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD"
				$"00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00"
				$"02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02"
				$"CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 30 FE"
				$"00 01 07 40 FD 00 03 04 00 0F C2 FE 00 00 02 FD"
				$"00 0A 80 00 71 C0 10 01 80 00 10 01 80 FE 00 00"
				$"04 FE 00 00 04 FE 00 04 7F 00 00 1F C8 FD 00 33"
				$"FE 00 09 18 C0 00 20 00 20 4C 00 04 20 FE 00 00"
				$"26 FE 00 0B 08 00 00 20 80 01 02 40 00 00 02 40"
				$"FE 00 00 40 FE 00 09 0C 00 00 20 21 00 00 08 40"
				$"80 FE 00 32 FE 00 09 10 40 00 20 00 20 44 00 04"
				$"10 FE 00 00 22 FE 00 06 08 00 00 20 80 01 02 FE"
				$"00 00 02 FD 00 00 40 FE 00 09 04 00 00 20 20 00"
				$"00 08 00 80 FE 00 33 FE 00 2D 20 06 36 73 8E 70"
				$"E5 8E 04 22 18 D9 8E 72 C7 36 63 9C 8E 38 20 9B"
				$"13 87 8C 6C 13 67 8C 6D B3 1C E4 31 B1 C1 C7 86"
				$"33 70 24 38 EE E8 89 C0 FE 00 33 FE 00 2D 20 09"
				$"19 24 53 20 46 51 07 C6 24 66 51 23 28 99 94 49"
				$"93 48 20 8C B1 02 12 34 31 92 12 34 CC A2 4C 48"
				$"CA 42 24 49 11 20 3C 45 24 4F 98 80 FE 00 33 FE"
				$"00 2D 20 10 91 21 D0 20 44 51 04 22 42 44 47 22"
				$"28 91 11 C8 90 40 20 88 91 02 21 20 11 12 21 20"
				$"88 8E 44 84 8A 00 E4 50 91 20 24 1D 04 48 88 80"
				$"FE 00 33 FE 00 2D 20 10 91 22 50 20 44 5F 04 12"
				$"42 44 49 22 2F 91 12 48 90 30 20 88 91 02 21 20"
				$"11 12 21 20 88 92 44 84 89 81 24 50 91 20 20 24"
				$"C2 88 08 80 FE 00 33 FE 00 2D 10 50 91 24 50 20"
				$"44 50 04 12 42 44 51 22 28 11 14 48 90 08 20 88"
				$"91 02 21 20 11 12 21 20 88 A2 44 84 88 42 24 50"
				$"91 20 20 44 22 88 08 80 FE 00 33 FE 00 2D 18 89"
				$"11 2C D1 28 54 51 04 22 24 44 53 2A 28 91 14 CA"
				$"91 48 11 08 91 42 12 20 11 12 12 20 88 A6 54 48"
				$"8A 42 64 49 13 28 21 4D 21 08 08 A0 FE 00 33 FE"
				$"00 2D 07 06 3B 93 6E 10 2E EE 0F C7 18 EE ED 97"
				$"77 3B BB 65 CE 70 0E 1D F8 87 0C 70 3B BF 0C 71"
				$"DD DB 2E 31 DF 81 B3 86 0D 90 7F 37 C1 1C 1C 48"
				$"FE 00 06 D4 00 00 02 FB 00 06 D4 00 00 02 FB 00"
				$"06 D4 00 00 0C FB 00 02 CD 00 02 CD 00 02 CD 00"
				$"02 CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00 02"
				$"CD 00 02 CD 00 02 CD 00 02 CD 00 02 CD 00"
			},
			/* [5] */
			shortComment {
				143
			},
			/* [6] */
			shortComment {
				131
			}
		}
	}
};

