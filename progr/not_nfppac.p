/* 
*/
{admcab.i}
def input parameter par-rec         as recid.

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

def buffer bmovimpack       for movimpack.
def buffer xestab   for estab.
def var vmovimpack      like movimpack.movseq.
def var vtotal      like movimpack.movpc.
def var vprocod     like produ.procod format ">>>>>>>>>".
def var vpronom     like produ.pronom format "x(19)".
def var vpctserv as dec format ">>9.99%".
def var vpctpromoc as dec format ">>9.99%".
def var vdescpromoc as dec format ">,>>9.99".
def var vpctdesc   as dec format ">>9.99%".
def var vdesc      as dec format ">,>>9.99".
def var vperc as dec .

form
    esqcom1
    with frame f-com1
                 row screen-lines no-box no-labels column 1 centered overlay.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

pause 0.
find plani  where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.

vmovimpack = 0.
vtotal = 0.
for each movimpack where movimpack.etbcod = plani.etbcod
                     and movimpack.placod = plani.placod
               use-index movimpack
               no-lock.
    vmovimpack = vmovimpack + 1.
    vtotal = vtotal + movimpack.movqtm * movimpack.movpc + movimpack.movacf 
            - movimpack.movdes.
end.
message vmovimpack vtotal.

esqcom1[1] = " 1.Consulta ".

display " " format "x(35)"  "P A C K S"
        with frame fprod centered width 81 no-box color message row 9 overlay.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        find first movimpack where movimpack.etbcod = plani.etbcod
                               and movimpack.placod = plani.placod
                             use-index movimpack
                             no-lock no-error.
    else
        find movimpack where recid(movimpack) = recatu1 no-lock.
    if not available movimpack
    then do:
        message "Sem itens".
        esqvazio = yes.
        leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run mostra-dados.
    recatu1 = recid(movimpack).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        find next movimpack where movimpack.etbcod = plani.etbcod
                              and movimpack.placod = plani.placod
                             use-index movimpack
                           no-lock.
        if not available movimpack
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run mostra-dados.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find movimpack where recid(movimpack) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.

            status default "".

            choose field movimpack.movseq help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5  
                      PF4 F4 ESC return).
        end.
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5"   
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
            end.    
        {esquema.i &tabela = "movimpack"
                   &campo  = "movimpack.movseq"
                   &where  = "movimpack.etbcod = plani.etbcod and 
                              movimpack.placod = plani.placod
                              use-index movimpack"
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

                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            if (esqcom1[esqpos1] = " 1.Inclusao " or
                esqvazio) 
            then do:
            end.

            if esqcom1[esqpos1] = " 1.Consulta " or
               esqcom1[esqpos1] = " 2.Altera "
            then do.
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run not_movimpack.p (input recid(plani),
                                 input recid(movimpack)).   
                view frame frame-a.
                view frame f-com1 .
            end.
            if esqcom1[esqpos1] = " 5.Tributacao "
            then run tributacao.
        end.
        if not esqvazio
        then run mostra-dados.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(movimpack).
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
    def var vpreco like movimpack.movpc.

        vtotal = movimpack.movqtm  * movimpack.movpc + movimpack.movacf
                 - movimpack.movdes.
        find pack of movimpack no-lock no-error.
        vprocod = movimpack.paccod.
        vpronom = pack.pacnom.
        vpreco = movimpack.movpc + (movimpack.movacf / movimpack.movqtm) -
                                (movimpack.movdes / movimpack.movqtm).
        display
            movimpack.movseq   column-label "Seq"      format ">>9"
            vprocod @ produ.procod    column-label "Codigo" format ">>>>>>>>>"
            vpronom @ produ.pronom    column-label "Descricao" format "x(20)"
            movimpack.movqtm   column-label "Qtd"
            vpreco         column-label "Preco"
            vtotal         column-label "Total"
            with frame frame-a 9 down centered row 10 no-box width 81
                                        overlay.

end Procedure.

/***
procedure tributacao.

    for each bmovimpack where bmovimpack.etbcod = plani.etbcod
                          and bmovimpack.placod = plani.placod
                    use-index movimpack
                    no-lock
                    break by bmovimpack.movalicms.
        disp
            bmovimpack.procod
            bmovimpack.movpc * bmovimpack.movqtm (total by bmovimpack.movalicms)
            bmovimpack.movalicms
            with frame f-tribu row 10 down.
    end.

end procedure.
***/
