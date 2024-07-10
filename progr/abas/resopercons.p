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
/*
def var vcmsalvlrcmon      like cmonope.cmopevlr label "Saldo Caixas".
def var vcmsalvlrbanco     like cmonope.cmopevlr label "Saldo BANCOS".
def var vmodsaldo-atual as dec.
def var vsaldo-atual as dec.
*/

def workfile wfsaldo
    field linha       as int
    field filial      like estab.etbcod column-label "Est" extent 2  
    field Emite       like abasresoper.emite column-label "Emite" extent 2  

    field LeadTimeInfo like abasresoper.leadtimeinfo 
                    column-label "" format "->>>9.99"           
            extent 2
    field LeadTime     like abasresoper.leadtime 
                    column-label "" format "->>>9.99"
        extent 2
    field QtdOpere     like abasresoper.qtdOper 
                    column-label "" format "->>>9"
        extent 2.
        
/*def var vcmsalvlrgeral  like wfsaldo.saldo[1].
def var vttvenda        like wfsaldo.venda[1].
def var vttreserva      like wfsaldo.reserva[1].
def var vttpedido       like wfsaldo.pedido[1].
*/

def var pprocod like produ.procod.

def temp-table tt-estoq no-undo
    field etbcod    like estab.etbcod
    field emite     like abasresoper.emite
    field leadtimeInfor  like abasresoper.leadtimeinfo
    field leadtime       like abasresoper.leadtime
    field qtdoper       like abasresoper.qtdoper
    index chave etbcod asc emite asc.

        form
            wfsaldo.filial[1] format ">>9"  column-label "Fil"
            wfsaldo.emite[1] format ">>>>>9"  column-label "Emite"
            
            wfsaldo.leadtimeinfo[1]  column-label "Informado"
            wfsaldo.leadtime[1]  column-label "Lead Time" 
            wfsaldo.QtdOper[1]  column-label "Oper" 
            
            vsep column-label "|" format "x(1)"
            wfsaldo.filial[2] format ">>9"  column-label "Fil"
            wfsaldo.emite[2] format ">>>>>9"  column-label "Emite"
            
            wfsaldo.leadtimeinfo[2]   column-label "Informado" 
            wfsaldo.leadtime[2]   column-label "Lead Time"  
            wfsaldo.QtdOper[2]  column-label "Oper" 
            
            with frame frame-a vdown down centered color messages row 6
                        OVERLAY .

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

def var par-procod as char init "MENU" .
form
    produ.pronom no-labels
        with frame fcab.
        
if par-procod = "MENU"
then do:
    update vmercacod  colon 65
           with side-label row 3 color message no-box width 81
            frame fcab.
    {validame.i vmercacod}
    pprocod = produ.procod.
end.
else do:
    if acha("PAI", par-procod) <> ?
    then do.
        for first produ where produ.itecod = int(acha("PAI", par-procod)) 
                       no-lock.
            pprocod = produ.procod.
        end.
    end.
    else do.
        find produ where produ.procod = int(par-procod) no-lock no-error.
        if not avail produ
        then do:
            message "Produto Não Cadastrado".
            pause.
            return.
        end.
        pprocod = produ.procod.
    end.
end.

disp produ.pronom 
    with frame fcab.
    
def var vetb as int.
vetb = 0.

    for each abasresoper where abasresoper.procod = pprocod no-lock.

        find first tt-estoq where 
            tt-estoq.etbcod = abasresoper.etbcod and
            tt-estoq.emite  = abasresoper.emite
        no-error.
        if not avail tt-estoq
        then do.
            create tt-estoq.
            tt-estoq.etbcod = abasresoper.etbcod.
            tt-estoq.emite  = abasresoper.emite.
        end.
    
        /*find abasresoper where 
                        abasresoper.procod = tt-produ.procod and
                        abasresoper.etbcod = estab.etbcod
                    no-lock no-error.
        */
        tt-estoq.leadtimeinfo =
                    if avail abasresoper
                    then abasresoper.leadtimeinfo
                    else 0.
        tt-estoq.leadtime =
                    if avail abasresoper
                    then abasresoper.leadtime
                    else 0.
        tt-estoq.qtdoper =
                    if avail abasresoper
                    then abasresoper.qtdoper
                    else 0.

    end.
vetb = 0.
for each tt-estoq.
/*    for each estoq where estoq.procod = produ.procod no-lock.*/
    vetb = vetb + 1.
end.
if vetb = 0     
then do:
    for each estab no-lock.
        create tt-estoq.
        tt-estoq.etbcod = estab.etbcod.
        vetb = vetb + 1.
    end.
end.

vetb = vetb / 2 .
vetb = vetb + 3.


vlinha = 1.
vconta = 1.

for each tt-estoq /*where estoq.procod = tt-produ.procod*/ no-lock.
/*    find estab of estoq no-lock.    */
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
            wfsaldo.filial[vconta]  = tt-estoq.etbcod
            wfsaldo.emite[vconta]  = tt-estoq.emite
            wfsaldo.leadtimeinfo[vconta]   = tt-estoq.leadtimeinfo
            wfsaldo.leadtime[vconta]   = tt-estoq.leadtime.
            wfsaldo.qtdoper[vconta]   = tt-estoq.qtdoper.
            
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

/*
assign
    vcmsalvlrgeral = 0
    vttvenda = 0
    vttreserva = 0
    vttpedido = 0.
*/

vdown = 0.
for each wfsaldo.
    assign
        vdown = vdown + 1.
        
/*        vttvenda   = vttvenda   + wfsaldo.venda[1]   + wfsaldo.venda[2]
        vttreserva = vttreserva + wfsaldo.reserva[1] + wfsaldo.reserva[2]
        vttpedido  = vttpedido  + wfsaldo.pedido[1]  + wfsaldo.pedido[2]
        vcmsalvlrgeral = vcmsalvlrgeral + wfsaldo.saldo[1] +
                                          wfsaldo.saldo[2] .
*/

end.
if vdown > 10
then vdown = 10.


/*******
disp /*space(5)*/ vttvenda  vcmsalvlrgeral vttreserva vttpedido
                "   C.Medio"
                produ.procmed when avail produ
    with frame fsubger col 6
        row screen-lines - 3
        /*centered*/ no-labels color messages /* title
                "-----------------------  TOTAIS  -----------------------"*/.
***/

                
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
        run mostra.
                       
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
        run mostra.
            
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
                                         wfsaldo.leadtimeinfo[1]
                                         wfsaldo.leadtime[1]
                                         wfsaldo.qtdoper[1].
            color display value(vcorban) wfsaldo.filial[2]
                                         wfsaldo.leadtimeinfo[2]
                                         wfsaldo.leadtime[2]
                                         wfsaldo.qtdoper[2].
                                         
                                         
            choose field wfsaldo.filial[1]
~            color value(vcorcai)
                go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return PF1 F1).
        end.
        
            color display value(vrevcai) wfsaldo.filial[1]
                                         wfsaldo.leadtimeinfo[1]
                                         wfsaldo.leadtime[1]
                                         wfsaldo.qtdoper[1].
            color display value(vrevban) wfsaldo.filial[2]
                                         wfsaldo.leadtimeinfo[2]
                                         wfsaldo.leadtime[2]
                                         wfsaldo.qtdoper[2].
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
            /*if par-procod <> "?"
            then return.*/
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
            /*if par-procod <> "?"
            then return.*/
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
                run abas/hisopercons.p (pprocod,
                                        wfsaldo.filial[1],
                                        wfsaldo.emite[1]).
          end.
          else do:
                run abas/hisopercons.p (pprocod ,
                                        wfsaldo.filial[2],
                                        wfsaldo.emite[2]).
          end.
          view frame frame-a.
          view frame fcab.
          view frame fsubcai.
        end.
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.
        run mostra.
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


procedure mostra.        
        pause 0.
        vmostra1 = wfsaldo.leadtimeinfo[1] <> ? or
                   wfsaldo.leadtime    [1] <> 0 or
                   wfsaldo.qtdoper     [1] <> 0.
        vmostra2 = wfsaldo.leadtimeinfo[2] <> ? or
                   wfsaldo.leadtime[2] <> 0 or
                   wfsaldo.qtdoper[2]  <> 0.
                   
        disp
            wfsaldo.filial[1] 
            wfsaldo.emite[1] 
            
            wfsaldo.leadtimeinfo[1] 
                    when vmostra1
            wfsaldo.leadtime[1]  when vmostra1
            wfsaldo.QtdOper[1]   when vmostra1
            
            vsep 
            wfsaldo.filial[2] 
            wfsaldo.emite[2]
            wfsaldo.leadtimeinfo[2]  when vmostra2
            wfsaldo.leadtime[2]     when vmostra2
            wfsaldo.QtdOper[2]   when vmostra2
            
            with frame frame-a.
end procedure.
 
