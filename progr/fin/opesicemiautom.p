/* 26112021 helio venda carteira */
def input param pstatus     as char init "ENVIAR".
def input param poperacao   as char init "CONTRATO".

def var xtime as int.
def var vconta as int.

{admbatch.i}

def new shared temp-table ttsicred no-undo
    field marca     as log format "*/ "
    field cobcod    like titulo.cobcod     
    field dtenvio   like lotefin.datexp
    field lotnum    like lotefin.lotnum
    field datamov   like pdvforma.datamov
    field ctmcod    like pdvforma.ctmcod        
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field qtd       as int 
    field vlf_principal  like contrato.vlf_principal
    field vlf_acrescimo  like contrato.vlf_acrescimo
    field vlentra  like contrato.vlentra 
    field vlseguro    like contrato.vlseguro
    field vltotal    like contrato.vltotal


    index idx is unique primary 
        cobcod asc
        datamov asc 
        dtenvio  asc
        lotnum
        ctmcod asc
        modcod asc
        tpcontrato asc            
     index idx2 marca asc datamov asc   .




run montatt.

    find first ttsicred where ttsicred.marca = yes no-error.
    if not avail ttsicred
    then do:
        message "Nenhum registro encontrato para " pstatus poperacao.
        
        return.
    end.     

run fin/opesicemienvia.p (poperacao, pstatus).


procedure montatt.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".

xtime = time.

for each ttsicred.
    delete ttsicred.
end.

vconta = 0.

for each cobra where cobra.sicred = yes and cobra.cobcod = 10 /* so financeira */ no-lock.
    
    if pstatus = "ENVIAR" or pstatus = "TRANSFERIR" or pstatus = "ERRO"
    then 
        for each sicred_contrato where
            sicred_contrato.operacao = poperacao and
            sicred_contrato.cobcod   = cobra.cobcod   and
            sicred_contrato.sstatus  = pstatus 
             no-lock.
            run gravatt.
        end.
            
end.

hide message no-pause.
           
end procedure.


procedure gravatt.
def var vtpcontrato     like contrato.tpcontrato.

    find lotefin where 
            lotefin.lotnum = sicred_contrato.lotnum no-lock no-error.
    
    find contrato where contrato.contnum = sicred_contrato.contnum no-lock.
    if contrato.dtinicial >= 06/01/2020
    then vtpcontrato = contrato.tpcontrato.
    else do:
        find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = 1
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
                    titulo.titpar     = 1 and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                end.
            vtpcontrato = if avail titulo
                      then titulo.tpcontrato
                      else "".
    end.
    
    vconta = vconta + 1.
    
    if vconta mod 1000 = 0
    then do:
        hide message no-pause.
        message color normal "fazendo calculos... aguarde... " string(time - xtime,"HH:MM:SS").
    end.
        
    find first ttsicred where
        ttsicred.cobcod  = sicred_contrato.cobcod and            
        ttsicred.datamov = sicred_contrato.datamov and
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?) and
        ttsicred.lotnum  = (if avail lotefin
                           then lotefin.lotnum
                           else ?) and
                           
        ttsicred.ctmcod  = sicred_contrato.ctmcod  and
        ttsicred.modcod  = contrato.modcod         and
        ttsicred.tpcontrato = vtpcontrato
        no-error.
    if not avail ttsicred
    then do:
        create ttsicred.
        
        ttsicred.marca   = yes . /** automatico **/
        
        ttsicred.cobcod  = sicred_contrato.cobcod.
        ttsicred.datamov = sicred_contrato.datamov.
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?).
        ttsicred.lotnum = (if avail lotefin
                           then lotefin.lotnum
                           else ?).
        
        ttsicred.ctmcod  = sicred_contrato.ctmcod.
        ttsicred.modcod  = contrato.modcod.
        ttsicred.tpcontrato = vtpcontrato.
    end.
    ttsicred.qtd = ttsicred.qtd + 1.
    ttsicred.vlf_principal = ttsicred.vlf_principal + contrato.vlf_principal.
    ttsicred.vlf_acrescimo = ttsicred.vlf_acrescimo + contrato.vlf_acrescimo.
    ttsicred.vlentra = ttsicred.vlentra + contrato.vlentra.
    ttsicred.vlseguro = ttsicred.vlseguro + contrato.vlseguro.
    ttsicred.vltotal = ttsicred.vltotal + contrato.vltotal.
 

end procedure.

