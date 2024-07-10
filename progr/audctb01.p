{admcab.i}
def new shared temp-table tt-clien like clien.

def new shared temp-table tt-resumo
    field etbcod like estab.etbcod 
    field vprazo as dec
    field ventra as dec
    field vprest as dec
    index i1 etbcod.
    .
     
     
form vet1 like estab.etbcod label "Filial"
     vet2 like estab.etbcod label "Ate"
     vdti as date format "99/99/9999" label "Periodo de"   at 1
     vdtf as date format "99/99/9999" label "Ate"
     with frame f-data 1 down centered side-label
     .

update vet1 validate(vet1 > 0,"")
        with frame f-data.
        
update  vet2 validate(vet2 > 0,"")
        with frame f-data.

update vdti vdtf with frame f-data.
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
        "Periodo invalido"
        view-as alert-box.
    undo.
end.

def var tprazo as dec.
def var tentrada as dec.
def var tprestacao as dec.

def var vcod as char format "x(18)".
def var varq as char.
def var varq1 as char.
def var sresp as log format "Sim/Nao".

def var vdata as date.
def stream stela.

output stream stela to terminal.

/**** Exportando Contas a Receber *********/

if opsys = "unix" 
then varq = "/admcom/audit/receber.txt".
else varq = "l:~\audit~\receber.txt".

    message "Confirma exportacao? " update sresp.
    if sresp = no
    then return.

def new shared temp-table tt-contrato like contrato.

form with frame f-stream 1 down centered no-box row 7 no-label.

output to value(varq).

def buffer bestab for estab.

for each bestab where bestab.etbcod >= vet1 and
                      bestab.etbcod <= vet2
                      no-lock:

    assign
        tprazo = 0 tentrada = 0 tprestacao = 0.
        
    disp stream stela 
        "Contas A Receber (C)..." at 1
        bestab.etbcod with frame f-stream.
    pause 0.

    find first tt-resumo where
               tt-resumo.etbcod = bestab.etbcod
               no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.etbcod = bestab.etbcod.
    end.
                 
    run calprazo.p ( input bestab.etbcod,
                        input vdti,
                        input vdtf ).
                           

    for each tt-contrato:                               
         find clien where 
                    clien.clicod = tt-contrato.clicod 
                    no-lock no-error.
         disp stream stela 
            tt-contrato.contnum with frame f-stream.
         pause 0.

         put unformatted
            tt-contrato.etbcod format ">>9"
            clien.clicod  format ">>>>>>>>>>>>>>>>>9"
            "DUP"
            string(tt-contrato.contnum) format "x(12)"
            year(tt-contrato.dtinicial) format "9999"
            month(tt-contrato.dtinicial) format "99"
            day(tt-contrato.dtinicial) format "99"
            clien.cidade[1] format "x(50)"
            clien.ufecod     format "!!"
            "C  "         format "!!!"
            tt-contrato.vltotal / 100 format "9999999999999999"
            "+"
            year(tt-contrato.dtinicial) format "9999"
            month(tt-contrato.dtinicial) format "99"
            day(tt-contrato.dtinicial) format "99"
            tt-contrato.vltotal / 100 format "9999999999999999"
            year(tt-contrato.dtinicial) format "9999"
            month(tt-contrato.dtinicial) format "99"
            day(tt-contrato.dtinicial) format "99"
            string(tt-contrato.contnum) format "x(12)"
            "15" format "x(28)"
            "CADASTRAMENTO" format "x(150)"
            skip
            .
        
        tprazo = tprazo + tt-contrato.vltotal.
            
        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
    end.
    tt-resumo.vprazo = tprazo.
    for each titold where titold.etbcobra = bestab.etbcod and
                      titold.titdtpag >= vdti and
                      titold.titdtpag <= vdtf no-lock.
        if titold.clifor = 1
        then next.
        if titold.titnat = yes
        then next.
        if titold.modcod <> "CRE"
        then next.
        
        find clien where clien.clicod = titold.clifor no-lock no-error.
        if not avail clien then next.
    
        disp stream stela 
            "Contas A Receber (R)..." at 1
            clien.clicod titold.titnum with frame f-stream.
        pause 0.

        if titold.etbcod = bestab.etbcod and
           titold.titpar = 0
        then do:
            tentrada = tentrada + titold.titvlcob. 
        end.
        else do:
            tprestacao = tprestacao + titold.titvlcob.
        end.

            put unformatted
            titold.etbcod format ">>9"
            titold.clifor  format ">>>>>>>>>>>>>>>>>9"
            "DUP"
            titold.titnum format "x(12)"
            year(titold.titdtpag) format "9999"
            month(titold.titdtpag) format "99"
            day(titold.titdtpag) format "99"
            clien.cidade[1] format "x(50)"
            clien.ufecod     format "!!"
            "R  "         format "!!!"
            titold.titvlcob / 100 format "9999999999999999"
            "-"
            year(titold.titdtemi) format "9999"
            month(titold.titdtemi) format "99"
            day(titold.titdtemi) format "99"
            titold.titvlcob / 100 format "9999999999999999"
            year(titold.titdtven) format "9999"
            month(titold.titdtven) format "99"
            day(titold.titdtven) format "99"
            titold.titnum + "/" + string(titold.titpar) format "x(12)"
            "162" format "x(28)"
            "BAIXA" format "x(150)"
            skip
            .

        find first tt-clien where
               tt-clien.clicod = clien.clicod no-error.
        if not avail tt-clien
        then do:
            create tt-clien.
            buffer-copy clien to tt-clien.
        end.
    end.
    tt-resumo.ventra = tentrada.
    tt-resumo.vprest = tprestacao.
end.


output close.

/*** Exportando clientes ****/


if opsys = "unix" 
then varq1 = "/admcom/audit/clientes.txt".
else varq1 = "l:~\audit~\clientes.txt".

output to value(varq).

for each tt-clien,
    first clien where clien.clicod = tt-clien.clicod no-lock:

    if clien.ciccgc = ""
    then next.

    disp stream stela 
            "Cadastro P. Fisica ..." at 1
            clien.ciccgc with frame f-stream.
    pause 0.

    put unformatted
        clien.clicod        format ">>>>>>>>>>>>>>>>>9"    /* 001-018 */
        clien.ciccgc        format "x(18)"        /* 019-036 */
        clien.ciinsc        format "x(20)"        /* 037-056 */
        " "                 format "x(14)"        /* 057-070 */
        clien.clinom        format "x(70)"        /* 071-140 */
        " "                 format "x(70)"        /* 141-210 */
        clien.endereco[1]       format "x(50)"        /* 211-280 */
        string(clien.numero[1]) format "x(10)"       
        clien.compl[1]          format "x(10)"       
        clien.bairro[1]         format "x(20)"        /* 281-300 */
        clien.cidade[1]         format "x(50)"        /* 301-350 */
        clien.ufecod[1]         format "x(02)"        /* 351-352 */
        clien.cep[1]            format "x(08)"        /* 353-360 */
        "BRA"                format "x(06)"        /* 361-366 */
        "BRASIL "            format "x(20)"        /* 367-386 */
        skip.
             
             
end.
output close.
              
output stream stela close.              

message color red/with
    skip
    "Arquivos gerados  " varq skip
    "                  " varq1 skip
    view-as alert-box.

def var varquivo as char.
sresp = yes.

message "Emitir resumo dos dados exportados? "
 update sresp.
if sresp
then do:
    if opsys = "UNIX"
    then varquivo = "/admcom/audit/resu-receber." + string(time).
    else varquivo = "l:~\audit~\resu-receber." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""audctb01""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """RESUMO EXPORTACAO RECEBER PARA AUDTI"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    for each tt-resumo:
        find estab where estab.etbcod = tt-resumo.etbcod no-lock.
        disp tt-resumo.etbcod  column-label "Filial"
             estab.etbnom no-label   format "x(20)"
             tt-resumo.vprazo(total) 
             column-label "Venda Prazo" format ">>>>>,>>9.99"
             tt-resumo.ventra(total)
             column-label "Entradas"    format ">>>>>,>>9.99"
             tt-resumo.vprest(total)
             column-label "Prestacoes"  format ">>>>>,>>9.99"
            with frame f-resumo down.
        down with frame f-resumo.
    end.        
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end. 
end.
return.



