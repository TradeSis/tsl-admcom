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
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","",""," 5.Tributacao "].
def var esqcom2         as char format "x(12)" extent 5.

def buffer bmovim       for movim.
def buffer xestab   for estab.
def var vmovim      like movim.movseq.
def var vmovqtm     like movim.movqtm.
def var vtotal      like movim.movpc.
def var vprocod     like produ.procod format ">>>>>>>>>".
def var vpronom     like produ.pronom format "x(19)".

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

find plani where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.

vmovim = 0.
vtotal = 0.
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
                 and movim.movtdc = plani.movtdc
                 and movim.movdat = plani.pladat
               use-index movim
               no-lock.
    vmovim = vmovim + 1.
    vmovqtm = vmovqtm + movim.movqtm.
    if tipmov.movtvenda and
           not tipmov.movtdev
    then vtotal = vtotal + (movim.movqtm * movim.movpc).
    else vtotal = vtotal + (movim.movqtm * movim.movpc) + movim.movacf
                  - movim.movdes.
end.
message vmovim vmovqtm vtotal.

esqcom1[1] = " 1.Consulta ".
/***
if sfuncod = 100
then esqcom1[2] = " 2.Altera ".
***/
if tipmov.movtvenda and tipmov.movtdev = no
then esqcom1[2] = " 2.Pedidos ".
if tipmov.movtvenda
then esqcom1[3] = " 3.Seguros ".

pause 0.
display 
   "                                P R O D U T O S                           "
   with frame fprod centered width 81 no-box color message row 9 overlay.
pause 0.

/* helio 26092022 */
if setbcod <> 999
then esqcom1 = "".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
            find first movim where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.movtdc = plani.movtdc
                               and movim.movdat = plani.pladat
                             use-index movim
                             no-lock no-error.
    else
        find movim where recid(movim) = recatu1 no-lock.
    if not available movim
    then do:
        message "Sem itens".
        esqvazio = yes.
        leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run mostra-dados.
    recatu1 = recid(movim).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
            find next movim where movim.etbcod = plani.etbcod
                              and movim.placod = plani.placod
                              and movim.movtdc = plani.movtdc
                              and movim.movdat = plani.pladat
                             use-index movim
                           no-lock.
        if not available movim
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
            find movim where recid(movim) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.

            status default "".

            choose field movim.movseq help ""
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
        {esquema.i &tabela = "movim"
                   &campo  = "movim.movseq"
                   &where  = "movim.etbcod = plani.etbcod and 
                              movim.placod = plani.placod and
                              movim.movtdc = plani.movtdc and
                              movim.movdat = plani.pladat use-index movim"
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
                run not_movim.p (input recid(plani),
                                 input recid(movim)).   
                view frame frame-a.
                view frame f-com1.
            end.
            if esqcom1[esqpos1] = " 2.Pedidos "
            then do.
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run not_pedven.p (recid(plani)).
                view frame frame-a.
                view frame f-com1.
            end.
            if esqcom1[esqpos1] = " 3.Seguros "
            then do.
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run not_movimseg.p (par-rec).
                view frame frame-a.
                view frame f-com1.
            end.
            
            if esqcom1[esqpos1] = " 5.Tributacao "
            then run tributacao.
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
    def var vpreco like movim.movpc.
/***
        if tipmov.movtvenda and
           not tipmov.movtdev
        then vtotal = movim.movqtm * movim.movpc.
        else vtotal = movim.movqtm * movim.movpc + movim.movacf - movim.movdes.
***/
    vtotal = movim.movqtm * movim.movpc + movim.movacf - movim.movdes.

    find produ of movim no-lock no-error.
    vprocod = movim.procod.
    vpronom = "".
        if not avail produ 
        then do.
            find prodnewfree of movim no-lock no-error.
            if avail prodnewfree
            then assign vprocod = prodnewfree.procod
                       vpronom = "(NF)" + prodnewfree.pronom.            
        end.
        else 
            if avail produ
            then assign vprocod = produ.procod
                       vpronom =  produ.pronom.
        if tipmov.movtvenda and
           not tipmov.movtdev
        then vpreco = (movim.movpc + (movim.movacf / movim.movqtm) -
                                        (movim.movdes / movim.movqtm)).
        else vpreco = (movim.movpc * movim.movqtm) - movim.movdes.
        display
            movim.movseq   column-label "Seq"      format ">>9"
            vprocod @ produ.procod    column-label "Codigo" format ">>>>>>>>>"
            vpronom @ produ.pronom    column-label "Descricao" format "x(20)"
            movim.movqtm   column-label "Qtd"
            vpreco         column-label "Preco"
            vtotal         column-label "Total"
            movim.opfcod   column-label "CFOP"
            with frame frame-a 9 down centered row 10 no-box width 81
                                        overlay.

end Procedure.

procedure tributacao.

    for each bmovim where bmovim.etbcod = plani.etbcod
                      and bmovim.placod = plani.placod
                      and bmovim.movtdc = plani.movtdc
                      and bmovim.movdat = plani.pladat
                    use-index movim
                    no-lock
                    break by bmovim.movalicms.
        disp
            bmovim.procod
            bmovim.movpc * bmovim.movqtm (total by bmovim.movalicms)
            bmovim.movbicms (total by bmovim.movalicms)
            bmovim.movalicms
            bmovim.movicms  (total by bmovim.movalicms)
            with frame f-tribu row 10 down.
    end.
    if sfuncod = 100
    then do.
        message "Calcular PIS/COFINS?" update sresp.
        if sresp
        then run piscofins2.p (recid(plani)).
    end.
end procedure.
