{wsnotamax.i new}  

def output parameter vstatus as char.
def output parameter vmensagem_erro as char.
def input parameter rec-mdfe as recid.

def buffer bmdfe for mdfe.
find mdfe where recid(mdfe) = rec-mdfe no-lock.

hide message no-pause. 
message "Consultando Situacao " mdfe.mdfechave.

def var mdfe_versao as char.
def var mdfe_modelo as char.
def var vemite_cnpj as char.
def var mdfe_dhemi as char.
def var mdfe_dhviag as char.



find mdfviagem of mdfe no-lock.
find frete of mdfviagem no-lock.
find forne of frete no-lock.
find tpfrete of frete no-lock.
find veiculo of mdfviagem no-lock.
find estab of mdfviagem no-lock.


vmetodo = "MDFeEmissaoConsultarSituacao".
vLOG    = "MDFe_" + string(mdfe.mdfenumero, "999999999").



vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").

    vxml = vxml + geraXmlNfe("Tag", "chMDFe", mdfe.mdfechave). 

vxml = vxml + geraXmlNfe("GrupoFIM", "parametros", "").


vxml = vxml + geraXmlNfe("GrupoFIM", "envNotamax", "").

run wsnotamax.p (  input "", /* Site em branco para padrao */   
                   input vmetodo, 
                   input vxml,
                   input vlog). /* GRAVA LOG */



do on error undo:
    find current mdfe exclusive.
    mdfe.wsretorno = "".
    mdfe.xmotivo = "".
end.



find first tt-xmlretorno where
    (tt-xmlretorno.tag = "mensagem_erro" or
    tt-xmlretorno.tag = "situacao_notamax_descricao")
    and tt-xmlretorno.valor <> ""
    
    no-error.
vmensagem_erro = if avail tt-xmlretorno
               then tt-xmlretorno.valor
               else "". 
if  vmensagem_erro <> ""
then do:
    do on error undo.
        find current mdfe exclusive.
        mdfe.wsretorno = vmensagem_erro.
    end.
    
    if vmensagem_erro = "MDFe encerrado" and
       mdfe.situacao  = "F"
    then do:
        do on error undo.
            find current mdfe exclusive.
            mdfe.situacao  = "E".
            mdfe.dtencer = today.
                if mdfe.situacao = "E"
                then do on error undo.
                    for each mdfnfe of mdfe.
                        create mdfhistnfe.
                        ASSIGN 
                            mdfhistnfe.etbcod      = mdfnfe.etbcod             ~                              mdfhistnfe.NfeChave    = mdfnfe.NfeID
                            mdfhistnfe.MdfVCod     = mdfnfe.MdfVCod
                            mdfhistnfe.MdfeCod     = mdfnfe.MdfeCod
                            mdfhistnfe.InfNfeChave = mdfnfe.InfNfeChave
                            mdfhistnfe.RotaSeq     = mdfnfe.RotaSeq
                            mdfhistnfe.Desti       = mdfnfe.Desti
                            mdfhistnfe.Emite       = mdfnfe.Emite
                            mdfhistnfe.TabEmite    = mdfnfe.TabEmite
                            mdfhistnfe.TabDesti    = mdfnfe.TabDesti
                            mdfhistnfe.cnpj_emite  = mdfnfe.cnpj_emite
                            mdfhistnfe.Serie       = mdfnfe.Serie
                            mdfhistnfe.Numero      = mdfnfe.Numero
                            mdfhistnfe.cidemi      = mdfnfe.cidemi
                            mdfhistnfe.ciddes      = mdfnfe.ciddes
                            mdfhistnfe.NfeID       = mdfnfe.NfeID
                            mdfhistnfe.PesoBrutoKG = mdfnfe.PesoBrutoKG
                            mdfhistnfe.ValorNota   = mdfnfe.ValorNota.
                        delete mdfnfe.
                    end.
                end.
             
        end.
    end.
    
    if vmensagem_erro = "MDFe cancelado" and
       mdfe.situacao  = "F"
    then do:
        do on error undo.
            find current mdfe exclusive.
            mdfe.situacao  = "C".
            mdfe.dtencer = today.
                if mdfe.situacao = "C"
                then do on error undo.
                    for each mdfnfe of mdfe.
                        create mdfhistnfe.
                        ASSIGN 
                            mdfhistnfe.etbcod      = mdfnfe.etbcod                                           mdfhistnfe.NfeChave    = mdfnfe.NfeID
                            mdfhistnfe.MdfVCod     = mdfnfe.MdfVCod
                            mdfhistnfe.MdfeCod     = mdfnfe.MdfeCod
                            mdfhistnfe.InfNfeChave = mdfnfe.InfNfeChave
                            mdfhistnfe.RotaSeq     = mdfnfe.RotaSeq
                            mdfhistnfe.Desti       = mdfnfe.Desti
                            mdfhistnfe.Emite       = mdfnfe.Emite
                            mdfhistnfe.TabEmite    = mdfnfe.TabEmite
                            mdfhistnfe.TabDesti    = mdfnfe.TabDesti
                            mdfhistnfe.cnpj_emite  = mdfnfe.cnpj_emite
                            mdfhistnfe.Serie       = mdfnfe.Serie
                            mdfhistnfe.Numero      = mdfnfe.Numero
                            mdfhistnfe.cidemi      = mdfnfe.cidemi
                            mdfhistnfe.ciddes      = mdfnfe.ciddes
                            mdfhistnfe.NfeID       = mdfnfe.NfeID
                            mdfhistnfe.PesoBrutoKG = mdfnfe.PesoBrutoKG
                            mdfhistnfe.ValorNota   = mdfnfe.ValorNota.
                        delete mdfnfe.
                    end.
                end.
             
        end.
    end.
    

    hide message no-pause.
    message 
     vmensagem_erro.
end.    


find first tt-xmlretorno where
    tt-xmlretorno.root = "infProt" and
    tt-xmlretorno.tag = "cStat"
    no-error.
vstatus  = if avail tt-xmlretorno
               then tt-xmlretorno.valor
               else "". 

find first tt-xmlretorno where
    tt-xmlretorno.root = "infProt" and
    tt-xmlretorno.tag = "xMotivo"
    no-error.
vmensagem_erro = if avail tt-xmlretorno
               then tt-xmlretorno.valor
               else "". 
if  vmensagem_erro <> "" and vstatus <> "100"
then do:
    do on error undo.
        find current mdfe exclusive.
        mdfe.cstat = vstatus.
        mdfe.xmotivo = vmensagem_erro.
    end.

    hide message no-pause.
    message 
    substring(vmensagem_erro,1,70) skip
    substring(vmensagem_erro,71,70) skip
    substring(vmensagem_erro,140,70) 
 
    view-as alert-box title "Retorno SEFAZ".
end.    


if vstatus = "100" and
   mdfe.situacao = "A"
then do on error undo:
    find current mdfe exclusive.
    mdfe.situacao = "F".
    mdfe.cstat = vstatus.
    mdfe.xmotivo = vmensagem_erro.
end.

hide message no-pause.

/**for each tt-xmlretorno.
    disp tt-xmlretorno.
    pause.
end.
**/
