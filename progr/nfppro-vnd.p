/***
40553
***/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5.
def var esqcom2         as char format "x(12)" extent 5.

{admcab.i}

def input parameter par-rec         as recid.

form
    esqcom1
    with frame f-com1
             row screen-lines no-box no-labels side-labels column 1 centered
                            overlay.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
pause 0.
find plani where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.
assign
    esqcom1 = ""
    esqcom2 = "".
if tipmov.movtdc = 5
then esqcom1[2] = "Telefonia".

/***
display 
"                                P R O D U T O S                           "
        with frame fprod centered width 81 no-box color message
                row 9 overlay.
***/        
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first movim where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.movdat = plani.pladat
                               and movim.movtdc = plani.movtdc
                               use-index movim
                                        no-lock no-error.
        else
            find last movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod 
and movim.movdat = plani.pladat 
and movim.movtdc = plani.movtdc
use-index movim
                                        no-lock no-error.
    else
        find movim where recid(movim) = recatu1 no-lock.
    if not available movim
    then do:
        esqvazio = yes.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run mostra-dados.
    end.
    else do:
        message "NF sem itentns."
        view-as alert-box.
        leave bl-princ.
    end.
        
    recatu1 = recid(movim).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        find next movim where movim.etbcod = plani.etbcod
                          and movim.placod = plani.placod 
                          and movim.movtdc = plani.movtdc
                          and movim.movdat = plani.pladat use-index movim
                        no-lock.
        if not available movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run mostra-dados.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find movim where recid(movim) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.

            choose field movim.movseq help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5  
                      PF4 F4 ESC return).

            status default "".

        end.
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5"   
            then do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqregua = yes.
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
            end.    
        {esquema.i &tabela = "movim"
                   &campo  = "movim.movseq"
                   &where  = "movim.etbcod = plani.etbcod and 
                              movim.placod = plani.placod and
                              movim.movdat = plani.pladat and 
                              movim.movtdc = plani.movtdc
                              use-index movim"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio or
           keyfunction(lastkey) = "1" or 
           keyfunction(lastkey) = "2" or 
           keyfunction(lastkey) = "3" or 
           keyfunction(lastkey) = "4" or 
           keyfunction(lastkey) = "5" or 
           keyfunction(lastkey) = "6" or 
           keyfunction(lastkey) = "7" or 
           keyfunction(lastkey) = "8" or 
           keyfunction(lastkey) = "9"  
        then do on error undo, retry on endkey undo, leave:
            form 
                 with frame f-movim 
                      centered side-label row 5 .

                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            if  (esqcom1[esqpos1] = " 1.Inclusao " or
                esqvazio) 
            then do:
            end.
            if esqcom1[esqpos1] = "Telefonia"
            then do.
                for each tbprice where tbprice.etb_venda = plani.etbcod
                                   and tbprice.data_venda = plani.pladat
                                   and tbprice.nota_venda = plani.numero
                                 no-lock.
                    disp tbprice.tipo
                        tbprice.serial
                        tbprice.vendedor
                        with frame f-price 5 down row 12.
                end.
                pause.
                hide frame f-price no-pause.
            end.
                if esqcom1[esqpos1] = " 1.Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run not_movim.p (input recid(plani),
                                     input recid(movim)).   
                    view frame frame-a.
                    view frame f-com1.
                end.
        end.
        if not esqvazio
        then run mostra-dados.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(movim).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame fprod   no-pause.
pause 0.

Procedure Mostra-Dados.
            find produ where produ.procod = movim.procod no-lock no-error.
            disp movim.movseq
                 movim.procod
                 produ.pronom format "x(25)" when avail produ
                 movim.ocnum[8] column-label "Promo"
                 movim.ocnum[9] when length(string(movim.ocnum[9])) < 6 
                        column-label "Plano" 
                 movim.movqtm
                        column-label "Qtd." format ">>>9"
                 movim.movpc column-label "Unitario" format ">>,>>9.99"
                (movim.movqtm * movim.movpc) format ">>,>>9.99"
                        column-label "Total"
            with frame frame-a 7 down centered row 12 no-box width 80 overlay.

End Procedure.

