{admcab.i }
def input parameter par-procod like produ.procod.
/*** ***/
def var vtemmix  as log.
def var vcriamix as log.
def var vestmax  like mixmprod.estmax.
def var vestmin  like mixmprod.estmin.
def var vmovalicms  like movim.movalicms.
def var vpisent     like clafis.pisent.
def var vpissai     like clafis.pissai.
def var vcofinsent  like clafis.cofinsent.
def var vcofinssai  like clafis.cofinssai.
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").


def temp-table tt-323 no-undo
    field STORE_ID    as char format "x(10)"
    field SKU_ID      as char format "x(25)"
    field ORIGIN_ID   as char format "x(12)"
    field OPEN_TO_BUY as char format "x(1)"
    field MIN_STK_QTY         as dec format ">>>>>>>>9999"
    field MAX_STK_QTY         as dec format ">>>>>>>>9999"
    field ITEM_ST_ATTR_01_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_02_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_03_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_04_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_05_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_06_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_07_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_08_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_09_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field ITEM_ST_ATTR_10_NO  as dec format ">>>>>>>>>>>>>>>>9999"
    field RECORD_STATUS       as char format "x(1)"
    field CREATE_USER_ID      as char format "x(25)"
    field CREATE_DATETIME     as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME as char format "x(16)"
    field etbcod like estab.etbcod

    index tt-323  is unique STORE_ID SKU_ID
    
    index tt323 is primary unique etbcod.



def temp-table tt-estab-mix
    field etbcod     like mixmprod.etbcod
    field codgrupo   like mixmprod.codgrupo
    field prioridade like mixmgrupo.prioridade
    field estmax     like mixmprod.estmax
    field estmin     like mixmprod.estmin
    field situacao   as log
    
    index estab is primary unique etbcod.

pause 0.

find produ where produ.procod = par-procod no-lock.

assign
        vcriamix = yes
        vestmax  = 0
        vestmin  = 0.
    if produ.catcod = 41
    then run mix-moda (output vtemmix). /* acertar tt-estab */


for each estab no-lock.

        def var vtipoLoja as char.
        vtipoLoja = if estab.tipoLoja = "Normal"
                    then "S"
                    else
                    if estab.tipoLoja = "CD"
                    then "W"
                    else
                    if estab.tipoLoja = "Outlet"
                    then "O"
                    else
                    if estab.tipoLoja = "E-COMMERCE"
                    then "E"
                    else "S".
        if vtipoLoja      = "W"       then next.
        if estab.tipoLoja = "Virtual" then next.
        if estab.tipoLoja = "escritorio" then next.
            
        /***************
        em 12/09/2013 todos os produtos irao para o Profimetrics
        54 [LEBES] Retirar filtro "descontinuados" e "classes" na interface 323
        
        if produ.clacod = 128061101 or
           produ.clacod = 128061701 or 
           produ.clacod = 128061702 or 
           produ.clacod = 128060107 or 
           produ.clacod = 129050101 or 
           produ.clacod = 118060101 or 
           produ.clacod = 118060102 or 
           produ.clacod = 118060103 or 
           produ.clacod = 118060201 or 
           produ.clacod = 118060202 or 
           produ.clacod = 118060203 or 
           produ.clacod = 118060204 or 
           produ.clacod = 127040202 or 
           produ.clacod = 127040203 or 
           produ.clacod = 127040204 or 
           produ.clacod = 127040205 or 
           produ.clacod = 127040206  
        then.
        else 
        if produ.descontinuado 
        then 
            if produ.datfimvida < 08/10/2013 then next.
        ***************/        
        
        if produ.catcod = 31 or
           produ.catcod = 41
        then .
        else next.
        
        if produ.catcod = 41 
        then do.
            assign
                vestmax = 0
                vestmin = 0
                vcriamix = yes.

            if vtemmix
            then do.
                find tt-estab-mix where tt-estab-mix.etbcod = estab.etbcod
                                    and tt-estab-mix.situacao
                              no-lock no-error.
                if not avail tt-estab-mix
                then assign
                        vcriamix = no.
                else
                    assign
                        vestmax  = tt-estab-mix.estmax
                        vestmin  = tt-estab-mix.estmin
                        vcriamix = yes.
            end.
        end.    

        def var vITEM_ST_ATTR_01_NO as dec.
        find estoq where estoq.procod = produ.procod and 
                         estoq.etbcod = estab.etbcod no-lock no-error.
        /* em 16/10/2013 - produto sem registro de estoq não cria 323*/
        if not avail estoq
        then next.
        vITEM_ST_ATTR_01_NO = if avail estoq and estoq.estatual > 0
                              then estoq.estatual * 10000
                              else 0.
        if vmovalicms = ? 
        then vmovalicms = 0.

        if vcriamix
        then do.
            vpisent = 0.
            vpissai = 0.
            vcofinsent = 0.
            vcofinssai = 0.
            find clafis where clafis.codfis = produ.codfis no-lock no-error.
            if avail clafis
            then assign vpisent     = clafis.pisent
                        vpissai     = clafis.pissai
                        vcofinsent  = clafis.cofinsent
                        vcofinssai  = clafis.cofinssai.

            if vpisent = ?      then vpisent = 0.
            if vpissai = ?      then vpissai = 0.
            if vcofinsent = ?   then vcofinsent = 0.
            if vcofinsent = ?   then vcofinssai = 0.

            find tt-323 where tt-323.STORE_ID   = string(estab.etbcod) and
                              tt-323.SKU_ID     = string(produ.procod)
                          no-error.  
            if not avail tt-323
            then create tt-323.
            assign tt-323.STORE_ID    = string(estab.etbcod)
                   tt-323.etbcod = estab.etbcod
                   tt-323.SKU_ID      = string(produ.procod)
                   tt-323.ORIGIN_ID   = "LEBES"
                   tt-323.OPEN_TO_BUY = string(produ.opentobuy,"Y/N")
                   tt-323.MIN_STK_QTY = vestmin * 10000
                   tt-323.MAX_STK_QTY = vestmax * 10000
                   tt-323.ITEM_ST_ATTR_01_NO  = vITEM_ST_ATTR_01_NO
                   tt-323.ITEM_ST_ATTR_02_NO  = 0
                   tt-323.ITEM_ST_ATTR_03_NO  = vmovalicms * 10000
                   tt-323.ITEM_ST_ATTR_04_NO  = if produ.proipiper = ? or 
                                                   produ.proipiper = 99
                                                then 0
                                                else produ.proipiper * 10000
                   /*17    * 10000       .*/
                   tt-323.ITEM_ST_ATTR_05_NO  = vpisent  * 10000
                   tt-323.ITEM_ST_ATTR_06_NO  = vpissai  * 10000
                   tt-323.ITEM_ST_ATTR_07_NO  = vcofinsent   * 10000
                   tt-323.ITEM_ST_ATTR_08_NO  = vcofinssai   * 10000
                   tt-323.ITEM_ST_ATTR_09_NO  = 0     * 10000
                   tt-323.ITEM_ST_ATTR_10_NO  = 0     * 10000
               
/*               message ITEM_ST_ATTR_03_NO           
                    ITEM_ST_ATTR_04_NO
               ITEM_ST_ATTR_05_NO ITEM_ST_ATTR_06_NO ITEM_ST_ATTR_07_NO ITEM_ST~_ATTR_08_NO.     */
               
                   tt-323.RECORD_STATUS            = "A"
                   tt-323.CREATE_USER_ID           = "ADMCOM"
                   tt-323.CREATE_DATETIME          = vsysdata
                   tt-323.LAST_UPDATE_USER_ID      = "ADMCOM"
                   tt-323.LAST_UPDATE_DATETIME     = vsysdata.
        end. /* vtemmix */
    end. /* for each estab ... */


 procedure mix-moda.

    def output parameter par-tem-mix as log.
    par-tem-mix = no.

    for each tt-estab-mix.
        delete tt-estab-mix.
    end.

    /* Tratar mix desativados 03/10/2013 */
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod = 0
                        and mixmprod.situacao = no
                      no-lock.

        /* Estabs do grupo */
        for each mixmgruetb where mixmgruetb.codgrupo = mixmprod.codgrupo
                            no-lock.
            find tt-estab-mix where tt-estab-mix.etbcod     = mixmgruetb.etbcod
                            no-error.
            if not avail tt-estab-mix
            then create tt-estab-mix.
            assign
                tt-estab-mix.etbcod     = mixmgruetb.etbcod
                tt-estab-mix.situacao   = no.
        end.
    end.    
    /* Definir os estabelecimentos do produto */
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod = 0
                        and mixmprod.situacao
                      no-lock.
        find mixmgrupo of mixmprod no-lock.

        /* Estabs do grupo */
        for each mixmgruetb where mixmgruetb.codgrupo = mixmprod.codgrupo
                              and mixmgruetb.situacao
                            no-lock.
            par-tem-mix = yes.

            find tt-estab-mix where tt-estab-mix.etbcod = mixmgruetb.etbcod
                              no-error.
            if not avail tt-estab-mix or
               tt-estab-mix.situacao = no
            then do.
                if not avail tt-estab-mix
                then do.
                    create tt-estab-mix.
                    assign
                        tt-estab-mix.etbcod     = mixmgruetb.etbcod.
                end.
                assign
                    tt-estab-mix.codgrupo   = mixmgruetb.codgrupo
                    tt-estab-mix.prioridade = mixmgrupo.prioridade
                    tt-estab-mix.estmax     = mixmprod.estmax
                    tt-estab-mix.estmin     = mixmprod.estmin
                    tt-estab-mix.situacao   = yes.
            end.
            else do.
                /* Estab ja incluido - verificar prioridade */
                if mixmgrupo.prioridade < tt-estab-mix.prioridade
                then
                    assign
                        tt-estab-mix.codgrupo   = mixmgruetb.codgrupo
                        tt-estab-mix.prioridade = mixmgrupo.prioridade
                        tt-estab-mix.estmax     = mixmprod.estmax
                        tt-estab-mix.estmin     = mixmprod.estmin.
            end.
        end.
    end.

    /* Acertar excecoes de min e max */
        
    for each mixmprod where mixmprod.procod = produ.procod
                        and mixmprod.etbcod > 0
                        and mixmprod.situacao
                      no-lock.
                                                            /**/
        find tt-estab-mix where tt-estab-mix.etbcod = mixmprod.etbcod 
                          no-error.
        if not avail tt-estab-mix
        then next.
        
        if tt-estab-mix.codgrupo = mixmprod.codgrupo
        then assign
            tt-estab-mix.estmax     = mixmprod.estmax
            tt-estab-mix.estmin     = mixmprod.estmin.
    end.

end procedure.


/*
*
*    tt-323.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-323
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5.
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer btt-323       for tt-323.
def var vtt-323         like tt-323.store_id.


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

bl-princ:
repeat:

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-323 where recid(tt-323) = recatu1 no-lock.
    if not available tt-323
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-323).
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-323
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
            find tt-323 where recid(tt-323) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-323.store_id)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-323.store_id)
                                        else "".
            run color-message.
            choose field tt-323.store_id help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                       PF4 F4 ESC return) .
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
                    if not avail tt-323
                    then leave.
                    recatu1 = recid(tt-323).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-323
                    then leave.
                    recatu1 = recid(tt-323).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-323
                then next.
                color display white/red tt-323.store_id with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-323
                then next.
                color display white/red tt-323.store_id with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-323
                 with frame f-tt-323 color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-323 on error undo.
                    create tt-323.
                    update tt-323.
                    recatu1 = recid(tt-323).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-323.
                    disp tt-323.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-323 on error undo.
                    find tt-323 where
                            recid(tt-323) = recatu1 
                        exclusive.
                    update tt-323.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-323.store_id
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-323 where true no-error.
                    if not available tt-323
                    then do:
                        find tt-323 where recid(tt-323) = recatu1.
                        find prev tt-323 where true no-error.
                    end.
                    recatu2 = if available tt-323
                              then recid(tt-323)
                              else ?.
                    find tt-323 where recid(tt-323) = recatu1
                            exclusive.
                    delete tt-323.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltt-323.p (input 0).
                    else run ltt-323.p (input tt-323.store_id).
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
        recatu1 = recid(tt-323).
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
    tt-323.STORE_ID     format "x(5)" label "Estab"
/*     tt-323.SKU_ID      format "x(10)"*/

    int( tt-323.MIN_STK_QTY) / 10000 column-label "M I X!Minimo" format ">>>>>9"
    int( tt-323.MAX_STK_QTY) / 10000 column-label "M I X!Maximo" format ">>>>>9"
     
    int(tt-323.ITEM_ST_ATTR_01_NO ) / 10000 column-label "Estoque"  format ">>>>>9"
    dec(tt-323.ITEM_ST_ATTR_03_NO) / 10000  column-label "ICMS!Credito" format ">>9.99"
    dec(tt-323.ITEM_ST_ATTR_04_NO) / 10000  column-label "ICM!Debito"  format ">>9.99"
    dec(tt-323.ITEM_ST_ATTR_05_NO) / 10000 column-label "PIS!Credito" format ">>9.99"
    dec(tt-323.ITEM_ST_ATTR_06_NO) / 10000 column-label "PIS!Debito" format ">>9.99"
    dec(tt-323.ITEM_ST_ATTR_07_NO) / 10000 column-label "COFINS!Credito" format ">>9.99"
    dec(tt-323.ITEM_ST_ATTR_08_NO) / 10000 column-label "COFINS!Debito" format ">>9.99"

        with frame frame-a 7 down centered color white/red row 9
        overlay
                title "  MIX 323 - produto " + string(produ.procod)  
                                + " " + 
                                produ.pronom
                .
end procedure.
procedure color-message.
color display message
        tt-323.store_id
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-323.store_id
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-323 where true
                                                no-lock no-error.
    else  
        find last tt-323  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-323  where true
                                                no-lock no-error.
    else  
        find prev tt-323   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-323 where true  
                                        no-lock no-error.
    else   
        find next tt-323 where true 
                                        no-lock no-error.
        
end procedure.
         

