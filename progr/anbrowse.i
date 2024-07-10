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

    IF an-seeid NE -1 THEN
    DO:
      {&AC}
      CHOOSE ROW {&CField} KEYS an-seekey GO-ON(F1 {&GOON}) 
      {&tempo} NO-ERROR.
      COLOR DISPLAY NORMAL {&cfield}.
      PAUSE 0.
      ASSIGN an-seeid = an-seerec[FRAME-LINE].
      {&OtherKeys}
      {{&OtherKeys1}}
    END.

    /* find first record logic */
    IF an-seeid = -1
        {&NonCharacter}
       OR (LASTKEY GE 32 AND LASTKEY LE 127)
        /{&NonCharacter}**/
    THEN DO:
      if an-recid = -1
      then do:
        FIND FIRST {&File} WHERE
            {&NonCharacter}
            {&CField} BEGINS an-seekey AND
            /{&NonCharacter}**/
            {&Where} {&LockType} NO-ERROR.
      end.
      else do:
        if an-recid <> ?
        then do:
            find first {&File} where recid ({&File}) = an-recid .
            an-recid = -1.
            /* FIND NEXT {&file} WHERE {&where} {&locktype} NO-ERROR. */
        end.
      end.
      IF AVAILABLE {&File} THEN
      DO:
        {&AftFnd}
        {{&AftFnd1}}
        CLEAR ALL.
        ASSIGN
          an-seeid = -1
          an-seerec[1] = ?
          an-seerec[1] = RECID({&File}).

        DISPLAY {&CField} {&OField}
          /{&UsePick}*/
          IF CAN-DO(an-seelst,STRING({&PickFld},"{&PickFrm}"))
          THEN "*" ELSE "" @ an-seelst
          /{&UsePick}*/.
      END.
      {&NonCharacter}
      ELSE
      IF LENGTH(an-seekey) > 1 THEN
      DO:
        ASSIGN an-seekey = SUBSTRING(an-seekey,LENGTH(an-seekey)).
        NEXT.
      END.
      ELSE
      IF LENGTH(an-seekey) = 1 THEN
      DO:
        MESSAGE "Nenhum registro comeca com " KEYLABEL(LASTKEY).
        ASSIGN an-seekey = "".
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
    ASSIGN an-seekey = "".
    else if "{&Noncharacter}" = "/*"
         then ASSIGN an-seekey = "".

    /* loop so that the page-up can come back to the page-down if needed */
    IF CAN-DO("PAGE-UP,CURSOR-UP,PAGE-DOWN,CURSOR-DOWN",KEYFUNCTION(LASTKEY))
      OR an-seeid = -1 THEN
    pge-{&file}-loop:
    DO WHILE TRUE:
      /* cursor down */
      IF INDEX(KEYFUNCTION(LASTKEY),"DOWN") > 0 OR an-seeid = -1 THEN
      DO:
        IF an-seeid NE -1 THEN
        FIND first {&File}     
          WHERE RECID({&File}) = an-seerec[FRAME-DOWN] no-lock NO-ERROR.
        IF NOT AVAILABLE {&File} THEN
        NEXT keys-loop.
        IF an-seeid NE -1 THEN
        DO:
          UP FRAME-LINE - 1.
          DOWN FRAME-DOWN - 1.
        END.
        DO WHILE TRUE:
            
          FIND NEXT {&file} WHERE {&where}
            {&locktype} NO-ERROR.
          IF NOT AVAILABLE {&file} THEN
          LEAVE.
          {&AftFnd}
          {{&AftFnd1}}
          /* was it a cursor-down */
          IF KEYFUNCTION(LASTKEY) = "Cursor-Down" OR
            /* or are we finishing off an incomplete page-up */
            (an-seerec[1] = ? AND an-seerec[FRAME-DOWN] NE ?) THEN
          DO:
            DO an-seeid = 1 TO FRAME-DOWN - 1:
              ASSIGN an-seerec[an-seeid] = an-seerec[an-seeid + 1].
            END.
            SCROLL UP.
          END.
          ELSE
          DO:
            IF FRAME-LINE = FRAME-DOWN THEN
            ASSIGN an-seerec = ?.
            DOWN.
          END.
          DISPLAY {&cfield} {&OField}
            /{&UsePick}*/
            IF CAN-DO(an-seelst,STRING({&PickFld},"{&PickFrm}"))
            THEN "*" ELSE "" @ an-seelst
            /{&UsePick}*/.
          ASSIGN an-seerec[FRAME-LINE] = RECID({&File}).
          IF FRAME-DOWN = FRAME-LINE AND an-seerec[1] NE ? THEN
          LEAVE.
        END.
        IF KEYFUNCTION(LASTKEY) NE "cursor-down" THEN
        UP FRAME-LINE - 1.
        ASSIGN an-seeid = 0.
        NEXT keys-loop.
      END.

      /* cursor up */
      ELSE
      DO:  
        FIND first {&File} WHERE recid({&file}) = an-seerec[1] no-lock
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
            ASSIGN an-seeid = -1.
            PAUSE 0.
            NEXT pge-{&file}-loop.
          END.
          {&AftFnd}
          {{&AftFnd1}}
          IF KEYFUNCTION(LASTKEY) = "Cursor-up" THEN
          DO:
            DO an-seeid = FRAME-DOWN TO 2 BY -1:
              ASSIGN an-seerec[an-seeid] = an-seerec[an-seeid - 1].
            END.
            SCROLL DOWN.
          END.
          ELSE
          DO:
            IF FRAME-LINE = 1 THEN
            ASSIGN an-seerec = ?.
            UP.
          END.
          DISPLAY {&cfield} {&OField}
            /{&UsePick}*/
            IF CAN-DO(an-seelst,STRING({&PickFld},"{&PickFrm}"))
            THEN "*" ELSE "" @ an-seelst
            /{&UsePick}*/.
          ASSIGN an-seerec[FRAME-LINE] = RECID({&File}).
          IF FRAME-LINE = 1 THEN
          NEXT keys-loop.
        END.
      END.
      LEAVE.
    END.
    IF LOOKUP(KEYFUNCTION(LASTKEY),"RETURN,GO,INSERT") > 0
    THEN DO:
      IF an-seeid = ? THEN
      NEXT.
      FIND FIRST {&File} WHERE RECID({&File}) = an-seeid .
      {{&AftSelect}}
      {&AftSelect1}
      /{&UsePick}*/
      IF KEYFUNCTION(LASTKEY) = "RETURN" THEN
      DO:
        IF NOT CAN-DO(an-seelst,STRING({&PickFld},"{&PickFrm}")) THEN
        DO:
          DISPLAY "*" @ an-seelst.
          ASSIGN an-seelst = an-seelst + "," + STRING({&PickFld},"{&PickFrm}").
        END.
        ELSE
        IF CAN-DO(an-seelst,STRING({&PickFld},"{&PickFrm}")) THEN
        DO:
          DISPLAY " " @ an-seelst.
          ASSIGN
            SUBSTRING(an-seelst,
            INDEX(an-seelst,"," + STRING({&PickFld},"{&PickFrm}")),
            LENGTH(STRING({&PickFld},"{&PickFrm}")) + 1) = "".
        END.
        NEXT.
      END.
      /{&UsePick}*/
      /*
      LEAVE.  /* this will leave if it is a go or we are not using pick */
      */
    END. /* end of record pick */
  END.
  /* if they end errored the release the record so that it is not avail
  *  to the calling program.  The calling program would think it was selected
  */
  IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
  RELEASE {&File}.
  /*HIDE.*/
END.
  