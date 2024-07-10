/*               to
*                                 R
*
*/

{admcab.i}
def var xtime as int.
def var vconta as int.

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
    initial ["<contratos>","  <marca>","  <todos>"," <enviar>"," "].

if pstatus <> "enviar" and pstatus <> "transferir"
then do:
    esqcom1[2] = "". 
    esqcom1[3] = "".
    esqcom1[4] = "".   
end.    

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
    field vlf_principal  like contrato.vlf_principal
    field vlf_acrescimo  like contrato.vlf_acrescimo
    field vlentra  like contrato.vlentra 
    field vlseguro    like contrato.vlseguro
    field vltotal    like contrato.vltotal


    index idx is unique primary 
        cobcod asc
        datamov asc 
        dtenvio  asc
        lotnum
        ctmcod asc
        modcod asc
        tpcontrato asc            
     index idx2 marca asc datamov asc   .

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
        ttsicred.vlf_principal  format    ">>>>>>9" column-label "princ"
        ttsicred.vlf_acrescimo  format    ">>>>>>9" column-label "acres"
        ttsicred.vlseguro       format    ">>>>>9" column-label "segur"
        ttsicred.vltotal        format    ">>>>>>9" column-label "total"
        with frame frame-a 9 down centered row 7
        no-box.

run fin/marcasic200.p.

if pstatus = "ENVIAR"
then run fin/opesicemivalid.p (pstatus).

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
        hide message no-pause.
                 
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
                
                
                /**
            if keyfunction(lastkey) = "L" or
               keyfunction(lastkey) = "l"
            then do:
                hide frame fcab no-pause.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.                
                run fin/fqanadoc.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttsicred.ctmcod,
                            ttsicred.modcod,
                            ttsicred.tpcontrato,
                            ttsicred.etbcod,
                            ttsicred.cobcod).

                leave.
            end.

                **/
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = "<contratos>"
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run fin/opesicemictr.p (poperacao,
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
                ttsicred.marca = not ttsicred.marca.
                disp ttsicred.marca with frame frame-a. 
                next.
            end.
            if esqcom1[esqpos1] = "  <todos>"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttsicred.marca.
                for each bttsicred.
                    bttsicred.marca = not vmarca.
                end.
                leave.
            end.
            
            if esqcom1[esqpos1] = " <enviar>"
            then do:
                        disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

                message "confirma gerar arquivo?" update sresp.
                if sresp
                then     run fin/opesicemienvia.p (poperacao, pstatus).
                
                recatu1 = ?. 
                run montatt.                                                        
                leave.
                
            end.

                /**    
                pfiltro = esqcom1[esqpos1].
                hide frame fcab no-pause.
                hide frame frame-a no-pause.                
                poldfiltro = ttsicred.filtro.
                run fin/telapdvdocref.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttsicred.ctmcod,
                            ttsicred.carteira,
                            ttsicred.modcod,
                            ttsicred.tpcontrato,
                            ttsicred.etbcod,
                            ttsicred.cobcod).
                pfiltro = poldfiltro.            
                hide frame frame-a no-pause.
                view frame fcab.
                leave.
                **/
                
             
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
        vlf_principal
        vlf_acrescimo
        vlseguro
        ttsicred.vltotal

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
        ttsicred.vlf_principal
        ttsicred.vlf_acrescimo
        ttsicred.vlseguro
        ttsicred.vltotal
                    
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
        ttsicred.vlf_principal
        ttsicred.vlf_acrescimo
        ttsicred.vlseguro
        ttsicred.vltotal
                    
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
        ttsicred.vlf_principal
        ttsicred.vlf_acrescimo
        ttsicred.vlseguro
        ttsicred.vltotal

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

xtime = time.

for each ttsicred.
    delete ttsicred.
end.

vconta = 0.

for each cobra where cobra.sicred = yes no-lock.
    
    if pstatus = "ENVIAR" or pstatus = "TRANSFERIR" or pstatus = "ERRO"
    then 
        for each sicred_contrato where
            sicred_contrato.operacao = poperacao and
            sicred_contrato.cobcod   = cobra.cobcod   and
            sicred_contrato.sstatus  = pstatus 
             no-lock.
            /* 08/2020 
                https://trello.com/c/3GmeuWDQ/102-chamado-30360-exporta%C3%A7%C3%A3o-contratos-lebes-financeira
            */ 
            find contrato where contrato.contnum = sicred_contrato.contnum no-lock.
 
            /*helio 51077 122020
            if contrato.dtinicial >= today
            then next.*/
             
            run gravatt.
        end.
    else
        for each sicred_contrato where
            sicred_contrato.operacao = poperacao and
            sicred_contrato.cobcod   = cobra.cobcod   and
            sicred_contrato.sstatus  = pstatus and
            sicred_contrato.datamov  >= vdtini and
            sicred_contrato.datamov  <= vdtfin
             no-lock.
            run gravatt.
        end.
            
end.

hide message no-pause.
           
end procedure.


procedure gravatt.
def var vtpcontrato     like contrato.tpcontrato.

    find lotefin where 
            lotefin.lotnum = sicred_contrato.lotnum no-lock no-error.
    
    find contrato where contrato.contnum = sicred_contrato.contnum no-lock.
    if contrato.dtinicial >= 06/01/2020
    then vtpcontrato = contrato.tpcontrato.
    else do:
        find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = 1
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
                    titulo.titpar     = 1 and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                end.
            vtpcontrato = if avail titulo
                      then titulo.tpcontrato
                      else "".
    end.
    
    vconta = vconta + 1.
    
    if vconta mod 1000 = 0
    then do:
        hide message no-pause.
        message color normal "fazendo calculos... aguarde... " string(time - xtime,"HH:MM:SS").
    end.
        
    find first ttsicred where
        ttsicred.cobcod  = sicred_contrato.cobcod and            
        ttsicred.datamov = sicred_contrato.datamov and
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?) and
        ttsicred.lotnum  = (if avail lotefin
                           then lotefin.lotnum
                           else ?) and
                           
        ttsicred.ctmcod  = sicred_contrato.ctmcod  and
        ttsicred.modcod  = contrato.modcod         and
        ttsicred.tpcontrato = vtpcontrato
        no-error.
    if not avail ttsicred
    then do:
        create ttsicred.
        ttsicred.cobcod  = sicred_contrato.cobcod.
        ttsicred.datamov = sicred_contrato.datamov.
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?).
        ttsicred.lotnum = (if avail lotefin
                           then lotefin.lotnum
                           else ?).
        
        ttsicred.ctmcod  = sicred_contrato.ctmcod.
        ttsicred.modcod  = contrato.modcod.
        ttsicred.tpcontrato = vtpcontrato.
    end.
    ttsicred.qtd = ttsicred.qtd + 1.
    ttsicred.vlf_principal = ttsicred.vlf_principal + contrato.vlf_principal.
    ttsicred.vlf_acrescimo = ttsicred.vlf_acrescimo + contrato.vlf_acrescimo.
    ttsicred.vlentra = ttsicred.vlentra + contrato.vlentra.
    ttsicred.vlseguro = ttsicred.vlseguro + contrato.vlseguro.
    ttsicred.vltotal = ttsicred.vltotal + contrato.vltotal.
 

end procedure.
