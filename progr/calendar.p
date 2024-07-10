/*-------------------------------------------------------------*/
/* calendar.p (v1.0) - a pop-up calendar program.     05/23/88 */
/*                                                             */
/* First presented at the Summer '88 PROGRESS Users Conference */
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Since we are never starting a transaction in this program,
   declare variables NO-UNDO to increase performance.          */

DEFINE VARIABLE hline AS CHARACTER NO-UNDO. /* horizontal line */

DEFINE VARIABLE mm    AS INTEGER   NO-UNDO. /* month */
DEFINE VARIABLE yy    AS INTEGER   NO-UNDO. /* year */
DEFINE VARIABLE x     AS INTEGER   NO-UNDO. /* max days in mth */
DEFINE VARIABLE i     AS INTEGER   NO-UNDO. /* scrap variable */
DEFINE VARIABLE dat   AS CHARACTER NO-UNDO. /* cal position */
DEFINE VARIABLE week  AS CHARACTER EXTENT 6 NO-UNDO.
DEFINE VARIABLE mgs   AS CHARACTER NO-UNDO. /* month string */
DEFINE VARIABLE this  AS CHARACTER NO-UNDO. /* current month */
DEFINE VARIABLE ml    AS CHARACTER NO-UNDO. /* month listing */

/* Set up month name string */
ml = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho,Julho,Agosto," +
     "Setembro,Outubro,Novembro,Dezembro".

/* Use horizontal bar character matching to local environment */
hline = "-".
IF OPSYS = "BTOS"  THEN hline = CHR(206).
IF OPSYS = "MSDOS" THEN hline = CHR(196).
IF OPSYS = "OS2"   THEN hline = CHR(196).

hline = hline + hline + " " + hline + hline + " "
      + hline + hline + " " + hline + hline + " "
      + hline + hline + " " + hline + hline + " "
      + hline + hline.

mm = MONTH(TODAY).
yy = YEAR(TODAY).
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Since we are using overlay frames, we specify PAUSE 0.  This
   tells PROGRESS that it does not have to pause before
   overlaying the frame on top of anything underneath, as it will
   by default.                                                 */
PAUSE 0.

/* Display the border frame: */
DISPLAY
  SPACE(8) "Calendario" SKIP(11)
  "Data:"
    ENTRY(MONTH(TODAY),ml) + " " +
      STRING(DAY(TODAY),IF DAY(TODAY) < 10 THEN "9" ELSE "99") +
      ", " +
      STRING(YEAR(TODAY),"9999") FORMAT "x(20)" SKIP
  WITH ROW 7 COLUMN 51 WIDTH 27 NO-BOX OVERLAY
    FRAME border COLOR MESSAGES.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Display the calendar frame inside and on top of the border
   frame.                                                      */

PAUSE 0. /* Suppress automatic PROGRESS pausing facility */
DISPLAY
  dat FORMAT "x(20)" SKIP

  "Do Se Te Qa Qi Se Sa" SKIP
  hline   FORMAT "x(20)" SKIP
  week[1] FORMAT "x(20)" SKIP
  week[2] FORMAT "x(20)" SKIP
  week[3] FORMAT "x(20)" SKIP
  week[4] FORMAT "x(20)" SKIP
  week[5] FORMAT "x(20)" SKIP
  week[6] FORMAT "x(20)" SKIP
  WITH ROW 8 COLUMN 53 NO-LABELS OVERLAY FRAME calendar.

/* Set the attribute of the "dat" field to reverse video. */
COLOR DISPLAY MESSAGES dat WITH FRAME calendar.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* Main keyboard read loop: */

DO WHILE TRUE:

  /* use maximum days in month to determine number of characters
     from string to display                                    */
  x = DAY( (DATE(mm,15,yy) + 20) - DAY(DATE(mm,15,yy) + 20) ).

  /* the above algorithm requires an explanation.  it returns
     the DAY of the last day of a month.  For example, it returns
     31 for January, 28 or 29 for February, etc.  Here is how
     this code works:

     1. get right in to the middle (15th) of the current month.
     2. add enough days (20) to get into the next month.
     3. count backwards the number of days into the next month
	you are.
     4. the result is the last day of the current month.       */

  /* use the day of the week of the first day of the month to set
     the starting offset into the string                       */
  i = WEEKDAY(DATE(mm,1,yy)).

  this = SUBSTR(
    "                   1  2  3  4  5  6  7  8  9 10 11 12 " +
    "13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 "
    ,22 - i * 3,x * 3 + i * 3 - 3).

  /* The whole purpose of creating the "this" variable is that if
     we display the months using a do-loop, performance suffers.
     Using substring manipulation, we can display the entire
     month in one statement, thus:                             */
  DISPLAY
    "   " + ENTRY(mm,ml) + ", " + STRING(yy,"9999") @ dat
    SUBSTR(this,  1,20) @ week[1]
    SUBSTR(this, 22,20) @ week[2]
    SUBSTR(this, 43,20) @ week[3]
    SUBSTR(this, 64,20) @ week[4]
    SUBSTR(this, 85,20) @ week[5]
    SUBSTR(this,106,20) @ week[6] WITH FRAME calendar.

  /* now, handle keyboard input */
  READKEY.

  IF KEYFUNCTION(LASTKEY) = "CURSOR-DOWN" AND yy > 1900 THEN
    yy = yy - 1.

  ELSE

  IF KEYFUNCTION(LASTKEY) = "CURSOR-UP" AND yy < 2099 THEN
    yy = yy + 1.

  ELSE

  IF KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN DO:
    mm = (IF mm = 1 THEN 12 ELSE mm - 1).
    IF mm = 12 AND yy > 1900 THEN yy = yy - 1.
  END.

  ELSE

  IF KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN DO:
    mm = (IF mm = 12 THEN 1 ELSE mm + 1).
    IF mm = 1 AND yy < 2099 THEN yy = yy + 1.
  END.

  ELSE

  IF KEYFUNCTION(LASTKEY) = "HOME" THEN DO:
    mm = MONTH(TODAY).
    yy = YEAR(TODAY).
  END.

  ELSE

  IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN LEAVE.

END.
/*-------------------------------------------------------------*/

/*-------------------------------------------------------------*/
/* By HIDEing overlay frames, PROGRESS will automatically
   redisplay any information that they covered when they were
   first displayed.                                            */

HIDE FRAME calendar NO-PAUSE.
HIDE FRAME border   NO-PAUSE.
RETURN.
/*-------------------------------------------------------------*/
