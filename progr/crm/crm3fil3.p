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

def shared temp-table tt-filtro
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

def buffer crm for ncrm.

def  shared temp-table tt-cidade
    field cidade as char
    field marca  as log format "*/ "
    index icidade is primary unique cidade.

def shared temp-table tt-produ
    field procod like produ.procod
    field pronom like produ.pronom
    index iprocod is primary unique procod.

def shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def shared temp-table tt-forne
    field forcod like forne.forcod
    field fornom like forne.fornom
    index iforcod is primary unique forcod.
    
/** nao compraram **/
def shared temp-table tt-nprodu
    field procod like produ.procod
    field pronom like produ.pronom
    index iprocod is primary unique procod.

def shared temp-table tt-nclase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def shared temp-table tt-nforne
    field forcod like forne.forcod
    field fornom like forne.fornom
    index iforcod is primary unique forcod.
    
/***/
 
def shared temp-table tt-bairro
    field bairro as char
    field marca  as log format "*/ "
    index ibairro is primary unique bairro.

def  shared temp-table tt-estciv
    field estciv as int
    field descricao as char
    field marca  as log format "*/ "
    index iestciv is primary unique estciv.

def shared temp-table tt-profissao
    field profissao as char
    field marca  as log format "*/ "
    index iprofissao is primary unique profissao.

def shared temp-table rfvtot
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

/**
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

**/

def var esqcom1         as char format "x(15)" extent 5
    initial [" Selecionar ","  "," ", " ",""].

def var esqcom2         as char format "x(14)" extent 5
            initial ["  ",
                     "  ",
                     "  ", 
                     "  ",
                     " "].

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

def var vdescri as char.
def var vtipo  as char.
def var vtecla-p as char.

/* Busca Cadastro de Tipos de Filtros */

def input parameter par-tipofiltro as char.
input from /admcom/progr/infc.ini.
repeat.
    import vdescri vtipo vtecla-p.
    find first tt-filtro where
        tt-filtro.tipo      = vtipo and
        tt-filtro.descricao = vdescri no-error.
    if not avail tt-filtro
    then do:
        create tt-filtro.
        tt-filtro.descricao = vdescri.
        tt-filtro.tipo      = vtipo.
        tt-filtro.considerar = no.
        assign
            tt-filtro.tecla-p    = if vtecla-p = "P" then "%" else "".
    end.
end.
input close.    

recatu1 = ?.


bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        find tt-filtro where recid(tt-filtro) = recatu1 no-lock.
    end.
        
    if not available tt-filtro
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-filtro).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-filtro
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
            find tt-filtro where recid(tt-filtro) = recatu1 no-lock.

            run p-total.
            run color-message.
            
            choose field 
                tt-filtro.descricao
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
                    if not avail tt-filtro
                    then leave.
                    recatu1 = recid(tt-filtro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-filtro
                    then leave.
                    recatu1 = recid(tt-filtro).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-filtro
                then next.
                color display white/red
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-filtro
                then next.
                color display white/red 
                                        with frame frame-a.
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

                if esqcom1[esqpos1] = " Selecionar "
                then do with frame frame-a on error undo.
                    recatu2 = recatu1.
                    update tt-filtro.considerar.
                    
                    if tt-filtro.considerar
                    then run p-filtro-considerar.
                    pause 0.
                    run p-nova-rfv.
                    pause 0.
                    run p-total.
                    pause 0.

                    
                    recatu1 = recatu2.    
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
        recatu1 = recid(tt-filtro).
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
    display 
        tt-filtro.descricao
        tt-filtro.considerar
            with frame frame-a col 2 11 down color white/red row 5
            no-box.
            
end procedure.

procedure color-message.

    /*
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
    */
    
end procedure.

procedure color-normal.
    /*
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
    */
    
end procedure.


procedure leitura.

    def input parameter par-tipo as char.
            
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
            find first tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.     
        else do: 
            find last tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
            find next tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.            
        else do: 
            find prev tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
            find prev tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.
        else do:
            find next tt-filtro where
                tt-filtro.tipo = par-tipofiltro no-lock no-error.
        end.
    end.        
        
end procedure.

procedure p-nao-libera:

    message " Procedimento ainda nao esta liberado" view-as alert-box.

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
    pause 0.
    disp skip(3)
         "      TOTAL GERAL" skip
         space(4)   i       no-label skip(2)
            
         "TOTAL SELECIONADO" skip
         space(4)   vtotqtd no-label skip

         with frame f-tot col 60 no-box overlay row 7.

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
 

    /*message "Filtrando Clientes...".*/
 vconta = 0.   
 for each b-rfvtot.
 b-rfvtot.qtd-sel = 0.
 end.
 
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
                then do:
                    if crm.sexo <> tt-filtro.log
                    then crm.mostra = no.
                
                    /*
                    find first crmclidado where
                        crmclidado.clicod = crm.clicod and
                        crmclidado.NOMEdado = tt-filtro.descricao
                        no-lock.
                    if not avail crmclidado
                    then crm.mostra = no.
                    else do:
                        if crmclidado.VALORdado <> tt-filtro.VALORdado
                        then crm.mostra = no.
                    end.
                    */
                    
                end.

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

/*        b-rfvtot.qtd-sel = b-rfvtot.qtd-sel + 1.    */
        
    end.
    for each crm where 
             crm.mostra = yes and
             crm.rfv    = b-rfvtot.rfv and
             crm.etbcod = if vetbcod = 0
                          then crm.etbcod
                          else vetbcod:

        b-rfvtot.qtd-sel = b-rfvtot.qtd-sel + 1.    

    end.   
    hide message no-pause.
    put screen row 15  column 1 fill(" ",80).
    put screen row 16  column 1 fill(" ",80). 
    put screen row 17  column 1 fill(" ",80).
    
 end.
 
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

procedure p-filtro-considerar.

    if tt-filtro.descricao = "SEXO"
    then do:
             update vsexo as log format "Masculino/Feminino" label "Sexo"
             with frame fsexo centered row 12 overlay side-labels.
        hide frame fsexo no-pause.
        tt-filtro.log = vsexo.
    end.

    if tt-filtro.descricao = "ESTADO CIVIL"
    then do:
        run crm20-estc.p.
    end.

    if tt-filtro.descricao = "FAIXA DE IDADE"
    then do:
             def var vini as int label "De".
        def var vfim as int label "Ate".
        update vini vfim
        with frame fint centered row 12 overlay side-labels.
        hide frame fint no-pause.
        tt-filtro.int[1] = vini.
        tt-filtro.int[2] = vfim.
    end.
    if tt-filtro.descricao = "COM DEPENDENTES"
    then do:
        /* Simplesmente Considera */
    end.
    if tt-filtro.descricao = "CIDADE"
    then do:
        run crm20-cid.p.
    end.
    if tt-filtro.descricao = "BAIRRO"
    then do:
        run crm20-bai.p.
    end.
    if tt-filtro.descricao = "POSSUI CELULAR"
    then do:
        /* Simplesmente Considera */
    end.
    if tt-filtro.descricao = "COM DEPENDENTES"
    then do:
        /* Simplismente Considera */
    end.
    if tt-filtro.descricao = "TIPO DE RESIDENCIA"
    then do:
             update vtiporesidencia as log format "Propria/Alugada"
                label "Tipo Residencia"
             with frame fres centered row 12 overlay side-labels.
        hide frame fres no-pause.             
        tt-filtro.log = vtiporesidencia.
    end.
    if tt-filtro.descricao = "CONSIDERAR SPC"
    then do:
        /* Simplesmente Considera */
    end.
    if tt-filtro.descricao = "PROFISSAO"
    then do:
        run crm20-prof.p.
    end.
    if tt-filtro.descricao = "RENDA MENSAL"
    then do:
             def var vdecini as int label "De".
        def var vdecfim as int label "Ate".
        update vdecini vdecfim
        with frame fdec centered row 12 overlay side-labels.
        hide frame fdec no-pause.
        tt-filtro.dec[1] = vdecini.
        tt-filtro.dec[2] = vdecfim.
    end.
    if tt-filtro.descricao = "POSSUI E-MAIL"
    then do:
        /* Simplesmente Considera */
    end.
    if tt-filtro.descricao = "POSSUI CARRO"
    then do:
        /* Simplesmente Considera */
    end.
    if tt-filtro.descricao = "LIMITE DE CREDITO"
    then do:
        update vdecini vdecfim
            with frame fdec.
            hide frame fdec no-pause.
        tt-filtro.dec[1] = vdecini.
        tt-filtro.dec[2] = vdecfim.
    end.
    if tt-filtro.tipo = "PRODUTO" and tt-filtro.descricao = "PRODUTO"
    then do:
        run crm20-pro.p.
    end.
    if  tt-filtro.tipo = "PRODUTO" and  tt-filtro.descricao = "FABRICANTE"
    then do:
        run crm20-fab.p.
    end.
    if  tt-filtro.tipo = "PRODUTO" and tt-filtro.descricao = "CLASSE"
    then do:
             create tt-clase.
        update tt-clase.clacod
        with frame fcla centered row 12 overlay side-labels.
        hide frame fcla no-pause.
    end.
    
    /* Nao Comprou */
    if tt-filtro.tipo = "NAOCOMP" and tt-filtro.descricao = "PRODUTO"
    then do:
        run crm20-npro.p.
    end.
    if  tt-filtro.tipo = "NAOCOMP" and  tt-filtro.descricao = "FABRICANTE"
    then do:
        run crm20-nfab.p.
    end.
    if  tt-filtro.tipo = "NAOCOMP" and tt-filtro.descricao = "CLASSE"
    then do:
        create tt-nclase.
        update tt-nclase.clacod
        with frame fcla.
        hide frame fcla no-pause.
    end.
     


end procedure.
