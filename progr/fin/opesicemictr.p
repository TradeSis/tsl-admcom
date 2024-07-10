/*               to
*                                 R
*
*/

{admcab.i}

def var pfiltro as char.
def input param poperacao   like sicred_contrato.operacao.
def input param pcobcod     like sicred_contrato.cobcod.
def input param pstatus     like sicred_contrato.sstatus.
def input param pdatamov    like sicred_contrato.datamov.
def input param pctmcod     like sicred_contrato.ctmcod.
def input param pmodcod     like contrato.modcod.
def input param ptpcontrato like contrato.tpcontrato.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<parcelas>","<Operacao>"," "," "," "].
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

if poperacao = "NOVACAO"
then esqcom1[3] = "<Novacao>".
def var par-dtini as date.
def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.


def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    index idx is unique primary tipo desc contnum asc.


def  temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field psicred   as recid
    index idx is unique primary 
        psicred asc.
        
def buffer bttcontrato for ttcontrato.
        
def var vfiltro as char.

    vfiltro = caps(poperacao) + "/" + caps(pstatus).
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        ttcontrato.marca format "*/ " column-label "*"
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        contrato.clicod 
        contrato.vlentra       column-label "entrada"
                                     format ">>>9.99"
        contrato.vlf_principal column-label "principal"
                                     format ">>>>>9.99"
        
        contrato.vlf_acrescimo column-label "acrescimo"
                                     format ">>>>>9.99"
        
        contrato.vlseguro      column-label " seguro"
                                     format ">>>9.99"
        
        contrato.vltotal       column-label "total" 
                                     format ">>>>>9.99"
        
        contrato.nro_parcela   column-label "par"
                                  format    ">>9"

        with frame frame-a 9 down centered row 7
        no-box.

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
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
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

    recatu1 = recid(ttcontrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcontrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcontrato where recid(ttcontrato) = recatu1 no-lock.

        status default "".
        
                        
        /**                        
        esqcom1[1] = if ttcontrato.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttcontrato.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttcontrato.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttcontrato.carteira = ? or
                        ttcontrato.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttcontrato.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttcontrato.cobcod = ?
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

        choose field contrato.contnum
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                if ttcontrato.marca = no
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
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcontrato
                then next.
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = "<parcelas>"
            then do:
                find sicred_contrato where recid(sicred_contrato) = ttcontrato.psicred
                    no-lock.
                run conco_v1701.p (string(sicred_contrato.contnum)).
            end.
            if esqcom1[esqpos1] = "<operacao>"
            then do:
                find sicred_contrato where recid(sicred_contrato) = ttcontrato.psicred
                    no-lock.
                find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock .

                run dpdv/pdvcope.p (recid(pdvmov)).
            end.
            if esqcom1[esqpos1] = "<novacao>"
            then do:
                find sicred_contrato where recid(sicred_contrato) = ttcontrato.psicred
                    no-lock.
                find first pdvmov where 
                    pdvmov.etbcod = sicred_contr.etbcod and
                    pdvmov.cmocod = sicred_contr.cmocod and
                    pdvmov.datamov = sicred_contr.datamov and
                    pdvmov.sequencia = sicred_contr.sequencia
                no-lock .
                    hide frame f-com1 no-pause.
                    find pdvtmov where pdvtmov.ctmcod = pdvmov.ctmcod no-lock.
                    if pdvtmov.novacao
                    then run fin/fqnovmov.p (recid(pdvmov)).

            end.
            
            
            if esqcom1[esqpos1] = "  <marca>"
            then do:
                ttcontrato.marca = not ttcontrato.marca.
                disp ttcontrato.marca with frame frame-a. 
                next.
            end.
            if esqcom1[esqpos1] = "  <todos>"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttcontrato.marca.
                for each bttcontrato.
                    bttcontrato.marca = not vmarca.
                end.
                leave.
            end.
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcontrato).
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
    find sicred_contrato where recid(sicred_contrato) = ttcontrato.psicred
        no-lock.
    find contrato of sicred_contrato no-lock.    
    display  
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
        contrato.vlentra
        contrato.vlseguro
        contrato.vltotal
        contrato.nro_parcela

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
        contrato.vlentra
        contrato.vlseguro
        
        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
                contrato.vlentra
        contrato.vlseguro

        contrato.vltotal
        contrato.nro_parcela

                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.marca
        contrato.etbcod 
        contrato.contnum 
        contrato.clicod 
        contrato.vlf_principal
        contrato.vlf_acrescimo
                contrato.vlentra
        contrato.vlseguro

        contrato.vltotal
        contrato.nro_parcela


        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttcontrato where
            no-lock no-error.
    end.
    else do:
        find first ttcontrato
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttcontrato where
            no-lock no-error.
    end.
    else do:
        find next ttcontrato
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttcontrato where
            no-lock no-error.
    end.
    else do:
        find prev ttcontrato
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure montatt.
def var vtpcontrato like contrato.tpcontrato.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each ttcontrato.
    delete ttcontrato.
end.
for each sicred_contrato where
        sicred_contrato.operacao = poperacao and
        sicred_contrato.cobcod   = pcobcod   and
        sicred_contrato.sstatus  = pstatus and
        sicred_contrato.datamov  = pdatamov and
        sicred_contrato.ctmcod    = pctmcod
         no-lock.
    find lotefin where 
            lotefin.lotnum = sicred_contrato.lotnum no-lock no-error.
    find contrato where contrato.contnum = sicred_contrato.contnum no-lock.
    
    /* 08/2020 
                https://trello.com/c/3GmeuWDQ/102-chamado-30360-exporta%C3%A7%C3%A3o-contratos-lebes-financeira
            */ 

    /*helio 51077 122020
    if pstatus = "ENVIAR"
    then  if contrato.dtinicial >= today 
          then next.*/

    if contrato.modcod <> pmodcod then next.
     
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
    if vtpcontrato <> ptpcontrato then next.
    
    create ttcontrato.
    ttcontrato.psicred = recid(sicred_contrato).
        
end.

hide message no-pause.
           
end procedure.

