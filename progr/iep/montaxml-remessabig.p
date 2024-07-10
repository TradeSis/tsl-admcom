def input  param poperacao   as char.
def input  param parquivo    as char.
def input  param psequencial as int.
def input param xtime   as int.
def output param pcodocorrencia as char.
def output param pocorrencia as char.

{/admcom/progr/api/acentos.i}

def var hSaida   as handle.
def var vlcsaida as longchar.

def var vvltotal as dec.
def shared temp-table ttprot
    field precid as recid.

def temp-table ttcomarca no-undo
    field cidcod    like munic.cidcod
    field qtd       as int.

def temp-table ttpracaprot
    field cidcod    like munic.cidcod
    field cidade    as char
    field precid    like ttprot.precid.
def buffer bttpracaprot for ttpracaprot.
    
def temp-table ttresponsejson  no-undo serialize-name "jsonSoapResponse"
      field nome_arquivo    as char 
      field operacaoSol     as char
      field Comarca         as char
      field total_registros as char
      field codocorrencia   as char
      field ocorrencia      as char.
def var vsaida as char.

def var ppid as char.
def var vchost as char.
def var vhostname as char.
def var wurl as char.

input through hostname.
import unformatted vhostname.
input close. 

hsaida   = temp-table ttresponsejson:handle. 


INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.


vsaida  = "/u/bsweb/works/wciepro_remessas_"  
            + string(today,"999999") +  trim(ppid) + replace(string(time,"HH:MM:SS"),":","") +  ".json". 
            
if vhostname = "SV-CA-DB-DEV" or 
   vhostname = "SV-CA-DB-QA"
then do: 
    wurl = "http://" + vhostname + "/bsweb/api/protesto/ieproEnviaRemessa".
end.    
else do:
    wurl = "http://10.2.0.83/bsweb/api/protesto/ieproEnviaRemessa".
end.    

output to value(vsaida + ".sh") CONVERT TARGET "UTF-8".
put unformatted
        "curl -X POST -s \"" + wURL + ""\" " +
        " -H \"Content-Type: application/json\" " +
        " --data @" + vsaida + ".data".
output close.

 output to value(vsaida + ".data") CONVERT TARGET "UTF-8".
put unformatted
        "\{\"dadosEntrada\": [ " +
        " \{ " +
        "   \"operacao\": \"remessas\", " +
        "   \"nome_arquivo\": \"" + parquivo + "\", " +
        "   \"dadosXml\": \" <remessa>   <nome_arquivo>" + parquivo + "</nome_arquivo> ".
                
output close.
 


def var clayout as longchar.
def var vlayout as char.
def var vlayout-transacao as char.


def var vqtdregistros     as int.
def var vlinha as int.
def var vvalortot as dec.

for each ttprot.
    find titprotesto where recid(titprotesto) = ttprot.precid no-lock.
    
    find contrato of titprotesto no-lock.
    find clien of titprotesto no-lock.
    
    create ttpracaprot.
    ttpracaprot.cidade = clien.cidade[1].
    ttpracaprot.precid = ttprot.precid.
    
    find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
    if not avail munic
    then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
    if avail munic and munic.cidcod <> ?
    then ttpracaprot.cidcod = munic.cidcod.
    else  ttpracaprot.cidcod = 4314902.

            find titprotcomarca where titprotcomarca.cidcod = ttpracaprot.cidcod no-lock no-error.
            if avail titprotcomarca
            then ttpracaprot.cidcod = titprotcomarca.comarca.
    
            find first ttcomarca where ttcomarca.cidcod = ttpracaprot.cidcod no-error.
            if not avail ttcomarca    
            then do:
                create ttcomarca.
                ttcomarca.cidcod = ttpracaprot.cidcod.
            end.    
            ttcomarca.qtd = ttcomarca.qtd + 1.
    
    
end.

for each ttcomarca break by ttcomarca.qtd.


        find munic where munic.cidcod = ttcomarca.cidcod no-lock.    
        input from /admcom/progr/iep/remessa-header.xml.
            import unformatted vlayout.
        input close.
        
        vqtdregistros = 0.
        vvalortot     = 0.  
        for each bttpracaprot where bttpracaprot.cidcod = ttcomarca.cidcod.
            find titprotesto where recid(titprotesto) = bttpracaprot.precid no-lock. 
            
            /*Helio 06022024- ajuste quando nao tem titulos em aberto */
            if titprotesto.titdtven = ?
            then next. 
            
            vqtdregistros = vqtdregistros + 1. 
            vvalortot = vvalortot + titprotesto.vlcobrado.
        end.

        vlayout = replace(vlayout,"@NOMEDOARQUIVO",parquivo).
        vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
        vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(pSEQUENCIAL)).
        vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros + 2)).
        vlayout = replace(vlayout,"@QTDTITULOS",string(vqtdregistros)).
        vlayout = replace(vlayout,"@CIDCOD",string(ttcomarca.cidcod)).
        

        vlinha = 1.                           
        vlayout = replace(vlayout,"@LINHA",string(vlinha)).

        output to value(vsaida + ".data") append CONVERT TARGET "UTF-8".
            vlayout = replace(vlayout,'\"','\\\"').
            vlayout = replace(vlayout,'&','E').
            put unformatted trim(vlayout).
        output close.
 
    for each ttpracaprot where ttpracaprot.cidcod = ttcomarca.cidcod.
    
    
        input from /admcom/progr/iep/remessa-transacao.xml.
            import unformatted vlayout-transacao.
        input close.

        find titprotesto where recid(titprotesto) = ttpracaprot.precid no-lock.

        if titprotesto.titdtven = ?
        then next. 
        
        find contrato of titprotesto no-lock.
        find clien of titprotesto no-lock.
    
        vvltotal = 0.
        for each titulo where titulo.titnat = no and titulo.empcod = 19 and
            titulo.clifor = contrato.clicod and titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.titnum = string(contrato.contnum) no-lock.
            vvltotal = vvltotal + titulo.titvlcob.
        end.
    
        vlayout = vlayout-transacao.
    
        find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
                            
        vlayout = replace(vlayout,"@TITNUM"     , string(titprotesto.contnum)).
        vlayout = replace(vlayout,"@NOSSONUMERO", titprotesto.nossonumero).

        vlayout = replace(vlayout,"@PRACAP",removeacento(substring(munic.cidnom,1,20))).

        message "          enviando " poperacao parquivo psequencial titprotesto.nossonumero "comarca" ttcomarca.cidcod.
            
        vlayout = replace(vlayout,"@TITDTEMI",string(contrato.dtinicial,"99999999")).
        vlayout = replace(vlayout,"@TITDTVEN",string(titprotesto.titdtven,"99999999")).
        vlayout = replace(vlayout,"@VLTOTAL",trim(string(vvltotal,">>>>>>>>>>>>>>>>>>>9.99")) ).

        vlayout = replace(vlayout,"@VLDIVIDA",trim(string(titprotesto.vlcobrado,">>>>>>>>>>>>>>>>>>>9.99")) ).
    
        vlayout = replace(vlayout,"@CLINOM",removeacento(clien.clinom)).
        vlayout = replace(vlayout,"@CPF",
              string(dec(  removeacento(if avail neuclien then string(neuclien.cpf) else if clien.ciccgc = ? then "0" else clien.ciccgc)
                    ),"99999999999999")).
        vlayout = replace(vlayout,"@ENDERECO",removeacento(clien.endereco[1]) + ", " +
                                                if clien.numero[1] <> ? then string(clien.numero[1]) else "").
        vlayout = replace(vlayout,"@CIINSC",removeacento(string(clien.CIINSC))).
    
        vlayout = replace(vlayout,"@CEP",removeacento(string(clien.cep[1]))).
        vlayout = replace(vlayout,"@CIDADE",removeacento(substring(clien.cidade[1],1,20))).
        vlayout = replace(vlayout,"@BAIRRO",removeacento(clien.bairro[1])).
    
        vlayout = replace(vlayout,"@UF",removeacento(clien.ufecod[1])).
    
    
    
        vlinha = vlinha + 1.
        vlayout = replace(vlayout,"@LINHA",string(vlinha)).
    
        output to value(vsaida + ".data") append CONVERT TARGET "UTF-8".
                 vlayout = replace(vlayout,'\\',' ').
                vlayout = replace(vlayout,"'","").
                
                vlayout = replace(vlayout,'\"','\\\"').
                vlayout = replace(vlayout,'&','E').

            put unformatted trim(vlayout).
        output close.    

    end.
    
        input from /admcom/progr/iep/remessa-trailler.xml.
            import unformatted vlayout.
        input close.

        vlayout = replace(vlayout,"@NOMEDOARQUIVO",parquivo).
        vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
        vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(PSEQUENCIAL)).

        vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros * 3)).

        vlayout = replace(vlayout,"@VALORTOT",trim(string(vvalortot,">>>>>>>>>>>>>>>>>>>9.99"))).

        vlinha = vlinha + 1.
        vlayout = replace(vlayout,"@LINHA",string(vlinha)).

        output to value(vsaida + ".data") append CONVERT TARGET "UTF-8".
            vlayout = replace(vlayout,'\"','\\\"').
            vlayout = replace(vlayout,'&','E').

            put unformatted trim(vlayout).
        output close.    

    
end.

output to value(vsaida + ".data") append CONVERT TARGET "UTF-8".
    put unformatted
    " </remessa> \" \} ]\}" 
        skip.
output close.

output to value(vsaida + ".sh") append CONVERT TARGET "UTF-8".
    put unformatted
        " -o "  + vsaida
        skip.
output close.


unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").

COPY-LOB FILE vsaida  TO vlcsaida.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

find first ttresponsejson no-error.

pocorrencia = "SEM RETORNO".
pcodocorrencia = ?.
if avail ttresponsejson
then do:
    for each ttresponsejson.
        
        ttresponsejson.ocorrencia = removeacento(ttresponsejson.ocorrencia).
        
        message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS")
        "montaxml-remessabig remessa " pSEQUENCIAL  ttresponsejson.comarca ttresponsejson.codocorrencia ttresponsejson.ocorrencia
            "registros:" ttresponsejson.total_registros.
    
        /* MARCA COMO ENVIADO */
        if int(ttresponsejson.codocorrencia) = 0 or "REGISTROS OK" = ttresponsejson.ocorrencia
        then do:
            for each ttpracaprot where ttpracaprot.cidcod = int(ttresponsejson.comarca).
                find ttprot where   ttpracaprot.precid = ttprot.precid.
                run iep/bproatualiza.p (ttprot.precid,today,"",pSEQUENCIAL).
                find titprotesto where recid(titprotesto) = ttprot.precid exclusive.
                titprotesto.cidcod  = ttpracaprot.cidcod.
                titprotesto.comarca = ttpracaprot.cidcod.
                delete ttprot.
            end.
        end.
        else do:
            /*pocorrencia = ttresponsejson.ocorrencia.
            pcodocorrencia = ttresponsejson.codocorrencia no-error.
            */
            
            create titprotremlog.
            titprotremlog.operacao = poperacao.
            titprotremlog.remessa  = pSEQUENCIAL.
            titprotremlog.cidcod   = int(ttresponsejson.comarca).
            titprotremlog.codocorrencia = ttresponsejson.codocorrencia.
            titprotremlog.ocorrencia = ttresponsejson.ocorrencia.
            
            for each ttpracaprot where ttpracaprot.cidcod = int(ttresponsejson.comarca).
                find ttprot where   ttpracaprot.precid = ttprot.precid.
                find titprotesto where recid(titprotesto) = ttprot.precid no-lock.
                create titprotremlctr.
                titprotremlctr.operacao = titprotremlog.operacao.
                titprotremlctr.remessa  = titprotremlog.remessa.
                titprotremlctr.cidcod   = titprotremlog.cidcod.
                titprotremlctr.nossoNumero =  titprotesto.nossoNumero.
                delete ttprot.
            end.            
        end.
    end.        
end.                                                        
