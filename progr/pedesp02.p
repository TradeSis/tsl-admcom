{admcab.i}

def buffer npedid for pedid.
def buffer nliped for liped.
def buffer nprodu for produ.
def buffer nforne for forne.
def var vfornom like forne.fornom.
def var vatraso as int.
def var vclien as char.
def var varqdg as char format "x(70)".
def var vendedor as char.
def temp-table tt-numped
    field pednum like pedid.pednum
    field etbcod like estab.etbcod
    field pedido like pedid.pednum
    field frecod like pedid.frecod
    field condat like pedid.condat
    .
def var vqtd-ped as int.
def var vnum-ped as char.
def var vpedtot like plani.platot.
def var vrepcod like repre.repcod.
def buffer bliped for liped.
def buffer cpedid for pedid.
def var varquivo as char.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var vdti as date.
def var vdtf as date.
def var vfuncod like func.funcod.
def var vclicod like clien.clicod. 
def var esqcom1         as char format "x(14)" extent 5
            initial ["Consulta","Procura","Imprime","Relatorio",""].
def var esqcom2         as char format "x(18)" extent 4
      initial ["Pedidos Vendedor","Pedidos Cliente","Pedidos Data",
                "Pedidos Previsao"].

if sparam = "SSH"
then assign
        esqcom1[3] = ""
        esqcom1[4] = "".
def input parameter p-tdc as int.
def var par-pedtdc as int initial 6.

if p-tdc > 0
then par-pedtdc = p-tdc.

def buffer bpedid            for pedid.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.

form esqcom1 with frame f-com1 centered
                 row 6 no-box no-labels side-labels column 1.
form esqcom2 with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def buffer bestab for estab.

form vetbcod label "Filial"    at 5                            
     bestab.etbnom no-label                                 
     vforcod like forne.forcod label "Fornecedor"  at 1    
     forne.fornom no-label                                
     /*vclicod like clien.clicod label "Cliente" at 4        
     clien.clblinom no-label*/                                
     with frame fest centered color white/cyan             
     side-labels width 80 row 3.                          

vetbcod = setbcod.
disp vetbcod with frame fest.
if vetbcod >= 900 or 
 {conv_igual.i vetbcod}
then update vetbcod with frame fest.                            
if vetbcod > 0                                             
then do:                                                   
    find bestab where bestab.etbcod = vetbcod no-lock.       
    disp bestab.etbnom no-label with frame fest.            
end.                                                       
update vforcod /*validate(vfabcod > 0,"Informe o Fabricante")*/ with frame fest.
if vforcod > 0
then do:
    find forne where forne.forcod = vforcod no-lock.
    disp forne.fornom with frame fest.
end.
/*
update vclicod with frame fest.   
if vclicod > 0
then do:
    find clien where clien.clicod = vclicod no-lock.
    disp clien.clinom with frame fest.
end.
*/
hide frame fest no-pause.

disp vetbcod label "Filial"    at 5                            
     bestab.etbnom no-label when avail bestab                                
     vforcod label "Fornecedor"  at 1    
     forne.fornom no-label  when avail forne   
     /*vclicod label "Cliente" at 4        
     clien.clinom no-label  when avail clien */                             
     with frame fest1 color white/cyan             
     side-labels width 80 row 3 no-box.      

def var vsel as char extent 2 format "x(15)"
            init[" marcar"," enviar"].

def var vselec as char extent 5 format "x(12)"
    init ["   TODOS","  ABERTOS"," PENDENTES","   ATRASO"," ENTREGUES"].
    .
def var vindex as int.    
disp vselec with frame fl1 no-label 1 down centered 
        no-box row 6.
choose field vselec with frame fl1.
vindex = frame-index.
if vindex <> 1 and vindex <> 3
then esqcom2[4] = "".
if vindex = 3  and vforcod > 0 
then esqcom1[5] = "Enviar e-mail" .
hide frame fl1 no-pause.
disp vselec[vindex] with frame fl2 row 5 centered no-box no-label
    color message.      
def temp-table tt-pedid like pedid
    index i1 /*comcod descending*/ peddat
    .
def temp-table btt-pedid like tt-pedid.

def temp-table tt-marca like tt-pedid.
    
for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true)
            no-lock:
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = par-pedtdc /*and
                         pedid.sitped = "A" and
                         pedid.peddat <= today*/
                         no-lock:
        if vindex = 1
        then.
        else if vindex = 2 and pedid.sitped = "A"
        then. 
        else if vindex = 3 /*and pedid.sitped = "P"*/ and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next.                
            if npedid.sitped = "F"
            then next.
        end.
        else if vindex = 5 and pedid.sitped = "P" and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next. 
            if npedid.sitped = "F"
            then.
            else next.               
        end.
        else if vindex = 4 and pedid.sitped = "P" and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next.                  
            if npedid.peddtf - today > 0
            then next.                  
        end.
        else next.

        if pedid.comcod > 0
        then 
        find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.

        for each liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum /*and
                             liped.lipsit = "A"*/
                             no-lock:
            find produ of liped no-lock.
            find forne where forne.forcod = produ.fabcod 
                    no-lock no-error.    
            if avail forne and vforcod > 0 and forne.forcod <> vforcod
            then next.
            create tt-pedid.
            buffer-copy pedid to tt-pedid.
            if avail npedid  and pedid.comcod > 0
            then assign
                tt-pedid.peddti = npedid.peddti
                tt-pedid.peddtf = npedid.peddtf.
            if avail npedid and pedid.comcod > 0 and
                npedid.sitped = "F"
            then assign    
                tt-pedid.pedsit = npedid.pedsit
                tt-pedid.sitped = npedid.sitped
                .
            leave.
        end.        
    end.                     
end.
for each estab  no-lock:
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = par-pedtdc and
                         pedid.condes = vetbcod
                         no-lock:
        if vindex = 1
        then.
        else if vindex = 2 and pedid.sitped = "A"
        then. 
        else if vindex = 3 /*and pedid.sitped = "P"*/ and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next.                
            if npedid.sitped = "F"
            then next.
        end.
        else if vindex = 5 and pedid.sitped = "P" and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next. 
            if npedid.sitped = "F"
            then.
            else next.               
        end.
        else if vindex = 4 and pedid.sitped = "P" and pedid.comcod <> 0
        then do:
            find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.
            if not avail npedid
            then next.                  
            if npedid.peddtf - today > 0
            then next.                  
        end.
        else next.

        if pedid.comcod > 0
        then 
        find npedid where npedid.pedtdc = 1 and
                              npedid.etbcod = 999 and
                              npedid.pednum = pedid.comcod
                              no-lock no-error.

        for each liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum /*and
                             liped.lipsit = "A"*/
                             no-lock:
            find produ of liped no-lock.
            find forne where forne.forcod = produ.fabcod 
                    no-lock no-error.    
            if avail forne and vforcod > 0 and forne.forcod <> vforcod
            then next.
            create tt-pedid.
            buffer-copy pedid to tt-pedid.
            if avail npedid  and pedid.comcod > 0
            then assign
                tt-pedid.peddti = npedid.peddti
                tt-pedid.peddtf = npedid.peddtf.
            if avail npedid and pedid.comcod > 0 and
                npedid.sitped = "F"
            then assign    
                tt-pedid.pedsit = npedid.pedsit
                tt-pedid.sitped = npedid.sitped
                .
            leave.
        end.        
    end.                     
end.

for each btt-pedid.
    delete btt-pedid.
end.
for each tt-pedid:
    create btt-pedid.
    buffer-copy tt-pedid to btt-pedid.
end.    
for each tt-marca: delete tt-marca. end.
def var vmarca as char.
def var vidx as int.
bl-princ:
repeat:
    status default "Situacao [A]berto [P]endente [F]echado [C]ancelado".
    pause 0. 
    
    disp with frame fest1. pause 0.
    vpedtdc = integer(par-pedtdc).
    disp esqcom1 with frame f-com1.

    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find last tt-pedid no-error.
    else
        find tt-pedid where recid(tt-pedid) = recatu1.
    if not available tt-pedid
    then do:
        message color red/with "Nenum registro encontrado" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    find first tt-marca where
                tt-marca.pedtdc = tt-pedid.pedtdc and
                tt-marca.etbcod = tt-pedid.etbcod and
                tt-marca.pednum = tt-pedid.pednum  
                no-error.
    if avail tt-marca
        then vmarca = "*". else vmarca = "".
    
    vfornom = "".
    find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
    find nprodu of nliped no-lock.
    find first nforne where nforne.forcod = nprodu.fabcod no-lock no-error.
    vfornom = string(nprodu.fabcod,">>>>>>9"). 
    if avail nforne
    then vfornom = vfornom + " " +  nforne.fornom. 
    vatraso = today - tt-pedid.peddtf.
    display vmarca  no-label format "x"
            space(0)
            tt-pedid.pednum format ">>>>>>>>9" help ""
            tt-pedid.etbcod column-label "Fil"
            tt-pedid.peddat column-label "Data" format "99/99/99"
            vfornom column-label "Fornecedor"   format "x(28)"
            tt-pedid.comcod column-label "Compra" format ">>>>>>>9"
                    when tt-pedid.comcod > 0
            tt-pedid.peddtf column-label "Previsao"
            tt-pedid.condes when tt-pedid.condes > 0
            column-label "Ent" format ">>9"
            tt-pedid.sitped column-label "Sit" format "x(3)"
            /*vatraso         column-label "Atraso" format ">>>>9"
                when vatraso <> ?
            */
            with frame frame-a 10 down centered color white/red row 7 overlay.

    recatu1 = recid(tt-pedid).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find prev tt-pedid no-error.
        if not available tt-pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        find first tt-marca where
                tt-marca.pedtdc = tt-pedid.pedtdc and
                tt-marca.etbcod = tt-pedid.etbcod and
                tt-marca.pednum = tt-pedid.pednum  
                no-error.
        if avail tt-marca
        then vmarca = "*". else vmarca = "".    
        vfornom = "".
        find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
        find nprodu of nliped no-lock.
        find first nforne where nforne.forcod = nprodu.fabcod no-lock no-error.
        vfornom = string(nprodu.fabcod,">>>>>>9") .
        if avail nforne 
        then vfornom = vfornom + " " +  nforne.fornom. 
        vatraso = today - tt-pedid.peddtf.
        display vmarca  no-label format "x"
            tt-pedid.pednum
            tt-pedid.etbcod 
            tt-pedid.peddat 
            vfornom 
            tt-pedid.comcod when tt-pedid.comcod > 0
            tt-pedid.peddtf 
            tt-pedid.condes when tt-pedid.condes > 0
            tt-pedid.sitped 
            /*vatraso       when vatraso <> ?
            */
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-pedid where recid(tt-pedid) = recatu1 .

        on f7 recall.
        hide message no-pause.
        status default "Situacao [A]berto [P]endente [F]echado [C]ancelado".
        pause 0. 
        choose field tt-pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red tt-pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for tt-pedid.pednum format ">>>>>>>>9".
            find last tt-pedid where  tt-pedid.pednum = input tt-pedid.pednum
                                                             no-error.
            if avail tt-pedid
            then recatu1 = recid(tt-pedid).
            leave.
        end.
        on f7 help.
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
                esqpos2 = if esqpos2 = 4 then 3 else esqpos2 + 1.
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev tt-pedid no-error.
            if not avail tt-pedid
            then next.
            color display white/red tt-pedid.pednum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next tt-pedid no-error.
            if not avail tt-pedid
            then next.
            color display white/red tt-pedid.pednum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-pedid no-error.
                if not avail tt-pedid
                then leave.
                recatu1 = recid(tt-pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-pedid no-error.
                if not avail tt-pedid
                then leave.
                recatu1 = recid(tt-pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            hide frame  frame-a no-pause.

            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 9 side-label centered
                color black/cyan.
                prompt-for tt-pedid.etbcod label "Filial"
                           tt-pedid.pednum label "Numero"
                           with frame f-procura.
                find first tt-pedid where
                           tt-pedid.etbcod = input frame f-procura 
                                            tt-pedid.etbcod and
                           tt-pedid.pednum = input frame f-procura
                                            tt-pedid.pednum
                           no-lock no-error.
                if not avail tt-pedid
                then message "Nenum registro encontrado." view-as alert-box.
                else recatu1 = recid(tt-pedid).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then repeat on endkey undo:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                vclien = "".
                if tt-pedid.clfcod > 0
                then do:
                    vclien = string(tt-pedid.clfcod,">>>>>>>>9").
                    find clien where 
                         clien.clicod = tt-pedid.clfcod no-lock no-error.
                    if avail clien
                    then vclien = vclien + " " + clien.clinom.
                end.    
                vendedor = "".     
                if tt-pedid.vencod > 0
                then do:
                    vendedor = string(tt-pedid.vencod,">>>>>>9"). 
                    find func where 
                         func.funcod = tt-pedid.vencod no-lock no-error.
                    if avail func
                    then vendedor = vendedor + " " + func.funnom.
                end.         
                if tt-pedid.comcod > 0
                then
                find npedid where npedid.etbcod = 999 and
                                  npedid.pedtdc = 1 and
                                  npedid.pednum = tt-pedid.comcod 
                                  no-lock no-error.
                disp tt-pedid.pednum at 1 label "  Pedido  "
                            format ">>>>>>>9"
                     vendedor at 1 label "  Vendedor"  format "x(40)"
                     vclien   at 1 label "  Cliente "  format "x(40)"
                     tt-pedid.frecod at 1 label "  Numero Venda"
                                     format ">>>>>>>>9"
                     tt-pedid.condat      label "Data Venda"
                     tt-pedid.condes when tt-pedid.condes > 0
                     label "Filial Entrega" format ">>9"
                     tt-pedid.pedobs[1]      label "Observacao" format "x(60)"
                     tt-pedid.pedobs[2]      at 13  no-label    format "x(60)"
                     tt-pedid.pedobs[3]      at 13  no-label    format "x(60)"
                     tt-pedid.pedobs[4]      at 13  no-label    format "x(60)"
                     with frame f-add 1 down  color message
                        row 5 side-label no-box width 80 overlay.
                for each liped where
                         liped.pedtdc = tt-pedid.pedtdc and
                         liped.etbcod = tt-pedid.etbcod and
                         liped.pednum = tt-pedid.pednum and
                         liped.predt  = tt-pedid.peddat
                         no-lock.   
                    find produ where produ.procod = liped.procod no-lock.
                    find nliped where
                         nliped.etbcod = npedid.etbcod and
                         nliped.pedtdc = npedid.pedtdc and
                         nliped.pednum = npedid.pednum and
                         nliped.procod = liped.procod
                         no-lock no-error.
                    disp liped.procod
                         produ.pronom format "x(30)"
                         liped.lipcor
                         liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         nliped.lipent  when avail nliped
                         column-label "Qtd.Ent" format ">>>9"
                                with frame f-con down centered
                                        color black/cyan width 80.
                end.
                pause.
                view frame f-com2 .
                leave.
            end.
            hide frame f-con no-pause.

            if esqcom1[esqpos1] = "Imprime"
            then do with frame f-Lista.
                if opsys = "UNIX"
                then varquivo = "../relat/pedesp" + string(time).
                else varquivo = "..\relat\pedesp" + string(time).
                {mdad.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "63"
                    &Cond-Var  = "120" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""pedesp02"" 
                    &Nom-Sis   = """SISTEMA COMERCIAL""" 
                    &Tit-Rel   = """PEDIDO ESPECIAL"""
                    &Width     = "120"
                    &Form      = "frame f-cabcab"}

                put skip(5)
                    "        DREBES & CIA LTDA         " at 40 skip(2).
                put "         PEDIDO ESPECIAL         " at 40 skip(2).
                find first liped where liped.pedtdc = tt-pedid.pedtdc and
                                       liped.etbcod = tt-pedid.etbcod and
                                       liped.pednum = tt-pedid.pednum .
                find produ of liped no-lock.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
                put fabri.fabfant at 40 skip(2).
                for each liped where liped.pedtdc = tt-pedid.pedtdc and
                                     liped.etbcod = tt-pedid.etbcod and
                                     liped.pednum = tt-pedid.pednum and
                                     liped.predt  = tt-pedid.peddat.
                    find estoq where estoq.etbcod = tt-pedid.etbcod and
                                     estoq.procod = liped.procod no-lock.
                    find produ of liped no-lock.
                    disp produ.procod at 10
                         produ.pronom
                         liped.lipcor column-label "Cor"
                         liped.lipqtd column-label "QTD"
                         estoq.estvenda column-label "Preco"
                                 with frame f-rom width 200 down.
                end.
                find estab where estab.etbcod = tt-pedid.etbcod no-lock.
                find func where func.etbcod = tt-pedid.etbcod and
                                func.funcod = tt-pedid.vencod no-lock no-error.
                put skip(7)
                "PEDIDO: " at 10 tt-pedid.pednum 
                "    ORDEM DE COMPRA: " tt-pedid.comcod format ">>>>>>>9" SKIP(1)
                "NF: " at 10 tt-pedid.frecod
                "         DATA VENDA: " tt-pedid.condat format "99/99/9999"
                                SKIP(1).
                if tt-pedid.vencod <> 0 and avail func
                then put "NOME: " at 10 func.funnom skip(1).
                else put "NOME:............... " at 10 skip(1).
                put "DATA: " at 10 today format "99/99/9999"
                    " FILIAL ORIGEM: " at 40
                estab.etbnom skip.
                if tt-pedid.condes > 0
                then put " FILIAL ENTREGA: " AT 40
                        tt-pedid.condes format ">>9" skip(1).
                output close.
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:    
                    {mrod.i}
                end.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Relatorio"
            then do:
                if opsys = "UNIX"
                then varquivo = "../relat/pedesp" + string(time).
                else varquivo = "..\relat\pedesp" + string(time).
        
                {mdad.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "63"
                    &Cond-Var  = "100" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""pedesp02"" 
                    &Nom-Sis   = """SISTEMA COMERCIAL""" 
                    &Tit-Rel   = """PEDIDO ESPECIAL - "" + vselec[vindex] "
                    &Width     = "100"
                    &Form      = "frame f-cabcab1"}

                disp with frame fest1.
                pause 0.
                for each tt-pedid no-lock:
                    vfornom = "".
                    find first nliped where 
                                nliped.etbcod = tt-pedid.etbcod and
                                nliped.pednum = tt-pedid.pednum and
                                nliped.pedtdc = tt-pedid.pedtdc
                                no-lock no-error.
                    find nprodu of nliped no-lock.
                    find first nforne where nforne.forcod = nprodu.fabcod 
                        no-lock no-error.
                    vfornom = string(nprodu.fabcod,">>>>>>9"). 
                    if avail nforne
                    then  vfornom = vfornom + " " +  nforne.fornom. 
                    vatraso = today - tt-pedid.peddtf.
                    display  tt-pedid.pednum
                             tt-pedid.etbcod column-label "Fil"
                             tt-pedid.peddat column-label "Data"
                             vfornom column-label "Fornecedor"  format "x(29)"
                             tt-pedid.comcod 
                                    column-label "Compra" format ">>>>>>>9"
                                    when tt-pedid.comcod > 0
                             tt-pedid.peddtf column-label "Previsao"
                             tt-pedid.condes when tt-pedid.condes > 0
                             column-label "Ent" format ">>9"
                             tt-pedid.sitped 
                            /*vatraso  column-label "Atraso" format ">>>>9"
                            when vatraso <> ?  */
                            with frame frame-a1 down width 100.
                    down with frame frame-a1.            
                end.
                output close.
                
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:    
                    {mrod.i}
                end.

                leave.
            end.
            if esqcom1[esqpos1] = "Enviar E-mail"
            then do:
                if opsys <> "UNIX"
                then do:
                    message "Opcao disponivel somente em terminal LINUX"
                    view-as alert-box.
                    leave.
                end.

                vidx = 0.
                disp vsel with frame f-sel 1 down centered overlay
                            row 12 no-label.
                choose field vsel with frame f-sel.
                vidx = frame-index.
                if vidx = 1 /* or vidx = 2 */
                then do:            
                find first tt-marca where 
                           tt-marca.pedtdc = tt-pedid.pedtdc and
                           tt-marca.etbcod = tt-pedid.etbcod and
                           tt-marca.pednum = tt-pedid.pednum
                           no-error.
                if avail tt-marca
                then do:
                    delete tt-marca.
                    vmarca = "".
                end.
                else do:
                    create tt-marca.
                    buffer-copy tt-pedid to tt-marca.
                    vmarca = "*".
                end.
                end.
                if vidx = 1
                then do:
                    recatu1 = recid(tt-pedid).
                    leave.
                end.
                else if vidx = 2
                then do:
                    vqtd-ped = 0.
                    vnum-ped = "".
                    sresp = no.
                    message "Confirma enviar e-mail ?" update sresp.
                    if sresp
                    then do:
                        find first tt-marca no-error  .
                        if not avail tt-marca
                        then do:
                            create tt-marca.
                            buffer-copy tt-pedid to tt-marca.
                            vmarca = "*".
                        end.
                        for each tt-marca where tt-marca.pedtdc = par-pedtdc:
                            vqtd-ped = vqtd-ped + 1.
                            create tt-numped.
                            assign
                                tt-numped.pednum = tt-marca.comcod
                                tt-numped.etbcod = tt-marca.etbcod
                                tt-numped.pedido = tt-marca.pednum
                                tt-numped.frecod = tt-marca.frecod
                                tt-numped.condat = tt-marca.condat.
                        end.
                        run env-mail.   
                    end.
                    next bl-princ.
                end.
            end.
        end.
        else do:
            if  esqcom2[esqpos2] = "Pedidos Vendedor"
            then do:
                update vfuncod format ">>>>>9" 
                    label "Informe o Codigo do VENDEDOR "
                    with frame f-func 1 down centered
                    row 12 overlay side-label .
                find first btt-pedid where
                           btt-pedid.vencod = vfuncod
                           no-error.
                if not avail btt-pedid 
                then do:
                    message color red/with "Nenhum registro encontrado."
                    view-as alert-box.
                end.  
                else do:
                    for each tt-pedid:
                        delete tt-pedid.
                    end.                
                    for each btt-pedid where
                         btt-pedid.vencod = vfuncod.
                         create tt-pedid.
                         buffer-copy btt-pedid to tt-pedid.
                    end.
                end.
                recatu1 = ?  .
                hide frame f-func no-pause.
                next bl-princ.             
            end.
            if  esqcom2[esqpos2] = "Pedidos Cliente"
            then do:
                update vclicod format ">>>>>>>9" 
                        label "Informe o codigo do CLIENTE"
                    with frame f-cli 1 down centered
                    row 12 overlay side-label .
                find first btt-pedid where
                           btt-pedid.clfcod = vclicod
                           no-error.
                if not avail btt-pedid 
                then do:
                    message color red/with "Nenhum registro encontrado."
                    view-as alert-box.
                end.  
                else do:
                    for each tt-pedid:
                           delete tt-pedid.
                    end.       
                    for each btt-pedid where
                         btt-pedid.clfcod = vclicod.
                        create tt-pedid.
                        buffer-copy btt-pedid to tt-pedid.
                    end.
                end.
                hide frame f-cli no-pause.
                recatu1 = ?.
                next bl-princ.             
            end.
            if  esqcom2[esqpos2] = "Pedidos Data"
            then do:
                update vdti format "99/99/9999"  label "Periodo de"
                       vdtf format "99/99/9999"  label "Ate"
                    with frame f-dat 1 down centered
                    row 12 overlay side-label .
                find first btt-pedid where
                           btt-pedid.peddat >= vdti and
                           btt-pedid.peddat <= vdtf no-error.
                if not avail btt-pedid 
                then do:
                    message color red/with "Nenhum registro encontrado."
                    view-as alert-box.
                end.  
                else do:
                    for each tt-pedid:
                           delete tt-pedid.
                    end.       
                    for each btt-pedid
                        where btt-pedid.peddat >= vdti and
                              btt-pedid.peddat <= vdtf .
                        create tt-pedid.
                        buffer-copy btt-pedid to tt-pedid.
                    end.    
                end.
                hide frame f-dat no-pause.
                recatu1 = ?.
                next bl-princ.  
            end.
            if  esqcom2[esqpos2] = "Pedidos Previsao"
            then do:
                for each tt-pedid:
                    delete tt-pedid.
                end.    
                for each btt-pedid:
                    find first pedid where 
                               pedid.pedtdc = 1 and
                               pedid.etbcod = 999 and
                               pedid.pednum = btt-pedid.comcod
                               no-lock no-error.
                    if avail pedid  and
                        pedid.peddti > today
                    then do:
                        create tt-pedid.
                        buffer-copy btt-pedid to tt-pedid.
                    end.    
                    else.
                end.
                hide frame f-dat no-pause.
                recatu1 = ?.
                next bl-princ.  
            end.
          end.
          view frame frame-a.
          view frame fest1.
        end.
          if keyfunction(lastkey) = "end-error"
          then do:
            view frame frame-a.
            view frame fest1.
        end.
        find first tt-marca where
                tt-marca.pedtdc = tt-pedid.pedtdc and
                tt-marca.etbcod = tt-pedid.etbcod and
                tt-marca.pednum = tt-pedid.pednum  
                no-error.
        if avail tt-marca
        then vmarca = "*". else vmarca = "". 
        vfornom = "".
        find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
        find nprodu of nliped no-lock.
        find first nforne where nforne.forcod = nprodu.fabcod 
                no-lock no-error.
        vfornom = string(nprodu.fabcod,">>>>>>9") .
        if avail nforne
        then vfornom = vfornom + " " +  nforne.fornom. 
        vatraso = today - tt-pedid.peddtf.
        display vmarca  
            tt-pedid.pednum
            tt-pedid.etbcod 
            tt-pedid.peddat 
            vfornom 
            tt-pedid.comcod   when tt-pedid.comcod <> 0
            tt-pedid.peddtf 
            tt-pedid.condes when tt-pedid.condes > 0
            tt-pedid.sitped
            /*
            vatraso           when vatraso <> ?
            */
            with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-pedid).
   end.
end.

procedure env-mail:
    def var varqmail as char.
    def var c-mail as char extent 5.
    def var v-assunto as char init "REQUISICAO DE MERCADORIAS".
    def var vi as int.
    def var vqt-pecas as int.
    def var vqt-itens as int.
    def var vlipcor like liped.lipcor.
    def var valor as dec format ">>>>9,99".

    vnum-ped = "".
    for each tt-numped where tt-numped.pednum > 0:
        vnum-ped = vnum-ped + string(tt-numped.pednum) + ", " .
    end.
    c-mail[1] = forne.email.
    varqmail = "./mailped.cmp".
    if search(varqmail) <> ?
    then do:
        vi = 1.
        input from value(varqmail).
        repeat:
            vi = vi + 1.
            import c-mail[vi].
        end.
        input close.
    end.
    vi = 0.
    repeat on endkey undo:
        update c-mail[1] label "   Para"  format "x(50)"
               c-mail[2] label "     Cc"  format "x(50)"
               c-mail[3] label "       "  format "x(50)"
               c-mail[4] label "       "  format "x(50)"
               c-mail[5] label "       "  format "x(50)"
               v-assunto label "Assunto"  format "x(50)"
               with frame f-mail width 80 side-label
               title " enviar e-mail ".
               
        if c-mail[1] = "" then next.
        if v-assunto = ""  then next.
        hide frame f-mail no-pause.     
        leave.
    end.
    
    if keyfunction(lastkey) = "end-error"
    then.
    else do:
        if opsys = "UNIX"
        then varquivo = "../relat/oc-mail." + string(time) .
        else varquivo = "..\relat\oc-mail." + string(time) .
        output to value(varquivo).
            put 
                    "DREBES & CIA LTDA    <br>     " skip 
                    "REQUISICAO DE MERCADORIA <br>  " skip
                    .
 
            put "<br>" skip
                "Informamos o envio de " vqtd-ped 
                " pedidos de compra <br>" skip
                "Pedidos: " vnum-ped format "x(800)" "<br>" skip
                "Favor confirmar o recebimento de todos os pedidos. "
                .

        output close.
        do vi = 1 to 5:
            if c-mail[vi] <> ""
            then do:
                
                /* Servico Novo -  Antonio */
                varqdg = "/admcom/progr/mail.sh " 
                        + "~"" + v-assunto + "~"" + " ~"" 
                        + varquivo + "~"" + " ~"" 
                        + c-mail[vi] + "~"" 
                        + " ~"guardian@lebes.com.br~"" 
                        + " ~"text/html~"". 
                        unix silent value(varqdg).

                /*  Servico Antigo
                unix silent value("/usr/bin/metasend -b -s " 
                    + "~"" + v-assunto + "~"" 
                    + " -F guardian@lebes.com.br -f " + varquivo 
                    + " -m text/html -t " + c-mail[vi]).
                */
                
            end.
            else leave.
        end.
        for each tt-marca where tt-marca.pednum > 0 no-lock: 
            find first tt-numped where tt-numped.pedido = tt-marca.pednum
                    no-lock no-error.
            find bestab where bestab.etbcod = tt-marca.etbcod no-lock.

            find pedid where pedid.pedtdc = tt-marca.pedtdc and
                             pedid.etbcod = tt-marca.etbcod and
                             pedid.pednum = tt-marca.pednum
                             no-lock no-error.
            find bpedid where bpedid.pedtdc = 1 and
                             bpedid.etbcod = 999 and
                             bpedid.pednum = tt-numped.pednum
                             no-lock no-error.
            if avail bpedid
            then do:
                
                if opsys = "UNIX"
                then varquivo = "../relat/oc-" + string(bpedid.pednum) + ".txt".
                else varquivo = "..\relat\oc-" + string(bpedid.pednum) + ".txt".

                output to value(varquivo).
 
                put 
                    "DREBES & CIA LTDA         " skip 
                    "REQUISICAO DE MERCADORIA   " skip
                    .
                
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.pednum = pedid.pednum
                                        no-lock.
                find produ of liped no-lock.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
                put fabri.fabfant "" skip.
                put fill("_",80) format "x(100)".
                
                for each bliped where bliped.pedtdc = bpedid.pedtdc and
                                      bliped.etbcod = bpedid.etbcod and
                                      bliped.pednum = bpedid.pednum 
                                      no-lock:
                    find estoq where estoq.etbcod = pedid.etbcod and
                                     estoq.procod = bliped.procod no-lock.
                    find produ of bliped no-lock.
                    find liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum and
                                     liped.procod = bliped.procod
                                     no-lock no-error.
                    if avail liped
                    then vlipcor = liped.lipcor.
                    else vlipcor = "".    
                    disp produ.procod   column-label "Codigo" format ">>>>>>9"
                         produ.pronom   column-label "Produto" format "x(38)"
                         vlipcor        column-label "Cor"  format "x(15)"
                         bliped.lipqtd  column-label "Quant."  format ">>>9"
                         estoq.estvenda column-label "Preco"  
                                            format ">>>,>>9.99"
                         with frame f-disp1 down width 100.
                    down with frame f-disp1.     
                end.
                
                find first func where func.etbcod = pedid.etbcod and
                                func.funcod = pedid.vencod no-lock no-error.
                put fill("_",80) format "x(80)" skip
                    "PEDIDO: " tt-numped.pedido   "" skip
                    "ORDEM DE COMPRA: " tt-numped.pednum format ">>>>>>>9"    
                                     "" skip 
                    "NF: " tt-numped.frecod
                    "     DATA VENDA: " tt-numped.condat format "99/99/9999"
                    "" skip.
                if pedid.vencod <> 0 and avail func
                then put "NOME: " func.funnom "" skip.
                else put "NOME:.................................. "  skip.
                put "DATA: " today format "99/99/9999"
                    "     FILIAL: "  bestab.etbnom  "" skip.
                output close.

                if opsys = "UNIX"
                then varquivo = "../relat/oc-" + string(bpedid.pednum) + ".htm".
                else varquivo = "..\relat\oc-" + string(bpedid.pednum) + ".htm".

                output to value(varquivo).
 
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.pednum = pedid.pednum
                                        no-lock.
                find produ of liped no-lock.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
 
                put unformatted
                    "<b>DE  :</b> DREBES & CIA LTDA        <BR> " skip 
                    "<b>PARA:</b> " caps(fabri.fabfant) format "x(40)" 
                    "<BR>" skip
                    "<BR><b>COMPRA:</b> " bpedid.pednum  skip
                        "<b>DATA:</b> " bpedid.peddat "<BR>"  skip
                    .
                
                PUT unformatted
                "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
                "          summary=~"DREBES & CIA LTDA~">" skip
                "<CAPTION><b>" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"left~">" skip
                "<COLGROUP align=~"left~">" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"left~">"  skip
                "<THEAD valign=~"top~">" skip
                "<TR>" skip
                "<TH><b>Codigo<BR>" skip
                "<TH><b>Produto<BR>" skip
                "<TH><b>Cor<BR>" skip
                "<TH><b>Quant<BR>" skip
                "<TH><b>Preço<BR>" skip
                "<TBODY>" skip
                .
                
                for each bliped where bliped.pedtdc = bpedid.pedtdc and
                                      bliped.etbcod = bpedid.etbcod and
                                      bliped.pednum = bpedid.pednum 
                                      no-lock:
                    find estoq where estoq.etbcod = pedid.etbcod and
                                     estoq.procod = bliped.procod no-lock.
                    find produ of bliped no-lock.
                    find liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum and
                                     liped.procod = bliped.procod
                                     no-lock no-error.
                    if avail liped
                    then vlipcor = liped.lipcor.
                    else vlipcor = "".
                    put unformatted
                        "<TR><TD>" produ.procod  
                        "<TD>" produ.pronom  format "x(40)"
                        "<TD>" vlipcor
                        "<TD>" bliped.lipqtd
                        "<TD>" string(estoq.estvenda,">>>,>>9.99") 
                        "</TR>"
                        skip.
 
                end.
                put "</TABLE>" skip.
                find first func where func.etbcod = pedid.etbcod and
                                func.funcod = pedid.vencod no-lock no-error.
                put "<BR>" skip
                    "<b>FILIAL:</b> " bestab.etbcod    "<BR>" skip
                    "<b>PEDIDO:</b> " tt-numped.pedido format ">>>>>>>9"
                     "<BR>" skip   
                    "<b>VENDA:</b> " tt-numped.frecod   
                        format ">>>>>>>9"              "<BR>" skip
                    "<b>DATA :</b> " tt-numped.condat 
                        format "99/99/9999"            "<BR>" skip
                    "<b>VENDEDOR:</b> " .       
                if pedid.vencod <> 0 and avail func
                then put func.funnom .
                else put ".................................. ".
                put "<BR>"  skip.
                output close.
 
                pause 2 no-message.
                do vi = 1 to 5:
                    if c-mail[vi] <> ""
                    then do:
                       
                          /* antonio Novo Servico */
            
                        varqdg = "/admcom/progr/mail.sh " 
                        + "~"" + v-assunto + "~"" + " ~"" 
                        + varquivo + "~"" + " ~"" 
                        + c-mail[vi] + "~"" 
                        + " ~"guardian@lebes.com.br~"" 
                        + " ~"text/html~"". 
                        unix silent value(varqdg).

                        
                        /* Servico antigo
                        unix silent value("/usr/bin/metasend -b -s " 
                            + "~"" + v-assunto + " " 
                            + string(bpedid.pednum) + "~"" 
                            + " -F guardian@lebes.com.br -f " + varquivo 
                            + " -m text/html -t " + c-mail[vi]).
                        */
                        
                        /*
                        unix silent value("/admcom/progr/mail.sh " 
                             + "REQUISICAO_DE_MERCADORIA_"  
                             + string(bpedid.pednum) + " " 
                             + varquivo + " " 
                             + c-mail[vi] + " > /tmp/mail.sh_oc.log 2>&1").
                        */
                    end.
                    else leave.
                end.
            end.                 
        end.
        output to value(varqmail).
        do vi = 2 to 5:
            if c-mail[vi] <> ""
            then export c-mail[vi].
        end.
        output close.
    end.
end procedure. 
                             
