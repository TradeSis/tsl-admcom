{admcab.i}
def buffer nliped for liped.
def buffer nprodu for produ.
def buffer nforne for forne.
def var vfornom like forne.fornom. 
def temp-table tt-numped
    field pednum like pedid.pednum
    field etbcod like estab.etbcod
    field pedido like pedid.pednum
    field frecod like pedid.frecod
    field condat like pedid.condat
    .
def var vqtd-ped as int.
def var vcomcod as int initial 6.
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
def var esqcom1         as char format "x(15)" extent 4
            initial ["Marca/Desmarca","Gera Compra","Consulta","Imprime"].
def var esqcom2         as char format "x(15)" extent 4
            initial ["Inclusao","Alteracao","Cancela",""].
/*esqcom2[1] = "".
esqcom2[2] = "".
*/
def input parameter p-tdc as int.

def var par-pedtdc as int initial 6.


if p-tdc > 0
then par-pedtdc = p-tdc.

def buffer bpedid            for pedid.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.
def var vclien    as char.
def var vendedor  as char.

form esqcom1 with frame f-com1 centered
                 row 6 no-box no-labels side-labels column 1.
form esqcom2 with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def buffer bestab for estab.
def var vclicod like clien.clicod.

form vetbcod label "Filial"    at 5                            
     bestab.etbnom no-label                                 
     vforcod like forne.forcod label "Fornecedor"  at 1    
     forne.fornom no-label                                
     /*vclicod like clien.clicod label "Cliente" at 4        
     clien.clblinom no-label*/                                
     with frame fest centered color white/cyan             
     side-labels width 80 row 3.                          
                       
update vetbcod with frame fest.                            
if vetbcod > 0                                             
then do:                                                   
    find bestab where bestab.etbcod = vetbcod no-lock.       
    disp bestab.etbnom no-label with frame fest.            
end.                                                       
update vforcod /*validate(vforcod > 0,"Informe o Fabricante")*/ with frame fest.
if vforcod > 0
then do:
find forne where forne.forcod = vforcod no-lock.
disp forne.fornom with frame fest.
end.
if vforcod > 0 
then.
else assign
        esqcom1[1] = ""
        esqcom1[2] = "".

hide frame fest no-pause.

disp vetbcod label "Filial"    at 5                            
     bestab.etbnom no-label when avail bestab                                
     vforcod label "Fornecedor"  at 1    
     forne.forcod no-label  when avail forne   
     "" at 1                           
     with frame fest1 color white/cyan             
     side-labels width 80 row 3 no-box.      


def temp-table tt-pedid like pedid
    index i1 comcod descending peddat.
def temp-table tt-marca like tt-pedid.
def var vcan as log format "Sim/Nao" init no.
if vetbcod > 0
then do:
message "Mostra Cancelados ?" update vcan.  
end.
  
for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true)
            no-lock:
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = par-pedtdc and
                         /*pedid.sitped = "A" and*/
                         pedid.peddat <= today
                         no-lock:
        if pedid.sitped <> "A"
        then do:
            if pedid.sitped = "C" and
               vcan
            then.
            else next.   
        end.
        for each liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum and
                             liped.lipsit = "A"  and
                             liped.procod = 0
                             :
            delete liped.
        end.                     
        for each liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum and
                             liped.lipsit = "A"
                             no-lock.
            find produ where produ.procod = liped.procod no-lock no-error.
            if not avail produ
            then next.
            find forne where forne.forcod = produ.fabcod no-lock.    
            if vforcod > 0 and forne.forcod <> vforcod
            then next.
            create tt-pedid.
            buffer-copy pedid to tt-pedid.
            leave.
        end.        
    end.                     
end.

for each tt-marca: delete tt-marca. end.
def var vmarca as char.

bl-princ:
repeat:

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
        message "Cadastro de pedidos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 9 1 column centered
            color black/cyan.
               hide frame f-com1 no-pause.
               hide frame f-com2 no-pause.
               run pedesp03.p ( input bestab.etbcod,
                               input  vpedtdc,
                               input vforcod,
                               output vrecped).
        end.
        message color red/with
        "Nenum registro encontrado."
        view-as alert-box.
        return.
    end.
    clear frame frame-a all no-pause.
    find first tt-marca where
                tt-marca.pedtdc = tt-pedid.pedtdc and
                tt-marca.etbcod = tt-pedid.etbcod and
                tt-marca.pednum = tt-pedid.pednum  
                no-error.
    if avail tt-marca
        then vmarca = "*". else vmarca = "".
    
    find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
    find nprodu of nliped no-lock no-error.
    
    find first nforne where nforne.forcod = nprodu.fabcod no-lock.                 vfornom = string(nforne.forcod,">>>>>>9") + " " +  nforne.fornom. 
           
    display vmarca  no-label format "x"
            tt-pedid.pednum  format ">>>>>>>9"
            tt-pedid.etbcod column-label "Fil"
            tt-pedid.peddat
            tt-pedid.sitped column-label "Sit"
            vfornom column-label "Fornecedor"
            tt-pedid.comcod column-label "Ordem" format ">>>>>9"
            tt-pedid.condes when tt-pedid.condes > 0
            column-label "Ent" format ">>9"
            with frame frame-a 10 down centered color white/red
            row 7 overlay.

    recatu1 = recid(tt-pedid).
    if esqregua
    then
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find prev tt-pedid no-error.
        if not available tt-pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find first tt-marca where
                tt-marca.pedtdc = tt-pedid.pedtdc and
                tt-marca.etbcod = tt-pedid.etbcod and
                tt-marca.pednum = tt-pedid.pednum  
                no-error.
        if avail tt-marca
        then vmarca = "*". else vmarca = "".    
        find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
        find nprodu of nliped no-lock.
        find first nforne where nforne.forcod = nprodu.fabcod no-lock.
        vfornom = string(nforne.forcod,">>>>>>9") + " " +  nforne.fornom. 
     
        display vmarca
                tt-pedid.pednum
                tt-pedid.etbcod
                tt-pedid.peddat
                tt-pedid.sitped
                vfornom
                tt-pedid.comcod
                tt-pedid.condes
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-pedid where recid(tt-pedid) = recatu1 .

        on f7 recall.
        choose field tt-pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red tt-pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for tt-pedid.pednum.
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
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color  display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev tt-pedid no-error.
            if not avail tt-pedid
            then next.
            color display white/red
                tt-pedid.pednum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next tt-pedid no-error.
            if not avail tt-pedid
            then next.
            color display white/red
                tt-pedid.pednum.
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
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Marca/Desmarca"
            then do with frame f-inclui overlay row 9 1 column centered
                color black/cyan.
                if tt-pedid.comcod <> 0
                then do:
                    bell.
                    message color red/with
                    "Compra ja emitida para pedido."
                    view-as alert-box.
                end.
                else do:
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
                recatu1 = recid(tt-pedid).
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
                disp tt-pedid.pednum at 1 label "  Pedido  "
                                format ">>>>>>>9"
                     vendedor at 1 label "  Vendedor"  format "x(40)"
                     vclien   at 1 label "  Cliente "  format "x(40)"
                     tt-pedid.frecod at 1 label "  Numero Venda"
                        format ">>>>>>>>9"
                     tt-pedid.condat      label "Data Venda"
                     tt-pedid.condes label "Filial Entrega" format ">>9"
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
                    disp liped.procod
                         produ.pronom format "x(30)"
                         liped.lipcor
                         liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         liped.lipent column-label "Qtd.Ent" format ">>>9"
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
                    &Nom-Rel   = ""pedsol"" 
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
                then put " FILIAL ENTREGA: " AT 40 pedid.condes skip(1).
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
            
            if esqcom1[esqpos1] = "Gera Compra"
            then do:
                if opsys <> "UNIX"
                then do:
                    message color red/with
                    "Opcao disponivel somente em terminal LINUX"
                    view-as alert-box.
                    leave.
                end.
                find first tt-marca where 
                            tt-marca.pedtdc = par-pedtdc no-error.
                if not avail tt-marca
                then do:
                    message color red/with
                    "Marcar pedido antes de gerar compra."
                    view-as alert-box.      
                    leave.          
                end.            

                update vcomcod label "Comprador" with frame f1.
                do:
                    find compr where compr.comcod = vcomcod no-lock no-error.
                    if not avail compr then do:
                        message "Comprador nao cadastrado ". pause.
                        leave.
                        
                end.
                display compr.comnom no-label with frame fest.

                end.
                


                
                message "Confirma gerar pedidos de compra? " update sresp.
                if not sresp
                then undo, leave.
                vqtd-ped = 0.
                vnum-ped = "".
                for each tt-marca where tt-marca.pedtdc = par-pedtdc    
                        :
                    vpedtot = 0.
                    vrepcod = 0.
                    for each liped where 
                             liped.pedtdc = tt-marca.pedtdc and
                             liped.etbcod = tt-marca.etbcod and
                             liped.pednum = tt-marca.pednum
                             no-lock:
                                    
                        find produ where produ.procod = liped.procod no-lock.
                        find forne where forne.forcod = produ.fabcod no-lock.
                        find repre where repre.repcod = forne.repcod no-lock 
                                no-error. 
                        if avail repre 
                        then vrepcod = repre.repcod.
                        else vrepcod = 0.

                        vpedtot = vpedtot + (liped.lippre * liped.lipqtd).
                    end.
                    
                    find last cpedid use-index ped
                                 where cpedid.etbcod = 999 and
                                       cpedid.pedtdc = 1  no-error.
                    if avail cpedid
                    then vpednum = cpedid.pednum + 1.
                    else vpednum = 1.
                    do transaction:
                    find pedid where pedid.pedtdc = tt-marca.pedtdc and
                                     pedid.etbcod = tt-marca.etbcod and
                                     pedid.pednum = tt-marca.pednum
                                     .
                    create bpedid.
                    assign bpedid.pedtdc    = 1
                           bpedid.pednum    = vpednum
                           bpedid.clfcod    = forne.forcod
                           bpedid.regcod    = 999
                           bpedid.peddat    = today 
                           bpedid.pedsit    = yes 
                           bpedid.sitped    = "A" 
                           bpedid.etbcod    = 999 
                           bpedid.condat   = today
                           bpedid.peddti   = today + 10
                           bpedid.peddtf   = today + 15
                           bpedid.crecod   = 60
                           bpedid.comcod   = 6
                           bpedid.fobcif   = no
                           bpedid.modcod   = "PED" 
                           bpedid.vencod   = vrepcod
                           bpedid.pedtot   = vpedtot
                           bpedid.comcod   = vcomcod
                           bpedid.pedobs[1] = ""
                           bpedid.pedobs[2] = ""
                           bpedid.pedobs[3] = ""
                           bpedid.pedobs[4] = ""
                           bpedid.pedobs[5] = ""
                           bpedid.pedobs[1] = "Pedido=" + 
                                        string(tt-marca.pednum) 
                                        +  "|Filial origem=" + 
                                        string(tt-marca.etbcod,">>9").
                        if tt-marca.condes > 0
                        then bpedid.pedobs[1] = bpedid.pedobs[1] +
                            "|Filial destino=" + string(tt-marca.condes,">>9").
                        else bpedid.pedobs[1] = bpedid.pedobs[1] +
                            "|Filial destino=" + string(tt-marca.etbcod,">>9").
                            
                        pedid.comcod = vpednum.
                        tt-marca.comcod = vpednum.
                    pedid.sitped = "P".
                    pedid.pedsit = yes.
                    end.
                    for each liped where 
                             liped.pedtdc = tt-marca.pedtdc and
                             liped.etbcod = tt-marca.etbcod and
                             liped.pednum = tt-marca.pednum
                             :
                        find produ of liped no-lock.
                        find forne where forne.forcod = produ.fabcod no-lock.
                        find bliped where bliped.etbcod = 999           and
                                          bliped.pedtdc = 1            and
                                          bliped.pednum = vpednum      and
                                          bliped.procod = liped.procod and
                                          bliped.lipcor = ""           and
                                          bliped.predt  = today no-error.
                        if not avail bliped
                        then do transaction:
                            create bliped.
                            assign bliped.pednum = vpednum
                                   bliped.pedtdc = 1
                                   bliped.predt  = today
                                   bliped.predtf = bpedid.peddtf 
                                   bliped.etbcod = 999
                                   bliped.procod = liped.procod 
                                   bliped.lippreco = liped.lippre 
                                   bliped.lipqtd = liped.lipqtd 
                                   bliped.lipsit = "A" 
                                   bliped.protip = "M".
                            
                            find estoq where estoq.etbcod = tt-marca.etbcod and
                                             estoq.procod = liped.procod
                                                    no-lock no-error.
                            if avail estoq
                            then bliped.lippreco = estoq.estcusto.
                                                    
                        
                        end.
                        do transaction:
                            liped.lipsit = "P".         
                        end.
                    end.
                    find first liped where 
                             liped.pedtdc = tt-marca.pedtdc and
                             liped.etbcod = tt-marca.etbcod and
                             liped.pednum = tt-marca.pednum and
                             liped.lipsit = "A" 
                             no-lock no-error.
                    if avail liped
                    then do transaction:
                        pedid.sitped = "A".
                    end. 
                    vqtd-ped = vqtd-ped + 1.
                    create tt-numped.
                    assign
                        tt-numped.pednum = bpedid.pednum
                        tt-numped.etbcod = tt-marca.etbcod
                        tt-numped.pedido = tt-marca.pednum
                        tt-numped.frecod = tt-marca.frecod
                        tt-numped.condat = tt-marca.condat
                        .
                end.
                sresp = no.
                message "Confirma enviar e-mail ?" update sresp.
                if sresp
                then do:
                    run env-mail.   
                end.
                leave bl-princ.
            end.
           end.
          else do:
            if esqcom2[esqpos2] = "Inclusao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedesp03.p ( input bestab.etbcod,
                                input  vpedtdc,
                                input  vforcod,
                                output vrecped ).
                if vrecped <> ?
                then do:
                    find pedid where recid(pedid) = vrecped no-lock.
                    create tt-pedid.
                    buffer-copy pedid to tt-pedid.
                    recatu1 = recid(tt-pedid).
                end.
                leave.
            end.
            if esqcom2[esqpos2] = "Alteracao"
            then do:
                find first pedid where pedid.pedtdc = tt-pedid.pedtdc and
                                       pedid.etbcod = tt-pedid.etbcod and
                                       pedid.pednum = tt-pedid.pednum
                                       no-lock.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedesp04.p ( recid(pedid),  
                                output vrecped ).
                if vrecped <> ?
                then do:
                    find pedid where recid(pedid) = vrecped no-lock.
                    find first tt-pedid where
                        recid(tt-pedid) = recatu1 no-error.
                    if avail tt-pedid
                    then  buffer-copy pedid to tt-pedid.
                    recatu1 = recid(tt-pedid).
                end.
 
                leave.
            end.
            if esqcom2[esqpos2] = "Cancela"
            then do:
                find first pedid where pedid.pedtdc = tt-pedid.pedtdc and
                                       pedid.etbcod = tt-pedid.etbcod and
                                       pedid.pednum = tt-pedid.pednum
                                       .
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                do transaction:
                
                pedid.pedobs[3] = pedid.pedobs[3]
                               + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                               + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                               + "|ETB_EXCLUSAO="  + string(setbcod)
                               + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                               + "|PROG_EXCLUSAO=" + program-name(1)
                               + "|".
                    
 
                pedid.sitped = "C".
                tt-pedid.sitped = "C".
                end.
                leave.
            end.
            /*******
            if  esqcom2[esqpos2] = "Duplicacao"
            then do:
                /**
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run peddup.p (input recatu1).
                disp esqcom1 with frame f-com1.
                */
            end.
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            ******/
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
        find first nliped where 
               nliped.etbcod = tt-pedid.etbcod and
               nliped.pednum = tt-pedid.pednum and
               nliped.pedtdc = tt-pedid.pedtdc
               no-lock no-error.
        find nprodu of nliped no-lock.
        find first nforne where nforne.forcod = nprodu.fabcod no-lock.
        vfornom = string(nforne.forcod,">>>>>>9") + " " +  nforne.fornom. 
                    
        display vmarca
                tt-pedid.pednum
                tt-pedid.etbcod
                tt-pedid.peddat
                tt-pedid.sitped
                vfornom
                tt-pedid.comcod 
                tt-pedid.condes
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
        vqtd-ped = 0.
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
                vqtd-ped = vqtd-ped + 1.
            end.
        end.        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/oc-mail." + string(time) .
        else varquivo = "..\relat\oc-mail." + string(time) .
        output to value(varquivo).
            put 
                    "DREBES & CIA LTDA    <br>     " skip 
                    "REQUISICAO DE MERCADORIA <br>  " skip
                    .
 
            put "<br>" skip
                "Informamos o envio de " vqtd-ped 
                " pedidos de compra <br>" skip
                "Pedidos: " vnum-ped format "x(800)" 
                "<br>" skip
                "Favor confirmar o recebimento de todos os pedidos. "
                .

        output close.
        do vi = 1 to 5:
            if c-mail[vi] <> ""
            then do:
                /**
                unix silent value("/usr/bin/metasend -b -s " 
                    + "~"" + v-assunto + "~"" 
                    + " -F guardian@lebes.com.br -f " + varquivo 
                    + " -m text/html -t " + c-mail[vi]).
                **/
                unix silent value("/admcom/progr/mail.sh "
                                 + "~"" + v-assunto + "~"" + " ~"" 
                                 + varquivo + "~"" + " ~"" 
                                 + c-mail[vi] + "~""
                                 + " ~"pedidosespeciais@lebes.com.br~""
                                 + " ~"text/html~"").
                    
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
                
                put "Observacao: " pedid.pedobs[1] format "x(60)" skip
                     pedid.pedobs[2] at 10 format "x(60)" skip
                     pedid.pedobs[2] at 10 format "x(60)" skip
                     pedid.pedobs[2] at 10 format "x(60)" skip
                     .
                    
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
                    "<b>FILIAL ORIGEM:</b> " bestab.etbcod    "<BR>" skip
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
                put "<b>FILIAL DESTINO:</b> " .
                if pedid.condes > 0
                then put string(pedid.condes,">>9").
                else put string(bestab.etbcod,">>9").
                put "<BR>" skip.

                put "<b>OBS:</b> " pedid.pedobs[1] format "x(60)" "<BR>" skip
                                   pedid.pedobs[2] format "x(60)" "<BR>" skip
                                   pedid.pedobs[3] format "x(60)" "<BR>" skip
                                   pedid.pedobs[4] format "x(60)" "<BR>" skip
                                   .
                output close.
 
                pause 2 no-message.
                do vi = 1 to 5:
                    if c-mail[vi] <> ""
                    then do:
                       
                       unix silent value("/admcom/progr/mail.sh "
                                 + "~"" + v-assunto + "~"" + " ~"" 
                                 + varquivo + "~"" + " ~"" 
                                 + c-mail[vi] + "~""
                                 + " ~"pedidosespeciais@lebes.com.br~""
                                 + " ~"text/html~"").
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

