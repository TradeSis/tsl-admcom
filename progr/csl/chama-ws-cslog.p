/* helio 06022023 - ID 155445 - cslog enviou no csml o campo idAcordoLebes, com este id fazendo teste se numero de acordo inicia com 9, para desprezar */
/*
Agosto/2018 - Chamar WS Cyber via SOAP
#1  Felipe gravar ID do contrato
#2 07.06.19 - TP 31325157
*/
def input param par-clicod like clien.clicod. /* vcpfcnpj       as char init "57709319068".*/

def output param vretorno       as char.
def var vcodigoretorno as int.
        
def var vtabela       as char.
def var vtabela-recid as recid.
def var Hdoc          as handle.
def var Hroot         as handle.

def var lReturn as log.
def var vlog    as log init no.
def var varqlog as char.
def var vversao as char.
def var vseq    as int.

def var hWebService as handle no-undo.
def var hWSAcordo   as handle no-undo.
def var vHost       as char   no-undo.

def var consultaAcordo         as longchar no-undo.
def var consultaAcordoResponse as longchar no-undo.

def shared temp-table tt-novacao
    field ahid    as char /* #2 */
    field ahdt    as date
    field vltotal as dec
    field idAcordo as int. /* helio 06022023 - ID 155445 -*/
    
def shared temp-table tt-contratos
    field adacct  as char format "x(20)"
    field titnum  as char format "x(15)"
    field adacctg as char
    
    field adahid  as char
    field etbcod  as int  format "999" .

def shared temp-table tt-acordo
    field apahid   as char 
    field titvlcob as dec 
    field titpar   as int 
    field titdtven as date
    field apflag   as char 
    field titjuro  as dec.

def temp-table tt-retorno no-undo
    field ahacct     as char
    field cgccpf     as char format "x(14)"
    field ahacctg    as char
    field ahagagncy  as char
    field ahbank     as char
    field ahbreak    as char
    field ahcndpaym  as char
    field ahcndpayn  as char
    field ahcollid   as char
    field ahcsinitnt as char
    field ahcttype   as char 
    field ahdt       as char
    field ahfreq     as char
    field ahid       as char
    field ahlvl      as char
    field ahnumup    as char
    field ahprd      as char
    field ahpytype   as char
    field ahrate     as char
    field ahrate2    as char    
    field ahregdt    as char
    field ahtotpmt   as char
    field ahtype     as char
    field idAcordoLebes as char /* helio 06022023 - ID 155445 - */
    field recidNovacao as recid.
 
def temp-table tt-xml no-undo
    field seq    as int
    field tabela as char format "x(40)"
    field campo  as char format "x(40)"
    field valor  as char format "x(20)".

for each tt-novacao.   delete tt-novacao.   end.
for each tt-contratos. delete tt-contratos. end.
for each tt-acordo.    delete tt-acordo.    end.
for each tt-retorno.   delete tt-retorno.   end.
for each tt-xml.       delete tt-xml.       end.

vversao      = os-getenv("versao-wsp2k").
if vversao = ?
then vversao = "".
else vversao = vversao + "_".

varqlog = "/ws/log/p2k" + vversao + string(today, "99999999") + ".log".

/**********************MAIN***********************************/
def var vhostname as char.
input through hostname.
import vhostname.
input close.

if vhostname = "SV-CA-DB-DEV" or vhostname = "SV-CA-DB-QA"
then do:
    create server hWebService.
    lReturn = hWebService:CONNECT("-WSDL "
                              + 'http://172.28.200.79:8203/SOAP?service=LojasLebesService&targetURI=urn:DWLibrary-LojasLebesService'
                              + " -nohostverify") no-error.
    if not lReturn  
    then do:
        run gera-log("Não foi possível se conectar ao servidor").
        return.
    end.

end.
else do:
    create server hWebService.
    lReturn = hWebService:CONNECT("-WSDL "
                              + 'http://172.28.200.79:8103/SOAP?service=LojasLebesService&targetURI=urn:DWLibrary-LojasLebesService'
                              + " -nohostverify") no-error.
    if not lReturn  
    then do:
        run gera-log("Não foi possível se conectar ao servidor").
        return.
    end.
end.

run LojasLebesService
set hWSAcordo 
on hWebService no-error.

if not valid-handle(hWSAcordo) 
then do:
    run gera-log("Não foi possível se conectar a PortType hWSAcordo").
    return.
end.

/**consultaAcordo = 
 '<consultaAcordo 
**          <cpfCnpj>' + vcpfcnpj + '</cpfCnpj>
                <consultaAcordo>'.**/
                
find neuclien where neuclien.clicod = par-clicod no-lock.

/* 08/07/2021 HELIO - CARD Problema no WS consulta acordo - Para ajustar para CNPJ */
if length(trim(string(neuclien.cpfcnpj))) > 11
then consultaAcordo = string(neuclien.cpfcnpj,"99999999999999").
else consultaAcordo = string(neuclien.cpfcnpj,"99999999999").
/* 08/07/2021 */

function consultaAcordo returns longchar
  (input consultaAcordo as longchar).
   /*in hWSAcordo*/
end function.

/* Function invocation of consultaAcordo operation. */
assign consultaAcordoResponse = consultaAcordo(consultaAcordo) no-error.

/**def var imsg as int.
DO iMsg = 1 TO ERROR-STATUS:NUM-MESSAGES:
      MESSAGE "Error number: " ERROR-STATUS:GET-NUMBER(iMsg) SKIP
          ERROR-STATUS:GET-MESSAGE(iMsg)
              VIEW-AS ALERT-BOX ERROR.
              END.**/
              
if error-status:error        or
   error-status:num-messages > 0
then do:
   run gera-log("Erro na estrutura XML de requisicao").
   return.
end.
      
/* Procedure invocation of consultaAcordo operation. */
run consultaAcordo in hWSAcordo(input consultaAcordo, 
                                output consultaAcordoResponse) no-error.
if error-status:error        or
   error-status:num-messages > 0
then do:
   run gera-log("Erro ao invocar a operation 'consultaAcordo'").
   return.
end.

/*TRATA RETORNO*/
create x-document HDoc           no-error.
Hdoc:load("LONGCHAR", consultaAcordoResponse, false) no-error.
          
if error-status:error          or
   error-status:num-messages > 0 
then do:
   run gera-log("Erro na estrutura XML de retorno").
   return.
end.

create x-noderef hroot           no-error.
hDoc:get-document-element(hroot) no-error.

if vlog
then do:
    output to /ws/log/ricardo.log.
   
end.    

run obtemnode ("", input hroot) no-error.

if vlog
then output close. 

/* passa da temporaria tt-xml para temp shared */
vtabela = "".

def var vahid as char.
vahid = "".
for each tt-xml by tt-xml.seq.

    if vlog
    then disp
        vtabela
        tt-xml.seq format ">>9"
        tt-xml.tabela
        tt-xml.campo format "x(20)"
        tt-xml.valor format "x(20)".

    if tt-xml.tabela <> vtabela
    then do:
        if tt-xml.tabela = "tt-contratos"
        then do: 
            create tt-contratos. 
            vtabela-recid = recid(tt-contratos).
        end.
        if tt-xml.tabela = "tt-retorno"
        then do: 
            if vahid = ""
            then do:
                 create tt-retorno. 
                 vtabela-recid = recid(tt-retorno).
                 create tt-novacao.
                 tt-retorno.recidNovacao = recid(tt-novacao).
            end.
            else do:
                find first tt-retorno where tt-retorno.ahid = vahid.
                 vtabela-recid = recid(tt-retorno).
                find first tt-novacao where recid(tt-novacao) = tt-retorno.recidNovacao no-error. 
            end.
        end.
        if tt-xml.tabela = "tt-acordo" and
           tt-xml.campo = "v1:apahid" /* #2 */
        then do: 
            create tt-acordo. 
            vtabela-recid = recid(tt-acordo).        
        end.
        if tt-xml.tabela = ""
        then do:
        
        end.
        vtabela = tt-xml.tabela.
     end.

     if tt-xml.tabela = ""
     then do:
         if tt-xml.campo = "v1:wsMensagemRetorno"
         then vretorno = tt-xml.valor.

         if tt-xml.campo = "v1:wsCodigoRetorno"
         then vcodigoretorno = int(tt-xml.valor).
     end.

     if tt-xml.tabela = "tt-contratos"
     then do:  
        find first tt-contratos where recid(tt-contratos) = vtabela-recid. 
        if tt-xml.campo = "v1:adacct"  
        then do:
            assign   
                 tt-contratos.adacct = tt-xml.valor   
                 tt-contratos.titnum = string(int(substring(tt-xml.valor,4))) 
                 tt-contratos.etbcod = int(substr(tt-xml.valor,1,3)).
        end.
        if tt-xml.campo = "v1:adahid"
        then 
            tt-contratos.adahid = tt-xml.valor. /*#1*/
     end.          

     if tt-xml.tabela = "tt-retorno"
     then do:  
        find first tt-retorno where recid(tt-retorno) = vtabela-recid.
        find first tt-novacao where recid(tt-novacao) = tt-retorno.recidNovacao no-error.
        
        if tt-xml.campo = "v1:ahacct" 
        then assign  
             tt-retorno.ahacct = tt-xml.valor
             tt-retorno.cgccpf = tt-xml.valor.
             
        if tt-xml.campo = "v1:ahcollid" 
        then assign tt-retorno.ahcollid = tt-xml.valor.
            
        if tt-xml.campo = "v1:ahdt" 
        then do:
            assign tt-retorno.ahdt   = tt-xml.valor.
            if avail tt-novacao
            then
                    tt-novacao.ahdt   = 
                    date(int(substr(tt-xml.valor, 1, 2)),
                         int(substr(tt-xml.valor, 3, 2)),
                         int(substr(tt-xml.valor, 5)) ).
        end.
        if tt-xml.campo = "v1:ahfreq" 
        then assign tt-retorno.ahfreq   = tt-xml.valor.
            
        if tt-xml.campo = "v1:ahid" 
        then do:
                assign tt-retorno.ahid     = tt-xml.valor.
            if avail tt-novacao
            then  tt-novacao.ahid     = tt-xml.valor /* #2 */.
            vahid = tt-retorno.ahid.
            run gera-log("  ahid=" + tt-xml.valor ).                    
       end.
        if tt-xml.campo = "v1:ahprd" 
        then assign tt-retorno.ahprd    = tt-xml.valor.

        if tt-xml.campo = "v1:ahpytype" 
        then assign tt-retorno.ahpytype = tt-xml.valor.
       
        if tt-xml.campo = "v1:ahrate" 
        then assign tt-retorno.ahrate   = tt-xml.valor.

        if tt-xml.campo = "v1:ahregdt" 
        then assign tt-retorno.ahregdt  = tt-xml.valor.
        
        if tt-xml.campo = "v1:ahtotpmt" 
        then assign tt-retorno.ahtotpmt = tt-xml.valor.
            
        if tt-xml.campo = "v1:ahtype" 
        then assign tt-retorno.ahtype   = tt-xml.valor.
        
        if tt-xml.campo = "v1:idAcordoLebes"  /* helio 06022023 - busca idAcordo */
        then do:
            assign tt-retorno.idAcordo   = tt-xml.valor.
            if avail tt-novacao
            then assign tt-novacao.idAcordo   = int(tt-xml.valor) no-error.
            run gera-log ("  AHID=" + tt-retorno.ahid + "/" + string(avail tt-novacao,"Sim/Nao") + " idAcordo " + tt-retorno.idAcordo).
        end.    
        
    end.
        
    if tt-xml.tabela = "tt-acordo"
    then do:  
        find first tt-acordo where recid(tt-acordo) = vtabela-recid no-error.
        if avail tt-acordo
        then do:
            if tt-xml.campo = "v1:apahid" 
            then assign tt-acordo.apahid   = tt-xml.valor.
        
            if tt-xml.campo = "v1:apamt" 
            then assign tt-acordo.titvlcob = dec(tt-xml.valor).
            
            if tt-xml.campo = "v1:apdetid" 
            then assign tt-acordo.titpar   = int(tt-xml.valor).
        
            if tt-xml.campo = "v1:apduedt" 
            then assign tt-acordo.titdtven = 
                            date(int(substr(tt-xml.valor,1,2)) , 
                                 int(substr(tt-xml.valor,3,2)) ,
                                 int(substr(tt-xml.valor,5,4)) ).
        
            if tt-xml.campo = "v1:apflag" 
            then assign tt-acordo.apflag   = tt-xml.valor.
            
            if tt-xml.campo = "v1:apintamt" 
            then do:
                assign tt-acordo.titjuro  = dec(tt-xml.valor).
                vahid = "".
            end.    
        end.
    end.

    delete tt-xml.
end.


/* helio 06022023 - elimina zerados*/
                for each tt-novacao where tt-novacao.ahid = "".
                    for each tt-contratos where tt-contratos.adahid = tt-novacao.ahid.
                        delete tt-contratos.
                    end.
                    for each tt-acordo where tt-acordo.apahid = tt-novacao.ahid.
                        delete tt-acordo.
                    end.    
                    delete tt-novacao.
                end.


/******retira valores dos nodos******/
procedure obtemnode.

    def input parameter par-pai as char.
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
    def var vok as log.
            
    create x-noderef hc.
    
    if vlog
    then put unformatted
            "Inicio Pai=" par-pai " Name=" vh:name
            skip.

    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).

        if vlog
        then put unformatted
            " hc:subtype=" hc:subtype              
            " vhname=" vh:name          
            " hc:node-value=" hc:node-value 
            " hc:num-children=" hc:num-children 

            " --- "   
             
             "Vh=" vh:num-children
             " subtype=" vh:subtype
             " name=" vh:name

             " hc"
             " subtype=" hc:subtype 
             " name=" hc:name
             " node-value=" hc:node-value
             skip.

        if hc:subtype = "Element"
        then do:
            vok = no.
            if vh:name = "v1:acordoAgrHdrLista" /*ok */
            then do:
                assign
                    par-pai = "tt-retorno"
                    vok = yes.
            end.
            if vh:name = "v1:TLebesContrato" /*"v1:contratos"*/
            then assign
                    par-pai = "tt-contratos"
                    vok = yes.

            if vh:name = "v1:TLebesParcela" /* "v1:paymentSchedules"*/
            then assign
                    par-pai = "tt-acordo"
                    vok = yes.
        end. 
        
        if hc:subtype = "text"
        then do:
            vseq = vseq + 1.
            create tt-xml.
            tt-xml.seq    = vseq.
            tt-xml.tabela = par-pai.
            tt-xml.campo  = vh:name.
            tt-xml.valor  = hc:node-value.
        end.

        if hc:num-children > 0
        then run obtemnode (par-pai, input hc:handle).
    end.

    if vlog
    then put unformatted
            "Fim " vh:name
            skip.
 
    /* #2 */
    if vh:name = "v1:TLebesContrato" /*"v1:contratos"*/ or
       vh:name = "v1:TLebesParcela" /*"v1:paymentSchedules"*/
    then do.
        vseq = vseq + 1.
        create tt-xml.
        tt-xml.seq    = vseq.
        tt-xml.tabela = "/" + vh:name.
    end.
    
end procedure.


/*** Log para verificar tempo dos webservices ***/
procedure gera-log.
    def input parameter par-texto as char.

    output to value(varqlog) append.
    put unformatted skip string(time, "hh:mm:ss") " WS CSLOG: " par-texto skip.
    output close.

end procedure.


/*DESCONECTA E DELETA VAR HANDLE*/
delete object hdoc.
delete object hroot.
delete object hWSAcordo.
hWebService:DISCONNECT().
delete object hWebService.


for each tt-contratos break by tt-contratos.adacct.
    if not first-of(tt-contratos.adacct)
    then delete tt-contratos.
end.
/**
   for each tt-contratos no-lock. /* Contratos do acordo do Cyber */
    disp tt-contratos.
    down.
   end. 
    for each tt-acordo.
        disp tt-acordo.
        down.
    end.
            
message vretorno view-as alert-box

**/
