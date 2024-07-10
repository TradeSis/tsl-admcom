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
**            {&chooseeys} = code to check if they have pressed one of the
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
form /{&usepick}*/
     a-seelst format "x" no-labels
     /{&usepick}*/
     with {&form}.

DO WITH {&FORM}:

    keys-loop:
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF a-seeid NE -1
        THEN DO:
            CHOOSE row   {&CField} help "{&help}"
                {&AutoReturn}
                KEYS a-seekey
     GO-ON({&go-on} F1 PF1 F4 PF4 F5 PF5 F7 PF7 TAB F8 PF8 F9 PF9 F10 PF10 )
                NO-ERROR .

            color display {&Color}/{&Color1} {&cfield}.

            PAUSE 0.
            ASSIGN a-seeid = a-seerec[FRAME-LINE].
             
            IF /*keyfunction(lastkey) = "TAB" or*/
                keyfunction(lastkey) = "END-ERROR"
            THEN
                LEAVE.
            
            IF keyfunction(lastkey) = "NEW-LINE" or
               keyfunction(lastkey) = "insert-mode"
            THEN DO:
                {{&AbreLinha}}
                {&abrelinha1}
            end.

            IF keyfunction(lastkey) = "GET" or
               keyfunction(lastkey) = "recall" or 
               keyfunction(lastkey) = "CLEAR"
            THEN DO:
                {&procura1}
                {{&Procura}}
                if available {&file}
                then
                    assign
                        a-recid = recid({&file})
                        a-seeid = -1.
            END.
            /*IF keyfunction(lastkey) <> "PAGE-UP" and
               keyfunction(lastkey) <> "PAGE-DOWN"
            THEN*/ DO:
                {{&otherkeys}}
                {&otherkeys1}
            end.
        END.
        /* find first record logic */
        IF a-seeid = -1
             {&NonCharacter}
            OR (LASTKEY GE 32 AND LASTKEY LE 127)
            /{&NonCharacter}**/
        THEN DO:
            if a-recid = -1
            then do:
                FIND FIRST {&File} WHERE
                        {&NonCharacter}
                        {&CField} BEGINS a-seekey AND /{&NonCharacter}**/
                        {&Where} {&LockType} NO-ERROR.
            end.
            else do:
                find first {&File} where recid ({&File}) = a-recid {&locktype}.
                ASSIGN
                    a-recid = -1.
            end.
            IF AVAILABLE {&File}
            THEN DO:
                {{&AftFnd}{&*}}
                {&AftFnd1}
                CLEAR ALL.
                ASSIGN
                    a-seeid = -1
                    a-seerec[1] = ?
                    a-seerec[1] = RECID({&File}).
                DISPLAY {&CField}
                        {&OField}
                        /{&UsePick}*/
                        IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
                        THEN "*" ELSE "" @ a-seelst
                        /{&UsePick}*/ /*color {&color}*/.

            END.
            {&NonCharacter}
            ELSE
                IF LENGTH(a-seekey) > 1
                THEN DO:
                    ASSIGN
                        a-seekey = SUBSTRING(a-seekey,LENGTH(a-seekey)).
                    NEXT.
                END.
                ELSE
                    IF LENGTH(a-seekey) = 1
                    THEN DO:
                        MESSAGE "Nenhum registro comeca com " KEYLABEL(LASTKEY).
                        ASSIGN a-seekey = "".
                        NEXT.
                    END.
                    /{&NonCharacter}**/
                    ELSE DO:
                        {{&NaoExiste}}
                        {&naoexiste1}
                    END.
        END.

        IF LASTKEY LT 32 OR LASTKEY GT 127
        THEN
            ASSIGN a-seekey = "".
        ELSE do:
            if "{&NonCharacter}" = "/*"
            THEN do:
                ASSIGN a-seekey = "".
            end.
        end.

        /* loop so that the page-up can come back to the page-down if needed */

        IF CAN-DO
        ("PAGE-UP,CURSOR-UP,PAGE-DOWN,CURSOR-DOWN",KEYFUNCTION(LASTKEY)) OR
            a-seeid = -1 
        THEN pge-{&file}-loop: DO WHILE TRUE:

            /* cursor down */

            IF INDEX(KEYFUNCTION(LASTKEY),"DOWN") > 0 OR
                a-seeid = -1 
            THEN DO:
                /******* aqui *******/
                IF a-seeid NE -1
                THEN 
                    FIND FIRST {&File} WHERE
                    RECID({&File}) = a-seerec[FRAME-DOWN]
                                             {&locktype} NO-ERROR.
                IF NOT AVAILABLE {&File}
                THEN
                    NEXT keys-loop.
                
                IF a-seeid NE -1
                THEN DO:
                    UP FRAME-LINE - 1.
                    DOWN FRAME-DOWN - 1.
                END.

                DO WHILE TRUE:
                    FIND NEXT {&file} WHERE {&where} {&locktype} NO-ERROR.
                    IF NOT AVAILABLE {&file}
                    THEN leave.

                    {{&AftFnd}{&*}}
                    {&AftFnd1}

                    /* was it a cursor-down */
                    IF KEYFUNCTION(LASTKEY) = "Cursor-Down" OR
                    /* or are we finishing off an incomplete page-up */
                        (a-seerec[1] = ? AND a-seerec[FRAME-DOWN] NE ?)
                    THEN DO:
                        DO a-seeid = 1 TO FRAME-DOWN - 1:
                            ASSIGN a-seerec[a-seeid] = a-seerec[a-seeid + 1].
                        END.
                        SCROLL UP.
                    END.
                    ELSE DO:
                        IF FRAME-LINE = FRAME-DOWN
                        THEN
                            ASSIGN a-seerec = ?.
                        DOWN.
                    END.

                    DISPLAY
                        {&cfield}
                        {&OField}
                        /{&UsePick}*/
                        IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
                        THEN
                            "*"
                        ELSE
                            "" @ a-seelst
                        /{&UsePick}*/ /*color {&color}*/.
                    
                    ASSIGN
                        a-seerec[FRAME-LINE] = RECID({&File}).
                    
                    IF FRAME-DOWN = FRAME-LINE AND
                        a-seerec[1] NE ?
                    THEN
                        LEAVE.
                END.

                IF KEYFUNCTION(LASTKEY) NE "cursor-down"
                THEN
                    UP FRAME-LINE - 1.

                ASSIGN
                    a-seeid = 0.
                NEXT keys-loop.
            END.
            /* cursor up */

            ELSE DO:
                FIND FIRST {&File} WHERE
                            RECID({&File}) = a-seerec[1] {&locktype}
                            NO-ERROR.
                IF NOT AVAILABLE {&File}
                THEN
                    NEXT keys-loop.
                UP FRAME-LINE - 1.
                DO WHILE TRUE:
                    FIND PREV {&file} WHERE {&where} {&locktype} NO-ERROR.

                    IF NOT AVAILABLE {&file}
                    THEN DO:
            /* if it is a curs-up or the initial find prev fails then we will */
            /* still be on line 1 and we can just leave. */
                        IF FRAME-LINE = 1
                        THEN
                            NEXT keys-loop.
                        ASSIGN a-seeid = -1.
                        PAUSE 0.
                        NEXT pge-{&file}-loop.
                    END.

                    {{&AftFnd}{&*}}
                    {&AftFnd1}

                    IF KEYFUNCTION(LASTKEY) = "Cursor-up"
                    THEN DO:
                        DO a-seeid = FRAME-DOWN TO 2 BY -1:
                            ASSIGN
                                a-seerec[a-seeid] = a-seerec[a-seeid - 1].
                        END.
                        SCROLL DOWN.
                    END.
                    ELSE DO:
                        IF FRAME-LINE = 1
                        THEN
                            ASSIGN a-seerec = ?.
                        UP  .
                    END.

                    DISPLAY
                        {&cfield}
                        {&OField}
                        /{&UsePick}*/
                        IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
                        THEN
                            "*"
                        ELSE
                            "" @ a-seelst
                        /{&UsePick}*/ /*color {&color}*/.

                    ASSIGN
                        a-seerec[FRAME-LINE] = RECID({&File}).

                    IF FRAME-LINE = 1
                    THEN
                        NEXT keys-loop.
                END.
            END.
            LEAVE.
        END.

        IF LOOKUP
(KEYFUNCTION(LASTKEY),
"RETURN,GO,DELETE-LINE,RECALL,CLEAR,GET,NEW-LINE,INSERT-MODE,PUT") > 0
        THEN DO:
            IF a-seeid = ?
            THEN
                NEXT.

            FIND FIRST {&File} WHERE RECID({&File}) = a-seeid {&locktype}
                                                      NO-ERROR.

            {{&AftSelect}{&*}}
            {&aftselect1}
            /{&UsePick}*/
            IF KEYFUNCTION(LASTKEY) = "RETURN"
            THEN DO:
                IF NOT CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
                THEN DO:
                    DISPLAY "*" @ a-seelst.
                    ASSIGN
                        a-seelst =
                        a-seelst + "," + STRING({&PickFld},"{&PickFrm}").
                END.
                ELSE
                    IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
                    THEN DO:
                        DISPLAY " " @ a-seelst.
                        ASSIGN
                            SUBSTRING(a-seelst,
                        INDEX(a-seelst,"," + STRING({&PickFld},"{&PickFrm}")),
                            LENGTH(STRING({&PickFld},"{&PickFrm}")) + 1) = "".
                    END.
                NEXT.
            END.
            /{&UsePick}*/
            /*
            leave. /* this will leave if it is a go or we are not using pick */
            */
        END. /* end of record pick */
    END.
    /* if they end errored the release the record so that it is not avail
    *  to the calling program.  The calling program would think it was selected
    */
    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
    RELEASE {&File}.
END.
 