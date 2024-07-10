/*-------------------------------------------------------------*/
/* calculat.p (v1.0) - pop-up calculator program      05/23/88 */
/*                                                             */
/* First presented at the Summer '88 PROGRESS Users Conference */
/*-------------------------------------------------------------*/

DEFINE VARIABLE acc AS DECIMAL   NO-UNDO. /* accumulator */
DEFINE VARIABLE ds  AS CHARACTER NO-UNDO. /* actual display */
DEFINE VARIABLE dsp AS DECIMAL   NO-UNDO. /* display contents */
DEFINE VARIABLE fst AS LOGICAL   NO-UNDO. /* first iteration */
DEFINE VARIABLE kbd AS CHARACTER NO-UNDO. /* keyboard */
DEFINE VARIABLE op  AS CHARACTER NO-UNDO. /* current operator */
DEFINE VARIABLE pop AS CHARACTER NO-UNDO. /* previous operator */
DEFINE VARIABLE pnt AS CHARACTER NO-UNDO. /* . or , (if -E)    */

/* calculator keypad (non-functional, for display only) */
DEFINE VARIABLE kys AS CHARACTER EXTENT 20 NO-UNDO FORMAT "xxx"
  INITIAL [
  "   ","   ","   "," / ",   /*|          / |*/
  " 7 "," 8 "," 9 "," * ",   /*| 7  8  9  * |*/
  " 4 "," 5 "," 6 "," - ",   /*| 4  5  6  - |*/
  " 1 "," 2 "," 3 "," + ",   /*| 1  2  3  + |*/
  " C "," 0 "," . "," = " ]. /*| C  0  .  = |*/

FORM
  SPACE(5) "Calculadora"
  SKIP(10)
  WITH FRAME border
  ROW 4 COLUMN 58 WIDTH 22 NO-BOX OVERLAY COLOR MESSAGES.
FORM
  dsp FORMAT "->>>,>>>,>>9.99" SKIP(1)
  kys[ 1 FOR 4] SKIP
  kys[ 5 FOR 4] SKIP
  kys[ 9 FOR 4] SKIP
  kys[13 FOR 4] SKIP
  kys[17 FOR 4] SKIP
  WITH ROW 5 COLUMN 60 FRAME calc OVERLAY NO-LABELS.
COLOR DISPLAY MESSAGES kys[1 FOR 20] WITH FRAME calc.

PAUSE 0.
VIEW FRAME border.
PAUSE 0.
DISPLAY kys[1 FOR 20] WITH FRAME calc.
PAUSE 0.
/*
  Now, set the dsp variable to the current field contents.
  Place this in an on-error block in case the current field
  isn't numeric!  Next, hide any resulting error messages
  displayed if the field is non-numeric
*/
DO ON ERROR UNDO,LEAVE:
  dsp = DECIMAL(FRAME-VALUE).
END.
HIDE MESSAGE NO-PAUSE.

ASSIGN
  acc = 0
  kbd = ""
  op  = ""
  pop = ""
  pnt = SUBSTR(STRING(1.1) , 2 , 1).

_outer:
DO WHILE TRUE:

  /* perform operations */
  acc = (IF pop = "+" THEN acc + dsp
    ELSE IF pop = "-" THEN acc - dsp
    ELSE IF pop = "/" THEN acc / (IF dsp = 0 THEN 1 ELSE dsp)
    ELSE IF pop = "*" THEN acc * dsp
    ELSE dsp).

  /* Use ASSIGN to code multiple assignments - makes for
     smaller .r files */
  ASSIGN
    pop = op
    op  = ""
    dsp = acc
    fst = TRUE
    ds  = STRING(acc).
  _inner:
  DO WHILE TRUE:
    DISPLAY dsp WITH FRAME calc.

    READKEY.
    kbd = KEYFUNCTION(LASTKEY).

    /* This is the clear and clear-last-entry key */
    IF kbd = "C" THEN
      IF dsp = 0 THEN acc = 0.
		 ELSE ASSIGN dsp = 0 ds = STRING(dsp).

    /* an operator has been detected */
    IF INDEX("+-*/=",kbd) > 0 THEN DO:
      op = kbd.
      LEAVE _inner.
    END.

    /* use this to apply digits */
    IF INDEX("0123456789",kbd) > 0 THEN
      ds = (IF fst THEN "" ELSE ds) + kbd.

    /* this handles the decimal point */
    IF kbd = pnt AND INDEX(ds,pnt) = 0 THEN
      ds = (IF fst THEN "0" ELSE ds) + pnt.

    /* the backspace key is handled by removing the last
       character of the "ds" variable */
    IF KEYFUNCTION(LASTKEY) = "BACKSPACE"
      AND LENGTH(ds) > 0 THEN
      ds = IF fst THEN "" ELSE SUBSTR(ds,1,LENGTH(ds) - 1).

    dsp = DECIMAL(ds).

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"
      OR KEYFUNCTION(LASTKEY) = "GO" THEN LEAVE _outer.

    fst = FALSE.
  END.

END.

HIDE FRAME calc NO-PAUSE.
HIDE FRAME border NO-PAUSE.

/* if the user hit GO instead of END-ERROR, insert the value */
IF KEYFUNCTION(LASTKEY) = "GO" THEN FRAME-VALUE = dsp.
RETURN.
