/*               to
*                                 R
*
*/

{admcab.i}

def var pfiltro as char.
/*
def input param poperacao   like sicred_pagam.operacao.
def input param pcobcod     like sicred_pagam.cobcod.
*/

def input param pstatus     like sicred_pagam.sstatus.
def input param pdescerro   like sicred_pagam.descerro.
/*
def input param pdatamov    like sicred_pagam.datamov.
def input param pctmcod     like sicred_pagam.ctmcod.
def input param pmodcod     like contrato.modcod.
def input param ptpcontrato like contrato.tpcontrato.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
*/

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



def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<titulo>","<operacao>"," "," "," "].
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def  temp-table ttpdvdoc no-undo
    field marca     as log format "*/ "
    field psicred   as recid
    index idx is unique primary 
        psicred asc.
        
def buffer bttpdvdoc for ttpdvdoc.
        
/*def var vfiltro as char.

    vfiltro = /**caps(poperacao) + "/" +**/ caps(pstatus).
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.*/

    form  
        ttpdvdoc.marca format "*/ " column-label "*"

        cobra.cobnom format "x(07)" column-label "prop"
        pdvdoc.datamov  column-label "Data" format "999999"
        
        pdvtmov.ctmnom   format "x(09)" column-label "oper"
        
        titulo.modcod  format "x(03)" column-label "mod"
        titulo.tpcontrato format "x" column-label "tp"

        pdvdoc.etbcod   column-label "Etb" format ">>9"
        cmon.cxacod   column-label "Cx" format ">>" 
        titulo.titnum
        pdvdoc.titvlcob column-label "Vlr!Nominal"     format "->>>>>9.99"      
        pdvdoc.valor   column-label "Total!Pago" format "->>>>>9.99"
         skip space(12) "-->>" sicred_pagam.descerro no-label
         skip(1)
                
                with frame frame-a 5 down centered row 5 
                width 80 overlay no-box no-underline.

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
    else find ttpdvdoc where recid(ttpdvdoc) = recatu1 no-lock.
    if not available ttpdvdoc
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

    recatu1 = recid(ttpdvdoc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttpdvdoc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttpdvdoc where recid(ttpdvdoc) = recatu1 no-lock.

        status default "".
        
                        
        /**                        
        esqcom1[1] = if ttpdvdoc.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttpdvdoc.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttpdvdoc.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttpdvdoc.carteira = ? or
                        ttpdvdoc.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttpdvdoc.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttpdvdoc.cobcod = ?
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

        choose field ttpdvdoc.marca
                      help "[E]xporta para Arquivo csv"

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      E e
                      tab PF4 F4 ESC return).

                if ttpdvdoc.marca = no
                then run color-normal.
                else run color-input. 
        pause 0. 
            if keyfunction(lastkey) = "E"
            then do:
                run geracsv.
                leave.
            end.

                                                                
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
                    if not avail ttpdvdoc
                    then leave.
                    recatu1 = recid(ttpdvdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttpdvdoc
                    then leave.
                    recatu1 = recid(ttpdvdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttpdvdoc
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttpdvdoc
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = "  <marca>"
            then do:
                ttpdvdoc.marca = not ttpdvdoc.marca.
                disp ttpdvdoc.marca with frame frame-a. 
                next.
            end.
            if esqcom1[esqpos1] = "  <todos>"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttpdvdoc.marca.
                for each bttpdvdoc.
                    bttpdvdoc.marca = not vmarca.
                end.
                leave.
            end.

                    if esqcom1[esqpos1] = "<titulo>"
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.

    
                        find sicred_pagam where recid(sicred_pagam) = ttpdvdoc.psicred no-lock.
                        find first pdvmov where 
                                pdvmov.etbcod = sicred_pagam.etbcod and
                                pdvmov.cmocod = sicred_pagam.cmocod and
                                pdvmov.datamov = sicred_pagam.datamov and
                                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                                
                                no-lock .
                        find pdvdoc of pdvmov where
                                pdvdoc.seqreg = sicred_pagam.seqreg
                                no-lock.
                        
                        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                                          titulo.titpar = pdvdoc.titpar
                                          no-lock no-error.
                        find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
    
                        if not avail titulo
                        then do:
                            find first titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.modcod = contrato.modcod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titpar = pdvdoc.titpar and
                            titulo.titdtemi = contrato.dtinicial
                            no-lock no-error.
                        end.
                        if avail titulo 
                        then run bsfqtitulo.p ( input recid(titulo)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                     

                    if esqcom1[esqpos1] = "<operacao>"
                    then do:
                        hide frame f-com2   no-pause.
                        hide frame f-com1   no-pause.
                        hide frame frame-a  no-pause.
                        hide frame fcab     no-pause.
                        hide frame f1       no-pause.
                        find sicred_pagam where recid(sicred_pagam) = ttpdvdoc.psicred no-lock.
                        find first pdvmov where 
                                pdvmov.etbcod = sicred_pagam.etbcod and
                                pdvmov.cmocod = sicred_pagam.cmocod and
                                pdvmov.datamov = sicred_pagam.datamov and
                                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                                no-lock .
                        run dpdv/pdvcope.p ( input recid(pdvmov)).
                        pause 0.
                        view frame f-com2   . pause 0.
                        view frame f-com1   . pause 0.
                        view frame frame-a  . pause 0.
                        view frame fcab     . pause 0.
                        view frame f1       . pause 0.
                    end.
                    
 
                /**    
                pfiltro = esqcom1[esqpos1].
                hide frame fcab no-pause.
                hide frame frame-a no-pause.                
                poldfiltro = ttpdvdoc.filtro.
                run fin/telapdvdocref.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttpdvdoc.ctmcod,
                            ttpdvdoc.carteira,
                            ttpdvdoc.modcod,
                            ttpdvdoc.tpcontrato,
                            ttpdvdoc.etbcod,
                            ttpdvdoc.cobcod).
                pfiltro = poldfiltro.            
                hide frame frame-a no-pause.
                view frame fcab.
                leave.
                **/
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttpdvdoc).
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

    find sicred_pagam where recid(sicred_pagam) = ttpdvdoc.psicred
        no-lock.
 
        find first pdvmov where 
                pdvmov.etbcod = sicred_pagam.etbcod and
                pdvmov.cmocod = sicred_pagam.cmocod and
                pdvmov.datamov = sicred_pagam.datamov and
                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
 
    find cmon   of pdvmov no-lock.
    find pdvtmov of pdvmov no-lock.
    find cobra of sicred_pagam no-lock.    
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
                    titulo.titpar     = sicred_pagam.titpar 
                    no-lock no-error.
                end.
    
    display
        ttpdvdoc.marca
        cobra.cobnom
        pdvdoc.etbcod
        cmon.cxacod
        pdvdoc.datamov
        pdvtmov.ctmnom 
        titulo.modcod when avail titulo
        titulo.tpcontrato when avail titulo
        
            trim(string(pdvdoc.contnum) + (if pdvdoc.titpar > 0
                                  then "/" + string(pdvdoc.titpar)
                                  else "")) @ titulo.titnum
        
        pdvdoc.titvlcob
        pdvdoc.valor   
            when pdvdoc.placod = 0 or pdvdoc.placod = ?

        sicred_pagam.descerro


        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttpdvdoc.marca
        cobra.cobnom
        pdvdoc.etbcod
        cmon.cxacod
        pdvdoc.datamov
        pdvtmov.ctmnom 
        titulo.modcod 
        titulo.tpcontrato 
        
                                  titulo.titnum
        
        pdvdoc.titvlcob
        pdvdoc.valor   
        sicred_pagam.descerro

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttpdvdoc.marca
        cobra.cobnom
        pdvdoc.etbcod
        cmon.cxacod
        pdvdoc.datamov
        pdvtmov.ctmnom 
        titulo.modcod 
        titulo.tpcontrato 
        
                                  titulo.titnum
        
        pdvdoc.titvlcob
        pdvdoc.valor   
        sicred_pagam.descerro

                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttpdvdoc.marca
        cobra.cobnom
        pdvdoc.etbcod
        cmon.cxacod
        pdvdoc.datamov
        pdvtmov.ctmnom 
        titulo.modcod 
        titulo.tpcontrato 
        
                                  titulo.titnum
        
        pdvdoc.titvlcob
        pdvdoc.valor   

        sicred_pagam.descerro

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttpdvdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttpdvdoc where
            no-lock no-error.
    end.
    else do:
        find first ttpdvdoc
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttpdvdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttpdvdoc where
            no-lock no-error.
    end.
    else do:
        find next ttpdvdoc
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttpdvdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttpdvdoc where
            no-lock no-error.
    end.
    else do:
        find prev ttpdvdoc
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure montatt.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each ttpdvdoc.
    delete ttpdvdoc.
end.
for each sicred_pagam where
/*        sicred_pagam.operacao = poperacao and
        sicred_pagam.cobcod   = pcobcod   and*/
        sicred_pagam.sstatus  = pstatus /*and
        sicred_pagam.datamov  = pdatamov and
        sicred_pagam.ctmcod    = pctmcod*/
         no-lock.
 
    if sicred_pagam.descerro <> pdescerro
        then next.
    create ttpdvdoc.
    ttpdvdoc.psicred = recid(sicred_pagam).
        
end.

hide message no-pause.
           
end procedure.



procedure geracsv.

    find first ttpdvdoc no-error.
    if not avail ttpdvdoc then return.
    find sicred_contrato where recid(sicred_contrato) = ttpdvdoc.psicred
        no-lock.
        def var verro as char.
    verro = replace(sicred_contrato.descerro," ","")    .
    verro = replace(verro,"/","").
    verro = substring(lc(verro),1,20).
    def var ccarteira as char.
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/financeira/erros_" + string(today,"999999")  + "_" +  verro + "_" + 
                        replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
   
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title " arquivo de saida".

   
            output to value(varq).    
                put unformatted
                    "propriedade" vcp
                    "filial" vcp
                    "data" vcp
                    "operacao" vcp
                    "modal" vcp
                    "tp" vcp
                    "contrato" vcp
                    "parcela" vcp
                    "valor" vcp
                    "erro" vcp
                    skip.

    for each ttpdvdoc.
        
        find sicred_pagam where recid(sicred_pagam) = ttpdvdoc.psicred
            no-lock.
 
        find first pdvmov where 
                pdvmov.etbcod = sicred_pagam.etbcod and
                pdvmov.cmocod = sicred_pagam.cmocod and
                pdvmov.datamov = sicred_pagam.datamov and
                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
 
            find cmon   of pdvmov no-lock.
        find pdvtmov of pdvmov no-lock.
        find cobra of sicred_pagam no-lock.    
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
                    titulo.titpar     = sicred_pagam.titpar 
                    no-lock no-error.
                end.
    
        put unformatted 
            cobra.cobnom vcp
            pdvdoc.etbcod  vcp
            pdvdoc.datamov vcp
            pdvtmov.ctmnom vcp
            titulo.modcod  vcp
            titulo.tpcontrato vcp
            pdvdoc.contnum vcp
            pdvdoc.titpar vcp
            pdvdoc.titvlcob vcp
            sicred_pagam.descerro vcp

            skip.
        

    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.




