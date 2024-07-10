        if  keyfunction(lastkey) = "TAB" 
        then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" 
        then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" 
        then do:
            if esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-esqcom1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-esqcom2.
            end.
            next.
        end.
