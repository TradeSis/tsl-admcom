/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
    #2 HelioNeto 06.11.2018 - Layout separado por tipo de carteira, similar ao frsalcart.p
                            - Retirado testes #1
    #3 Helio.Neto 24.01.19 - Nao gera mais PDF 
*/

def input parameter varqlog as char.

{/admcom/progr/admcab-batch.i}

def buffer bestab for estab. /*#2*/
def var vdata as date. /*#2*/
def var wcrenov like titulo.titvlcob. /*#2*/
 
def var varqpdf as char extent 3.

def var vdia as int.
def var vmes as int.
def var vano as int.

def var p-dti as date extent 3.
def var p-dtf as date extent 3.

if month(today) = 1
then assign
        vmes = 10
        vano = year(today) - 1.
else if month(today) = 2
    then assign
            vmes = 11
            vano = year(today) - 1.
    else if month(today) = 3
        then assign
                vmes = 12
                vano = year(today) - 1.
        else assign
                vmes = month(today) - 3
                vano = year(today).

assign
    p-dti[1] = date(vmes,01,vano)
    p-dtf[1] = date(if vmes = 12 then 1 else vmes + 1,1,
              if vmes = 12 then vano + 1 else vano) - 1
    p-dti[2] = date(if vmes = 12 then 1 else vmes + 1,01,
                  if vmes = 12 then vano + 1 else vano)
    p-dtf[2] = date(if vmes = 11 then 1 else
                    if vmes = 12 then 2 
                    else vmes + 2,1,
                    if vmes >= 11 then vano + 1 else vano) - 1
    p-dti[3] = date(if vmes = 11 then 1 else
                    if vmes = 12 then 2 
                    else vmes + 2,1,
                    if vmes >= 11 then vano + 1 else vano) 

    /**helio 06.01.2017
    p-dtf[3] = date(if vmes = 11 then 2 else
                    if vmes = 12 then 3 
                    else vmes + 3,1,
                    if vmes >= 11 then vano + 1 else vano) - 1
    .                
    **/
    
    p-dtf[3] = date(if vmes = 10 then 1 else
                    if vmes = 11 then 2 else
                    if vmes = 12 then 3 
                    else vmes + 3,1,
                    if vmes >= 10 then vano + 1 else vano) - 1.

message  p-dti[1] p-dtf[1] p-dti[2] p-dtf[2] p-dti[3] p-dtf[3].
pause 0.

def var etb-tit like estab.etbcod.

def temp-table tt-etbtit /*#2*/ no-undo
    field etbcod like estab.etbcod
    field titvlcob like fin.titulo.titvlcob
    /* #2 */
    field fei    like titulo.titvlcob
    field lp     like titulo.titvlcob
    field nov    like titulo.titvlcob
    field cre    like titulo.titvlcob
    /* #2 */
    
    index i1 /*#2*/ is unique primary etbcod asc.
 
def var tot-vencido as dec format ">>>,>>>,>>9.99".
def var tot-vencer as dec format ">>>,>>>,>>9.99".

def var vi as int.

def var varquivo as char extent 3.

do vi = 1 to 3:


    varquivo[vi] = "/admcom/relat/vencidos_periodo" + 
                string(p-dti[vi],"99999999") + "_" +
                string(p-dtf[vi],"99999999")
                /* #3 */ + ".txt".
                
        
    for each tt-etbtit: delete tt-etbtit. end.
    
        for each estab no-lock:
            find first tt-etbtit where
                tt-etbtit.etbcod = estab.etbcod no-error.
            if not avail tt-etbtit
            then do:
                create tt-etbtit.
                tt-etbtit.etbcod = estab.etbcod.
            end.    
            do vdata = p-dti[vi] to p-dtf[vi]: /*#2*/
             for each fin.titulo use-index titdtven
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = "CRE" and
                       fin.titulo.etbcod = estab.etbcod and
                       fin.titulo.titdtven = vdata /*#2*/
                       no-lock:

                etb-tit = fin.titulo.etbcod.
                run muda-etb-tit.
                if fin.titulo.titsit <> "LIB" 
                then next.
    
                /*#2*/
                                
                find first tt-etbtit where
                    tt-etbtit.etbcod = etb-tit no-error.
                if not avail tt-etbtit
                then do:
                    create tt-etbtit.
                    tt-etbtit.etbcod = etb-tit.
                end. 
                tt-etbtit.titvlcob = tt-etbtit.titvlcob + fin.titulo.titvlcob.
                    /* #2 */
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
                       titulo.tpcontrato = "L" 
                    then do:
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then 
                          tt-etbtit.fei = tt-etbtit.fei + titulo.titvlcob.
                        else
                          tt-etbtit.lp  = tt-etbtit.lp  + titulo.titvlcob.
                    end.
                    else do:
                        if titulo.tpcontrato = "N"
                        then
                           tt-etbtit.nov  = tt-etbtit.nov + titulo.titvlcob.
                        else
                           tt-etbtit.cre  = tt-etbtit.cre + titulo.titvlcob.
                    end.                
                    /* #2 */
            
             end.
            end. /*#2 DATA */ 
        end.
    
    run relatorio.
    
end.

def var vassunto as char.

do vi = 1 to 3:
 
    vassunto = "VENCIDOS NO PERIODO " + string(vi).
    
    if search(varqpdf[vi]) <> ?
    then do:
        run envia_info_anexo.p(input "1043", input varqlog,
                input varqpdf[vi], input vassunto).
    end.
    pause 2 no-message.
end.

procedure muda-etb-tit.

    if etb-tit = 10 and
        fin.titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.

procedure relatorio:

    {mdad.i
    &Saida     = "value(varquivo[vi])" 
    &Page-Size = "0"
    &Cond-Var  = "140"
    &Page-Line = "0"
    &Nom-Rel   = """"
    &Nom-Sis   = """SISTEMA DE CREDIARIO H061118"""
    &Tit-Rel   = """POSICAO VENCIDOS PERIODO DE "" + 
                     string(p-dti[vi],""99/99/9999"") + "" A "" +
                     string(p-dtf[vi],""99/99/9999"")"
    &Width     = "140"
    &Form      = "frame f-cabcab"}

    for each tt-etbtit where tt-etbtit.titvlcob > 0:
        find first bestab where
                   bestab.etbcod = tt-etbtit.etbcod no-lock no-error. 

        wcrenov = tt-etbtit.nov + tt-etbtit.cre. /* #2 */

        disp tt-etbtit.etbcod   column-label "Filial"
             bestab.etbnom no-label  when avail bestab format "x(15)"
             tt-etbtit.titvlcob(total) column-label "(1+2+3+4) Total"
              /* #2 */
             tt-etbtit.fei (total) column-label "(1) Feirao"
             tt-etbtit.lp  (total) column-label "(2) LP" 
             tt-etbtit.nov (total) column-label "(3) Novacao"
             tt-etbtit.cre (total) column-label "(4) Venda"
             wcrenov (total) column-label "(3+4) Crediario"
            /* #2 */
            with frame f1 down width 140.
                       
    end.         
    output close.

    varqpdf[vi] = varquivo[vi] /* #3 .pdf" */ .

    /*#3run /admcom/progr/ger-arq-PDF.p(input varquivo[vi], input varqpdf[vi]).*/

end procedure.