/*
*
* Consulta Gererica de cmsalvlrs Caixas/Bancos             cmon/cxbcon.p
*
*/

{cabec.i}

def var vmostra1 as log.
def var vmostra2 as log.
def var vsep as char initial "|".
def var vlinha as int.
def var vconta as int.
def var vcorcai as char.
def var vcorban as char.
def var vrevcai as char.
def var vrevban as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var vdown           as int.
def var vcmsalvlrcmon      like cmonope.cmopevlr label "Saldo Caixas".
def var vcmsalvlrbanco     like cmonope.cmopevlr label "Saldo BANCOS".
def var vmodsaldo-atual as dec.
def var vsaldo-atual as dec.
def workfile wfsaldo
    field linha       as int
    field filial      like estab.etbcod column-label "Est" extent 2  
     /*
    field nome        like estab.etbnom column-label "Nome" extent 2 
                format "x(10)"
                */
    field venda like movim.movpc  column-label "" format "->>>9.99"          
            extent 2
    field saldo like cmonope.cmopevlr column-label "" format "->>>9.99"
        extent 2
    field Reserva like cmonope.cmopevlr column-label "" format ">>>9.99"
        extent 2
    field Pedido like cmonope.cmopevlr column-label "" format ">>9.99"
        extent 2.
        
def var vcmsalvlrgeral  like wfsaldo.saldo[1].
def var vttvenda        like wfsaldo.venda[1].
def var vttreserva      like wfsaldo.reserva[1].
def var vttpedido       like wfsaldo.pedido[1].

def buffer bcmon for cmon.

    form
        esqcom1
            with frame f-com1
                 row 5 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def input parameter par-procod as char.

if par-procod = "MENU"
then do:
    update vmercacod  colon 65
           with side-label row 3 color message no-box width 81
            frame fcab.
    {validame.i vmercacod}
end.
else do:
    find produ where produ.procod = int(par-procod) no-lock no-error.
    if not avail produ
    then do:
        message "Produto Não Cadastrado".
        pause.
        return.
    end.
end.
def var vetb as int.
vetb = 0.
for each estoq where estoq.procod = produ.procod no-lock.
    vetb = vetb + 1.
end.
vetb = vetb / 2 .
vetb = vetb + 3.
     
vlinha = 1.
vconta = 1.

for each estoq where estoq.procod = produ.procod no-lock.
    find estab of estoq no-lock.    
    if vconta <= 2
    then do:
        find first wfsaldo where
                wfsaldo.linha = vlinha
                no-error.
        if not avail wfsaldo
        then do:
            create wfsaldo.
            wfsaldo.linha = vlinha.
        end.         
        assign
            wfsaldo.filial[vconta] = estoq.etbcod
/*            wfsaldo.nome[vconta]   = estab.etbnom */
            wfsaldo.saldo[vconta]  = estoq.estatual.
        for each movim where
                    movim.procod = produ.procod and
                    movim.movdat >= date(month(today),01,year(today))
                    no-lock.
            if movim.etbcod <> estab.etbcod then next.
            find plani of movim no-lock no-error.
            if not avail plani
            then next.
            find tipmov of plani no-lock.
            if tipmov.movtvenda = no
            then next.
            if plani.notsit <> "F"
            then next.
            wfsaldo.venda[vconta] = wfsaldo.venda[vconta]
                            + if tipmov.movtdev
                              then - movim.movqtm
                              else movim.movqtm.
                            /*
                            + (movim.movqtm * movim.movpc) - movim.movdes.
                            */
                            
        end.
        for each prodistr where
                prodistr.lipsit = "A" and
                prodistr.procod = produ.procod and
                prodistr.etbabast = estoq.etbcod
                no-lock.
            if prodistr.tipo <> "NEG" and
               prodistr.tipo <> "LOJ" and
               prodistr.tipo <> "COM"
            then wfsaldo.pedido[vconta] = wfsaldo.pedido[vconta]
                            + prodistr.lipqtd.
            else wfsaldo.reserva[vconta] = wfsaldo.reserva[vconta]
                            + prodistr.lipqtd.
                
        end.        
    end.
    vlinha = vlinha + 1.
    if vlinha = vetb
    then assign
            vconta = vconta + 1
            vlinha = 1.
    if vconta = 3
    then assign
            vlinha = vlinha + 1
            vconta = 1.
end.

assign
    vcmsalvlrgeral = 0
    vttvenda = 0
    vttreserva = 0
    vttpedido = 0.

vdown = 0.
for each wfsaldo.
    assign
        vdown = vdown + 1
        vttvenda   = vttvenda   + wfsaldo.venda[1]   + wfsaldo.venda[2]
        vttreserva = vttreserva + wfsaldo.reserva[1] + wfsaldo.reserva[2]
        vttpedido  = vttpedido  + wfsaldo.pedido[1]  + wfsaldo.pedido[2]
        vcmsalvlrgeral = vcmsalvlrgeral + wfsaldo.saldo[1] +
                                          wfsaldo.saldo[2] .
end.
if vdown > 10
then vdown = 10.

disp /*space(5)*/ vttvenda  vcmsalvlrgeral vttreserva vttpedido
                "   C.Medio" produ.procmed
    with frame fsubger col 6
        row screen-lines - 3
        /*centered*/ no-labels color messages /* title
                "-----------------------  TOTAIS  -----------------------"*/.
/*
disp vcmsalvlrcmon COLON 1
     vcmsalvlrbanco COLON 36
        with frame fsubcai centered
        row screen-lines - 5
            overlay
                no-labels  color messages title
"------------------ Caixas --------------------------- Bancos ----------------".

*/
bl-princ:
repeat:
    /*
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        find first wfsaldo where
                    true
            no-error.
    else
        find wfsaldo where recid(wfsaldo) = recatu1.
    if not available wfsaldo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do with frame frame-a:
        pause 0.
        vmostra1 = wfsaldo.venda[1] <> 0 or
                   wfsaldo.saldo[1] <> 0 or
                   wfsaldo.reserva[1] <> 0 or
                   wfsaldo.pedido[1] <> 0.
        vmostra2 = wfsaldo.venda[2] <> 0 or
                   wfsaldo.saldo[2] <> 0 or
                   wfsaldo.reserva[2] <> 0 or
                   wfsaldo.pedido[2] <> 0.
                   
        disp
            wfsaldo.filial[1] format ">>9"  column-label "Fil"
/*            wfsaldo.nome[1]   format "x(10)"  column-label "" */
            wfsaldo.venda[1]  column-label "Venda Mes"
                    when vmostra1
            wfsaldo.saldo[1]  column-label "Estoque" when vmostra1
            wfsaldo.reserva[1] column-label "Reserva" when vmostra1
            wfsaldo.pedido[1] column-label "R.NORM" when vmostra1
            vsep column-label "|" format "x(1)"
            wfsaldo.filial[2] format ">>9"  column-label "Fil"
/*            wfsaldo.nome[2]   format "x(10)"  column-label "" */
            wfsaldo.venda[2]   column-label "Venda Mes" when vmostra2
            wfsaldo.saldo[2]   column-label "Estoque"  when vmostra2
            wfsaldo.reserva[2] column-label "Reserva" when vmostra2
            wfsaldo.pedido[2]  column-label "R.NORM" when vmostra2
            
            with frame frame-a vdown down centered color messages row 6
                        OVERLAY /*title

"--------- Caixas -----------------  SALDOS  ---------------- Bancos ----------"
*/ .
    end.
    recatu1 = recid(wfsaldo).
    /*
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        find next wfsaldo where
                    true
                no-error.
        if not available wfsaldo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        vmostra1 = wfsaldo.venda[1] <> 0 or
                   wfsaldo.saldo[1] <> 0 or
                   wfsaldo.reserva[1] <> 0 or
                   wfsaldo.pedido[1] <> 0.
        vmostra2 = wfsaldo.venda[2] <> 0 or
                   wfsaldo.saldo[2] <> 0 or
                   wfsaldo.reserva[2] <> 0 or
                   wfsaldo.pedido[2] <> 0.
            
        disp
            wfsaldo.filial[1]
/*            wfsaldo.nome[1]*/
            wfsaldo.venda[1] when vmostra1
            wfsaldo.saldo[1] when vmostra1
            wfsaldo.reserva[1] when vmostra1
            wfsaldo.pedido[1] when vmostra1
            vsep  
            wfsaldo.filial[2]
/*            wfsaldo.nome[2] */
            wfsaldo.venda[2] when vmostra2
            wfsaldo.saldo[2] when vmostra2
            wfsaldo.reserva[2] when vmostra2
            wfsaldo.pedido[2] when vmostra2
             
                with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find wfsaldo where recid(wfsaldo) = recatu1.
            if esqregua
            then
                assign
                    vcorcai = "normal"
                    vrevcai = "message"
                    vcorban = "message"
                    vrevban = "message".
            else
                assign
                    vcorcai = "message"
                    vrevcai = "message"
                    vcorban = "normal"
                    vrevban = "message".
                    
            color display value(vcorcai) wfsaldo.filial[1]
                                         /*(wfsaldo.nome[1]*/
                                         wfsaldo.venda[1]
                                         wfsaldo.saldo[1].
            color display value(vcorban) wfsaldo.filial[2]
                                         /*wfsaldo.nome[2]*/
                                         wfsaldo.venda[2]
                                         wfsaldo.saldo[2].
                                         
                                         
            choose field wfsaldo.filial[1]
~            color value(vcorcai)
                go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return PF1 F1).
        end.
        
            color display value(vrevcai) wfsaldo.filial[1]
                                         /*wfsaldo.nome[1]*/
                                         wfsaldo.venda[1]
                                         wfsaldo.saldo[1].
            color display value(vrevban) wfsaldo.filial[2]
                                         /*wfsaldo.nome[2]*/
                                         wfsaldo.venda[2]
                                         wfsaldo.saldo[2].
        hide message no-pause.

        if keyfunction(lastkey) = "GO"
        then do:
            /*
            frame-value = if esqregua then wfsaldo.salcai
                                      else wfsaldo.salban.
                                      */
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:                                             /*
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.*/
            end.
            else do:                                    /*
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.*/
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if par-procod <> "?"
            then return.
            esqregua = no.
            if esqregua
            then do:    /*
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.*/
            end.
            else do:                                                    /*
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.*/
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if par-procod <> "?"
            then return.
            esqregua = yes.
            if esqregua
            then do:                                                    /*
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.*/
            end.
            else do:                                                    /*
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.*/
            end.
            next.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next wfsaldo where
                        true
                    no-error.
                if not avail wfsaldo
                then leave.
                recatu2 = recid(wfsaldo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev wfsaldo where
                    true
                    no-error.
                if not avail wfsaldo
                then leave.
                recatu1 = recid(wfsaldo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next wfsaldo where
                        true
                 no-error.
            if not avail wfsaldo
            then next.
            /*
            color display value(vcorcai) cmon.cxanom.
            color display value(vcorban) bcmon.cxanom
                                         wfsaldo.salban. */
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wfsaldo where
                    true
                 no-error.
            if not avail wfsaldo
            then next.
            /*
            color display value(vcorcai) cmon.cxanom.
            color display value(vcorban) bcmon.cxanom
                                         wfsaldo.salban. */
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave.
          hide frame frame-a no-pause.
          hide frame fsubger  no-pause.
          hide frame fsubcai  no-pause.
          if esqregua
          then do:
            /*
                find cmon where cmon.cmocod = wfsaldo.cxbcai no-error.
                run ancmope.p (input vdata,
                               input recid(cmon)).
            */
          end.
          else do:
            /*
                find bcmon where bcmon.cmocod = wfsaldo.cxbban no-error.
                run ancmope.p (input vdata,
                               input recid(bcmon)).
            */          end.
          view frame frame-a.
          view frame fsubger.
          view frame fsubcai.
        end.
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.
        vmostra1 = wfsaldo.venda[1] <> 0 or
                   wfsaldo.saldo[1] <> 0 or
                   wfsaldo.reserva[1] <> 0 or
                   wfsaldo.pedido[1] <> 0.
        vmostra2 = wfsaldo.venda[2] <> 0 or
                   wfsaldo.saldo[2] <> 0 or
                   wfsaldo.reserva[2] <> 0 or
                   wfsaldo.pedido[2] <> 0.
        
                disp
            wfsaldo.filial[1]
            /*wfsaldo.nome[1]*/
            wfsaldo.venda[1] when vmostra1
            wfsaldo.saldo[1] when vmostra1
            wfsaldo.reserva[1] when vmostra1
            wfsaldo.pedido[1] when vmostra1
            vsep
            wfsaldo.filial[2]
            /*wfsaldo.nome[2]*/
            wfsaldo.venda[2] when vmostra2
            wfsaldo.saldo[2] when vmostra2
            wfsaldo.reserva[2] when vmostra2
            wfsaldo.pedido[2] when vmostra2
                with frame frame-a.
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(wfsaldo).
   end.
end.
hide frame frame-a no-pause.
/*hide frame f-com1  no-pause.
hide frame f-com2  no-pause.*/
hide frame fsubger no-pause.
hide frame fsubcai no-pause.
