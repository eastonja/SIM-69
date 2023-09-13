* ******************************************************
* ******************************************************
* **                                                  **
* **               OLED AND RTC I2C DEMO              **
* **                                                  **
* **                  v 1.00                          **
* **               WRITTEN 09/12/2023                 **
* **                BY JEFF EASTON                    **
* **                                                  **
* ******************************************************
* ******************************************************

* DEMO CODE.  READS THE I2C REAL TIME CLOCK EVERY SECOND.  DISPLAYS TIME ON I2C OLED DISPLAY.  
* BLINKS THE COLON BETWEEN THE HOURS AND MINUTES EVERY HALF SECOND

OLEADDR 	EQU		$78			* SSD1306 ON 2.4" 128X64 DOT MATRIX OLED DISPLAY (0111 100X).  ALTERNATE IS $7A IF DC PIN IS HIGH
P8584		EQU		$AF80		* BASE ADDRESS OF I2C CHIP
P8584SX		EQU		P8584+0		* S0/S3
P8584S1		EQU		P8584+1		* S1

* EQUATES BASED ON SMARTBUG V1.27A ASSEMBLED 09/12/2023
* IF RUNNING THIS CODE ON NEWER SB VERSIONS, THE BELOW ADDRESSES WILL NEED TO BE ADJUSTED.

I2CDADD		EQU		$033D		* I2C ADDRESS HI/LO
I2CBUFF		EQU		$033F		* I2C BUFFER
I2CWRIT		EQU		$EA64		* I2C START WRITE
I2CTXONE	EQU		$EAE5		* I2C TX ONE BYTE
I2CTX 		EQU		$EAC2		* I2C SEND COMMAND BYTES
I2CSTOP		EQU		$EA88		* I2C STOP TRANSMISSION
RTCGET		EQU		$EAF7		* GET RTC DATA INTO I2CBUFF
OLEDINIT	EQU		$ED23		* iNITIALIZE OLED PANEL
OLEDHOM		EQU		$ED4D		* OLED HOME CURSOR
OLEDCLS		EQU		$ED79		* OLED CLEAR SCREEN HOME CURSOR
WORD1		EQU		$0339		* GEN TEMP FOR WORD
WORD2		EQU		$033B		* GEN TEMP FOR WORD
DELAY		EQU		$EE65		* DELAY Y= INPUT 10uS/LOOP
CONVHL		EQU		$E076		* CONVERT LEFT HEX DIGIT TO ASCII
CONVHR		EQU		$E07A		* CONVERT RIGHT HEX DIGIT TO ASCII


			ORG		$7000
START		JSR		OLEDINIT	* INIT OLED PANEL
			JSR		OLEDCLS		* CLEAR ENTIRE PANEL
			LDX		#OLEDHEAD	* GET HEADER STRING ADDR
			JSR		OLEDSOUT	* PRINT IT ON THE OLED	(4 ROWS)
TIMELP		JSR		OLEDHOMR5	* RESET PANEL TO 5TH ROW ONLY
			LDX		#OLED5BC	* GET 5 BLANK CHARACTERS
			JSR		OLEDSOUT	* PRINT IT ON THE OLED
			JSR		RTCGET		* GET TIME FROM I2C RTC
			LDA		I2CBUFF+2	* GET HOURS
			ANDA	#%00111111	* MASK TO 2 DIGIT HOURS (24hr mode)
			JSR		CONVHL		* CONVERT HI NIBBLE TO ASCII
			STA		WORD1		* SAVE ASCII 10'S HOUR	
			LDA		I2CBUFF+2	* GET HOURS
			ANDA	#%00111111	* MASK TO 2 DIGIT HOURS
			JSR		CONVHR		* CONVERT LO NIBBLE TO ASCII
			STA		WORD1+1		* SAVE ASCII 1'S HOUR
			LDA		I2CBUFF+1	* GET MINUTES
			ANDA	#%01111111	* MASK TO 7 BITS
			JSR		CONVHL		* CONVERT HI NIBBLE TO ASCII			
			STA		WORD2		* SAVE ASCII 10'S MINUTES
			LDA		I2CBUFF+1	* GET MINUTES
			ANDA	#%01111111	* MASK TO 7 BITS
			JSR		CONVHR		* CONVERT LO NIBBLE TO ASCII		
			STA		WORD2+1		* SAVE ASCII 1'S MINUTES
			LDA		WORD1		* GET 10'S HOUR
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD1+1		* GET 1'S HOUR
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		#$3A		* PRINT COLON
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD2		* GET 10'S MINUTES
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD2+1		* GET 1'S MINUTES
			JSR		OLEDSENDCHR	* SEND TO OLED	
			LDX		#$C350		* DELAY 1/2 SEC
			JSR     DELAY
			JSR		OLEDHOMR5	* RESET PANEL TO 5TH ROW ONLY
			LDX		#OLED5BC	* GET 5 BLANK CHARACTERS
			JSR		OLEDSOUT	* PRINT IT ON THE OLED		
			LDA		WORD1		* GET 10'S HOUR
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD1+1		* GET 1'S HOUR
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		#$20		* PRINT SPACE
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD2		* GET 10'S MINUTES
			JSR		OLEDSENDCHR	* SEND TO OLED
			LDA		WORD2+1		* GET 1'S MINUTES
			JSR		OLEDSENDCHR	* SEND TO OLED	
			LDX		#$C350		* DELAY 1/2 SEC
			JSR     DELAY
			LBRA	TIMELP		* RESET 5TH LINE, REPEAT TIME
			
			

*
* OLED 128X64 DISPLAY, SET DISPLAY RAM START LINE TO 5 ONLY ONE ROW
*
OLEDHOMR5	LDA     #OLEADDR	* START WRITE WITH OLED ADDRESS
			JSR     I2CWRIT 
			LDA		#$00		* SET CONTROL BYTE (Co=0, D/C=0)
			JSR 	I2CTXONE
			LDA		#$21		* SET COLUMN ADDRESS (TRIPLE BYTE CONFIG)
			JSR 	I2CTXONE
			LDA		#$00		* COLUMN ADDRESS START AT 0
			JSR 	I2CTXONE
			LDA		#$7F		* COLUMN ADDRESS END AT 127
			JSR 	I2CTXONE
			LDA		#$22		* SET PAGE ADDRESS (TRIPLE BYTE CONFIG)
			JSR 	I2CTXONE
			LDA		#$04		* PAGE ADDRESS START AT 5th ROW
			JSR 	I2CTXONE
			LDA		#$04		* PAGE ADDRESS END AT 5th ROW
			JSR 	I2CTXONE
			JSR     I2CSTOP     * STOP TRANSMISSION 
			RTS		


		
*
* TEST WRITE OLED
*
POLEDTEST	LDX		#OLEDTST		* GET STRING ADDR
			JSR		OLEDSOUT		* PRINT IT ON THE OLED
			RTS
POLEDHEAD	LDX		#OLEDHEAD		* GET STRING ADDR
			JSR		OLEDSOUT		* PRINT IT ON THE OLED
			RTS
OLEDTST		FCC		'Hello World OLED'
			FCB		$04
OLEDHEAD	FCC 	'     SIM-69     '
			FCC		' By Jeff Easton '
			FCC		'                '
			FCC		' Current Time:  '
			FCB		$04
OLED5BC		FCC		'     '
			FCB 	$04
OLED6BC		FCC		'      '
			FCB 	$04
*
* PRINT ASCII STRING TO THE OLED
*
* X= ADDRESS OF ASCII STRING.  MUST END WITH $04 AND BE LESS THAN 16 CHARACTERS LONG
*  USES A
*
OLEDSOUT	LDA		,X+				* PICK UP A CHARACTER AND INC X 
			CMPA	#$04			* IS IT THE EOF MARKER?
			BEQ		OLEDSOUE		* YES SO EXIT
			JSR		OLEDSENDCHR		* SEND CHAR TO OLED
			BRA		OLEDSOUT		* LOOP FOR MORE
OLEDSOUE	RTS						* STOP TRANSMISSION	


*
* SEND ONE ASCII CHAR TO OLED
*  A = ASCII CHAR
*  USES B, PRESERVES X
*
OLEDSENDCHR	PSHS	X
			PSHS	A	
			LDA     #OLEADDR	* START WRITE WITH OLED ADDRESS
			JSR     I2CWRIT 
			LDA		#$40		* SET CONTROL BYTE (Co=0, D/C=1)
			JSR 	I2CTXONE
			LDA		#$00		* PAD FIRST COLUMN AS BLANK (5X7 CHAR IN 8X8 BLOCK)
			JSR 	I2CTXONE
			PULS	B
			SUBB	#$20		* SUBTRACT $20 FOR FIRST 20 BUTES MISSING IN TABLES
			CLRA
			TFR		D,X			* GET ASCII IN X, msb $00
			LDA		FONTC1,X	* GET FIRST COLUMN FONT PIXELS
			JSR		I2CTXONE
			LDA		FONTC2,X	* GET SECOND COLUMN FONT PIXELS
			JSR		I2CTXONE
			LDA		FONTC3,X	* GET THIRD COLUMN FONT PIXELS
			JSR		I2CTXONE
			LDA		FONTC4,X	* GET FOURTH COLUMN FONT PIXELS
			JSR		I2CTXONE
			LDA		FONTC5,X	* GET FIFTH COLUMN FONT PIXELS
			JSR		I2CTXONE
			LDA		#$00		* PAD SEVENTH COLUMN AS BLANK (5X7 CHAR IN 8X8 BLOCK)
			JSR 	I2CTXONE
			LDA		#$00		* PAD EIGHTH COLUMN AS BLANK (5X7 CHAR IN 8X8 BLOCK)
			JSR 	I2CTXONE
			JSR     I2CSTOP     * STOP TRANSMISSION 
			PULS	X
			RTS
			
*
*  CHARACHTERMAP IN 5 COLUMNS
*
* FONT BITMAP COLUMN1
FONTC1		FCB 	$00			*	20 	32
			FCB $00	*	21 	33 	!
			FCB $00	*	22 	34 
			FCB $14	*	23 	35 	#
			FCB $24	*	24 	36 	$
			FCB $23	*	25 	37 	%
			FCB $36	*	26 	38 	&
			FCB $00	*	27 	39 	'
			FCB $00	*	28 	40 	(
			FCB $00	*	29 	41 	)
			FCB $14	*	2A 	42 	*
			FCB $08	*	2B 	43 	+
			FCB $00	*	2C 	44 
			FCB $08	*	2D 	45 	-
			FCB $00	*	2E 	46 	.
			FCB $20	*	2F 	47 	/
			FCB $3E	*	30 	48 	0
			FCB $00	*	31 	49 	1
			FCB $42	*	32 	50 	2
			FCB $21	*	33 	51 	3
			FCB $18	*	34 	52 	4
			FCB $27	*	35 	53 	5
			FCB $3C	*	36 	54 	6
			FCB $03	*	37 	55 	7
			FCB $36	*	38 	56 	8
			FCB $06	*	39 	57 	9
			FCB $00	*	3A 	58 	:
			FCB $00	*	3B 	59 	;
			FCB $08	*	3C 	60 	<
			FCB $14	*	3D 	61 	=
			FCB $00	*	3E 	62 	>
			FCB $02	*	3F 	63 	?
			FCB $32	*	40 	64 	@
			FCB $7E	*	41 	65 	A
			FCB $7F	*	42 	66 	B
			FCB $3E	*	43 	67 	C
			FCB $7F	*	44 	68 	D
			FCB $7F	*	45 	69 	E
			FCB $7F	*	46 	70 	F
			FCB $3E	*	47 	71 	G
			FCB $7F	*	48 	72 	H
			FCB $00	*	49 	73 	I
			FCB $20	*	4A 	74 	J
			FCB $7F	*	4B 	75 	K
			FCB $7F	*	4C 	76 	L
			FCB $7F	*	4D 	77 	M
			FCB $7F	*	4E 	78 	N
			FCB $3E	*	4F 	79 	O
			FCB $7F	*	50 	80 	P
			FCB $3E	*	51 	81 	Q
			FCB $7F	*	52 	82 	R
			FCB $46	*	53 	83 	S
			FCB $01	*	54 	84 	T
			FCB $3F	*	55 	85 	U
			FCB $1F	*	56 	86 	V
			FCB $3F	*	57 	87 	W
			FCB $63	*	58 	88 	X
			FCB $07	*	59 	89 	Y
			FCB $61	*	5A 	90 	Z
			FCB $7F	*	5B 	91 	[
			FCB $15	*	5C 	92 	'\'
			FCB $00	*	5D 	93 	]
			FCB $04	*	5E 	94 	^
			FCB $40	*	5F 	95 	_
			FCB $00	*	60 	96 	`
			FCB $20	*	61 	97 		a
			FCB $7F	*	62 	98 		b
			FCB $38	*	63 	99 		c
			FCB $38	*	64	100 	d
			FCB $38	*	65	101 	e
			FCB $08	*	66	102 	f
			FCB $0C	*	67	103 	g
			FCB $7F	*	68	104 	h
			FCB $00	*	69	105 	i
			FCB $20	*	6A	106 	j
			FCB $7F	*	6B	107 	k
			FCB $00	*	6C	108 	l
			FCB $7C	*	6D	109 	m
			FCB $7C	*	6E	110 	n
			FCB $38	*	6F	111 	o
			FCB $7C	*	70	112 	p
			FCB $08	*	71	113 	q
			FCB $7C	*	72	114 	r
			FCB $48	*	73	115 	s
			FCB $04	*	74	116 	t
			FCB $3C	*	75	117 	u
			FCB $1C	*	76	118 	v
			FCB $3C	*	77	119 	w
			FCB $44	*	78	120 	x
			FCB $0C	*	79	121 	y
			FCB $44	*	7A	122 	z
			FCB $00	*	7B	123 	{
			FCB $00	*	7C	124 	|
			FCB $00	*	7D	125 	}
			FCB $08	*	7E	126 	~
			FCB $08	*   7F	127

* FONT BITMAP COLUMN2
FONTC2		FCB 	$00			*	20 	32
			FCB $00	*	21 	33 	!
			FCB $07	*	22 	34 
			FCB $7F	*	23 	35 	#
			FCB $2A	*	24 	36 	$
			FCB $13	*	25 	37 	%
			FCB $49	*	26 	38 	&
			FCB $05	*	27 	39 	'
			FCB $1C	*	28 	40 	(
			FCB $41	*	29 	41 	)
			FCB $08	*	2A 	42 	*
			FCB $08	*	2B 	43 	+
			FCB $50	*	2C 	44 
			FCB $08	*	2D 	45 	-
			FCB $60	*	2E 	46 	.
			FCB $10	*	2F 	47 	/
			FCB $51	*	30 	48 	0
			FCB $42	*	31 	49 	1
			FCB $61	*	32 	50 	2
			FCB $41	*	33 	51 	3
			FCB $14	*	34 	52 	4
			FCB $45	*	35 	53 	5
			FCB $4A	*	36 	54 	6
			FCB $01	*	37 	55 	7
			FCB $49	*	38 	56 	8
			FCB $49	*	39 	57 	9
			FCB $36	*	3A 	58 	:
			FCB $56	*	3B 	59 	;
			FCB $14	*	3C 	60 	<
			FCB $14	*	3D 	61 	=
			FCB $41	*	3E 	62 	>
			FCB $01	*	3F 	63 	?
			FCB $49	*	40 	64 	@
			FCB $11	*	41 	65 	A
			FCB $49	*	42 	66 	B
			FCB $41	*	43 	67 	C
			FCB $41	*	44 	68 	D
			FCB $49	*	45 	69 	E
			FCB $09	*	46 	70 	F
			FCB $41	*	47 	71 	G
			FCB $08	*	48 	72 	H
			FCB $41	*	49 	73 	I
			FCB $40	*	4A 	74 	J
			FCB $08	*	4B 	75 	K
			FCB $40	*	4C 	76 	L
			FCB $02	*	4D 	77 	M
			FCB $04	*	4E 	78 	N
			FCB $41	*	4F 	79 	O
			FCB $09	*	50 	80 	P
			FCB $41	*	51 	81 	Q
			FCB $09	*	52 	82 	R
			FCB $49	*	53 	83 	S
			FCB $01	*	54 	84 	T
			FCB $40	*	55 	85 	U
			FCB $20	*	56 	86 	V
			FCB $40	*	57 	87 	W
			FCB $14	*	58 	88 	X
			FCB $08	*	59 	89 	Y
			FCB $51	*	5A 	90 	Z
			FCB $41	*	5B 	91 	[
			FCB $16	*	5C 	92 	'\'
			FCB $41	*	5D 	93 	]
			FCB $02	*	5E 	94 	^
			FCB $40	*	5F 	95 	_
			FCB $01	*	60 	96 	`
			FCB $54	*	61 	97 		a
			FCB $48	*	62 	98 		b
			FCB $44	*	63 	99 		c
			FCB $44	*	64	100 	d
			FCB $54	*	65	101 	e
			FCB $7E	*	66	102 	f
			FCB $52	*	67	103 	g
			FCB $08	*	68	104 	h
			FCB $44	*	69	105 	i
			FCB $40	*	6A	106 	j
			FCB $10	*	6B	107 	k
			FCB $41	*	6C	108 	l
			FCB $04	*	6D	109 	m
			FCB $08	*	6E	110 	n
			FCB $44	*	6F	111 	o
			FCB $14	*	70	112 	p
			FCB $14	*	71	113 	q
			FCB $08	*	72	114 	r
			FCB $54	*	73	115 	s
			FCB $3F	*	74	116 	t
			FCB $40	*	75	117 	u
			FCB $20	*	76	118 	v
			FCB $40	*	77	119 	w
			FCB $28	*	78	120 	x
			FCB $50	*	79	121 	y
			FCB $64	*	7A	122 	z
			FCB $08	*	7B	123 	{
			FCB $00	*	7C	124 	|
			FCB $41	*	7D	125 	}
			FCB $08	*	7E	126 	~
			FCB $1C	*   7F	127

* FONT BITMAP COLUMN3
FONTC3		FCB 	$00		*	20 	32
			FCB $4F	*	21 	33 	!
			FCB $00	*	22 	34 
			FCB $14	*	23 	35 	#
			FCB $7F	*	24 	36 	$
			FCB $08	*	25 	37 	%
			FCB $55	*	26 	38 	&
			FCB $03	*	27 	39 	'
			FCB $22	*	28 	40 	(
			FCB $22	*	29 	41 	)
			FCB $3E	*	2A 	42 	*
			FCB $3E	*	2B 	43 	+
			FCB $30	*	2C 	44 
			FCB $08	*	2D 	45 	-
			FCB $60	*	2E 	46 	.
			FCB $08	*	2F 	47 	/	
			FCB $49	*	30 	48 	0
			FCB $7F	*	31 	49 	1
			FCB $51	*	32 	50 	2
			FCB $45	*	33 	51 	3
			FCB $12	*	34 	52 	4
			FCB $45	*	35 	53 	5
			FCB $49	*	36 	54 	6
			FCB $71	*	37 	55 	7
			FCB $49	*	38 	56 	8
			FCB $49	*	39 	57 	9
			FCB $36	*	3A 	58 	:
			FCB $36	*	3B 	59 	;
			FCB $22	*	3C 	60 	<
			FCB $14	*	3D 	61 	=
			FCB $22	*	3E 	62 	>
			FCB $51	*	3F 	63 	?
			FCB $79	*	40 	64 	@
			FCB $11	*	41 	65 	A
			FCB $49	*	42 	66 	B
			FCB $41	*	43 	67 	C
			FCB $41	*	44 	68 	D
			FCB $49	*	45 	69 	E
			FCB $09	*	46 	70 	F
			FCB $49	*	47 	71 	G
			FCB $08	*	48 	72 	H
			FCB $7F	*	49 	73 	I
			FCB $41	*	4A 	74 	J
			FCB $14	*	4B 	75 	K
			FCB $40	*	4C 	76 	L
			FCB $0C	*	4D 	77 	M
			FCB $08	*	4E 	78 	N
			FCB $41	*	4F 	79 	O
			FCB $09	*	50 	80 	P
			FCB $51	*	51 	81 	Q
			FCB $19	*	52 	82 	R
			FCB $49	*	53 	83 	S
			FCB $7F	*	54 	84 	T
			FCB $40	*	55 	85 	U
			FCB $40	*	56 	86 	V
			FCB $38	*	57 	87 	W
			FCB $08	*	58 	88 	X
			FCB $70	*	59 	89 	Y
			FCB $49	*	5A 	90 	Z
			FCB $41	*	5B 	91 	[
			FCB $7C	*	5C 	92 	'\'
			FCB $41	*	5D 	93 	]
			FCB $01	*	5E 	94 	^
			FCB $40	*	5F 	95 	_
			FCB $02	*	60 	96 	`
			FCB $54	*	61 	97 		a
			FCB $44	*	62 	98 		b
			FCB $44	*	63 	99 		c
			FCB $44	*	64	100 	d
			FCB $54	*	65	101 	e
			FCB $09	*	66	102 	f
			FCB $52	*	67	103 	g
			FCB $04	*	68	104 	h
			FCB $7D	*	69	105 	i
			FCB $44	*	6A	106 	j
			FCB $28	*	6B	107 	k
			FCB $7F	*	6C	108 	l
			FCB $18	*	6D	109 	m
			FCB $04	*	6E	110 	n
			FCB $44	*	6F	111 	o
			FCB $14	*	70	112 	p
			FCB $14	*	71	113 	q
			FCB $04	*	72	114 	r
			FCB $54	*	73	115 	s
			FCB $44	*	74	116 	t
			FCB $40	*	75	117 	u
			FCB $40	*	76	118 	v
			FCB $38	*	77	119 	w
			FCB $10	*	78	120 	x
			FCB $50	*	79	121 	y
			FCB $54	*	7A	122 	z
			FCB $36	*	7B	123 	{
			FCB $7F	*	7C	124 	|
			FCB $36	*	7D	125 	}
			FCB $2A	*	7E	126 	~
			FCB $2A	*   7F	127

* FONT BITMAP COLUMN4
FONTC4	FCB 	$00		*	20 	32
			FCB $00	*	21 	33 	!
			FCB $07	*	22 	34 
			FCB $7F	*	23 	35 	#
			FCB $2A	*	24 	36 	$
			FCB $64	*	25 	37 	%
			FCB $22	*	26 	38 	&
			FCB $00	*	27 	39 	'
			FCB $41	*	28 	40 	(
			FCB $1C	*	29 	41 	)
			FCB $08	*	2A 	42 	*
			FCB $08	*	2B 	43 	+
			FCB $00	*	2C 	44 
			FCB $08	*	2D 	45 	-
			FCB $00	*	2E 	46 	.
			FCB $04	*	2F 	47 	/
			FCB $45	*	30 	48 	0
			FCB $40	*	31 	49 	1
			FCB $49	*	32 	50 	2
			FCB $4B	*	33 	51 	3
			FCB $7F	*	34 	52 	4
			FCB $45	*	35 	53 	5
			FCB $49	*	36 	54 	6
			FCB $09	*	37 	55 	7
			FCB $49	*	38 	56 	8
			FCB $29	*	39 	57 	9
			FCB $00	*	3A 	58 	:
			FCB $00	*	3B 	59 	;
			FCB $41	*	3C 	60 	<
			FCB $14	*	3D 	61 	=
			FCB $14	*	3E 	62 	>
			FCB $09	*	3F 	63 	?
			FCB $41	*	40 	64 	@
			FCB $11	*	41 	65 	A
			FCB $49	*	42 	66 	B
			FCB $41	*	43 	67 	C
			FCB $22	*	44 	68 	D
			FCB $49	*	45 	69 	E
			FCB $09	*	46 	70 	F
			FCB $49	*	47 	71 	G
			FCB $08	*	48 	72 	H
			FCB $41	*	49 	73 	I
			FCB $3F	*	4A 	74 	J
			FCB $22	*	4B 	75 	K
			FCB $40	*	4C 	76 	L
			FCB $02	*	4D 	77 	M
			FCB $10	*	4E 	78 	N
			FCB $41	*	4F 	79 	O
			FCB $09	*	50 	80 	P
			FCB $21	*	51 	81 	Q
			FCB $29	*	52 	82 	R
			FCB $49	*	53 	83 	S
			FCB $01	*	54 	84 	T
			FCB $40	*	55 	85 	U
			FCB $20	*	56 	86 	V
			FCB $40	*	57 	87 	W
			FCB $14	*	58 	88 	X
			FCB $08	*	59 	89 	Y
			FCB $45	*	5A 	90 	Z
			FCB $00	*	5B 	91 	[
			FCB $16	*	5C 	92 	'\'
			FCB $7F	*	5D 	93 	]
			FCB $02	*	5E 	94 	^
			FCB $40	*	5F 	95 	_
			FCB $04	*	60 	96 	`
			FCB $54	*	61 	97 		a
			FCB $44	*	62 	98 		b
			FCB $44	*	63 	99 		c
			FCB $48	*	64	100 	d
			FCB $54	*	65	101 	e
			FCB $01	*	66	102 	f
			FCB $52	*	67	103 	g
			FCB $04	*	68	104 	h
			FCB $40	*	69	105 	i
			FCB $3D	*	6A	106 	j
			FCB $44	*	6B	107 	k
			FCB $40	*	6C	108 	l
			FCB $04	*	6D	109 	m
			FCB $04	*	6E	110 	n
			FCB $44	*	6F	111 	o
			FCB $14	*	70	112 	p
			FCB $18	*	71	113 	q
			FCB $04	*	72	114 	r
			FCB $54	*	73	115 	s
			FCB $40	*	74	116 	t
			FCB $20	*	75	117 	u
			FCB $20	*	76	118 	v
			FCB $40	*	77	119 	w
			FCB $28	*	78	120 	x
			FCB $50	*	79	121 	y
			FCB $4C	*	7A	122 	z
			FCB $41	*	7B	123 	{
			FCB $00	*	7C	124 	|
			FCB $08	*	7D	125 	}
			FCB $1C	*	7E	126 	~
			FCB $08	*   7F	127

* FONT BITMAP COLUMN5
FONTC5	FCB 	$00		*	20 	32
			FCB $00	*	21 	33 	!
			FCB $00	*	22 	34 
			FCB $14	*	23 	35 	#
			FCB $12	*	24 	36 	$
			FCB $62	*	25 	37 	%
			FCB $50	*	26 	38 	&
			FCB $00	*	27 	39 	'
			FCB $00	*	28 	40 	(
			FCB $00	*	29 	41 	)
			FCB $14	*	2A 	42 	*
			FCB $08	*	2B 	43 	+
			FCB $00	*	2C 	44 
			FCB $08	*	2D 	45 	-
			FCB $00	*	2E 	46 	.
			FCB $02	*	2F 	47 	/
			FCB $3E	*	30 	48 	0
			FCB $00	*	31 	49 	1
			FCB $46	*	32 	50 	2
			FCB $31	*	33 	51 	3
			FCB $10	*	34 	52 	4
			FCB $39	*	35 	53 	5
			FCB $30	*	36 	54 	6
			FCB $07	*	37 	55 	7
			FCB $36	*	38 	56 	8
			FCB $1E	*	39 	57 	9
			FCB $00	*	3A 	58 	:
			FCB $00	*	3B 	59 	;
			FCB $00	*	3C 	60 	<
			FCB $14	*	3D 	61 	=
			FCB $08	*	3E 	62 	>
			FCB $06	*	3F 	63 	?
			FCB $3E	*	40 	64 	@
			FCB $7E	*	41 	65 	A
			FCB $36	*	42 	66 	B
			FCB $22	*	43 	67 	C
			FCB $1C	*	44 	68 	D
			FCB $41	*	45 	69 	E
			FCB $01	*	46 	70 	F
			FCB $7A	*	47 	71 	G
			FCB $7F	*	48 	72 	H
			FCB $00	*	49 	73 	I
			FCB $01	*	4A 	74 	J
			FCB $41	*	4B 	75 	K
			FCB $40	*	4C 	76 	L
			FCB $7F	*	4D 	77 	M
			FCB $7F	*	4E 	78 	N
			FCB $3E	*	4F 	79 	O
			FCB $06	*	50 	80 	P
			FCB $5E	*	51 	81 	Q
			FCB $46	*	52 	82 	R
			FCB $31	*	53 	83 	S
			FCB $01	*	54 	84 	T
			FCB $3F	*	55 	85 	U
			FCB $1F	*	56 	86 	V
			FCB $3F	*	57 	87 	W
			FCB $63	*	58 	88 	X
			FCB $07	*	59 	89 	Y
			FCB $43	*	5A 	90 	Z
			FCB $00	*	5B 	91 	[
			FCB $15	*	5C 	92 	'\'
			FCB $00	*	5D 	93 	]
			FCB $04	*	5E 	94 	^
			FCB $40	*	5F 	95 	_
			FCB $00	*	60 	96 	`
			FCB $78	*	61 	97 		a
			FCB $38	*	62 	98 		b
			FCB $20	*	63 	99 		c
			FCB $7F	*	64	100 	d
			FCB $18	*	65	101 	e
			FCB $02	*	66	102 	f
			FCB $3E	*	67	103 	g
			FCB $78	*	68	104 	h
			FCB $00	*	69	105 	i
			FCB $00	*	6A	106 	j
			FCB $00	*	6B	107 	k
			FCB $00	*	6C	108 	l
			FCB $78	*	6D	109 	m
			FCB $78	*	6E	110 	n
			FCB $38	*	6F	111 	o
			FCB $08	*	70	112 	p
			FCB $7C	*	71	113 	q
			FCB $08	*	72	114 	r
			FCB $20	*	73	115 	s
			FCB $20	*	74	116 	t
			FCB $7C	*	75	117 	u
			FCB $1C	*	76	118 	v
			FCB $3C	*	77	119 	w
			FCB $44	*	78	120 	x
			FCB $3C	*	79	121 	y
			FCB $44	*	7A	122 	z
			FCB $00	*	7B	123 	{
			FCB $00	*	7C	124 	|
			FCB $00	*	7D	125 	}
			FCB $08	*	7E	126 	~
			FCB $08	*   7F	127