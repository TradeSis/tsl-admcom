/****************************************************************************
****************************************************************************
** Program: fbrowse.i
** Created: 6/21/89
** Modifid: 3/14/90 wlb - added additional parameters
**
**Parameters: {&File}     = filename
**            {&CField}   = choose field to display
**            {&Where}    = logical condition for selecting records must be
**                          TRUE at least
**
**   The following parameters are optional
**
**            {&OField}   = other fields to display
**            {&AftFnd}   = code to execute after finding record (ie find
**                          associated record.
**            {&LockType} = type of lock used on records
**            {&NonCharacter} = set to slash-splat if the choose field is
**                           not a character field.
**            {&AftSelect} = code to execute after a record is selected
**            {&GOON}     = other keys to go-on
**            {&OtherKeys} = code to check if they have pressed one of the
**                          optional {&GOON} keys.
**
**            {&form}     = Custom FORM Statement
**
**      Pick Multi Records parameters
**            {&UsePick}  = *
**            {&PickFld}  = field name to store in pick list.  This can be
**                          any expression -- even a recid function.
**            {&PickFrm}  = format of &PickFld expression i.e. 9999 or x(10)
****************************************************************************
\****************************************************************************/

fbrowse-loop:
DO WITH {&FORM}:

  keys-loop:
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF i-seeid NE -1 THEN
    DO:
      {&AC}
      CHOOSE ROW {&CField} KEYS i-seekey GO-ON(F1 {&GOON}) NO-ERROR.
      COLOR DISPLAY NORMAL {&cfield}.
      PAUSE 0.
      ASSIGN i-seeid = i-seerec[FRAME-LINE].
      {&OtherKeys}
      {{&OtherKeys1}}
    END.

    /* find first record logic */
    IF i-seeid = -1
        {&NonCharacter}
       OR (LASTKEY GE 32 AND LASTKEY LE 127)
        /{&NonCharacter}**/
    THEN DO:
      if i-recid = -1
      then do:
        FIND FIRST {&File} WHERE
            {&NonCharacter}
            {&CField} BEGINS i-seekey AND
            /{&NonCharacter}**/
            {&Where} {&LockType} NO-ERROR.
      end.
      else do:
        if i-recid <> ?
        then do:
            find first {&File} where recid ({&File}) = i-recid .
            i-recid = -1.
            /* FIND NEXT {&file} WHERE {&where} {&locktype} NO-ERROR. */
        end.
      end.
      IF AVAILABLE {&File} THEN
      DO:
        {&AftFnd}
        {{&AftFnd1}}
        CLEAR ALL.
        ASSIGN
          i-seeid = -1
          i-seerec[1] = ?
          i-seerec[1] = RECID({&File}).

        DISPLAY {&CField} {&OField}
          /{&UsePick}*/
          IF CAN-DO(i-seelst,STRING({&PickFld},"{&PickFrm}"))
          THEN "*" ELSE "" @ i-seelst
          /{&UsePick}*/.
      END.
      {&NonCharacter}
      ELSE
      IF LENGTH(i-seekey) > 1 THEN
      DO:
        ASSIGN i-seekey = SUBSTRING(i-seekey,LENGTH(i-seekey)).
        NEXT.
      END.
      ELSE
      IF LENGTH(i-seekey) = 1 THEN
      DO:
        MESSAGE "Nenhum registro comeca com " KEYLABEL(LASTKEY).
        ASSIGN i-seekey = "".
        NEXT.
      END.
      /{&NonCharacter}**/
      ELSE
      DO:
        {{&notfound1}}.
        MESSAGE "Nenhum Registro Encontrado".
        {&NotFound}.
        LEAVE.
      END.
    END.

    IF LASTKEY LT 32 OR LASTKEY GT 127 THEN
    ASSIGN i-seekey = "".
    else if "{&Noncharacter}" = "/*"
         then ASSIGN i-seekey = "".

    /* loop so that the page-up can come back to the page-down if needed */
    IF CAN-DO("PAGE-UP,CURSOR-UP,PAGE-DOWN,CURSOR-DOWN",KEYFUNCTION(LASTKEY))
      OR i-seeid = -1 THEN
    pge-{&file}-loop:
    DO WHILE TRUE:
      /* cursor down */
      IF INDEX(KEYFUNCTION(LASTKEY),"DOWN") > 0 OR i-seeid = -1 THEN
      DO:
        IF i-seeid NE -1 THEN
        FIND first {&File}     
          WHERE RECID({&File}) = i-seerec[FRAME-DOWN] no-lock NO-ERROR.
        IF NOT AVAILABLE {&File} THEN
        NEXT keys-loop.
        IF i-seeid NE -1 THEN
        DO:
          UP FRAME-LINE - 1.
          DOWN FRAME-DOWN - 1.
        END.
        DO WHILE TRUE:
            
          FIND NEXT {&file} WHERE {&where}
            {&locktype} NO-ERROR.
          IF NOT AVAILABLE {&file} THEN
          LEAVE.
          else do:
          {&AftFnd}
          {{&AftFnd1}}
          /* was it a cursor-down */
          IF KEYFUNCTION(LASTKEY) = "Cursor-Down" OR
            /* or are we finishing off an incomplete page-up */
            (i-seerec[1] = ? AND i-seerec[FRAME-DOWN] NE ?) THEN
          DO:
            DO i-seeid = 1 TO FRAME-DOWN - 1:
              ASSIGN i-seerec[i-seeid] = i-seerec[i-seeid + 1].
            END.
            SCROLL UP.
          END.
          ELSE
          DO:
            IF FRAME-LINE = FRAME-DOWN THEN
            ASSIGN i-seerec = ?.
            DOWN.
          END.
          DISPLAY {&cfield} {&OField}
            /{&UsePick}*/
            IF CAN-DO(i-seelst,STRING({&PickFld},"{&PickFrm}"))
            THEN "*" ELSE "" @ i-seelst
            /{&UsePick}*/.
          ASSIGN i-seerec[FRAME-LINE] = RECID({&File}).
          IF FRAME-DOWN = FRAME-LINE AND i-seerec[1] NE ? THEN
          LEAVE.
          end.
        END.
        IF KEYFUNCTION(LASTKEY) NE "cursor-down" THEN
        UP FRAME-LINE - 1.
        ASSIGN i-seeid = 0.
        NEXT keys-loop.
      END.

      /* cursor up */
      ELSE
      DO:  
        FIND first {&File} WHERE recid({&file}) = i-seerec[1] no-lock
            NO-ERROR.
        IF NOT AVAILABLE {&File} THEN
        NEXT keys-loop.
        UP FRAME-LINE - 1.
        DO WHILE TRUE:
          FIND PREV {&file} WHERE {&where}
            {&locktype} NO-ERROR.
          IF NOT AVAILABLE {&file} THEN
          DO:
            /* if it is a curs-up or the initial find prev fails then we will */
            /* still be on line 1 and we can just leave. */
            IF FRAME-LINE = 1 THEN
            NEXT keys-loop.
            ASSIGN i-seeid = -1.
            PAUSE 0.
            NEXT pge-{&file}-loop.
          END.
          {&AftFnd}
          {{&AftFnd1}}
          IF KEYFUNCTION(LASTKEY) = "Cursor-up" THEN
          DO:
            DO i-seeid = FRAME-DOWN TO 2 BY -1:
              ASSIGN i-seerec[i-seeid] = i-seerec[i-seeid - 1].
            END.
            SCROLL DOWN.
          END.
          ELSE
          DO:
            IF FRAME-LINE = 1 THEN
            ASSIGN i-seerec = ?.
            UP.
          END.
          DISPLAY {&cfield} {&OField}
            /{&UsePick}*/
            IF CAN-DO(i-seelst,STRING({&PickFld},"{&PickFrm}"))
            THEN "*" ELSE "" @ i-seelst
            /{&UsePick}*/.
          ASSIGN i-seerec[FRAME-LINE] = RECID({&File}).
          IF FRAME-LINE = 1 THEN
          NEXT keys-loop.
        END.
      END.
      LEAVE.
    END.
    IF LOOKUP(KEYFUNCTION(LASTKEY),"RETURN,GO,INSERT") > 0
    THEN DO:
      IF i-seeid = ? THEN
      NEXT.
      FIND FIRST {&File} WHERE RECID({&File}) = i-seeid .
      {{&AftSelect}}
      {&AftSelect1}
      /{&UsePick}*/
      IF KEYFUNCTION(LASTKEY) = "RETURN" THEN
      DO:
        IF NOT CAN-DO(i-seelst,STRING({&PickFld},"{&PickFrm}")) THEN
        DO:
          DISPLAY "*" @ i-seelst.
          ASSIGN i-seelst = i-seelst + "," + STRING({&PickFld},"{&PickFrm}").
        END.
        ELSE
        IF CAN-DO(i-seelst,STRING({&PickFld},"{&PickFrm}")) THEN
        DO:
          DISPLAY " " @ i-seelst.
          ASSIGN
            SUBSTRING(i-seelst,
            INDEX(i-seelst,"," + STRING({&PickFld},"{&PickFrm}")),
            LENGTH(STRING({&PickFld},"{&PickFrm}")) + 1) = "".
        END.
        NEXT.
      END.
      /{&UsePick}*/
      LEAVE. 
    END. /* end of record pick */
  END.
  /* if they end errored the release the record so that it is not avail
  *  to the calling program.  The calling program would think it was selected
  */
  IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
  RELEASE {&File}.
  HIDE.
END.
  