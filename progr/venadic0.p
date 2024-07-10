{admcab.i}
{setbrw.i}                                                                      

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].


form vetbcod label   "Cod.Filial"
     estab.etbnom no-label
     vdti at 1 label "Periodo de"
     vdtf      label "Ate"
     with frame f-c 1 down width 80 side-label.

do on error undo, retry with frame f-c:
    update vetbcod.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock .
        disp estab.etbnom.
    end.
    update vdti vdtf.   
    if vdti > vdtf
    then undo.    
end.

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


def temp-table tt-sel
    field vencod like plani.vencod
    field vdesc as char
    index i1 vencod.
    
def var i as int.
def buffer bestab for estab.
def var vindex as int.
def var vsel as char format "x(15)" extent 2
    init["JUSTIFICATIVA","PRODUTO"].
disp vsel with frame f-sel centered no-label 1 down.
choose field vsel with frame f-sel.
def var varquivo as char.
    
for each bestab where (if vetbcod > 0
    then bestab.etbcod = vetbcod else true) no-lock:
    for each plani where plani.movtdc = 30 and
                         plani.etbcod = bestab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf
                         no-lock.
        if plani.usercod = ""
        then next.
        if  vindex = 1 and
            acha("PRODUTO",plani.usercod) <> ?
        then next.
        if vindex = 2 and
            acha("JUSTIFICA",plani.usercod) <> ?
        then next.    
        create tt-sel.
        tt-sel.vencod = plani.vencod.
        tt-sel.vdesc = plani.usercod.
        
    end.                         
end.                         
        if opsys = "UNIX"
    then varquivo = "/admcom/relat/ctintcmp" + "."
                    + string(time).
    else varquivo = "..~\relat~\ctintcmp"  + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""venadic0"" 
                &Nom-Sis   = """COMERCIAL""" 
                &Tit-Rel   = """" 
                &Width     = "110"
                &Form      = "frame f-cabcab"}


    for each tt-sel use-index i1:
        disp tt-sel.vencod
             tt-sel.vdesc
             with frame f-disp down width 120.
        down with frame f-disp.  
    end.
           
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

    


