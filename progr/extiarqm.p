def temp-table tt-titulo like titulo.
def temp-table tt-clien like clien.
def temp-table tt-forne like forne.
def temp-table tt-contrato like contrato.
def var sresp as log format "Sim/Nao".
def var vqtd like tt-contrato.vltotal.
def var varq as char.
def var varq1 as char.
def var vcliente as char.
def var vciccgc like clien.ciccgc.
def var vciinsc like clien.ciinsc.
def var vcep    like clien.cep.
def var vcompl like clien.compl.
def var vdata as date.
def var vdti as date.
def var vdtf as date.
def var voperacao as char.
def var vsinal as char.
def var trecebe as dec.
def var tjuro as dec.
def var tdevol as dec.
def stream stela.
do on error undo:
    update vdti label "Periodo de" format "99/99/9999"
           vdtf label "Ate"        format "99/99/9999"
           with frame f-data 1 down centered side-label.
end.
if opsys = "unix" 
then varq = "/admcom/audit/receber." + string(day(vdti)) + "a" +
                        string(day(vdtf)) + string(month(vdtf)) + string(year(vdtf)).
else varq = "l:\audit\receber." + string(day(vdti)) + "a" +
        string(day(vdtf)) + string(month(vdtf)) + string(year(vdtf)).

    message "Confirma exportacao? " update sresp.
    if sresp = no
    then return.


def var tprazo as dec.
form with frame f-stream 1 down centered no-box row 7 no-label.

output stream stela to terminal.

output to value(varq).

def buffer bestab for estab.

def buffer bsispro for sispro.

do vdata = vdti to vdtf:
    disp stream stela 
            "Exportando Contas a Receber... " at 1
            vdata with frame f-stream.
    pause 0.
    find sispro where sispro.codred = 15 no-lock.
    for each contarqm where 
             contarqm.dtinicial = vdata no-lock:
         if contarqm.situacao <> 9
         then next.
         find clien where 
                    clien.clicod = contarqm.clicod 
                    no-lock no-error.
         if not avail clien 
            or clien.clicod = 0
         then next.
            
         vcliente  = "C" + string(clien.clicod,"9999999999").
         
         put unformatted
            contarqm.etbcod format ">>9"
            vcliente "       "
            "CON"
            string(contarqm.contnum) format "x(12)"
            year(contarqm.dtinicial) format "9999"
            month(contarqm.dtinicial) format "99"
            day(contarqm.dtinicial) format "99"
            "C  "         format "!!!"
            contarqm.vltotal * 100 format "9999999999999999"
            "+"
            year(contarqm.dtinicial) format "9999"
            month(contarqm.dtinicial) format "99"
            day(contarqm.dtinicial) format "99"
            contarqm.vltotal * 100 format "9999999999999999"
            year(contarqm.dtinicial) format "9999"
            month(contarqm.dtinicial) format "99"
            day(contarqm.dtinicial) format "99"
            string(contarqm.contnum) format "x(12)"
            sispro.codest format "x(28)"
            "CADASTRAMENTO" format "x(150)"
            skip
            .
        
        tprazo = tprazo + contarqm.vltotal.
            
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
        
    end.
    find sispro where sispro.codred = 15 no-lock.
    for each tituarqm where 
            tituarqm.titdtpag = vdata no-lock:
        if tituarqm.titnat = yes
        then next.
        if tituarqm.titsit <> "PAG"
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.

        vcliente  = "C" + string(clien.clicod,"9999999999").

        put unformatted
            tituarqm.etbcod format ">>9"
            vcliente "       "
            "CON"
            tituarqm.titnum format "x(12)"
            year(tituarqm.titdtpag) format "9999"
            month(tituarqm.titdtpag) format "99"
            day(tituarqm.titdtpag) format "99"
            "R  "         format "!!!"
            tituarqm.titvlcob * 100 format "9999999999999999"
            "-"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titvlcob * 100 format "9999999999999999"
            year(tituarqm.titdtven) format "9999"
            month(tituarqm.titdtven) format "99"
            day(tituarqm.titdtven) format "99"
            tituarqm.titnum + "/" + string(tituarqm.titpar) format "x(12)"
            sispro.codest format "x(28)"
            "PAGAEMNTOS" format "x(150)"
            skip
            .
        
        trecebe = trecebe + tituarqm.titvlcob.
        
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
        if tituarqm.titvljur > 0
        then do:
            find bsispro where bsispro.codred = 234 no-lock.
            put unformatted
            tituarqm.etbcod format ">>9"
            vcliente "       "
            "CON"
            tituarqm.titnum format "x(12)"
            year(tituarqm.titdtpag) format "9999"
            month(tituarqm.titdtpag) format "99"
            day(tituarqm.titdtpag) format "99"
            "J  "         format "!!!"
            tituarqm.titvljur * 100 format "9999999999999999"
            "-"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titvljur * 100 format "9999999999999999"
            year(tituarqm.titdtven) format "9999"
            month(tituarqm.titdtven) format "99"
            day(tituarqm.titdtven) format "99"
            tituarqm.titnum + "/" + string(tituarqm.titpar) format "x(12)"
            bsispro.codest format "x(28)"
            "JUROS RECEBIDOS" format "x(150)"
            skip
            .

            tjuro = tjuro + tituarqm.titvljur.

        end.
    end.
end.  
find sispro where sispro.codred = 163 no-lock no-error.

def var vdata1 as date. 
do vdata1 = vdti to vdtf:
    disp stream stela 
            "Exportando Devolucao ..." at 1
            vdata1  with frame f-stream.
    pause 0.

    for each tituarqm where
         tituarqm.empcod = 19 and
         tituarqm.titnat = yes and
         tituarqm.modcod = "DEV" and
         tituarqm.titdtven = vdata1
         no-lock:
        if tituarqm.clifor = 1
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.

        vcliente  = "C" + string(clien.clicod,"9999999999").
        put unformatted
            tituarqm.etbcod format ">>9"
            vcliente "       "
            "NF "
            tituarqm.titnum format "x(12)"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            "R  "         format "!!!"
            tituarqm.titvlcob * 100 format "9999999999999999"
            "-"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titvlcob * 100 format "9999999999999999"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titnum + "/" + string(tituarqm.titpar) format "x(12)"
            sispro.codest format "x(28)"
            "DEVOLUCAO VENDA" format "x(150)"
            skip
            .
        tdevol = tdevol + tituarqm.titvlcob.
        
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
    end.
    for each tituarqm where
         tituarqm.empcod = 19 and
         tituarqm.titnat = no and
         tituarqm.modcod = "CRE" and
         tituarqm.titdtemi >= vdti and
         tituarqm.titdtemi <= vdtf and
         tituarqm.moecod = "DEV"
         no-lock:
        if tituarqm.clifor = 1
        then next.
        find clien where clien.clicod = tituarqm.clifor no-lock no-error.
        if not avail clien or
            clien.clicod = 0 then next.

        vcliente  = "C" + string(clien.clicod,"9999999999").
        put unformatted
            tituarqm.etbcod format ">>9"
            vcliente "       "
            "NF "
            tituarqm.titnum format "x(12)"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            "R  "         format "!!!"
            tituarqm.titvlcob * 100 format "9999999999999999"
            "-"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titvlcob * 100 format "9999999999999999"
            year(tituarqm.titdtemi) format "9999"
            month(tituarqm.titdtemi) format "99"
            day(tituarqm.titdtemi) format "99"
            tituarqm.titnum + "/" + string(tituarqm.titpar) format "x(12)"
            sispro.codest format "x(28)"
            "DEVOLUCAO VENDA" format "x(150)"
            skip
            .
        tdevol = tdevol + tituarqm.titvlcob.
        
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
    end.
end.        
for each lanctbcx where lanctbcx.datlan >= vdti and
                        lanctbcx.datlan <= vdtf 
                        no-lock:
    if lanctb.lancod = 1297
    then find sispro where sispro.codred = 20  no-lock no-error.
    if lanctb.lancod = 1298
    then find sispro where sispro.codred = 17  no-lock no-error.

    find forne where forne.forcod = lanctbcx.forcod no-lock.
    
    vcliente  = "C" + string(forne.forcod,"9999999999").
    if lanctbcx.lantip = "C"
    then  assign voperacao = "R" vsinal = "-".
    else  assign voperacao = "C" vsinal = "+".
    put unformatted
            lanctbcx.cxacod format ">>9"
            vcliente "       "
            "REC"
            lanctbcx.titnum format "x(12)"
            year(lanctbcx.datlan) format "9999"
            month(lanctbcx.datlan) format "99"
            day(lanctbcx.datlan) format "99"
            voperacao        format "!!!"
            lanctbcx.vallan * 100 format "9999999999999999"
            vsinal format "x"
            year(lanctbcx.datlan) format "9999"
            month(lanctbcx.datlan) format "99"
            day(lanctbcx.datlan) format "99"
            lanctbcx.vallan * 100 format "9999999999999999"
            year(lanctbcx.datlan) format "9999"
            month(lanctbcx.datlan) format "99"
            day(lanctbcx.datlan) format "99"
            string(lanctbcx.titnum) format "x(12)"
            sispro.codest format "x(28)"
            lanctbcx.comhis format "x(150)"
            skip
            .

        find first tt-forne where
                   tt-forne.forcod = forne.forcod no-error.
        if not avail tt-forne
        then do:
            create tt-forne.
            buffer-copy forne to tt-forne.
        end.           
                   
        /*
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
        **/ 
 
end.                        
                        
output close.

if opsys = "unix" 
then varq1 = "/admcom/audit/clientes." + string(day(vdti)) + "a" +
                        string(month(vdtf)) + string(year(vdtf),"9999").
else varq1 = "l:\audit\clientes." + string(day(vdti)) + "a" +
                        string(month(vdtf)) + string(year(vdtf),"9999").

output to value(varq1).

for each tt-clien where tt-clien.clicod <> 0,
    first clien where clien.clicod = tt-clien.clicod no-lock:
    /*
    if clien.ciccgc = ""
    then next.
     */
    disp stream stela 
            "Exportando Clientes ..." at 1
            clien.ciccgc with frame f-stream.
    pause 0.
    

    vcliente  = "C" + string(clien.clicod,"9999999999").
    vciccgc   = clien.ciccgc.
    vciinsc   = clien.ciinsc.
    vcep[1]   = clien.cep[1].
    vcompl[1] = clien.compl[1].
    if vciccgc = ? then vciccgc = "". 
    if vciinsc = ? then vciinsc = "".
    if vcep[1] = ? then vcep[1] = "".
    if vcompl[1] = ? then vcompl[1] = "".
    put unformatted
        vcliente "       " /* 001-018 */ 
        vciccgc                 format "x(18)"        /* 019-036 */
        vciinsc                 format "x(20)"        /* 037-056 */
        " "                     format "x(14)"        /* 057-070 */
        clien.clinom            format "x(70)"        /* 071-140 */
        " "                     format "x(70)"        /* 141-210 */
        clien.endereco[1]       format "x(50)"        /* 211-280 */
        string(clien.numero[1]) format "x(10)"       
        vcompl[1]               format "x(10)"       
        clien.bairro[1]         format "x(20)"        /* 281-300 */
        clien.cidade[1]         format "x(50)"        /* 301-350 */
        clien.ufecod[1]         format "x(02)"        /* 351-352 */
        vcep[1]                 format "x(08)"        /* 353-360 */
        "BRA"                   format "x(06)"        /* 361-366 */
        "BRASIL "               format "x(20)"        /* 367-386 */
        skip.
             
             
end.
for each tt-forne where tt-forne.forcod <> 0,
    first forne where forne.forcod = tt-forne.forcod no-lock:
    /*
    if clien.ciccgc = ""
    then next.
    */
    disp stream stela 
            "Exportando Clientes ..." at 1
            clien.ciccgc with frame f-stream.
    pause 0.
    

    vcliente  = "C" + string(forne.forcod,"9999999999").
    vciccgc   = forne.forcgc.
    vciinsc   = forne.forinest.
    vcep[1]   = forne.forcep.
    vcompl[1] = forne.forcomp.
    if vciccgc = ? then vciccgc = "". 
    if vciinsc = ? then vciinsc = "".
    if vcep[1] = ? then vcep[1] = "".
    if vcompl[1] = ? then vcompl[1] = "".
    put unformatted
        vcliente "       " /* 001-018 */ 
        vciccgc                 format "x(18)"        /* 019-036 */
        vciinsc                 format "x(20)"        /* 037-056 */
        " "                     format "x(14)"        /* 057-070 */
        forne.fornom            format "x(70)"        /* 071-140 */
        " "                     format "x(70)"        /* 141-210 */
        forne.forrua            format "x(50)"        /* 211-280 */
        string(forne.fornum) format "x(10)"       
        vcompl[1]               format "x(10)"       
        forne.forbairro            format "x(20)"        /* 281-300 */
        forne.formunic            format "x(50)"        /* 301-350 */
        forne.ufecod            format "x(02)"        /* 351-352 */
        vcep[1]                 format "x(08)"        /* 353-360 */
        "BRA"                   format "x(06)"        /* 361-366 */
        "BRASIL "               format "x(20)"        /* 367-386 */
        skip.
             
             
end.
output close.
output stream stela close.

message color red/with
    "Arquivos gerados" skip
    varq skip
    varq1 skip(1)
    "Emissoes=" string(tprazo,">>>,>>>,>>9.99") 
    "Recebimentos=" string(trecebe,">>>,>>>,>>9.99")   skip
    "Juros=" string(tjuro,">>>,>>>,>>9.99") 
    "Devolucoes=" string(tdevol,">>>,>>>,>>9.99")
    view-as alert-box title " Atencao "
    .
