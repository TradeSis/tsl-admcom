def var vdescricao as char.
def var icont as int.

def var vcomp-produtos as char.
def var vcomp-classes as char.
def var vcomp-fabricantes as char.

def var vncomp-produtos as char.
def var vncomp-classes as char.
def var vncomp-fabricantes as char.

def buffer tt-fabricantes for crmfabricantes.
def buffer tt-produtos    for crmprodutos.
def buffer tt-classes     for crmclasses.

/*
def shared temp-table tt-fabricantes
    field clicod as int
    field fabcod as int
    index i-prif is primary unique clicod fabcod.
def shared temp-table tt-produtos
    field clicod as int
    field procod as int
    index i-prip is primary unique clicod procod.
def shared temp-table tt-classes
    field clicod as int
    field clacod as int
    index i-pric is primary unique clicod clacod.
*/

def var vrfv as char format "x(3)".
def var vok as log.
def var vok2 as log.
def shared var vetbcod like estab.etbcod.

def var vperc as dec format ">>9.99%".

def var vrec as i format "9".
def var vfre as i format "9".
def var vval as i format "9".

def var varquivo as char.
def var vtotqtd as integer format ">>>>>>>>>>>>9".

def shared var vri as date format "99/99/9999" extent 5.
def shared var vrf as date format "99/99/9999" extent 5.

def shared var vfi as inte extent 5 format ">>>>>>>9".
def shared var vff as inte extent 5 format ">>>>>>>9".

def shared var vvi as dec format ">>>,>>9.99" extent 5.
def shared var vvf as dec format ">>>,>>9.99" extent 5.


def shared var i as i format ">>>>>>>>>>>>9".

def new shared temp-table tt-filtro
    field descricao  as char format "x(30)"
    field considerar as log  format "Sim/Nao"
    field tipo       as char
    field tecla-p    as char
    field log        as log  format "Sim/Nao"
    field data       as date format "99/99/9999" extent 2
    field dec        as dec  extent 2
    field int        as int  extent 2
    field etbcod     like estab.etbcod
    index ietbcod  etbcod.

def buffer ztt-filtro for tt-filtro. 

 
/* retirado pois vai usar tabela de banco
def shared temp-table crm
    field clicod like clien.clicod
    field nome like clien.clinom format "x(30)"
    field mes-ani     as int
    field email       as log format "Sim/Nao"
    field sexo        as log format "Masculino/Feminino"
    field est-civil   as int 
    field idade       as int
    field dep         as log format "Sim/Nao"
    field cidade      as char
    field bairro      as char 
    field celular     as log format "Sim/Nao"
    field residencia  as log format "Propria/Alugada"
    field profissao   as char
    field renda-mes   as dec
    field renda-tot   as dec
    field spc         as log format "Sim/Nao" 
    field carro       as log format "Sim/Nao"    
    field mostra      as log format "Sim/Nao"
    field valor       as dec format ">>>,>>9.99"
    field limite      as dec format ">,>>9.99"
    field recencia    as date format "99/99/9999"
    field frequencia  as int label "Freq" format ">>>9"
    field rfv         as int format "999"
    field produtos    as char
    field classes     as char
    field fabricantes as char
    index iclicod clicod.
*/

def buffer crm for ncrm.

def new shared temp-table tt-cidade
    field cidade as char
    field marca  as log format "*/ "
    index icidade is primary unique cidade.

def new shared temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    index iprocod is primary unique procod.

def new shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def new shared temp-table tt-forne
    field forcod like forne.forcod
    field fornom like forne.fornom
    index iforcod is primary unique forcod.
    
/** nao compraram **/
def new shared temp-table tt-nprodu
    field procod like produ.procod
    field pronom like produ.pronom
    index iprocod is primary unique procod.

def new shared temp-table tt-nclase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def new shared temp-table tt-nforne
    field forcod like forne.forcod
    field fornom like forne.fornom
    index iforcod is primary unique forcod.
    
/***/
 
def new shared temp-table tt-bairro
    field bairro as char
    field marca  as log format "*/ "
    index ibairro is primary unique bairro.

def new shared temp-table tt-estciv
    field estciv as int
    field descricao as char
    field marca  as log format "*/ "
    index iestciv is primary unique estciv.

def new shared temp-table tt-profissao
    field profissao as char
    field marca  as log format "*/ "
    index iprofissao is primary unique profissao.

def new shared temp-table rfvtot
    field rfv   as int format "999"
    field recencia   as char format "x(7)"
    field frequencia as char format "x(7)"
    field valor      as char format "x(7)"
    field qtd-ori   as int
    field qtd-sel   as int
    field flag  as log format "*/ "
    field per-tot   as dec format ">>9.99%"
    field etbcod  like estab.etbcod
    index irfv-asc as primary unique rfv etbcod
    index irfv-des rfv descending
    index iqtd-asc qtd-ori
    index iqtd-des qtd-ori descending
    index ietbcod etbcod
    index iflagetb flag etbcod.


def buffer b-rfvtot for rfvtot.

def var iregs           as inte   initial 0       no-undo.
def var dPctTotal       as dec format ">>9.99%"   no-undo.     

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var vordem as char extent 4  format "x(24)"
                init["1. R  F  V - Ascending  ",
                     "2. R  F  V - Descending ",
                     "3. QTD ORI - Ascending  ",
                     "4. QTD ORI - Descending "].
                     
def var vordenar as integer.

def var esc-fil as char format "x(27)" extent 3
    initial ["  Dados do Cliente         ",
             "  Cliente comprou ...      ",
             "  Cliente nao comprou ...  "].

def var esqcom1         as char format "x(15)" extent 5
    initial [" Marca "," Ordenacao "," Filtro ", " Consulta ",""].

def var esqcom2         as char format "x(14)" extent 5
            initial [" Marca Todos ",
                     " Listagem ",
                     " Gera Acao ", 
                     " Consulta Acao ",
                     " Lista Medias "].

{admcab.i}

def buffer brfvtot       for rfvtot.
def var vrfvtot         like rfvtot.rfv.
def shared var vetbcodfin  like estab.etbcod. 

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

run p-rfv-ini.

bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if vordenar = 0 
    then vordenar = 2.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        if vordenar = 1
        then find rfvtot use-index irfv-asc 
                              where recid(rfvtot) = recatu1 no-error. 
        else 
        if vordenar = 2 
        then find rfvtot use-index irfv-des 
                              where recid(rfvtot) = recatu1  no-error. 
        else 
        if vordenar = 3
        then find rfvtot use-index iqtd-asc
                              where recid(rfvtot) = recatu1  no-error.
        else                                    
        if vordenar = 4
        then find rfvtot use-index iqtd-des
                              where recid(rfvtot) = recatu1  no-error.
    end.
        
    if not available rfvtot
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(rfvtot).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available rfvtot
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
             if vordenar = 1
             then find rfvtot use-index irfv-asc 
                                   where recid(rfvtot) = recatu1
                                    no-error.
             else
             if vordenar = 2
             then find rfvtot use-index irfv-des
                                   where recid(rfvtot) = recatu1
                                    no-error.
             else
             if vordenar = 3
             then find rfvtot use-index iqtd-asc
                                   where recid(rfvtot) = recatu1
                                    no-error.
             else                                    
             if vordenar = 4
             then find rfvtot use-index iqtd-des
                                   where recid(rfvtot) = recatu1
                                    no-error.

            run p-total.
            run color-message.
            
            choose field rfvtot.flag
                         /*rfvtot.rfv*/
                         
                         rfvtot.recencia
                         rfvtot.frequencia
                         rfvtot.valor
                         
                         rfvtot.qtd-ori
                         rfvtot.per-tot /*vperc*/
                         rfvtot.qtd-sel
                         help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            run color-normal.
            
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
                    run leitura (input "down").
                    if not avail rfvtot
                    then leave.
                    recatu1 = recid(rfvtot).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail rfvtot
                    then leave.
                    recatu1 = recid(rfvtot).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail rfvtot
                then next.
                color display white/red
                              rfvtot.flag
                              /*rfvtot.rfv*/

                         rfvtot.recencia
                         rfvtot.frequencia
                         rfvtot.valor
                              
                              
                              rfvtot.qtd-ori
                              rfvtot.per-tot /*vperc*/
                              rfvtot.qtd-sel 
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail rfvtot
                then next.
                color display white/red rfvtot.flag
                                        /*rfvtot.rfv*/

                         rfvtot.recencia
                         rfvtot.frequencia
                         rfvtot.valor
                                        
                                        
                                        rfvtot.per-tot /*vperc*/
                                        rfvtot.qtd-ori
                                        rfvtot.qtd-sel with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form rfvtot
                 with frame f-rfvtot color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Ordenacao "
                then do with frame f-ordem on error undo.

                    view frame frame-a. pause 0.
                    disp  vordem[1] skip   
                          vordem[2] skip 
                          vordem[3] skip
                          vordem[4]
                          with frame f-esc title "Ordenar por" row 7
                             centered color with/black no-label overlay. 
    
                    choose field vordem auto-return with frame f-esc.
                    vordenar = frame-index.

                    clear frame f-esc no-pause.
                    hide frame f-esc no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
                end.


                if esqcom1[esqpos1] = " Marca "
                then do with frame f-marca1 on error undo.

                    find rfvtot where recid(rfvtot) = recatu1 no-error.
                    if not avail rfvtot then leave.
                    
                    if rfvtot.flag = no
                    then assign
                            rfvtot.qtd-sel = rfvtot.qtd-ori
                            rfvtot.flag = yes.
                    else assign
                            rfvtot.qtd-sel = 0
                            rfvtot.flag = no.
                    
                    find first tt-filtro /*where
                            tt-filtro.considerar = yes*/ no-error.
                    if avail tt-filtro
                    then run p-nova-rfv.

                end.
                
                
                if esqcom1[esqpos1] = " Filtro "
                then do with frame f-filtro on error undo.
                
                    find first brfvtot where 
                               brfvtot.flag = yes  no-error.
                    if not avail brfvtot
                    then do:
                        message "Para filtrar voce deve marcar algum registro".
                        recatu1 = ?.
                        leave.
                    end.
                    hide message no-pause.
                    
                    
                    view frame frame-a. pause 0.

                    disp  skip(1)
                          esc-fil[1] skip 
                          esc-fil[2] skip
                          esc-fil[3] skip(1)
                          with frame f-esc-fil title " Tipo de Filtro " row 7
                             centered color with/black no-label overlay. 
    
                    choose field esc-fil auto-return with frame f-esc-fil.
                    
                    clear frame f-esc-fil no-pause.
                    hide frame f-esc-fil no-pause.
                    
                    if frame-index = 1
                    then run p-fil (input "CLIENTE"). 
                    else 
                    if frame-index = 2
                    then run p-fil (input "PRODUTO").
                    else
                    if frame-index = 3
                    then run p-fil (input "NAOCOMP").
                    
                    recatu1 = ?.
                    leave.

                    view frame f-tot.  pause 0.
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    
                    
                end.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-cons on error undo.

                    find first brfvtot where 
                               brfvtot.flag = yes  no-error.
                    if not avail brfvtot
                    then do:
                      message "Para consultar voce deve marcar algum registro".
                      recatu1 = ?.
                      leave.
                    end.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-tot   no-pause.
                    hide message no-pause.
                    
                    run crm20-con.p.
                    
                    view frame f-tot.  pause 0.
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    
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
                
                if esqcom2[esqpos2] = " Marca Todos "
                then do:
                    for each rfvtot:
                        rfvtot.qtd-sel = rfvtot.qtd-ori.
                        rfvtot.flag = yes.
                    end.
                    
                    find first tt-filtro no-error.
                    if avail tt-filtro
                    then run p-nova-rfv.
                    
                    leave.
                end.
                
                if esqcom2[esqpos2] = " Listagem "
                then do:
                    run emite-listagem.
                    leave.
                end.
                
                if esqcom2[esqpos2] = " Gera Acao "
                then do:
                    run p-acao.
                    leave.
                end.
                
                if esqcom2[esqpos2] = " Lista Medias "
                then do:
                        run p-lista-medias.
                        leave.
                end.
                
                
                if esqcom2[esqpos2] = " Consulta Acao "
                then do:

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-tot   no-pause.
                    hide message no-pause.
                    
                    run crm20-cacao.p.
                    
                    view frame f-tot.  pause 0.
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    
                    leave.              
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
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(rfvtot).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    vperc = 0.
    vperc = ((rfvtot.qtd-ori * 100) / i).
    display rfvtot.flag    column-label "*"
            /*rfvtot.rfv   column-label "R F V"*/

            rfvtot.recencia   column-label "RECENCIA"
            rfvtot.frequencia column-label "FREQUENCIA"
            rfvtot.valor      column-label "VALOR"
            
            rfvtot.qtd-ori column-label "QTD ORI" format ">>>,>>9"
            rfvtot.per-tot /*vperc*/ column-label "%QTD ORI!/ TOTAL"
            rfvtot.qtd-sel column-label "QTD SEL" format ">>>,>>9"
            with frame frame-a col 2 11 down color white/red row 5.
            
end procedure.

procedure color-message.
    vperc = 0.
    vperc = ((rfvtot.qtd-ori * 100) / i).
    color display message
                  rfvtot.flag    column-label "*"
                  /*rfvtot.rfv column-label "R F V"*/
                         rfvtot.recencia
                         rfvtot.frequencia
                         rfvtot.valor
                  
                  
                  rfvtot.per-tot /*vperc*/
                  rfvtot.qtd-ori column-label "QTD ORI"
                  rfvtot.qtd-sel column-label "QTD SEL"
                  with frame frame-a.
end procedure.

procedure color-normal.
    vperc = 0.
    vperc = ((rfvtot.qtd-ori * 100) / i).

    color display normal
                  rfvtot.flag    column-label "*"
                  /*rfvtot.rfv column-label "R F V"*/

                         rfvtot.recencia
                         rfvtot.frequencia
                         rfvtot.valor
                  
                  
                  rfvtot.per-tot /*vperc*/
                  rfvtot.qtd-ori column-label "QTD ORI"
                  rfvtot.qtd-sel column-label "QTD SEL"
                  with frame frame-a.

end procedure.


procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
             if vordenar = 1
             then find first rfvtot use-index irfv-asc 
                                    where true  no-error.
             else
             if vordenar = 2
             then find first rfvtot use-index irfv-des
                                    where true  no-error.
             else
             if vordenar = 3
             then find first rfvtot use-index iqtd-asc
                                    where true  no-error.
             else                                    
             if vordenar = 4
             then find first rfvtot use-index iqtd-des
                                    where true  no-error.
        end.     
        else do: 
             if vordenar = 1
             then find last rfvtot use-index irfv-asc 
                                   where true  no-error.
             else
             if vordenar = 2
             then find last rfvtot use-index irfv-des
                                   where true  no-error.
             else
             if vordenar = 3
             then find last rfvtot use-index iqtd-asc
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find last rfvtot use-index iqtd-des
                                   where true  no-error.
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
             if vordenar = 1
             then find next rfvtot use-index irfv-asc 
                                   where true  no-error.
             else
             if vordenar = 2
             then find next rfvtot use-index irfv-des
                                   where true  no-error.
             else
             if vordenar = 3
             then find next rfvtot use-index iqtd-asc
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next rfvtot use-index iqtd-des
                                   where true  no-error.
        end.            
        else do: 
             if vordenar = 1
             then find prev rfvtot use-index irfv-asc 
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev rfvtot use-index irfv-des
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev rfvtot use-index iqtd-asc
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev rfvtot use-index iqtd-des
                                   where true  no-error.
  
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
             if vordenar = 1
             then find prev rfvtot use-index irfv-asc 
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev rfvtot use-index irfv-des
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev rfvtot use-index iqtd-asc
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev rfvtot use-index iqtd-des
                                   where true  no-error.

        
        end.
        else do:
             if vordenar = 1
             then find next rfvtot use-index irfv-asc 
                                   where true  no-error.
             else
             if vordenar = 2
             then find next rfvtot use-index irfv-des
                                   where true  no-error.
             else
             if vordenar = 3
             then find next rfvtot use-index iqtd-asc
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next rfvtot use-index iqtd-des
                                   where true  no-error.
        end.
    end.        
        
end procedure.
         
procedure emite-listagem:

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20" + string(time).
    else assign
            varquivo = "l:\relat\crm20" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = ""crm20""  
        &Nom-Sis   = """CRM"""  
        &Tit-Rel   = """RECENCIA, FREQUENCIA e VALOR """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

        for each rfvtot where
                 rfvtot.etbcod = if vetbcod = 0
                                 then rfvtot.etbcod 
                                 else vetbcod by rfvtot.rfv descending:

            disp rfvtot with centered.
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.        
end.
/*
procedure pi-etiqueta:

def var p-nomarq  as char form "x(8)".

def var chora    as char form "x(06)".
    
assign chora = substring(string(time,"HH:MM:SS"),1,2) +
               substring(string(time,"HH:MM:SS"),4,2) +
               substring(string(time,"HH:MM:SS"),7,2).

assign p-nomarq = "crmmal" + chora.    

for each clien where clicod >= 10010 and
                     clicod <= 10100 no-lock:

     create tt-etiqueta.
     assign tt-etiqueta.rProdu = recid(clien)
            tt-etiqueta.procod = clien.clicod
            tt-etiqueta.qtdest = 1.
end.

run etqmal1a.p (input table tt-etiqueta,
                 input p-nomarq).


end procedure.
*/

procedure p-nao-libera:

    message " Procedimento ainda nao esta liberado" view-as alert-box.

end procedure.

procedure p-lista-medias:

   def var icontar     as     inte                  init 0             no-undo.
   def var iseq        as     inte                  init 0             no-undo.
   def var iqtd-ori    as     inte                  init 0             no-undo.
   def var itotfil     as     inte form ">>>>>>>9"  init 0             no-undo.
   def var itotger     as     inte form ">>>>>>>9"  init 0             no-undo.   def var dtotfil     as     deci form ">>9.99%"   init 0             no-undo.
   def var dmedfil     as     deci form ">>9.99%"   init 0             no-undo.
   def var dmedtot     as     deci form ">>9.99%"   init 0             no-undo.
   def var dmedfai     as     deci form ">>9.99%"   init 0             no-undo.
   def var dtotger     as     deci form ">>9.99%"   init 0             no-undo.
   def var ietbcod     like estab.etbcod.
  
   def buffer bf-medias  for medias.
/* ------------------------------------------------------------------------- */

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20brw2" + string(time).
    else assign
            varquivo = "l:\relat\crm20brw2" + string(time).

    {mdadmcab.i                           
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = ""crm20rp""  
        &Nom-Sis   = """CRMRP"""  
        &Tit-Rel   = """RECENCIA, FREQUENCIA e VALOR """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put "RFV"        at 15
        "RECENCIA"   at 25
        "FREQUENCIA" at 35
        "VALOR"      at 48
        "QTDE"       at 57
        "TOTAL"      at 66
        skip.
    put fill("-",70) form "x(70)"
        skip.

    assign itotfil = 0
           dtotfil = 0
           dmedfai = 0
           dmedfil = 0
           dmedtot = 0.
   
    for each medias where
             medias.etbcod = (if vetbcod <> 0
                              then vetbcod                 
                              else medias.etbcod) no-lock 
                                                  break by medias.etbcod 
                                                  by medias.qtd-ori descending:
         
         if first-of(medias.etbcod)
         then do:
                 assign icontar = 1.
                 put "Estabelecimento: "
                     medias.etbcod
                     skip(1). 
         end.
         
         put medias.rfv                     at 15
             medias.recencia                at 25
             medias.frequencia              at 35
             medias.valor                   at 48
             medias.qtd-ori form ">>>>9"    at 56
             medias.qtd-tot                 at 64 
             skip.
         /* Zerar a cada filial */
         assign itotfil = itotfil + medias.qtd-ori
                dtotfil = dtotfil + medias.qtd-tot.
         /* Acumular para geral */
         assign itotger = itotger + medias.qtd-ori
                dtotger = dtotger + medias.qtd-tot.
         if last-of(medias.etbcod)
         then do:
                 put skip
                     "________"                 at 53
                     "________"                 at 66
                     skip
                     itotfil  form "zzzzzzz9"   at 53
                     dtotfil                    at 67
                     skip(2).

                 assign dmedfai = ((itotfil * 100) / medias.sequencia)
                        dmedfil = ((medias.medfil * 100) / medias.sequencia)
                        dmedtot = ((itotfil * 100 ) / i).
                 put skip
                     "Registros: "
                     "   Faixa "
                     itotfil              form "zzzzzzz9"
                     " - Filial  "
                     medias.sequencia     form "zzzzzzz9"
                     "  ( Total = "
                     i                    form "zzzzzzz9"
                     " )"
                     skip
                     "Media    : "
                     "   Faixa  "
                     dmedfai
                     " - Filial   "  
                     dmedfil
                     skip(1).
                 assign itotfil = 0
                        dtotfil = 0
                        dmedfai = 0
                        dmedfil = 0
                        dmedtot = 0.
            
         end.
         if last(medias.etbcod)
         then put skip(1).
          
    end.
    
    put "Registros "
        i               form "zzzzzzz9"
        "   -   " 
        "Media Geral  "
        dtotger
        "   -   "
        "Qtde Geral  "
        itotger
        skip. 
        
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.
     
end procedure.

procedure p-total.
    vtotqtd = 0.

    for each brfvtot where 
             brfvtot.flag = yes and
             brfvtot.etbcod = if vetbcod = 0
                              then brfvtot.etbcod
                              else vetbcod:
        vtotqtd = vtotqtd + brfvtot.qtd-sel.
        
    end.

    disp skip(3)
         "      TOTAL GERAL" skip
         space(4)   i       no-label skip(2)
            
         "TOTAL SELECIONADO" skip
         space(4)   vtotqtd no-label skip

         with frame f-tot col 60 no-box overlay.

end procedure.


procedure p-rfv-ini:                

    vrec = 0. 
    vfre = 0. 
    vval = 0.

    for each crm where
             crm.etbcod = (if vetbcod <> 0
                          then vetbcod                 
                          else crm.etbcod):

        find first rfvcli where
                   rfvcli.setor = 0      and
                   rfvcli.clicod = crm.clicod no-lock no-error.
                   
        find first rfvtot where rfvtot.rfv = crm.rfv and
                   rfvtot.etbcod = crm.etbcod no-error.
        if not avail rfvtot
        then do:
            create rfvtot.
            assign rfvtot.rfv            = crm.rfv
                   rfvtot.flag           = no
                   rfvtot.etbcod         = crm.etbcod.

            vdescricao = "".

            do icont = 1 to length(string(crm.rfv)):
               find rfv-tipo where
                    rfv-tipo.codigo = int(substring(string(crm.rfv),icont,1)) 
                    no-lock no-error.
               if avail rfv-tipo
               then do:
                   if icont = 1
                   then assign rfvtot.recencia      = rfv-tipo.descricao.                   if icont = 2
                   then assign rfvtot.frequencia    = rfv-tipo.descricao.
                   if icont = 3
                   then assign rfvtot.valor         = rfv-tipo.descricao.
               end. 
            end.
        end.
        assign rfvtot.qtd-ori    = rfvtot.qtd-ori + 1.
        assign rfvtot.per-tot    = (rfvtot.qtd-ori * 100) / i.
  end.

end procedure.


procedure p-nova-rfv:
 def var vconta as int.
 def var vloop as int.
 def var vmens2 as char.
 def var vtime as int.
 
 vmens2 = " F I L T R A N D O   *    *    *    *    *    *    *    *    *    *"
        + "   *    *".

vtime = time.
vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .
 

 for each b-rfvtot where 
          b-rfvtot.flag   = yes and
          b-rfvtot.etbcod = if vetbcod = 0
                            then b-rfvtot.etbcod 
                            else vetbcod:
          
    b-rfvtot.qtd-sel = 0.    
    
    for each crm where 
             crm.rfv    = b-rfvtot.rfv and
             crm.etbcod = if vetbcod = 0
                          then crm.etbcod
                          else vetbcod:

        crm.mostra = yes.
        vconta = vconta + 1.
        
        for each tt-filtro:
        
        /***/
        vloop = vloop + 1. 

        if vloop > 199
        then do: 
            put screen color normal    row 16  column 1 vmens2.
            put screen color messages  row 17  column 20 /*15*/
            " Decorridos : " + string(time - vtime,"HH:MM:SS") 
            + " Minutos    ".
             
            vmens2 = substring(vmens2,2,78) + substring(vmens2,1,1).
            vloop = 0.
        end.
        
        /**/
        
            if tt-filtro.considerar
            then do: /*Filtra*/
            
                if tt-filtro.descricao = "SEXO"
                then
                    if crm.sexo <> tt-filtro.log
                    then crm.mostra = no.

                if tt-filtro.descricao = "FAIXA DE IDADE"
                then
                    if crm.idade >= tt-filtro.int[1] and
                       crm.idade <= tt-filtro.int[2]
                    then.
                    else crm.mostra = no.
            
                if tt-filtro.descricao = "MES DE ANIVERSARIO"
                then
                    if crm.mes-ani >= tt-filtro.int[1] and
                       crm.mes-ani <= tt-filtro.int[2]
                    then.
                    else crm.mostra = no.

                if tt-filtro.descricao = "COM DEPENDENTES"
                then
                    if not crm.dep
                    then crm.mostra = no.

                if tt-filtro.descricao = "POSSUI CELULAR"
                then
                    if not crm.celular
                    then crm.mostra = no.
                    
                if tt-filtro.descricao = "TIPO DE RESIDENCIA"
                then
                    if crm.residencia <> tt-filtro.log
                    then crm.mostra = no.

                if tt-filtro.descricao = "POSSUI CARRO"
                then 
                    if not crm.carro
                    then crm.mostra = no.
                
                if tt-filtro.descricao = "CONSIDERAR SPC"
                then
                    if crm.spc
                    then crm.mostra = no.
                
                if tt-filtro.descricao = "POSSUI E-MAIL"
                then
                    if not crm.email
                    then crm.mostra = no.

                if tt-filtro.descricao = "RENDA MENSAL"
                then
                    if crm.renda-mes >= tt-filtro.dec[1] and
                       crm.renda-mes <= tt-filtro.dec[2]
                    then.
                    else crm.mostra = no.
                
                if tt-filtro.descricao = "RENDA TOTAL"
                then
                    if crm.renda-tot >= tt-filtro.dec[1] and
                       crm.renda-tot <= tt-filtro.dec[2]
                    then.
                    else crm.mostra = no.

                if tt-filtro.descricao = "LIMITE DE CREDITO"
                then do:
                        if crm.limite >= tt-filtro.dec[1] and
                           crm.limite <= tt-filtro.dec[2]
                        then.
                           else crm.mostra = no.
                end.    

                if tt-filtro.descricao = "CIDADE"
                then do:
                    find tt-cidade where tt-cidade.cidade = crm.cidade
                                         no-error.
                    if avail tt-cidade
                    then do:
                        if not tt-cidade.marca 
                        then crm.mostra = no.
                    end.
                    else crm.mostra = no.
                end.

                if tt-filtro.descricao = "BAIRRO"
                then do:
                    find tt-bairro where tt-bairro.bairro = crm.bairro
                                         no-error.
                    if avail tt-bairro
                    then do:
                        if not tt-bairro.marca 
                        then crm.mostra = no.
                    end.
                    else crm.mostra = no.
                end.
                
                if tt-filtro.descricao = "PROFISSAO"
                then do:
                    find tt-profissao where 
                         tt-profissao.profissao = crm.profissao no-error.
                    if avail tt-profissao
                    then do:
                        if not tt-profissao.marca 
                        then crm.mostra = no.
                    end.
                    else crm.mostra = no.
                end.
                
                if tt-filtro.descricao = "ESTADO CIVIL"
                then do:
                    find tt-estciv where tt-estciv.estciv = crm.est-civ
                                         no-error.
                    if avail tt-estciv
                    then do:
                        if not tt-estciv.marca 
                        then crm.mostra = no.
                    end.
                    else crm.mostra = no.
                end.
                
                if tt-filtro.tipo = "PRODUTO"
                then do:
                    vok = yes.
                    run p-compras-cli (input crm.clicod,
                                       input vetbcod,
                                       input vri[1],
                                       input vrf[5],
                                       input tt-filtro.descricao,
                                       output vok).
                    if not vok
                    then crm.mostra = no.
                end.
                
                if tt-filtro.tipo = "NAOCOMP"
                then do:
                    vok2 = yes.
                    run p-nao-comprou (input crm.clicod,
                                       input vetbcod,
                                       input vri[1],
                                       input vrf[5],
                                       input tt-filtro.descricao,
                                       output vok2).
                
                    if not vok2
                    then crm.mostra = no.
                end.

            end.

        end.
        
        if crm.mostra = no
        then next.

        b-rfvtot.qtd-sel = b-rfvtot.qtd-sel + 1.    
        
    end.
    
    
    hide message no-pause.
    put screen row 15  column 1 fill(" ",80).
    put screen row 16  column 1 fill(" ",80). 
    put screen row 17  column 1 fill(" ",80).
    
 end.
end procedure.


procedure p-fil:
    def input parameter p-tipo as char.

    hide frame f-com1  no-pause. 
    hide frame f-com2  no-pause. 
    hide frame f-tot   no-pause. 
     
     
    for each tt-profissao. delete tt-profissao. end. 
    for each tt-cidade. delete tt-cidade. end. 
    for each tt-bairro. delete tt-bairro. end. 
    for each tt-estciv. delete tt-estciv. end.  
    
    if p-tipo = "CLIENTE" 
    then do:
     for each brfvtot where brfvtot.flag   = yes and
                            brfvtot.etbcod = if vetbcod = 0
                                             then brfvtot.etbcod
                                             else vetbcod: 
        for each crm where crm.rfv    = brfvtot.rfv and
                           crm.etbcod = if vetbcod = 0
                                        then crm.etbcod
                                        else vetbcod:   
            find tt-bairro where tt-bairro.bairro = crm.bairro no-error.  
            if not avail tt-bairro 
            then do: 
                create tt-bairro. 
                assign tt-bairro.bairro = crm.bairro 
                       tt-bairro.marca  = no. 
            end.  
            find tt-estciv where tt-estciv.estciv = crm.est-civ no-error. 
            if not avail tt-estciv 
            then do: 
                create tt-estciv. 
                assign tt-estciv.estciv    = crm.est-civ 
                       tt-estciv.marca     = no. 
            end.  
            find tt-cidade where tt-cidade.cidade = crm.cidade no-error. 
            if not avail tt-cidade 
            then do: 
                create tt-cidade. 
                assign tt-cidade.cidade = crm.cidade 
                       tt-cidade.marca  = no. 
            end.
            find tt-profissao where 
                     tt-profissao.profissao = crm.profissao no-error. 
            if not avail tt-profissao 
            then do:
                create tt-profissao. 
                assign tt-profissao.profissao = crm.profissao
                       tt-profissao.marca  = no.
            end.
        end.
     end.
    end.
    
    hide message no-pause.
    run crm/crm3fil3.p (p-tipo).
        /*run crm20-fil2.p (input p-tipo).*/

end procedure.

procedure p-compras-cli:
    def input parameter p-clicod like clien.clicod.
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-dti as date format "99/99/9999".
    def input parameter p-dtf as date format "99/99/9999".
    def input parameter p-descricao as char.
    def output parameter p-ok as log.
    def var vdt-aux as date format "99/99/9999".
    def var cont as int.
        
    /***/
    for each plani use-index plasai
           where plani.movtdc = 5
             and plani.desti  = p-clicod no-lock:
             
            if plani.pladat < vri[1] and
               plani.pladat > vrf[5]
            then next.
 
            
            if vetbcod <> 0
            then if plani.etbcod <> vetbcod
                 then next.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                
                /*** Compraram ***/
                if p-descricao = "PRODUTO"
                then do:
                    find first tt-produ 
                         where tt-produ.procod = produ.procod
                                                 no-lock no-error.
                    if not avail tt-produ
                    then next.
                end.
                if p-descricao = "FABRICANTE"
                then do:
                    find first tt-forne
                         where tt-forne.forcod = produ.fabcod
                                                 no-lock no-error.
                    if not avail tt-forne
                    then next.
                end.
                if p-descricao = "CLASSE"
                then do:
                    find first tt-clase
                         where tt-clase.clacod = produ.clacod
                                                 no-lock no-error.
                    if not avail tt-clase 
                    then next.
                end.
                
                cont = cont + 1.
            end.
    end.
    /****/
    
    cont = 0.    
    if p-descricao = "PRODUTO" 
    then do: 
        for each tt-produ:
            find first tt-produtos where 
                       tt-produtos.clicod = crm.clicod 
                   and tt-produtos.procod = tt-produ.procod no-error.
            if avail tt-produtos
            then assign cont = cont + 1.
        end.
    end.
    
    if p-descricao = "FABRICANTE" 
    then do: 
        for each tt-forne:
            find first tt-fabricantes where
                       tt-fabricantes.clicod = crm.clicod
                   and tt-fabricantes.fabcod = tt-forne.forcod no-error.
            if avail tt-fabricantes
            then assign cont = cont + 1.
        end.
    end.
    
    if p-descricao = "CLASSE"
    then do:
        for each tt-clase:
            find first tt-classes where
                       tt-classes.clicod = crm.clicod
                   and tt-classes.clacod = tt-clase.clacod no-error.    
            if avail tt-classes
            then assign cont = cont + 1.
        end.
    end.
    
    
    
    if cont > 0 
    then p-ok = yes.
    else p-ok = no.
    
end procedure.

/***/

procedure p-nao-comprou:
    def input parameter p-clicod like clien.clicod.
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-dti as date format "99/99/9999".
    def input parameter p-dtf as date format "99/99/9999".
    def input parameter p-descricao as char.
    def output parameter p-ok2 as log init yes.
    def var vdt-aux as date format "99/99/9999".
    def var cont as int.
        
    /****/
    for each plani use-index plasai
           where plani.movtdc = 5
             and plani.desti  = p-clicod no-lock:
             
            if plani.pladat < vri[1] and
               plani.pladat > vrf[5]
            then next.
 
            
            if vetbcod <> 0
            then if plani.etbcod <> vetbcod
                 then next.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                
                /*** Nao Compraram ***/
                if p-descricao = "PRODUTO"
                then do:
                    find first tt-nprodu 
                         where tt-nprodu.procod = produ.procod
                                                 no-lock no-error.
                    if avail tt-nprodu
                    then p-ok2 = no.
                end.

                if p-descricao = "FABRICANTE"
                then do:
                    find first tt-nforne
                         where tt-nforne.forcod = produ.fabcod
                                                 no-lock no-error.
                    if avail tt-nforne
                    then p-ok2 = no.
                end.
                
                if p-descricao = "CLASSE"
                then do:
                    find first tt-nclase
                         where tt-nclase.clacod = produ.clacod
                                                 no-lock no-error.
                    if avail tt-nclase 
                    then p-ok2 = no.
                end.
                
            end.
    end.
    /****/
    
    p-ok2 = yes.
    
    if p-descricao = "PRODUTO"
    then do:
        for each tt-nprodu:
            find first tt-produtos where
                       tt-produtos.clicod = crm.clicod
                   and tt-produtos.procod = tt-nprodu.procod no-error.
            if avail tt-produtos
            then p-ok2 = no.
        end.
    end.
    
    if p-descricao = "FABRICANTE"
    then do:
        for each tt-nforne:
            find first tt-fabricantes where
                       tt-fabricantes.clicod = crm.clicod
                   and tt-fabricantes.fabcod = tt-nforne.forcod no-error.
            if avail tt-fabricantes
            then p-ok2 = no. 
        end.
    end.
    
    if p-descricao = "CLASSE"
    then do:
        for each tt-nclase:
            find first tt-classes where
                       tt-classes.clicod = crm.clicod
                   and tt-classes.clacod = tt-nclase.clacod no-lock no-error.
            if avail tt-classes
            then p-ok2 = no.
        end.
    end.
      
    
end procedure.

procedure p-acao:

    def var vnumacao as int.
    def var vdescricao as char.
    def var vdata1 as date format "99/99/9999".
    def var vdata2 as date format "99/99/9999".
    def var vvalor like acao.valor.
    
    hide message no-pause.
    view frame frame-a. pause 0.

    do on error undo:
        
         update skip(1)
                space(2) vdescricao label "Tipo de Acao" 
                         format "x(50)" space(2)
                skip
                space(2) vdata1     label "Data Inicio."
                vdata2     label "Final"
                skip
                space(2) vvalor     label "Valor......."
                skip(1)
                with frame f-acao centered overlay
                            row 10 side-labels
                            title " Acao ".


    end.

    sresp = yes.
    message "Gerar Acao para os clientes selecionados ?" update sresp.
    if sresp
    then do:
        hide message no-pause.
        message "Aguarde ... Gerando Acao ...".
        find last acao no-lock no-error.
        if not avail acao
        then vnumacao = 1.
        else vnumacao = acao.acaocod + 1.
        
        create acao.
        assign acao.acaocod   = vnumacao
               acao.descricao = caps(vdescricao)
               acao.dtini     = vdata1
               acao.dtfin     = vdata2
               acao.valor     = vvalor.
        
        assign vcomp-produtos     = "|"
               vcomp-fabricantes  = "|"
               vcomp-classes      = "|"
               vncomp-produtos    = "|"
               vncomp-fabricantes = "|"
               vncomp-classes     = "|".
               
               
        for each ztt-filtro where 
                 ztt-filtro.considerar = yes  no-lock:
                 
            if ztt-filtro.tipo = "PRODUTO" /*Compraram*/
            then do:
                if ztt-filtro.descricao = "PRODUTO"
                then do:
                    for each tt-produ:
                        vcomp-produtos = vcomp-produtos 
                                  + string(tt-produ.procod) 
                                  + "|".
                    end.
                    acao.produtos[1] = vcomp-produtos.
                end.
                
                if ztt-filtro.descricao = "FABRICANTE"
                then do:
                    for each tt-forne:
                        vcomp-fabricantes = vcomp-fabricantes 
                                  + string(tt-forne.forcod) 
                                  + "|".
                    end.
                    
                    acao.fabricantes[1] = vcomp-fabricantes.
                    
                end.
                
                if ztt-filtro.descricao = "CLASSE"
                then do:
                    for each tt-clase:
                        vcomp-classes = vcomp-classes
                                  + string(tt-clase.clacod) 
                                  + "|".
                    end.
                    
                    acao.classes[1] = vcomp-classes.
                    
                end.
            end.
            
            if ztt-filtro.tipo = "NAOCOMP" /*Nao Compraram*/
            then do:

                if ztt-filtro.descricao = "PRODUTO"
                then do:
                    for each tt-nprodu:
                        vncomp-produtos = vncomp-produtos 
                                  + string(tt-nprodu.procod) 
                                  + "|".
                    end.
                
                    acao.produtos[2] = vncomp-produtos.

                end.
                
                if ztt-filtro.descricao = "FABRICANTE"
                then do:
                    for each tt-nforne:
                        vncomp-fabricantes = vncomp-fabricantes 
                                  + string(tt-nforne.forcod) 
                                  + "|".
                    end.
                    
                    acao.fabricantes[2] = vncomp-fabricantes.
                    
                end.
                
                if ztt-filtro.descricao = "CLASSE"
                then do:
                    for each tt-nclase:
                        vncomp-classes = vncomp-classes
                                  + string(tt-nclase.clacod) 
                                  + "|".
                    end.
                    
                    acao.classes[2] = vncomp-classes.
                    
                end.
            
            end.
        end.
        /*
        
        run conecta_d.p.
        if not connected("d")
        then do:
            sresp = no.
            message "NÆo conectou LP. Continuar mesmo assim ?"
            update sresp.
            if not sresp then return.
        end.
        */ 
        
        for each rfvtot where 
             rfvtot.flag = yes and
             rfvtot.etbcod = if vetbcod = 0
                              then rfvtot.etbcod
                              else vetbcod:
                                   /*
        for each rfvtot where rfvtot.flag = yes:
                */
            disp rfvtot.
    
    for each crm where 
            (if rfvtot.qtd-ori = rfvtot.qtd-sel
             then true
             else crm.mostra = yes) and
             crm.rfv    = rfvtot.rfv and
             crm.etbcod = if vetbcod = 0
                          then crm.etbcod
                          else vetbcod:

                          /*
            for each crm where crm.rfv = rfvtot.rfv
                       and crm.mostra = yes:
                       */
                disp crm.
                
                find acao-cli where acao-cli.acaocod = acao.acaocod
                                and acao-cli.clicod  = crm.clicod no-error.
                if not avail acao-cli
                then do:
                    create acao-cli.
                    assign acao-cli.acaocod = acao.acaocod
                           acao-cli.clicod  = crm.clicod
                           acao-cli.recencia = crm.recencia
                           acao-cli.frequencia = crm.frequencia
                           acao-cli.valor = crm.valor.
                end.
            end. 
        end.
    end.
       
    hide message no-pause.
    message "Acao gerada com sucesso!".
    pause 2 no-message.
    hide message no-pause.

end procedure.

