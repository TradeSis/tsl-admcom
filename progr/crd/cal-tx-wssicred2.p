def input parameter vEmpresa      as integer.
def input parameter vAgencia      as integer.
def input parameter vProduto      as integer.
def input parameter vLojista      as integer.
def input parameter vLoja         as integer.
def input parameter vPlano        as integer.
def input parameter vPrazo        as integer.
def input parameter vValorCompra  as decimal.
def input parameter vValorPMT     as decimal.
def input parameter vDiasParaPgto as integer.
def input parameter vTaxa         as decimal.
def input parameter vSeguro       as decimal.
def output parameter vret-Empresa             as char.
def output parameter vret-Agencia             as char.
def output parameter vret-Lojista             as char.
def output parameter vret-Loja                as char.
def output parameter vret-Produto             as char.
def output parameter vret-Plano               as char.
def output parameter vret-Prazo               as char.
def output parameter vret-Emissao             as char.
def output parameter vret-PrimeiroVencimento  as char.
def output parameter vret-PMT                 as char.
def output parameter vret-ValorTAC            as char.
def output parameter vret-ValorTfc            as char.
def output parameter vret-Seguro              as char.
def output parameter vret-ValorIOF            as char.
def output parameter vret-ValorFinanciado     as char.
def output parameter vret-Taxa                as char.
def output parameter vret-Coeficiente         as char.
def output parameter vret-IRR                 as char.
def output parameter vret-ValorLiberar        as char.
def output parameter vret-CET                 as char.
def output parameter vret-CETAnual            as char.
def output parameter vret-PST                 as char.
def output parameter vret-TFC                 as char.
def output parameter vret-Tac                 as char.
def output parameter vret-ValorTotal          as char.

def var sh     as handle NO-UNDO.
def var vlf    as char. /* line feed */
def var vcab1  as char.
def var vxml   as char.
def var vtam   as int.
def var vretws as char.
def var sb     as memptr.
def var vb     as memptr.

/*** Log para verificar tempo dos webservices ***/
def var varqlog as char.
def var vversao as char.

vversao = os-getenv("versao-wsp2k").
if vversao = ?
then vversao = "".
else vversao = vversao + "_".

def var varqestatistica as char.
def var vtimeini as int.

def var vhostname as char.
input through hostname.
import vhostname.
input close.

if vhostname = "SV-CA-DB-DEV" or 
   vhostname = "SV-CA-DB-QA"
then do:
    varqlog = "/admcom/barramento/logs/sicred" + vversao + string(today, "99999999") + ".log".
    varqestatistica = "/admcom/barramento/logs/sicred_estatistica_" + 
        string(today,"99999999") + ".log".

end.
else do:
    varqlog = "/work-vnx/integracao-work/log/sicred" + vversao + string(today, "99999999") + ".log".
    varqestatistica = "/work-vnx/integracao-work/log/sicred_estatistica_" + 
        string(today,"99999999") + ".log".
end.        
vtimeini = time. 

/*** ***/

vlf   = chr(10).


function GeraXml returns log
    (input p-tag   as char,
     input p-valor as char):

    vxml = vxml + "<" + p-tag + ">" + trim(p-valor) + "</" + p-tag + ">".

end function.


/* le_xml.p */
FUNCTION pega returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"<"). 
        if entry(1,entry(vx,par-onde,"<"),">") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"<"),">"). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
/* */

vxml = '<?xml version="1.0" encoding="utf-8"?>'  +
    '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
    'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
    'xmlns:soap12="http://~www.w3.org/2003/05/soap-envelope">' +
    '  <soap12:Body> <Simulacao xmlns="http://tempuri.org/"> '.

geraxml("Empresa",string(vEmpresa,">>99")).     
geraxml("Agencia",string(vAgencia,">>9999")).
geraxml("Produto",string(vProduto,">>999999")).
geraxml("Lojista",string(vLojista,">>999999")).
geraxml("Loja", string(vLoja,">>9999")).
geraxml("Plano",string(vPlano,">>9999")).
geraxml("Prazo",string(vPrazo,">>999")).
geraxml("ValorCompra",string(vValorCompra)).
geraxml("ValorPMT",string(vValorPMT)).
geraxml("DiasParaPgto",string(vDiasParaPgto)).

/* Credito Pessoal */
if vtaxa > 0 or
   vseguro > 0
then do.
    geraxml("ValorTFC",   string(vtaxa)).
    geraxml("ValorSeguro",string(vseguro)).
end.

vxml = vxml + "</Simulacao> </soap12:Body> </soap12:Envelope>".

/* Conexao ao WS */
vcab1 = "POST /webservicesicred/SicredWS.asmx HTTP/1.1" + vlf +
        "Host: sv-ca-fin-apl.lebes.com.br" + vlf +
        "Content-Type: application/soap+xml; charset=utf-8" + vlf +
        "Content-Length: " + string(length(vxml)) + vlf + vlf.

run gera-log("Conectando").

create socket sh no-error.
if sh:connect("-H sv-ca-fin-apl.lebes.com.br -S 80")
then do:
    set-size(sb) = 30000.
    set-size(vb) = 30000.

    put-string(sb, 1) = vcab1 + vxml.
    sh:write(sb, 1, length(vcab1) + length(vxml)).

    pause 1 /*** 2 ***/ no-message.

    vtam = sh:GET-BYTES-AVAILABLE().
    sh:read(vb , 1, vtam).
    assign vretws = get-string(vb,1). 
end.
sh:disconnect().
Delete Object sh.

/***
put unformatted vxml skip(1).
put unformatted vretws.
***/
run gera-log("Retorno=" + vretws).

run le_xml(vretws, "Empresa", output vret-Empresa).           
run le_xml(vretws, "Agencia", output vret-Agencia).
run le_xml(vretws, "Lojista", output vret-Lojista).
run le_xml(vretws, "Loja", output vret-Loja).
run le_xml(vretws, "Produto", output vret-Produto).
run le_xml(vretws, "Plano", output vret-Plano).
run le_xml(vretws, "Prazo", output vret-Prazo).
run le_xml(vretws, "Emissao", output vret-Emissao).
run le_xml(vretws, "PrimeiroVencimento", output vret-PrimeiroVencimento).
run le_xml(vretws, "PMT", output vret-PMT).
run le_xml(vretws, "ValorTAC", output vret-ValorTAC).
run le_xml(vretws, "ValorTfc", output vret-ValorTfc).
run le_xml(vretws, "Seguro", output vret-Seguro).
run le_xml(vretws, "ValorIOF", output vret-ValorIOF).
run le_xml(vretws, "ValorFinanciado", output vret-ValorFinanciado).
run le_xml(vretws, "Taxa", output vret-Taxa).
run le_xml(vretws, "Coeficiente", output vret-Coeficiente).
run le_xml(vretws, "IRR", output vret-IRR).
run le_xml(vretws, "ValorLiberar", output vret-ValorLiberar).
run le_xml(vretws, "CET", output vret-CET).
run le_xml(vretws, "CETAnual", output vret-CETAnual).
run le_xml(vretws, "PST", output vret-PST).
run le_xml(vretws, "TFC", output vret-TFC).
run le_xml(vretws, "Tac", output vret-Tac).
run le_xml(vretws, "ValorTotal", output vret-ValorTotal).

run gera-log("Fim").

output to value(varqestatistica) append.
put unformatted
    skip
    "wssicred2.p" + ";" +
    string(today,"99999999") + ";" +
    replace(string(vtimeini,"HH:MM:SS"),":","") + ";" +
    replace(string(time,"HH:MM:SS"),":","") + ";" +
    replace(string(time - vtimeini,"HH:MM:SS"),":","")
    skip.
output close.

procedure le_xml.

    def input parameter parq-onde as char.
    def input parameter parq-oque as char.
    def output parameter p-resultado as char.

    p-resultado = "".
    if pega(parq-oque, parq-onde) <> ?
    then p-resultado = pega(parq-oque, parq-onde).
        
end procedure.


procedure gera-log.
    def input parameter par-texto as char.

    output to value(varqlog) append.
    put unformatted skip
        today " " string(time, "hh:mm:ss")
        " WS SICRED - " par-texto skip.
    output close.

end procedure.

