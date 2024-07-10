/* helio 14042023 Qualitor ID 21258 - Cancelamento de contratos Chama Doutor.*/

def input param precidmedadesao as recid.
def  shared variable sfuncod  like func.funcod.
def var vtime as int.
vtime = time.
 
{/admcom/progr/med/meddefs.i NEW}

def var pok as log.
def var hEntrada as handle.
def var hSaida   as handle.

def var vcurl as char.
def var vlcentrada as longchar.
def var vlcsaida as longchar.

def var vsaida as char.
def var vresposta as char.

find medadesao where recid(medadesao) = precidmedadesao no-lock.
if medadesao.dtcanc <> ?
then do:
    message "ja cancelado".
    pause 1.
    return.
end.    
find cmon of medadesao no-lock. 

create ttcancelaadesao.
    ttcancelaadesao.idAdesaoLebes         = string(medadesao.idAdesao).
    ttcancelaadesao.idPropostaAdesaoLebes = medadesao.idPropostaAdesaoLebes.
    ttcancelaadesao.dataTransacao         = string(year(medadesao.dataTransacao),"9999") + "-" +
                                            string(month(medadesao.dataTransacao),"99") + "-" +
                                            string(day(medadesao.dataTransacao),"99").
    ttcancelaadesao.etbcod                = string(medadesao.etbcod).
    ttcancelaadesao.numeroComponente      = string(cmon.cxacod).
    ttcancelaadesao.nsuTransacao          = medadesao.nsuTransacao.
    ttcancelaadesao.dataProposta          = string(year(medadesao.dataproposta),"9999") + "-" +
                                            string(month(medadesao.dataproposta),"99") + "-" +
                                            string(day(medadesao.dataproposta),"99").
    ttcancelaadesao.tipoServico           = medadesao.tipoServico.
    ttcancelaadesao.valorServico          = trim(string(medadesao.valorServico,"->>>>>>>>>>>>>>>>>>>9.99")).
    ttcancelaadesao.procod                = string(medadesao.procod).
    ttcancelaadesao.idmedico              = medadesao.idmedico.

for each medadedados of medadesao no-lock.
    create ttcanceladados.
    ttcanceladados.idcampo     =   medadedados.idcampo.
    ttcanceladados.conteudo    =   medadedados.conteudo.

end.

def var ppid as char.
def var vchost as char.
def var vhostname as char.
def var wurl as char.

input through hostname.
import unformatted vhostname.
input close. 

def var vhost as char.
vhost = "10.2.0.83".
if vhostname = "SV-CA-DB-DEV" then vhost = "sv-ca-db-dev".
if vhostname = "SV-CA-DB-QA" then vhost = "sv-ca-db-qa".

hentrada = DATASET cancelaAdesao:HANDLE.
hEntrada:WRITE-JSON("longchar",vLCEntrada, false).


hsaida   = temp-table ttadesaoCancelamentoStatus:handle. 


INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

wurl = "http://" + vhost + "/bsweb/api/medico/cancelaAdesao".

vsaida  = "/ws/works/cancelaAdesao_"  
            + string(today,"999999") +  trim(ppid) + replace(string(vtime,"HH:MM:SS"),":","") +  ".json". 

output to value(vsaida + ".sh") CONVERT TARGET "UTF-8".
put unformatted
        "curl -X POST -s \"" + wURL + ""\" " +
        " -H \"Content-Type: application/json\" " +
        " -o " + vsaida + 
        " -d '" + string(vLCEntrada) + "'".
output close.
 
unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

vresposta = "".
input from value(vsaida) no-echo.
import unformatted vresposta.        
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

pok = ?.
for each ttadesaoCancelamentoStatus.
    if pok = ?
    then pok = yes.
    
    if int(ttadesaoCancelamentoStatus.statusParceiro) <> 200
    then do:
        pok = no.
        hide message no-pause.
        message ttadesaoCancelamentoStatus.codigoParceiro ttadesaoCancelamentoStatus.mensagemParceiro.
        pause 1 no-message.     
    end.    

                create medadecanc.
                medadecanc.idAdesao         = medadesao.idAdesao.
                medadecanc.dtcanc           = today.
                medadecanc.funcod           = sfuncod.
                medadecanc.hrcanc           = vtime.
                medadecanc.codigoParceiro   = ttadesaoCancelamentoStatus.codigoParceiro.
                medadecanc.statusParceiro   = ttadesaoCancelamentoStatus.statusParceiro.
                medadecanc.mensagemParceiro = ttadesaoCancelamentoStatus.mensagemParceiro.
        
end.
    
    
if pok
then do on error undo:

    find current medadesao exclusive no-wait no-error.
    if avail medadesao
    then do: 
        medadesao.dtcanc = today.
        for each medaderepasse of medadesao where
                medaderepasse.dtvenc >= today .
            medaderepasse.rstatus = no. /* cancelado*/        
        end.        
        run med/pgerabaixacnt.p (input recid(medadesao)).    
    end.
    
        
    
end.    

