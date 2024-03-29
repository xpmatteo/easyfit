/*
	This file is part of EasyFit, a nonlinear fitting program for the Macintosh�.
	
	Copyright � 1989 Matteo Vaccari & Mario Negri Institute
	
	NOTE: see documentation in file UEasyFit.dlog.p near the DoShowAboutApp
	method.
*/

/* include my definitions */
#include "Declarations.r"

data 'STYL' (kAboutAppStylesRes) {
	$"000E 0009 0016 2C40 0016 2B84 0016 2B9C"            /* ...�..,@..+�..+� */
	$"0016 2B7C 0000 0004 0007 0002 0033 0006"            /* ..+|.........3.. */
	$"0041 0002 0044 0006 0056 0002 008C 0005"            /* .A...D...V...�.. */
	$"00BC 0002 00BE 0000 0122 0001 0503 0007"            /* .�...�..."...... */
	$"06A1 0008 06F9 0007 0741 0001 0883 FFFF"            /* .�.......A...�.. */
	$"08C6 FFFF 08C6 FFFF 0908 FFFF"                      /* .�...�..�... */
};

data 'STYL' (kAboutAppElementsRes) {
	$"0001 0010 000C 0003 0000 000C 0000 0000"            /* ................ */
	$"0000 0002 0010 000C 0003 0000 0000 0000"            /* ................ */
	$"0000 0000 0004 0013 000E 0003 0000 000E"            /* ................ */
	$"0000 0000 0000 0000 0010 000C 0000 0000"            /* ................ */
	$"0000 0000 0000 0000 0001 0017 0012 0003"            /* ................ */
	$"0500 0012 0000 0000 0000 0001 0013 000E"            /* ................ */
	$"0003 0400 000E 0000 0000 0000 0002 0013"            /* ................ */
	$"000E 0003 0100 000E 0000 0000 0000 0002"            /* ................ */
	$"0010 000C 0003 0100 0000 0000 0000 0000"            /* ................ */
	$"0001 0010 000C 0003 0500 0000 0000 0000"            /* ................ */
	$"0000"                                               /* .. */
};


data 'TEXT' (kAboutAppTextRes,
#if qNames
"AboutApp text",
#endif
purgeable)
{
	$"4561 7379 4669 740D 0D61 206E 6F6E 6C69"            /* EasyFit��a nonli */
	$"6E65 6172 2063 7572 7665 2066 6974 7469"            /* near curve fitti */
	$"6E67 2061 7070 6C69 6361 7469 6F6E 0D0D"            /* ng application�� */
	$"6279 204D 6174 7465 6F20 5661 6363 6172"            /* by Matteo Vaccar */
	$"6920 2620 4D61 7572 697A 696F 2052 6F63"            /* i & Maurizio Roc */
	$"6368 6574 7469 0D6F 6620 7468 6520 4269"            /* chetti�of the Bi */
	$"6F6D 6174 6865 6D61 7469 6373 2061 6E64"            /* omathematics and */
	$"2042 696F 7374 6174 6973 7469 6373 2055"            /*  Biostatistics U */
	$"6E69 7420 6F66 2074 6865 200D 4D61 7269"            /* nit of the �Mari */
	$"6F20 4E65 6772 6920 496E 7374 6974 7574"            /* o Negri Institut */
	$"6520 666F 7220 5068 6172 6D61 636F 6C6F"            /* e for Pharmacolo */
	$"6769 6320 5265 7365 6172 6368 0D0D 5468"            /* gic Research��Th */
	$"6973 2070 726F 6772 616D 2069 7320 436F"            /* is program is Co */
	$"7079 7269 6768 7420 A920 3139 3839 2D31"            /* pyright � 1989-1 */
	$"3939 3120 4D61 7474 656F 2056 6163 6361"            /* 991 Matteo Vacca */
	$"7269 2026 204D 6172 696F 204E 6567 7269"            /* ri & Mario Negri */
	$"2049 6E73 7469 7475 7465 2E20 416C 6C20"            /*  Institute. All  */
	$"7269 6768 7473 2072 6573 6572 7665 642E"            /* rights reserved. */
	$"0D0D 5468 6973 2070 726F 6772 616D 2077"            /* ��This program w */
	$"6173 2077 7269 7474 656E 2077 6974 6820"            /* as written with  */
	$"4D61 6341 7070 A820 3A20 A920 3139 3835"            /* MacApp� : � 1985 */
	$"2D31 3939 3020 4170 706C 6520 436F 6D70"            /* -1990 Apple Comp */
	$"7574 6572 2C20 496E 632E 0D0D 4974 2069"            /* uter, Inc.��It i */
	$"7320 7265 616C 6C79 2069 6D70 6F72 7461"            /* s really importa */
	$"6E74 2079 6F75 2074 6F20 7265 6164 2074"            /* nt you to read t */
	$"6865 2064 6F63 756D 656E 7461 7469 6F6E"            /* he documentation */
	$"2062 6566 6F72 6520 6174 7465 6D70 7469"            /*  before attempti */
	$"6E67 2074 6F20 7573 6520 7468 6973 2061"            /* ng to use this a */
	$"7070 6C69 6361 7469 6F6E 2E0D 0D54 6869"            /* pplication.��Thi */
	$"7320 6170 706C 6963 6174 696F 6E20 7761"            /* s application wa */
	$"7320 6465 7665 6C6F 7065 6420 6174 2074"            /* s developed at t */
	$"6865 204D 6172 696F 204E 6567 7269 2049"            /* he Mario Negri I */
	$"6E73 7469 7475 7465 2066 6F72 2050 6861"            /* nstitute for Pha */
	$"726D 6163 6F6C 6F67 6963 2052 6573 6561"            /* rmacologic Resea */
	$"7263 6820 696E 204D 696C 616E 6F2E 2054"            /* rch in Milano. T */
	$"6865 204D 6172 696F 204E 6567 7269 2049"            /* he Mario Negri I */
	$"6E73 7469 7475 7465 2069 7320 6120 6E6F"            /* nstitute is a no */
	$"6E2D 7072 6F66 6974 2069 6E64 6570 656E"            /* n-profit indepen */
	$"6465 6E74 2072 6573 6561 7263 6820 6F72"            /* dent research or */
	$"6761 6E69 7A61 7469 6F6E 2E0D 0D45 6173"            /* ganization.��Eas */
	$"7946 6974 2069 7320 6469 7374 7269 6275"            /* yFit is distribu */
	$"7465 6420 6279 2074 6865 204D 6172 696F"            /* ted by the Mario */
	$"204E 6567 7269 2049 6E73 7469 7475 7465"            /*  Negri Institute */
	$"2E20 5468 6520 6170 706C 6963 6174 696F"            /* . The applicatio */
	$"6E20 616E 6420 6974 7320 646F 6375 6D65"            /* n and its docume */
	$"6E74 6174 696F 6E20 2861 7320 6120 4D69"            /* ntation (as a Mi */
	$"6372 6F73 6F66 7420 576F 7264 2064 6F63"            /* crosoft Word doc */
	$"756D 656E 7429 2063 6F73 7420 6120 736D"            /* ument) cost a sm */
	$"616C 6C20 6665 652C 2069 6E20 6F72 6465"            /* all fee, in orde */
	$"7220 746F 2072 6566 756E 6420 7468 6520"            /* r to refund the  */
	$"496E 7374 6974 7574 6527 7320 6578 7065"            /* Institute's expe */
	$"6E73 6573 2E0D 0D54 6865 2066 6565 2061"            /* nses.��The fee a */
	$"6C6C 6F77 7320 616E 2069 6E64 6976 6964"            /* llows an individ */
	$"7561 6C20 6F72 2061 6E20 696E 7374 6974"            /* ual or an instit */
	$"7574 696F 6E20 746F 2075 7365 2074 6865"            /* ution to use the */
	$"2061 7070 6C69 6361 7469 6F6E 2E20 5468"            /*  application. Th */
	$"6520 6665 6520 6279 206E 6F20 6D65 616E"            /* e fee by no mean */
	$"7320 616C 6C6F 7773 2061 6E79 626F 6479"            /* s allows anybody */
	$"2074 6F20 646F 2061 6E79 206F 6620 7468"            /*  to do any of th */
	$"6520 666F 6C6C 6F77 696E 6720 7468 696E"            /* e following thin */
	$"6773 3A0D 2020 2D20 6469 7374 7269 6275"            /* gs:�  - distribu */
	$"7469 6E67 2063 6F70 6965 7320 6F66 2045"            /* ting copies of E */
	$"6173 7946 6974 206F 7220 6F66 2069 7473"            /* asyFit or of its */
	$"2064 6F63 756D 656E 7461 7469 6F6E 2C20"            /*  documentation,  */
	$"6F72 0D20 202D 206D 6F64 6966 7969 6E67"            /* or�  - modifying */
	$"2069 6E20 616E 7920 7761 7920 4561 7379"            /*  in any way Easy */
	$"4669 7420 6F72 2069 7473 2064 6F63 756D"            /* Fit or its docum */
	$"656E 7461 7469 6F6E 2E0D 0D49 6620 796F"            /* entation.��If yo */
	$"7520 7075 626C 6973 6820 6120 7363 6965"            /* u publish a scie */
	$"6E74 6966 6963 2070 6170 6572 2075 7369"            /* ntific paper usi */
	$"6E67 2045 6173 7946 6974 2072 6573 756C"            /* ng EasyFit resul */
	$"7473 2C20 6974 2077 6F75 6C64 2062 6520"            /* ts, it would be  */
	$"6E69 6365 2074 6F20 7772 6974 6520 736F"            /* nice to write so */
	$"6D65 7768 6572 6520 696E 2079 6F75 7220"            /* mewhere in your  */
	$"7061 7065 7220 7468 6174 2074 6865 2064"            /* paper that the d */
	$"6174 6120 7765 7265 2063 6F6D 7075 7465"            /* ata were compute */
	$"6420 7769 7468 2045 6173 7946 6974 2C20"            /* d with EasyFit,  */
	$"616E 6420 6164 6420 7468 6520 6164 6472"            /* and add the addr */
	$"6573 7320 6F66 2074 6865 204D 6172 696F"            /* ess of the Mario */
	$"204E 6567 7269 2049 6E73 7469 7475 7465"            /*  Negri Institute */
	$"2E0D 0D49 4D50 4F52 5441 4E54 2044 4953"            /* .��IMPORTANT DIS */
	$"434C 4149 4D45 520D 4561 7379 4669 7420"            /* CLAIMER�EasyFit  */
	$"6973 2064 6973 7472 6962 7574 6564 2022"            /* is distributed " */
	$"6173 2069 7322 2C20 7769 7468 6F75 7420"            /* as is", without  */
	$"616E 7920 7761 7272 616E 7479 2C20 6569"            /* any warranty, ei */
	$"7468 6572 2065 7870 7265 7373 6564 206F"            /* ther expressed o */
	$"7220 696D 706C 6965 642C 2061 626F 7574"            /* r implied, about */
	$"2069 7473 2066 6974 6E65 7373 2066 6F72"            /*  its fitness for */
	$"2061 6E79 2070 6172 7469 6375 6C61 7220"            /*  any particular  */
	$"7075 7270 6F73 652E 204E 6569 7468 6572"            /* purpose. Neither */
	$"204D 6172 696F 204E 6567 7269 2049 6E73"            /*  Mario Negri Ins */
	$"7469 7475 7465 206E 6F72 204D 6174 7465"            /* titute nor Matte */
	$"6F20 5661 6363 6172 6920 6173 7375 6D65"            /* o Vaccari assume */
	$"2061 6E79 2072 6573 706F 6E73 6962 696C"            /*  any responsibil */
	$"6974 7920 6162 6F75 7420 6461 6D61 6765"            /* ity about damage */
	$"7320 696E 6375 7272 6564 2065 6974 6865"            /* s incurred eithe */
	$"7220 6469 7265 6374 6C79 206F 7220 696E"            /* r directly or in */
	$"6469 7265 6374 6C79 2066 726F 6D20 7468"            /* directly from th */
	$"6520 7573 6520 6F66 2045 6173 7946 6974"            /* e use of EasyFit */
	$"2E20 4561 7379 4669 7420 6861 7320 6265"            /* . EasyFit has be */
	$"656E 2074 686F 726F 7567 686C 7920 7465"            /* en thoroughly te */
	$"7374 6564 2061 6E64 2077 6527 7665 2064"            /* sted and we've d */
	$"6F6E 6520 6F75 7220 6265 7374 2074 6F20"            /* one our best to  */
	$"656E 7375 7265 2069 7473 2063 6F72 7265"            /* ensure its corre */
	$"6374 6E65 7373 3B20 686F 7765 7665 722C"            /* ctness; however, */
	$"2045 6173 7946 6974 2072 6573 756C 7473"            /*  EasyFit results */
	$"2073 686F 756C 6420 6E6F 7420 6265 2074"            /*  should not be t */
	$"7275 7374 6564 2077 6865 6E20 616E 2065"            /* rusted when an e */
	$"7272 6F72 2063 6F75 6C64 2072 6573 756C"            /* rror could resul */
	$"7420 696E 2064 616D 6167 6520 746F 2074"            /* t in damage to t */
	$"6865 2068 6561 6C74 6820 6F66 2068 756D"            /* he health of hum */
	$"616E 2062 6569 6E67 732E 2049 6620 796F"            /* an beings. If yo */
	$"7520 646F 2074 7275 7374 2045 6173 7946"            /* u do trust EasyF */
	$"6974 2072 6573 756C 7473 2C20 796F 7520"            /* it results, you  */
	$"646F 2069 7420 656E 7469 7265 6C79 2061"            /* do it entirely a */
	$"7420 796F 7572 206F 776E 2072 6973 6B2E"            /* t your own risk. */
	$"0D0D 4966 2079 6F75 2068 6170 7065 6E20"            /* ��If you happen  */
	$"746F 2068 6176 6520 616E 7920 7072 6F62"            /* to have any prob */
	$"6C65 6D20 696E 2074 6865 2075 7365 206F"            /* lem in the use o */
	$"6620 4561 7379 4669 742C 206F 7220 6966"            /* f EasyFit, or if */
	$"2079 6F75 2066 696E 6420 6120 6275 672C"            /*  you find a bug, */
	$"206F 7220 796F 7520 7468 696E 6B20 796F"            /*  or you think yo */
	$"7520 6861 7665 2075 7365 6675 6C20 7375"            /* u have useful su */
	$"6767 6573 7469 6F6E 732C 2070 6C65 6173"            /* ggestions, pleas */
	$"6520 636F 6E74 6163 7420 7468 6520 6175"            /* e contact the au */
	$"7468 6F72 732E 2057 6520 6E65 6564 2079"            /* thors. We need y */
	$"6F75 7220 6865 6C70 2074 6F20 656E 7375"            /* our help to ensu */
	$"7265 2045 6173 7946 6974 2063 6F72 7265"            /* re EasyFit corre */
	$"6374 6E65 7373 2061 6E64 2075 7365 6675"            /* ctness and usefu */
	$"6C6E 6573 732E 2057 7269 7465 2074 6F3A"            /* lness. Write to: */
	$"0D0D 4D61 7572 697A 696F 2052 6F63 6368"            /* ��Maurizio Rocch */
	$"6574 7469 2C20 4D61 7474 656F 2056 6163"            /* etti, Matteo Vac */
	$"6361 7269 0D4D 6172 696F 204E 6567 7269"            /* cari�Mario Negri */
	$"2049 6E73 7469 7475 7465 2C0D 7669 6120"            /*  Institute,�via  */
	$"4572 6974 7265 6120 3632 2C0D 3230 3135"            /* Eritrea 62,�2015 */
	$"3720 4D69 6C61 6E6F 2C0D 4974 616C 792E"            /* 7 Milano,�Italy. */
	$"0D00 00"                                            /* �.. */
};

