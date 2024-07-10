def input  param poperacao   as char.
def input  param parquivo    as char.
def input  param psequencial as int.
def input param xtime   as int.
def output param pcodocorrencia as char.
def output param pocorrencia as char.

{/admcom/progr/api/acentos.i}


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
    
def var vsaida as char.

def var ppid as char.
def var vchost as char.
def var vhostname as char.
def var wurl as char.

input through hostname.
import unformatted vhostname.
input close. 



INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.


vsaida  = "/admcom/tmp/iep/remessas/" + parquivo.
/*_remessas_"   + string(today,"999999") +  trim(ppid) + replace(string(time,"HH:MM:SS"),":","") +  ".arquivo". */
            

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
        
        input from /admcom/progr/iep/remessa-header.arquivo.
            import unformatted vlayout.
        input close.
        
        vqtdregistros = 0.
        vvalortot     = 0.  
        for each bttpracaprot where bttpracaprot.cidcod = ttcomarca.cidcod.
            find titprotesto where recid(titprotesto) = bttpracaprot.precid no-lock. 
            vqtdregistros = vqtdregistros + 1. 
            vvalortot = vvalortot + titprotesto.vlcobrado.
        end.

        vlayout = replace(vlayout,"@NOMEDOARQUIVO",parquivo).
        vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
        vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(pSEQUENCIAL,"999999")).
        vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros + 2,"9999")).
        vlayout = replace(vlayout,"@QTDTITULOS",string(vqtdregistros,"9999")).
        vlayout = replace(vlayout,"@CIDCOD",string(ttcomarca.cidcod,"9999999")).
        vlayout = replace(vlayout,"@497",string(" ","x(497)")).

        vlinha = 1.                           
        vlayout = replace(vlayout,"@LINHA",string(vlinha,"9999")).

        output to value(vsaida) append CONVERT TARGET "UTF-8".
            vlayout = replace(vlayout,'\"','\\\"').
            vlayout = replace(vlayout,'&','E').
            put unformatted trim(vlayout) skip.
        output close.
 
    for each ttpracaprot where ttpracaprot.cidcod = ttcomarca.cidcod.
    
        input from /admcom/progr/iep/remessa-transacao.arquivo.
            import unformatted vlayout-transacao.
        input close.

        find titprotesto where recid(titprotesto) = ttpracaprot.precid no-lock.
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
        vlayout = replace(vlayout,"@TITNUM"     , string(string(titprotesto.contnum),"x(11)")).
        vlayout = replace(vlayout,"@NOSSONUMERO", STRING(titprotesto.nossonumero,"x(15)")).
                                                                                         
        vlayout = replace(vlayout,"@PRACAP",removeacento(string(munic.cidnom,"x(20)"))).

        /*message "          enviando " poperacao parquivo psequencial titprotesto.nossonumero "comarca" ttcomarca.cidcod.*/
            
        vlayout = replace(vlayout,"@TITDTEMI",string(contrato.dtinicial,"99999999")).
        vlayout = replace(vlayout,"@TITDTVEN",string(if titprotesto.titdtven = ? then today else titprotesto.titdtven,"99999999")).
        vlayout = replace(vlayout,"@VLTOTAL",trim(string(vvltotal * 100,"99999999999999")) ).

        vlayout = replace(vlayout,"@VLDIVIDA",trim(string(titprotesto.vlcobrado * 100,"99999999999999")) ).
    
        vlayout = replace(vlayout,"@CLINOM",string(removeacento(clien.clinom),"x(45)")).
        vlayout = replace(vlayout,"@CPF",
              string(dec(  removeacento(if avail neuclien then string(neuclien.cpf) else if clien.ciccgc = ? then "0" else clien.ciccgc)
                    ),"99999999999999")).
        vlayout = replace(vlayout,"@ENDERECO",string(removeacento(clien.endereco[1]) + ", " +
                                                if clien.numero[1] <> ? then string(clien.numero[1]) else "","x(45)")).
        vlayout = replace(vlayout,"@CIINSC",string(removeacento(string(clien.CIINSC)),"x(11)")).
    
        vlayout = replace(vlayout,"@CEP",removeacento(string(clien.cep[1],"x(8)"))).
        vlayout = replace(vlayout,"@CIDADE",string(removeacento(clien.cidade[1]),"x(20)")).
        vlayout = replace(vlayout,"@BAIRRO",string(removeacento(clien.bairro[1]),"x(20)")).
    
        vlayout = replace(vlayout,"@UF",removeacento(clien.ufecod[1])).
    
    
    
        if vlayout <> ?
        then do:
            vlinha = vlinha + 1.
            vlayout = replace(vlayout,"@LINHA",string(vlinha,"9999")).
        
            output to value(vsaida) append CONVERT TARGET "UTF-8".
                 vlayout = replace(vlayout,'\\',' ').
                vlayout = replace(vlayout,"'","").
                
                vlayout = replace(vlayout,'\"','\\\"').
                vlayout = replace(vlayout,'&','E').

            put unformatted trim(vlayout) skip.
            output close.    
        end.

    end.
    
        input from /admcom/progr/iep/remessa-trailler.arquivo.
            import unformatted vlayout.
        input close.

        vlayout = replace(vlayout,"@NOMEDOARQUIVO",parquivo).
        vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
        vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(PSEQUENCIAL)).

        vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros * 3,"99999")).

        vlayout = replace(vlayout,"@VALORTOT",trim(string(vvalortot * 100,"999999999999999999"))).
        vlayout = replace(vlayout,"@521",string(" ","x(521)")).
        vlinha = vlinha + 1.
        vlayout = replace(vlayout,"@LINHA",string(vlinha,"9999")).

        output to value(vsaida) append CONVERT TARGET "UTF-8".
            vlayout = replace(vlayout,'\"','\\\"').
            vlayout = replace(vlayout,'&','E').

            put unformatted trim(vlayout) skip.
        output close.    

    
end.

    for each ttcomarca break by ttcomarca.qtd.

            for each ttpracaprot where ttpracaprot.cidcod = ttcomarca.cidcod.
                find ttprot where   ttpracaprot.precid = ttprot.precid.
                run iep/bproatualiza.p (ttprot.precid,today,"",pSEQUENCIAL).
                find titprotesto where recid(titprotesto) = ttprot.precid exclusive.
                titprotesto.cidcod  = ttpracaprot.cidcod.
                titprotesto.comarca = ttpracaprot.cidcod.
                delete ttprot.
            end.
            
    end.            
