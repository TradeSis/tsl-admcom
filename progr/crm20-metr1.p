/* ************************************************************************
*  Progrma...: crm20-metr1.p
*  Funcao....: Metrica 
***********************************************************************  */ 

{admcab.i}
def var vok as log init no.

def var w1 as int.
def var w2 as int.
def var w3 as int.
def var vpcod as char.
def var vfcod as char.
def var vccod as char.

def temp-table tt-pro
    field procod as int
    index i-prip is primary unique procod.

/*
def temp-table tt-fabricantes
    field fabcod as int
    index i-prif is primary unique fabcod.
    
def temp-table tt-produtos
    field procod as int
    index i-prip is primary unique procod.
    
def temp-table tt-classes
    field clacod as int
    index i-pric is primary unique clacod.
*/

def buffer tt-produtos    for crmprodutos.
def buffer tt-classes     for crmclasses.
def buffer tt-fabricantes for crmfabricantes.

def temp-table tt-nfabricantes
    field fabcod as int
    index i-prif is primary unique fabcod.
    
def temp-table tt-nprodutos
    field procod as int
    index i-prip is primary unique procod.
    
def temp-table tt-nclasses
    field clacod as int
    index i-pric is primary unique clacod.

def input parameter p-acao as int.

def var vrentab like acao.valor.
def var vcusto like acao.valor.

def var vdia as int.
def var vacum-valor as dec.      
def var vtotal-cli as int format ">>>>>9".
def var vperc-acum as dec format ">>>9.99".

def var vtotval like acao.valor.
def var vtotqtd as int format ">>>>>>>>9".
def var vparti  as int format ">>>>>9".

def temp-table tt-metrica
    field acaocod   like acao.acaocod
    field d         as   int format ">>9"
    field dia       as   date format "99/99/9999"
    field parti     as   int format ">>>>>>9"
    field qtd       as   int format ">>>>>>9"
    field valor     like acao.valor
    field valor-plani like acao.valor
    field acum-valor like acao.valor
    field perc-dia  as   dec format ">>9.99"
    field perc-acum as   dec format ">>>9.99"
    field estcusto  like estoq.estcusto
    index ipri is primary unique acaocod dia 
    index idia dia asc.
    
def var vperc as dec format ">>9.99%".

find acao where acao.acaocod = p-acao no-lock no-error.
if not avail acao then leave.

message "Aguarde, gerando consulta ...".
for each acao-cli where acao-cli.acaocod = acao.acaocod no-lock.
    vtotal-cli = vtotal-cli + 1.
end.

/*************/

/*Fabricantes*/
w1 = 0. vfcod = "". 
do w1 = 1 to length(acao.fabricantes[1]). 
    if substring(acao.fabricantes[1],w1,1) = "|"
    then do: 
        find tt-fabricantes where 
             tt-fabricantes.fabcod = int(vfcod) no-error.
                                  
        if not avail tt-fabricantes 
        then do: 
            create tt-fabricantes. 
            assign tt-fabricantes.fabcod = int(vfcod). 
        end.
        vfcod = "".
    end.
        
    if substring(acao.fabricantes[1],w1,1) <> "|"
    then  
        vfcod = vfcod + substring(acao.fabricantes[1],w1,1).

end. 
/*Fabricantes*/

/*Fabricantes*/
w1 = 0. vfcod = "". 
do w1 = 1 to length(acao.fabricantes[2]). 
    if substring(acao.fabricantes[2],w1,1) = "|"
    then do: 
        find tt-nfabricantes where 
             tt-nfabricantes.fabcod = int(vfcod) no-error.
                                  
        if not avail tt-nfabricantes 
        then do: 
            create tt-nfabricantes. 
            assign tt-nfabricantes.fabcod = int(vfcod). 
        end.
        vfcod = "".
    end.
        
    if substring(acao.fabricantes[2],w1,1) <> "|"
    then  
        vfcod = vfcod + substring(acao.fabricantes[2],w1,1).

end. 
/*Fabricantes*/

    
/*Produtos*/
w2 = 0. vpcod = "". 
do w2 = 1 to length(acao.produtos[1]). 
    if substring(acao.produtos[1],w2,1) = "|" 
    then do: 
        find tt-produtos where
             tt-produtos.procod = int(vpcod) no-error.
                                  
        if not avail tt-produtos
        then do: 
            create tt-produtos. 
            assign tt-produtos.procod = int(vpcod). 
        end.
        vpcod = "".
    end.
        
    if substring(acao.produtos[1],w2,1) <> "|" 
    then 
        vpcod = vpcod + substring(acao.produtos[1],w2,1).

end.  
/*Produtos*/


/*Produtos*/
w2 = 0. vpcod = "". 
do w2 = 1 to length(acao.produtos[2]). 
    if substring(acao.produtos[2],w2,1) = "|" 
    then do: 
        find tt-nprodutos where
             tt-nprodutos.procod = int(vpcod) no-error.
                                  
        if not avail tt-nprodutos
        then do: 
            create tt-nprodutos. 
            assign tt-nprodutos.procod = int(vpcod). 
        end.
        vpcod = "".
    end.
        
    if substring(acao.produtos[2],w2,1) <> "|" 
    then 
        vpcod = vpcod + substring(acao.produtos[2],w2,1).

end.  
/*Produtos*/

/*Classes*/ 
w3 = 0. vccod = "". 
do w3 = 1 to length(acao.classes[1]). 
    if substring(acao.classes[1],w3,1) = "|" 
    then do: 
        find tt-classes where
             tt-classes.clacod = int(vccod) no-error.
                                  
        if not avail tt-classes 
        then do: 
            create tt-classes. 
            assign tt-classes.clacod = int(vccod). 
        end. 
        vccod = "". 
    end.
        
    if substring(acao.classes[1],w3,1) <> "|" 
    then  
        vccod = vccod + substring(acao.classes[1],w3,1).
         
end. 
/*Classes*/

/*Classes*/ 
w3 = 0. vccod = "". 
do w3 = 1 to length(acao.classes[2]).
    if substring(acao.classes[2],w3,1) = "|" 
    then do: 
        find tt-nclasses where
             tt-nclasses.clacod = int(vccod) no-error.
                                  
        if not avail tt-nclasses 
        then do: 
            create tt-nclasses. 
            assign tt-nclasses.clacod = int(vccod). 
        end. 
        vccod = "". 
    end.
        
    if substring(acao.classes[2],w3,1) <> "|" 
    then  
        vccod = vccod + substring(acao.classes[2],w3,1).
         
end. 
/*Classes*/

/************/


/***/
    find first tt-produtos no-error.
    if avail tt-produtos
    then do:
        for each tt-produtos:
            find tt-pro where tt-pro.procod = tt-produtos.procod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.procod = tt-produtos.procod.
            end.
        end.
    end.

    find first tt-nprodutos no-error.
    if avail tt-nprodutos
    then do:
        for each tt-nprodutos:
            find tt-pro where tt-pro.procod = tt-nprodutos.procod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.procod = tt-nprodutos.procod.
            end.
        end.
    end.

    find first tt-fabricantes no-error.
    if avail tt-fabricantes
    then do:
        for each tt-fabricantes:
            for each produ where
                     produ.fabcod = tt-fabricantes.fabcod no-lock:
               find tt-pro where
                    tt-pro.procod = produ.procod no-error.
               if not avail tt-pro
               then do:
                    create tt-pro.
                    assign tt-pro.procod = produ.procod.
               end.
            end.                
        end.
    end.

    find first tt-nfabricantes no-error.
    if avail tt-nfabricantes
    then do:
        for each tt-nfabricantes:
            for each produ where
                     produ.fabcod = tt-nfabricantes.fabcod no-lock:
               find tt-pro where
                    tt-pro.procod = produ.procod no-error.
               if not avail tt-pro
               then do:
                    create tt-pro.
                    assign tt-pro.procod = produ.procod.
               end.
            end.                
        end.
    end.


    find first tt-classes no-error.
    if avail tt-classes
    then do:
        for each tt-classes:
            for each produ where
                     produ.clacod = tt-classes.clacod no-lock:
               find tt-pro where
                    tt-pro.procod = produ.procod no-error.
               if not avail tt-pro
               then do:
                    create tt-pro.
                    assign tt-pro.procod = produ.procod.
               end.
            end.                
        end.
    end.

    find first tt-nclasses no-error.
    if avail tt-nclasses
    then do:
        for each tt-nclasses:
            for each produ where
                     produ.clacod = tt-nclasses.clacod no-lock:
               find tt-pro where
                    tt-pro.procod = produ.procod no-error.
               if not avail tt-pro
               then do:
                    create tt-pro.
                    assign tt-pro.procod = produ.procod.
               end.
            end.                
        end.
    end.




/***/



for each acao-cli where 
         acao-cli.acaocod = acao.acaocod no-lock,
    each plani where plani.movtdc  = 5 
                 and plani.desti   = acao-cli.clicod 
                 and plani.pladat >= acao.dtini 
                 and plani.pladat <= acao.dtfin
                 no-lock break by acao-cli.clicod.

        find tt-metrica where 
             tt-metrica.acaocod = acao.acaocod and
             tt-metrica.dia = plani.pladat no-error.
        if not avail tt-metrica
        then do:
            create tt-metrica.
            assign tt-metrica.acaocod = acao.acaocod
                   tt-metrica.dia     = plani.pladat.
        end.
        
        vok = no.
        
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock.
        
            /***/
        
            find first tt-pro where tt-pro.procod = movim.procod no-error.
            if avail tt-pro
            then vok = yes.

            if vok = no then next.
            
            /***/
            
            find estoq where estoq.etbcod = movim.etbcod
                         and estoq.procod = movim.procod no-lock no-error.
            tt-metrica.estcusto = tt-metrica.estcusto +
                    (movim.movqtm * estoq.estcusto).
            
            
            tt-metrica.valor = tt-metrica.valor +
                    (movim.movpc * movim.movqtm).

        end.
                         
        if vok = no then next.
        
        if first-of(acao-cli.clicod)
        then tt-metrica.parti = tt-metrica.parti + 1.
        
        assign vtotqtd = vtotqtd + 1
               vtotval = vtotval + (if plani.biss > 0 
                                    then plani.biss 
                                    else plani.platot)
               tt-metrica.qtd = tt-metrica.qtd + 1
               tt-metrica.valor-plani = 
                    tt-metrica.valor-plani + (if plani.biss > 0
                                              then plani.biss
                                              else plani.platot).
end.

vcusto = 0.
vperc-acum = 0.
vacum-valor = 0.
vdia = 0.
vparti = 0.

for each tt-metrica:
    vdia = vdia + 1.
    vparti = vparti + tt-metrica.parti.
    tt-metrica.d = vdia.
    tt-metrica.perc-dia  =  ((tt-metrica.parti * 100) / vtotal-cli).
    vperc-acum = vperc-acum + tt-metrica.perc-dia.
    tt-metrica.perc-acum =  tt-metrica.perc-acum + vperc-acum.
    
    vacum-valor = vacum-valor + tt-metrica.valor-plani.
    tt-metrica.acum-valor = tt-metrica.acum-valor + vacum-valor.

    tt-metrica.valor = tt-metrica.valor +
                    (tt-metrica.valor-plani - tt-metrica.valor).
    vcusto = vcusto + tt-metrica.estcusto.
end.

hide message no-pause.

def buffer btt-metrica for tt-metrica.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].




form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-metrica where recid(tt-metrica) = recatu1 no-lock.
    if not available tt-metrica
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-metrica).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-metrica
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
            find tt-metrica where recid(tt-metrica) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then ""
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then ""
                                        else "".
            pause 0. run p-total. pause 0.
            run color-message.
            choose field tt-metrica.d
                         tt-metrica.dia 
                         tt-metrica.parti
                         tt-metrica.perc-dia
                         tt-metrica.perc-acum
                         tt-metrica.qtd
                         tt-metrica.valor
                         tt-metrica.acum-valor
                         help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail tt-metrica
                    then leave.
                    recatu1 = recid(tt-metrica).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-metrica
                    then leave.
                    recatu1 = recid(tt-metrica).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-metrica
                then next.
                color display white/red tt-metrica.d
                                        tt-metrica.dia  
                                        tt-metrica.parti
                                        tt-metrica.perc-dia 
                                        tt-metrica.perc-acum
                                        tt-metrica.qtd
                                        tt-metrica.valor 
                                        tt-metrica.acum-valor
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-metrica
                then next.
                color display white/red tt-metrica.d
                                        tt-metrica.dia  
                                        tt-metrica.parti
                                        tt-metrica.perc-dia 
                                        tt-metrica.perc-acum
                                        tt-metrica.qtd 
                                        tt-metrica.valor 
                                        tt-metrica.acum-valor
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " "
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
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-metrica).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        find first tt-metrica where tt-metrica.acaocod = 0.
        if avail tt-metrica
        then
            delete tt-metrica.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-metrica.d         no-label
            tt-metrica.dia       column-label "Dia"   format "99/99/9999"
            tt-metrica.parti     column-label "Partic" format ">>>>>>9"
            tt-metrica.perc-dia  column-label "% Dia"
            tt-metrica.perc-acum column-label "% Acum"        
            tt-metrica.qtd       column-label "Qtd NF"   format ">>>>>9"
            tt-metrica.valor     column-label "Valor"
            tt-metrica.acum-valor column-label "Val.Acum"
            with frame frame-a 10 down column 3 color white/red row 4
                                 title " Metrica " .
end procedure.

procedure color-message.
    color display message
            tt-metrica.d         no-label
            tt-metrica.dia       column-label "Dia"  format "99/99/9999"
            tt-metrica.parti     column-label "Partic" format ">>>>>>9"
            tt-metrica.perc-dia  column-label "% Dia"
            tt-metrica.perc-acum column-label "% Acum"        
            tt-metrica.qtd       column-label "Qtd NF"  format ">>>>>9"
            tt-metrica.valor     column-label "Valor"
            tt-metrica.acum-valor column-label "Val.Acum"
            with frame frame-a.
end procedure.
procedure color-normal.
    color display normal
        tt-metrica.d         no-label
        tt-metrica.dia       column-label "Dia"  format "99/99/9999"
        tt-metrica.parti     column-label "Partic" format ">>>>>>9"
        tt-metrica.perc-dia  column-label "% Dia"
        tt-metrica.perc-acum column-label "% Acum"        
        tt-metrica.qtd       column-label "Qtd NF"  format ">>>>>9"
        tt-metrica.valor     column-label "Valor"
        tt-metrica.acum-valor column-label "Val.Acum"
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-metrica where true
                                                no-lock no-error.
    else  
        find last tt-metrica  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-metrica  where true
                                                no-lock no-error.
    else  
        find prev tt-metrica   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-metrica where true  
                                        no-lock no-error.
    else   
        find next tt-metrica where true 
                                        no-lock no-error.
        
end procedure.
         

procedure p-total.
    vrentab = (vtotval - (vcusto + acao.valor)).
    vperc = ((vparti * 100) / vtotal-cli).
    
    disp
         "TOTAL VENDA   |->" vtotval    no-label skip
         "TOTAL CUSTO   |->" vcusto     no-label skip
         "CUSTO DA ACAO |->" acao.valor no-label skip
         "RENTABILIDADE |->" vrentab    no-label
         with frame f-tot col 4  no-box. pause 0.

    disp
         "PARTIC. DA ACAO |->" vtotal-cli no-label "/ 100.00%" 
         "PARTIC. RETORNO |->" vparti no-label "/"
         vperc no-label
         with frame f-tot2 col 37 no-box. pause 0.

end procedure.
