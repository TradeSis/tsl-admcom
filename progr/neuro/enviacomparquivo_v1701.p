/*
#1 08.11.18 - TP 27238470 - Otimizacao
*/
{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var varqsai as char.
def var vdtenvio as date.
def var vhrenvio as int.

vdtenvio = today.
vhrenvio = time.

    varqsai = "/admcom/tmp/neuro/" +
              string(year(vdtenvio),"9999") +
              string(month(vdtenvio),"99") +
              string(day(vdtenvio),"99")   +
              "_" + 
              replace(string(vhrenvio,"HH:MM:SS"),":","") +
              "_" +
              "comportamento.csv".

def var vt as int.              
def var vsep as char init ";".


vt = 0.
    
for each neuclien
        where compsitenvio = "ENVIAR"
        no-lock.

    find clien where clien.clicod = neuclien.clicod no-lock no-error.
    if not avail clien   
    then next.
 
    vt = vt + 1.
    leave. /* #1 */
end.
if vt = 0
then do:
    message today string(time,"HH:MM:SS") "      Sem Clientes para gerar!".
    return.
end.

message today string(time,"HH:MM:SS") /* #1 "      Encontrou" vt "Clientes" */
                                      " Abrindo arquivo" varqsai.
vt = 0.
output to value(varqsai).

    put unformatted

    "PROP_CONTACLIDB"     vsep        
    "PROP_CHDEVOLV"     vsep   
    "PROP_DTCHDEVOL"     vsep  
    "PROP_VALORCHDEVOLV"     vsep  
    "PROP_SALDOTOTNOV"     vsep    
    "PROP_SALDOVENCNOV"     vsep   
    "PROP_ATRASONOV"     vsep  
    "PROP_QTDENOV"     vsep    
    "PROP_DTCADASTRODB"     vsep 
    "PROP_LIMITEATUALDB"     vsep    
    "PROP_VALIDADELIMDB"     vsep    
    "PROP_LIMITETOMDB"     vsep  
    "PROP_LIMITEDISPDB"     vsep 
    "PROP_QTDECONT"     vsep   
    "PROP_PARCPAG"     vsep    
    "PROP_PARCABERT"     vsep  
    "PROP_DTULTCPA"     vsep   
    "PROP_ATRASOPARCDB"     vsep 
    "PROP_ATRASOPARCPERCDB"     vsep 
    "PROP_MEDIACONT"     vsep  
    "PROP_MAIORACUM"     vsep  
    "PROP_DTMAIORACUM"     vsep    
    "PROP_PARCMEDIA"     vsep  
    "PROP_ATRASOATUALDB"     vsep    
    "PROP_DTMAIORATRASO"     vsep  
    "PROP_VLRPARCVENC"     vsep    
    "PROP_VLRPAGO"     vsep    
    "PROP_PONTUAL"     vsep    
    "PROP_ATRASOMEDIO"     vsep    
    "PROP_MAIORATRASO"     vsep    
    "PROP_DTNASCCLIDB"     vsep  
    "PROP_JUROVENDA"     vsep  
    "PROP_JUROATRASO"     vsep 
    "PROP_CONTRATO100"     vsep    
    "PROP_CONTRATO350"     vsep    
    "PROP_CONTRATO800"     vsep    
    "PROP_CONTRATO1500"     vsep   
    "PROP_CONTMAIOR1500"     vsep  
    "PROP_PROFISSAODB"     vsep  
    "PROP_RENDAMESDB"     vsep   
    "PROP_LOGRADCLIDB"     vsep  
    "PROP_NUMERODB"     vsep 
    "PROP_CEPDB"     vsep    
    "PROP_BAIRROCLIDB"     vsep  
    "PROP_CIDADEDB"     vsep 
    "PROP_UFDB"     vsep 
    "PROP_NOTADB"     vsep   
    "PROP_ATRASO4MESES"     vsep   
    "PROP_DTULTPAGTO"     vsep 
    "PROP_MAIORCONT"     vsep  
    "PROP_LSTCOMPROMET"  vsep   
    "PROP_TOTALNOV"      vsep
    "PROP_CPFCLIBD"      vsep   
    "PRP_NOMECLIBD".
    
    
for each neuclien
        where compsitenvio = "ENVIAR"
        no-lock.

    find clien where clien.clicod = neuclien.clicod no-lock no-error.
    if not avail clien   
    then next.
    
    vt = vt + 1.
    
    run neuro/comportamento.p (neuclien.clicod,
                               ?,
                               output var-propriedades).

    var-salaberto = dec(pega_prop("LIMITETOM")).
    var-sallimite  = neuclien.vlrlimite - var-salaberto.
    
    put unformatted skip

    neuclien.clicod     vsep        
    pega_prop("CHDEVOLV")    vsep   
    pega_prop("DTCHDEVOL")     vsep  
    pega_prop("VALORCHDEVOLV")   vsep  
    pega_prop("SALDOTOTNOV")     vsep    
    pega_prop("SALDOVENCNOV")     vsep   
    pega_prop("ATRASONOV")     vsep  
    pega_prop("QTDENOV")     vsep    
    neuclien.dtcad /*"PROP_DTCADASTRO")*/     vsep 
    neuclien.vlrlimite  /*"PROP_LIMITEATUAL" */    vsep    
    neuclien.vctolimite /*"PROP_VALIDADELIM" */    vsep    
    var-salaberto       /*"PROP_LIMITETOM"   */  vsep  
    var-sallimite       /*"PROP_LIMITEDISP"  */   vsep 
    pega_prop("QTDECONT")     vsep   
    pega_prop("PARCPAG")     vsep    
    pega_prop("PARCABERT")     vsep  
    pega_prop("DTULTCPA")     vsep   
    pega_prop("ATRASOPARC")     vsep 
    pega_prop("ATRASOPARCPERC")     vsep 
    pega_prop("MEDIACONT")     vsep  
    pega_prop("MAIORACUM")     vsep  
    pega_prop("DTMAIORACUM")     vsep    
    pega_prop("PARCMEDIA")     vsep  
    pega_prop("ATRASOATUAL")     vsep    
    pega_prop("DTMAIORATRASO")     vsep  
    pega_prop("VLRPARCVENC")     vsep    
    pega_prop("VLRPAGO")     vsep    
    pega_prop("PONTUAL")     vsep    
    pega_prop("ATRASOMEDIO")     vsep    
    pega_prop("MAIORATRASO")     vsep    
    pega_prop("DTNASCCLI")     vsep  
    pega_prop("JUROVENDA")     vsep  
    pega_prop("JUROATRASO")     vsep 
    pega_prop("CONTRATO100")     vsep    
    pega_prop("CONTRATO350")     vsep    
    pega_prop("CONTRATO800")     vsep    
    pega_prop("CONTRATO1500")     vsep   
    pega_prop("CONTMAIOR1500")     vsep  
    clien.proprof[1]  /*pega_prop("PROFISSAO") */    vsep  
    pega_prop("RENDAMES")     vsep   
    clien.endereco[1] /*pega_prop("LOGRADCLI") */    vsep  
    clien.numero[1]   /* pega_prop("NUMERO")   */  vsep 
    clien.cep[1]        /*pega_prop("CEP")     */ vsep    
    clien.bairro[1]   /* pega_prop("BAIRROCLI")*/     vsep  
    clien.cidade[1]   /*pega_prop("CIDADE") */    vsep 
    clien.ufecod[1]  /*pega_prop("UF") */    vsep 
    pega_prop("NOTA")     vsep   
    pega_prop("ATRASO4MESES")     vsep   
    pega_prop("DTULTPAGTO")     vsep 
    pega_prop("MAIORCONT")     vsep  
    pega_prop("LSTCOMPROMET")  vsep
    pega_prop("TOTALNOV")   vsep       
    trim(clien.ciccgc)      vsep   
    trim(clien.clinom).

    run p.
     
end.

output close.

message today string(time,"HH:MM:SS") "      Fechando arquivo" varqsai.

message today string(time,"HH:MM:SS") "      Enviados" vt "Clientes.".

procedure p.
    do on error undo:
         find current neuclien exclusive.
         assign
             neuclien.compsitenvio = "ENVIADO"
             neuclien.compdtultenvio = today.
    end.                                
end procedure.

