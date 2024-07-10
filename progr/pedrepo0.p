/*  pedrepo0.p              */
/* Programa desativado em 14/08/2014.           */
/* solicitado pelo Felipe Trojack                       */
{admcab.i}

message "Programa desativado em 14/08/2014." 
        view-as alert-box.
do on error undo.        
    leave.        
end.

def var setbcod-ant  like setbcod.
def buffer nliped for liped.
def buffer nprodu for produ.
def buffer nforne for forne.
def buffer bpedid for pedid.
def buffer cpedid for pedid.
def buffer bliped for liped.
def buffer cliped for liped.
def var vfornom like forne.fornom. 
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
def var varquivo as char.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(20)" extent 3
            initial ["  Informa Quantidade","    Gera Pedido",""].
def var esqcom2         as char format "x(15)" extent 4
            initial ["","","",""].

def var p-tdc as int init 7.

def var par-pedtdc as int initial 7.


if p-tdc > 0
then par-pedtdc = p-tdc.

def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.
def var vclien    as char.
def var vendedor  as char.

form esqcom1 with frame f-com1 centered
                 row 5 no-box no-labels side-labels column 1.
form esqcom2 with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

def buffer bestab for estab.
def buffer bestoq for estoq.
def buffer bfestoq for estoq.
def var vclicod like clien.clicod.

vetbcod = setbcod.
disp vetbcod with frame f1.
if vetbcod >= 900 OR
 {conv_igual.i vetbcod}
then
update vetbcod label "Filial"
        with frame f1 1 down
                width 80 color message side-label no-box.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
else return.
def var vestatual like estoq.estatual.
def temp-table tt-liped like liped
    index i1 predt descending . 
def var reserva as dec.
setbcod-ant = setbcod.
setbcod = vetbcod.
for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true)
            no-lock:
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = par-pedtdc and
                         pedid.sitped = "A" and
                         pedid.peddat <= today
                         no-lock:
        for each bliped where bliped.pedtdc = pedid.pedtdc and
                             bliped.etbcod = pedid.etbcod and
                             bliped.pednum = pedid.pednum and
                             bliped.lipsit = "A"
                             :
            find produ where produ.procod = bliped.procod no-lock no-error.
            if not avail produ then next.
            {tbcntgen6.i today}            
            if avail tbcntgen
            then do:
                delete bliped.
                next.
            end.
            sresp = no.
            /**/
            run tem-mix.p(input produ.procod,
                        output sresp).
            if sresp = no
            then do:
                delete bliped.       
                next.
            end.
            /**/
            
            find bfestoq where bfestoq.etbcod = 900
                           and bfestoq.procod = produ.procod
                                no-lock no-error.
            
            find estoq where estoq.etbcod = 993 and
                     estoq.procod = produ.procod
                     no-lock.
                     
            vestatual = 0.
            run estoque-reserva.
            vestatual = estoq.estatual - reserva.
            
            if avail bfestoq
            then vestatual = vestatual + bfestoq.estatual.
            
            if vestatual <= 0
            then do:
                delete bliped.
            end.    
            else do:
                create tt-liped.
                buffer-copy bliped to tt-liped.
            end.
        end.        
    end.                     
end.

setbcod = setbcod-ant.
def var est-atual as dec.
def var vmarca as char.

status default " [R] = Produto de reposicao   [N] = Produto novo ".

bl-princ:
repeat:

    vpedtdc = integer(par-pedtdc).
    disp esqcom1 with frame f-com1.
    pause 0.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find last tt-liped no-error.
    else
        find tt-liped where recid(tt-liped) = recatu1.
    if not available tt-liped
    then do:
        message color red/with
        "Nenum registro encontrado."
        view-as alert-box.
        return.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = tt-liped.procod no-lock.   
    
    find bfestoq where bfestoq.etbcod = 900
                   and bfestoq.procod = produ.procod
                                no-lock no-error.
    
    find estoq where estoq.etbcod = 993 and
                     estoq.procod = produ.procod
                     no-lock.
    assign
        reserva = 0 est-atual = 0.
    run estoque-reserva.
    est-atual = estoq.estatual - reserva.
    
    if avail bfestoq
    then est-atual = est-atual + bfestoq.estatual.
    
    if est-atual < 0
    then est-atual = 0.     
    find first bestoq where bestoq.etbcod = vetbcod and
                      bestoq.procod = tt-liped.procod
                      no-lock no-error.
    display tt-liped.procod    format ">>>>>>9"
            produ.pronom format "x(33)"
            tt-liped.lipqtd   column-label "Qtd!Pede" format ">>9"
            estoq.estvenda    column-label "Pr.Venda" format ">>,>>9.99"
            est-atual         column-label "Est!Dep" format "->>>9" 
            bestoq.estatual when avail bestoq
              column-label "Est!Loja"     format "->>9"
            tt-liped.predt    column-label "Data" format "99/99/99"
            tt-liped.protip   column-label "T" format "x"
            with frame frame-a 11 down width 80 color white/red
            row 6  overlay.
    pause 0.
    recatu1 = recid(tt-liped).
    if esqregua
    then
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    pause 0.
    repeat:
        find prev tt-liped no-error.
        if not available tt-liped
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find produ where produ.procod = tt-liped.procod no-lock.
        
        find bfestoq where bfestoq.etbcod = 900
                       and bfestoq.procod = produ.procod
                              no-lock no-error.
        
        find estoq where estoq.etbcod = 993 and
                     estoq.procod = produ.procod
                     no-lock.
        assign
        reserva = 0 est-atual = 0.
        run estoque-reserva.
        est-atual = estoq.estatual - reserva.
        
        if avail bfestoq
        then est-atual = est-atual + bfestoq.estatual.
        
        if est-atual < 0
        then est-atual = 0.   
        find first bestoq where bestoq.etbcod = vetbcod and
                          bestoq.procod = tt-liped.procod
                          no-lock no-error.
        display tt-liped.procod
                produ.pronom
                tt-liped.lipqtd
                estoq.estvenda
                tt-liped.predt
                est-atual
                bestoq.estatual when avail bestoq
                tt-liped.predt
                tt-liped.protip
                with frame frame-a.
        pause 0.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    view frame frame-a.
    repeat with frame frame-a:
        find  tt-liped where recid(tt-liped) = recatu1 .
        run fab-cla.
        choose field tt-liped.procod
            help " [R] = Produto de reposicao   [N] = Produto novo "
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down F7 PF7
                  tab PF4 F4 ESC return).
        
        color display white/red tt-liped.procod.
        
        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            recatu1 = recid(tt-liped).
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
            find prev tt-liped no-error.
            if not avail tt-liped
            then next.
            color display white/red
                tt-liped.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next tt-liped no-error.
            if not avail tt-liped
            then next.
            color display white/red
                tt-liped.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-liped no-error.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-liped no-error.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            find first tt-liped where
                      tt-liped.lipqtd <> ? no-error.
            if avail tt-liped
            then do:
                sresp = no.
                message 
                "Quantidades foram alteradas. Deseja realmente sair? "
                update sresp.
                if not sresp
                then next bl-princ.
                message 
                "Excluir quantidades = 0 ?" update sresp.
                if sresp
                then do:
                    for each tt-liped where 
                             tt-liped.lipqtd = 0:
                        find liped where liped.pedtdc = tt-liped.pedtdc and
                             liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.procod = tt-liped.procod and
                             liped.predt  = tt-liped.predt and
                             liped.lipsit = "A"
                             no-error.
                        if avail liped
                        then do transaction:
                            delete liped.
                        end.
                        delete tt-liped.
                    end.
                end.
            end.          
                      
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "  Informa Quantidade"
            then do:
                do on error undo, retry:
                    update tt-liped.lipqtd with frame frame-a.
                    if tt-liped.lipqtd > 3
                    then do:
                        find first tbcntgen where
                                   tbcntgen.tipcon = 5 and
                                   tbcntgen.etbcod = 0 and
                                   tbcntgen.numfim = string(produ.procod)
                                   no-lock no-error.
                        if avail tbcntgen and tbcntgen.valor > 0
                            and tt-liped.lipqtd = tbcntgen.quantidade
                            and int(substr(string(tt-liped.lipqtd /
                                tbcntgen.quantidade,">>>>>9.99"),8,2)) = 0
                        then.
                        else do:    
                            message  color red/with
                                "Quantidade maxima permitida" skip
                                "3 por produto."
                                view-as alert-box.
                            tt-liped.lipqtd = ?.
                            undo, retry.
                        end.
                    end.
                end.        
                /*if tt-liped.lipqtd = 0
                then do:
                    find liped where liped.pedtdc = tt-liped.pedtdc and
                             liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.procod = tt-liped.procod and
                             liped.predt  = tt-liped.predt and
                             liped.lipsit = "A"
                             no-error.
                    if avail liped
                    then do transaction:
                        delete liped.
                    end.
                    delete tt-liped.
                    recatu1 = ?.   
                    next.           
                end.*/
                if tt-liped.lipqtd >= 0
                then do:
                    recatu1 = recid(tt-liped).
                end.
                leave.
            end.
            if esqcom1[esqpos1] = "    Gera Pedido"
            then do:
                find first tt-liped where 
                           tt-liped.lipqtd <> ?  and
                           tt-liped.lipqtd <> 0
                           no-error.
                if not avail tt-liped
                then do:
                    recatu1 = ?.
                    leave.            
                end.
                sresp = no.
                message "Confirma Gerar Pedido? " update sresp.
                if sresp
                then do transaction:
                    find last bpedid where
                              bpedid.pedtdc = 3 and
                              bpedid.etbcod = setbcod  and
                              bpedid.pednum < 100000
                              no-error.
                    if avail bpedid
                    then vpednum = bpedid.pednum + 1.
                    else vpednum = 1.
                    find bestab where bestab.etbcod = setbcod no-lock.
                    create cpedid.
                    assign
                        cpedid.etbcod = bestab.etbcod
                        cpedid.pedtdc = 3
                        cpedid.peddat = today
                        cpedid.pednum = vpednum
                        cpedid.sitped = "E"
                        cpedid.pedsit = yes
                        cpedid.regcod = bestab.regcod
                        cpedid.modcod = "PEDR".

                    for each tt-liped where tt-liped.lipqtd <> ? :
                        if tt-liped.lipqtd > 0
                        then do:
                        create cliped.
                        ASSIGN
                            cliped.pedtdc    = cpedid.pedtdc
                            cliped.pednum    = cpedid.pednum
                            cliped.procod    = tt-liped.procod
                            cliped.lippreco  = 0
                            cliped.lipsit    = "B"
                            cliped.predtf    = ?
                            cliped.predt     = cpedid.peddat
                            cliped.etbcod    = cpedid.etbcod
                            cliped.lipqtd    = tt-liped.lipqtd
                            cliped.protip    = string(time) 
                            .

                        end.
                        find liped where liped.etbcod = tt-liped.etbcod and
                                         liped.pednum = tt-liped.pednum and
                                         liped.pedtdc = tt-liped.pedtdc and
                                         liped.procod = tt-liped.procod
                                         no-error.
                        if avail liped
                        then delete liped. 
                        delete tt-liped.
                    end.
                    message color red/with
                    "Pedido gerado " cpedid.pednum 
                    view-as alert-box.     
                end.
                recatu1 = ?.
                next bl-princ.
            end.
           end.
          else do:
            if esqcom2[esqpos2] = ""
            then do:
            end.
            if esqcom2[esqpos2] = ""
            then do:
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
        find produ where produ.procod = tt-liped.procod no-lock. 
        
        find bfestoq where bfestoq.etbcod = 900
                       and bfestoq.procod = produ.procod
                               no-lock no-error.
        
        find estoq where estoq.etbcod = 993 and
                     estoq.procod = produ.procod
                     no-lock.
        assign
        reserva = 0 est-atual = 0.
        run estoque-reserva.
        est-atual = estoq.estatual - reserva.
        
        if avail bfestoq
        then est-atual = est-atual + bfestoq.estatual.
        
        if est-atual < 0
        then est-atual = 0.   
        find first bestoq where bestoq.etbcod = vetbcod and
                          bestoq.procod = tt-liped.procod
                          no-lock no-error.
        display tt-liped.procod
                produ.pronom
                tt-liped.lipqtd
                estoq.estvenda
                est-atual
                bestoq.estatual when avail bestoq
                tt-liped.predt
                tt-liped.protip
                with frame frame-a.
        pause 0.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        pause 0.
        recatu1 = recid(tt-liped).
   end.
end.

procedure estoque-reserva:
    def var vdata as date.
    if estoq.etbcod = 993
        or estoq.etbcod = 900
    then do:
        reserva = 0. 
        do vdata = today - 10 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                reserva = reserva + liped.lipqtd.
            
            end.
        end.
    end.
end procedure.
procedure fab-cla:
def buffer bprodu for produ.
find bprodu where bprodu.procod = tt-liped.procod no-lock.
find fabri where fabri.fabcod = bprodu.fabcod no-lock.
find clase where clase.clacod = bprodu.clacod no-lock.
message "Fabricante: "  fabri.fabnom "(" fabri.fabcod ")".
message "    Classe: "  clase.clanom "(" clase.clacod ")".
end procedure.

