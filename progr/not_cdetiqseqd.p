{admcab.i}
{setbrw.i}
{anset.i}

def input parameter p-etiqope as int.
def input parameter p-etiqseq as int.
def input parameter p-row     as int.

def var n-etiqseq as int.
def var recatu1 as recid.
def var vtitulo as char.
def buffer betiqseq for etiqseq.

form etiqseq.etseqclf format "x(3)"
     etiqseq.etmovcod
     space(0) "-" space(0)
     etiqmov.etmovnom format "x(38)"
     etiqseq.etopeseq
     etiqseq.etopesup
     etiqseq.movtdc
     space(0) "-" space(0)
     tipmov.movtnom   format "x(6)" no-label
    with frame f-etiqseq
        column 1 + p-row
        row 3 + p-row
        overlay
        down
        no-labels color withe/brown
        title vtitulo.
        
find first etiqseq where etiqseq.etopecod = p-etiqope and 
                         etiqseq.etopesup = p-etiqseq 
        no-lock no-error.
if not avail etiqseq
then do:
    message "Ultimo Nivel".
    pause.
    return.
end.
                                           
    if p-etiqseq = 0
    then do:
        find etiqope where etiqope.etopecod = p-etiqope no-lock.
        vtitulo = etiqope.etopenom.
    end.
    pause 0.
    l1:
    repeat :
        clear frame f-etiqseq all.
        hide frame f-etiqseq.
        
        assign
            an-seeid = -1
            an-recid = -1
            an-seerec = ?.
            
        {anbrowse.i
            &color      = withe/brown
            &file       = etiqseq
            &CField     = etiqseq.etseqclf
            &OField     = "etiqmov.etmovnom etiqseq.movtdc
                           etiqseq.etmovcod etiqseq.etopeseq
                           etiqseq.etopesup tipmov.movtnom when avail tipmov"
            &Where      = "etiqseq.etopecod = p-etiqope and 
                           etiqseq.etopesup = p-etiqseq"
            &AftFnd     = "find etiqmov of etiqseq no-lock.
                           find tipmov of etiqseq no-lock no-error."
            &AftSelect1 = "recatu1 = recid(etiqseq).
                           n-etiqseq = etiqseq.etopeseq.
                           leave keys-loop."
            &Otherkeys1 = "not_cdetiqseqd.ok" 
            &goon       = "f9 pf9"                      
            &Form       = " frame f-etiqseq " 
        }.
        if keyfunction(lastkey) = "END-ERROR" 
        then leave.

        clear frame f-etiqseq all no-pause.
        find etiqseq where recid(etiqseq) = recatu1 no-lock.
        find etiqmov of etiqseq no-lock.
        find tipmov where tipmov.movtdc = etiqseq.opccod no-lock no-error.
        pause 0.
        disp etiqmov.etmovnom
             etiqseq.etseqclf
             etiqseq.movtdc
             etiqseq.etmovcod
             etiqseq.etopeseq
             etiqseq.etopesup
             tipmov.movtnom when avail tipmov
             with frame f-etiqseq.
            
        p-row = p-row + 2.
        if p-row > 17
        then p-row = 5.
        run not_cdetiqseqd.p (p-etiqope,n-etiqseq,p-row).
        p-row = p-row - 2.
    end. 

    hide frame f-etiqseq no-pause.
    clear frame f-etiqseq all no-pause.
