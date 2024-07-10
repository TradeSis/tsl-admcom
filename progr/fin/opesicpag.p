/* 26112021 helio venda carteira */
{admcab.i}
def var pfiltro as char.
def input param poperacao as char.
def input param pstatus   as char.


def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<parcelas>","  <marca>","  <todos>"," <enviar>"," "].
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def new shared temp-table ttsicred no-undo
    field marca     as log format "*/ "
    field cobcod    like titulo.cobcod     
    field dtenvio   like lotefin.datexp
    field lotnum    like lotefin.lotnum
    
    field datamov   like pdvforma.datamov
    field ctmcod    like pdvforma.ctmcod        
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field qtd       as int 

    field titvlcob       like pdvdoc.titvlcob
    field valor_encargo  like pdvdoc.valor_encargo
    field desconto       like pdvdoc.desconto
    field valor          like pdvdoc.valor


    index idx is unique primary 
        cobcod asc
        dtenvio  asc
        datamov asc 
        ctmcod asc
        modcod asc
        tpcontrato asc  
        lotnum          .
def buffer bttsicred for ttsicred.


def var vfiltro as char.

    vfiltro = 
                caps(poperacao) + "/" + caps(pstatus).
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        ttsicred.marca format "*/ " column-label "*"
        cobra.cobnom format "x(07)" column-label "prop"
        ttsicred.datamov format "999999" column-label "data"
        ttsicred.dtenvio format "999999" column-label "envio"
        ttsicred.ctmcod  format "x(03)" column-label "cod"
        pdvtmov.ctmnom   format "x(09)" column-label "oper"
        ttsicred.modcod  format "x(03)" column-label "mod"
        ttsicred.tpcontrato format "x" column-label "tp"
        ttsicred.qtd format ">>>>"    column-label "qtd"  

        ttsicred.titvlcob  format    "->>>>>9" column-label "princ"
        ttsicred.valor_encargo  format    "->>>>>9" column-label "juros"
        ttsicred.desconto       format    "->>>>9" column-label "descon"
        ttsicred.valor          format    "->>>>>9" column-label "total"
        
        with frame frame-a 9 down centered row 7
        no-box.

if pstatus = "ENVIAR"
then run fin/opesicpagvalid.p (pstatus).

run montatt.




/**disp 
    space(32)
    vtitvlcob    no-label          format   "-zzzzzzz9.99"
    vjuros       no-label           format     "-zzzzz9.99"
    vdescontos   no-label        format     "-zzzzz9.99"
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.
**/


bl-princ:
repeat:


/**disp
    vtitvlcob
    vjuros
    vdescontos
    vtotal   

        with frame ftot.
**/

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttsicred where recid(ttsicred) = recatu1 no-lock.
    if not available ttsicred
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttsicred).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttsicred
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttsicred where recid(ttsicred) = recatu1 no-lock.

        status default "".
        
                        
        /**                        
        esqcom1[1] = if ttsicred.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttsicred.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttsicred.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttsicred.carteira = ? or
                        ttsicred.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttsicred.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttsicred.cobcod = ?
                     then "Propriedade"
                     else "".
        **/
                     
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        if ttsicred.lotnum <> ?
        then  message color normal "exportado no lote" ttsicred.lotnum "em" ttsicred.dtenvio.

        choose field ttsicred.datamov
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                if ttsicred.marca = no
                then run color-normal.
                else run color-input. 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttsicred
                    then leave.
                    recatu1 = recid(ttsicred).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttsicred
                    then leave.
                    recatu1 = recid(ttsicred).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttsicred
                then next.
                color display white/red ttsicred.datamov with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttsicred
                then next.
                color display white/red ttsicred.datamov with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
                
            if keyfunction(lastkey) = "L" or
               keyfunction(lastkey) = "l"
            then do:
            end.

                
                
        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = "<parcelas>"
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run fin/opesicpagdoc.p (poperacao,
                                        ttsicred.cobcod,
                                        pstatus,
                                        ttsicred.datamov,
                                        ttsicred.ctmcod,
                                        ttsicred.modcod,
                                        ttsicred.tpcontrato).
                leave.
                
            end.

            if esqcom1[esqpos1] = "  <marca>"
            then do:
                find first bttsicred where bttsicred.marca = yes and bttsicred.cobcod <> ttsicred.cobcod
                    no-error.
                if avail bttsicred
                then do:
                    hide message no-pause.
                    find cobra where cobra.cobcod = bttsicred.cobcod no-lock.
                    message "Existem" cobra.cobnom "Marcados".
                    pause 2 no-message. 
                end.
                else do:
                    ttsicred.marca = not ttsicred.marca.
                    disp ttsicred.marca with frame frame-a. 
                end.    
                next.
            end.
            if esqcom1[esqpos1] = "  <todos>"
            then do:
                def var vmarca as log.
                find first bttsicred where bttsicred.marca = yes and bttsicred.cobcod <> ttsicred.cobcod
                    no-error.
                if avail bttsicred
                then do:
                    hide message no-pause.
                    find cobra where cobra.cobcod = bttsicred.cobcod no-lock.
                    message "Existem" cobra.cobnom "Marcados".
                    pause 2 no-message. 
                end.
                else do:
                    vmarca = ttsicred.marca.
                    for each bttsicred where bttsicred.cobcod = ttsicred.cobcod.
                        bttsicred.marca = not vmarca.
                    end.
                end.
                leave.
            end.
            if esqcom1[esqpos1] = " <enviar>"
            then do: 
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1. 

                find first bttsicred where bttsicred.marca = yes  no-error.
                if not avail bttsicred
                then do:
                    message "Nenhum registro marcado".
                    next.
                end.
                find cobra where cobra.cobcod = bttsicred.cobcod no-lock.  

                message "confirma gerar arquivo" poperacao cobra.cobcod cobra.cobnom "?" update sresp.
                if sresp
                then do: 
                    if cobra.cobcod = 10
                    then do:
                        if poperacao = "CANCELAMENTO"
                        then run fin/opesiccanenvia.p (poperacao, pstatus).
                        else if poperacao = "ESTORNO"
                             then run fin/opesicestenvia.p (poperacao, pstatus).
                             else do:
                                run fin/opesicpagenvia.p (poperacao, pstatus).
                            end.     
                    end.
                    if cobra.cobcod = 14
                    then do:
                        if poperacao = "CANCELAMENTO" or
                           poperacao = "ESTORNO"
                        then do:
                            message "Ainda nao existe layout para esta operacao".
                            pause.
                            leave.
                        end.
                        if poperacao = "PAGAMENTO"
                        then do:
                            run fin/opefidcpagenvia.p (poperacao,pstatus).
                        end.   
                    end.
                    /* helio 21122021 retirado do projeto
                    *if cobra.cobcod = 16
                    *then do:
                    *    if poperacao = "PAGAMENTO"
                    *    then do:
                    *        run finct/opefidcpagenvia16.p (poperacao,pstatus).
                    *    end.
                    *end.        
                    */
                end.    
                
                recatu1 = ?. 
                run montatt.                                                        
                leave.
                
            end.
            
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttsicred).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find cobra where cobra.cobcod = ttsicred.cobcod no-lock.
    find pdvtmov where pdvtmov.ctmcod = ttsicred.ctmcod no-lock.
    display  
        ttsicred.marca
        cobra.cobnom        
        ttsicred.datamov
        ttsicred.dtenvio
        ttsicred.ctmcod
        pdvtmov.ctmnom
        ttsicred.modcod
        ttsicred.tpcontrato
        ttsicred.qtd     
        ttsicred.titvlcob
        ttsicred.valor_encargo
        ttsicred.desconto
        ttsicred.valor

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        cobra.cobnom
        ttsicred.datamov
        ttsicred.dtenvio
        ttsicred.ctmcod
        pdvtmov.ctmnom 
        ttsicred.modcod 
        ttsicred.tpcontrato
        ttsicred.qtd 
        ttsicred.titvlcob
        ttsicred.valor_encargo
        ttsicred.desconto
        ttsicred.valor
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        cobra.cobnom
        ttsicred.datamov
        ttsicred.dtenvio
        ttsicred.ctmcod
        pdvtmov.ctmnom 
        ttsicred.modcod 
        ttsicred.tpcontrato
        ttsicred.qtd 
        ttsicred.titvlcob
        ttsicred.valor_encargo
        ttsicred.desconto
        ttsicred.valor
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        cobra.cobnom
        ttsicred.datamov
        ttsicred.dtenvio
        ttsicred.ctmcod
        pdvtmov.ctmnom 
        ttsicred.modcod 
        ttsicred.tpcontrato
        ttsicred.qtd 
        ttsicred.titvlcob
        ttsicred.valor_encargo
        ttsicred.desconto
        ttsicred.valor

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttsicred  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttsicred where
            no-lock no-error.
    end.
    else do:
        find first ttsicred
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttsicred  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttsicred where
            no-lock no-error.
    end.
    else do:
        find next ttsicred
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttsicred  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttsicred where
            no-lock no-error.
    end.
    else do:
        find prev ttsicred
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure montatt.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each ttsicred.
    delete ttsicred.
end.

for each cobra where cobra.sicred = yes and not (cobra.cobcod = 16 or cobra.cobcod = 14) no-lock.
    if pstatus = "ENVIAR"
    then 
        for each sicred_pagam where
            sicred_pagam.operacao = poperacao and
            sicred_pagam.cobcod   = cobra.cobcod   and
            sicred_pagam.sstatus  = pstatus 
             no-lock.
             
             
            run gravatt.      
    end.
    else 
        for each sicred_pagam where
            sicred_pagam.operacao = poperacao and
            sicred_pagam.cobcod   = cobra.cobcod   and
            sicred_pagam.sstatus  = pstatus and
            sicred_pagam.datamov  >= vdtini and
            sicred_pagam.datamov  <= vdtfin
             no-lock.
            run gravatt.      
    end.
    
end.

hide message no-pause.
           
end procedure.


procedure gravatt.
    find lotefin where 
            lotefin.lotnum = sicred_pagam.lotnum no-lock no-error.
    find contrato where contrato.contnum = sicred_pagam.contnum no-lock.

        find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = sicred_pagam.titpar
                      no-lock no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     = sicred_pagam.titpar and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                    if not avail titulo then next.
                end.
 
        find first pdvmov where 
                pdvmov.etbcod = sicred_pagam.etbcod and
                pdvmov.cmocod = sicred_pagam.cmocod and
                pdvmov.datamov = sicred_pagam.datamov and
                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
     
    find first ttsicred where
        ttsicred.cobcod  = sicred_pagam.cobcod and            
        ttsicred.datamov = sicred_pagam.datamov and
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?) and
        ttsicred.lotnum  = (if avail lotefin
                           then lotefin.lotnum
                           else ?) and
        ttsicred.ctmcod  = sicred_pagam.ctmcod  and
        ttsicred.modcod  = titulo.modcod         and
        ttsicred.tpcontrato = titulo.tpcontrato
        no-error.
    if not avail ttsicred
    then do:
        create ttsicred.
        ttsicred.cobcod  = sicred_pagam.cobcod.
        ttsicred.datamov = sicred_pagam.datamov.
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?).
        ttsicred.lotnum = (if avail lotefin
                           then lotefin.lotnum
                           else ?).
        ttsicred.ctmcod  = sicred_pagam.ctmcod.
        ttsicred.modcod  = titulo.modcod.
        ttsicred.tpcontrato = titulo.tpcontrato.
    end.
    ttsicred.qtd = ttsicred.qtd + 1.
    
    ttsicred.titvlcob = ttsicred.titvlcob + pdvdoc.titvlcob.
    ttsicred.valor_encargo = ttsicred.valor_encargo + pdvdoc.valor_encargo.
    ttsicred.desconto = ttsicred.desconto + pdvdoc.desconto.
    ttsicred.valor = ttsicred.valor + pdvdoc.valor.
 

end procedure.



