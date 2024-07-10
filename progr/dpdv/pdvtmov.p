/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio


            substituir    pdvmov
                          <tab>
*
*/


def var vforma as char.
def var vctmseq as int.
def var vvalor as dec.
def var vseq as int.
def buffer bfunc for func.
def var vfunape  like func.funape.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Origem Nov","", " "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def var crelatorios     as char format "x(30)" extent 5 initial
           [
            "Lancamento Contabil ",
            "Listagem ",
            "Recibo ",
            "Imp.Cheque",
            ""].

{admcab.i}

def input parameter  par-etbcod as int.
def input parameter  par-cmon-recid     as recid.
def input parameter  par-dtini           as date format "99/99/9999".
def input parameter  par-dtfim           as date.
def input parameter  par-ctmcod         as char.

def var vhora               as  char format "x(5)" label "Hora".
def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdt       as date format "99/99/9999".

/*
find CMon   where recid(CMon) = par-CMon-Recid no-lock no-error.
find cmtipo of cmon no-lock.
*/

def new shared var vetbcod like estab.etbcod.
def new shared var vdtini as date format "99/99/9999" label "De".
def new shared var vdtfin as date format "99/99/9999" label "Ate".              
vetbcod = par-etbcod.
vdtini = par-dtini.
vdtfin = par-dtfim.

def temp-table ttmoeda no-undo
    field ctmcod  like pdvtmov.ctmcod  
    FIELD titvlcob   as dec format "->>>>,>>9.99" column-label "VlNominal"
    FIELD encargo   as dec  format "->>>,>>9.99" column-label "encargos"
    FIELD desconto  as dec  format "->>>,>>9.99" column-label "descontos"
    FIELD valor   as dec    format "->>>>,>>9.99" column-label "total"
    
    index x is unique primary  ctmcod asc.
 
form            
    pdvtmov.ctmnom
    ttmoeda.titvlcob
    ttmoeda.encargo
    ttmoeda.desconto
    ttmoeda.valor
    
     with frame frame-a 10 down row 5 
                  centered
                 overlay.
 
                 
pause 0.
                  /*
def shared frame f-cmon.
                    */

    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "CAIXA" format ">>9"
         CMon.cxanom             no-label
         par-dtini      label "Dt Ini"
         CMon.cxadt     format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

find cmon where recid(cmon) = par-cmon-recid no-lock no-error.

        display par-etbcod @ cmon.etbcod
                CMon.cxanom when avail cmon
                CMon.cxacod when avail cmon
                with frame f-CMon.
    if not avail cmon
    then disp "Geral" @ cmon.cxanom 
        with frame f-cmon.

    disp par-dtini when par-dtini <> par-dtfim
         par-dtfim @ cmon.cxadt
         with frame f-cmon.
                 /*
if par-data <> ?
then vdata = par-data.

        display vdata @ CMon.cxadt
                with frame f-CMon.
                   */
                   
form
    esqcom1
    with frame f-com1
                 row 21 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.




for each cmon where cmon.etbcod = par-etbcod no-lock.
    for each pdvmov where pdvmov.etbcod = cmon.etbcod and
                          pdvmov.cmocod = cmon.cmocod and
                           pdvmov.datamov >= par-dtini and pdvmov.datamov <= par-dtfim no-lock.
        for each pdvdoc of pdvmov no-lock.
            if pdvdoc.pstatus <> yes then next. 
        
            find first ttmoeda where ttmoeda.ctmcod = pdvmov.ctmcod no-error.
            if not avail ttmoeda
            then do:
                create ttmoeda.
                ttmoeda.ctmcod = pdvmov.ctmcod.
            end.    
                ttmoeda.titvlcob = ttmoeda.titvlcob + pdvdoc.titvlcob.    
                ttmoeda.encargo = ttmoeda.encargo + pdvdoc.valor_encargo.    
                ttmoeda.desconto = ttmoeda.desconto + pdvdoc.desconto.    
                ttmoeda.valor = ttmoeda.valor + pdvdoc.valor.    
        end.
    end.
end.

        
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    esqascend = yes.
bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first ttmoeda 
                                        no-lock no-error.
        else
            find last ttmoeda
                                        no-lock no-error.
    else
        find ttmoeda where recid(ttmoeda) = recatu1 no-lock.
    if not available ttmoeda
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        message "Nenhuma Movimento".
        pause 1 no-message.
        leave bl-princ.
    end.

    recatu1 = recid(ttmoeda).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.**/
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next ttmoeda where true
                                        no-lock no-error.
        else
            find prev ttmoeda where true
                                        no-lock no-error.
        if not available ttmoeda
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
                    
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find ttmoeda where recid(ttmoeda) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttmoeda.ctmcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttmoeda.ctmcod)
                                        else "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.
            
            display esqcom1
                    with frame f-com1.
                                choose field pdvtmov.ctmnom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      /*tab*/ PF4 F4 ESC return) .
                     
            status default "".

        end.

            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    if esqascend
                    then
                        find next ttmoeda  where true
                                            no-lock no-error.
                    else
                        find prev ttmoeda  where true
                                            no-lock no-error.
                    if not avail ttmoeda
                    then leave.
                    recatu1 = recid(ttmoeda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    if esqascend
                    then
                        find prev ttmoeda  where true
                                        no-lock no-error.
                    else
                        find next ttmoeda  where true
                                        no-lock no-error.
                    if not avail ttmoeda
                    then leave.
                    recatu1 = recid(ttmoeda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                if esqascend
                then
                    find next ttmoeda  where true
                                    no-lock no-error.
                else
                    find prev ttmoeda  where true
                                    no-lock no-error.
                if not avail ttmoeda
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                if esqascend
                then
                    find prev ttmoeda  where true
                                    no-lock no-error.
                else
                    find next ttmoeda  where true
                                    no-lock no-error.
                if not avail ttmoeda
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.


        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttmoeda
                 with frame f-ttmoeda color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " consulta "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.

                    find pdvtmov where pdvtmov.ctmcod = ttmoeda.ctmcod no-lock.
                    if pdvtmov.novacao
                    then run fin/fqanadocnov.p   ("Novacoes","","",ttmoeda.ctmcod,?,?,?,?,?).
                    else run fin/fqanadoc.p ("Movimentacoes","","",ttmoeda.ctmcod,?,?,?,?).


                    leave.
                end.
                if esqcom1[esqpos1] = " origem Nov "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.

                    run fin/fqanadoc.p ("Origem","","",ttmoeda.ctmcod,?,?,?,?).


                    leave.
                end.
                


            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        /*else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(ttmoeda).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame f-com2           no-pause.
hide frame frame-a          no-pause.
hide frame frame-esquerda   no-pause.
hide frame frame-direita    no-pause.
hide frame f-banco          no-pause.
hide frame f-cmon           no-pause.
hide frame separa           no-pause.
hide frame separa2          no-pause.
hide frame frelatorios      no-pause.
hide frame fcolor           no-pause.

PROCEDURE frame-a.

        find pdvtmov where pdvtmov.ctmcod =  ttmoeda.ctmcod no-lock no-error.
        display
            if avail pdvtmov
            then pdvtmov.ctmnom 
            else ttmoeda.ctmcod @ pdvtmov.ctmnom 
            ttmoeda.titvlcob
            ttmoeda.encargo
            ttmoeda.desconto
            ttmoeda.valor 
                    with frame frame-a.

end procedure.




