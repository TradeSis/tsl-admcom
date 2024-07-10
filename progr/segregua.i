def var vi as int.

if not avail bsegur
then find first bsegur where
           bsegur.empcod = 19 and
           bsegur.etbcod = setbcod and
           bsegur.funcod = sfuncod and
           bsegur.programa = program-name(2)
           no-lock no-error.

if not avail bsegur
then find first bsegur where
           bsegur.empcod = 19 and
           bsegur.etbcod = setbcod and
           bsegur.funcod = sfuncod and
           bsegur.programa = program-name(3)
           no-lock no-error.
if not avail bsegur
then find first bsegur where
           bsegur.empcod = 19 and
           bsegur.etbcod = setbcod and
           bsegur.funcod = sfuncod and
           bsegur.programa = program-name(4)
           no-lock no-error.

if avail bsegur and
         (bsegur.regua[1] <> "" or
         bsegur.regua[6] <> "")
then do:
    do vi = 1 to 5:
        if esqcom1[vi] <> ""
        then do:
            if trim(esqcom1[vi]) = trim(bsegur.regua[1]) or
               trim(esqcom1[vi]) = trim(bsegur.regua[2]) or
               trim(esqcom1[vi]) = trim(bsegur.regua[3]) or
               trim(esqcom1[vi]) = trim(bsegur.regua[4]) or
               trim(esqcom1[vi]) = trim(bsegur.regua[5]) 
            then esqcom1[vi] = "".
        end.       
    end.
    do vi = 1 to 5:
        if esqcom2[vi] <> ""
        then do:
            if trim(esqcom2[vi]) = trim(bsegur.regua[6]) or
               trim(esqcom2[vi]) = trim(bsegur.regua[7]) or
               trim(esqcom2[vi]) = trim(bsegur.regua[8]) or
               trim(esqcom2[vi]) = trim(bsegur.regua[9]) or
               trim(esqcom2[vi]) = trim(bsegur.regua[10]) 
            then esqcom2[vi] = "".
        end.       
    end.
end.
