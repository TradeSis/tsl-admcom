
{cabec.i}
def input param par-rec-mdfviagem as recid.
def input param par-ufemi as char.
def input param par-ufdes as char.
def input-output param par-rec as recid.

def var vrenavam as int.
/**
def var mdfe_modelo as char.
def var mdfe_sequencia as int.
**/
def var mdfe_forma_emissao as int.
def var mdfe_dv as int.
def var mdfe_chave as char.

def var ibge-uf-emite as char.
def var mdfe_serie as char.
def var mdfe_numero as int.

def buffer bmdfe for mdfe.

def var vufemi like munic.ufecod.
def var vmunicemi like munic.cidnom.
def var vcidemi like munic.cidcod.


def var vufdes like munic.ufecod.
def var vmunicdes like munic.cidnom.
def var vciddes like munic.cidcod.


find mdfe where recid(mdfe) = par-rec no-lock no-error.
if not avail mdfe
then do:
    find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
                                       
    find estab where estab.etbcod = mdfviagem.etbcod no-lock.
    find first tabaux where  tabaux.tabela = "codigo-ibge" and
                    tabaux.nome_campo = estab.ufecod 
                    no-lock no-error.
    if not avail tabaux
    then do:
        message color red/with
         "Codigo do IBGE nao cadastrado para UF " estab.ufecod 
        view-as alert-box.
        return.
    end.  
    ibge-uf-emite = tabaux.valor_campo.

    
end.
else do:
    par-ufemi = mdfe.ufemi.
    par-ufdes = mdfe.ufdes.
    ibge-uf-emite = mdfe.ibge-ufemi.
    mdfe_serie = mdfe.mdfeserie.
    
    find mdfviagem where mdfviagem.mdfvcod = mdfe.mdfvcod no-lock.
end.

if not avail mdfe
then do:

    run le_tabini.p (mdfviagem.etbcod , 0, "MDFE - SERIE", OUTPUT mdfe_serie).
    if mdfe_serie = "" or mdfe_serie = ?
    then mdfe_serie = "001".


    find last bmdfe where bmdfe.etbcod = mdfviagem.etbcod and
                          bmdfe.mdfeserie  = mdfe_serie
    no-lock no-error.
    mdfe_numero = if avail bmdfe 
                then bmdfe.mdfenumero + 1
                else 30.
end.

find frete of mdfviagem no-lock.
find veiculo of mdfviagem no-lock.

if mdfviagem.motoristacpf[1] = "" or
   mdfviagem.motoristanome[1] = ""
then do:
    hide message no-pause.
    message "Viagem sem MOTORISTA" view-as alert-box.
    return.
end.

/**
if mdfviagem.segresp = no and
   mdfviagem.segrespcnpjcpf = "" 
then do:
    hide message no-pause.
    message "Viagem sem CNPJ do Responsavel Contratante pelo SEGURO"
             view-as alert-box.
    return.
end.

if mdfviagem.Seguradora = "" or
   mdfviagem.SegCNPJ = "" 
then do:
    hide message no-pause.
    message "Viagem sem Nome ou CNPJ Seguradora" view-as alert-box.
    return.
end.


if mdfviagem.SegnApol = "" or
   mdfviagem.SegnAver= "" 
then do:
    hide message no-pause.
    message "Viagem sem Apolice ou Averbacao do Seguro" view-as alert-box.
    return.
end.

if not avail frete or
   frete.rntrc = 0 or
   frete.rntrc = ?
then do:
    hide message no-pause.
    message "Transportadora sem RNTRC Informada" view-as alert-box.
    return.
end.


if mdfviagem.CIOT = "" or
   mdfviagem.CIOTCNPJ = "" 
then do:
    hide message no-pause.
    message "Viagem sem CIOT" view-as alert-box.
    return.
end.
**/

if veiculo.tprodado = 0 or
   veiculo.tprodado = ?
then do:
    hide message no-pause.
    message "Veiculo sem Tipo de Rodado Informado" view-as alert-box.
    return.
end.

if veiculo.tpcarroceria = ?
then do:
    hide message no-pause.
    message "Veiculo sem Tipo de Carroceria Informado" view-as alert-box.
    return.
end.


if veiculo.ufplaca = ? or
   veiculo.ufplaca = ""
then do:
    hide message no-pause.
    message "Veiculo sem UF  Informado" view-as alert-box.
    return.
end.


if veiculo.renavam = ? or
   veiculo.renavam = ""
then do:
    hide message no-pause.
    message "Veiculo sem RENAVAM  Informado" view-as alert-box.
    return.
end.
vrenavam = int(veiculo.renavam) no-error.

if vrenavam = ? then do:
    hide message no-pause.
    message "Veiculo RENAVAM  Invalido" view-as alert-box.
    return.
end.

if veiculo.tara = ? or
   veiculo.tara = 0
then do:
    hide message no-pause.
    message "Veiculo sem TARA  Informada" view-as alert-box.
    return.
end.

if not avail mdfe
then do on error undo.
    create mdfe.
        par-rec = recid(mdfe).
        mdfe.etbcod              = mdfviagem.etbcod.
        mdfe.MdfVCod             = mdfviagem.MdfVCod.
        mdfe.MdfeCod             = next-value(mdfeseq).
        mdfe.ibge-ufemi =        ibge-uf-emite.        
        mdfe.UFEmi               = par-UFEmi.
        mdfe.UFDes               = par-UFDes.
        mdfe.MdfeSerie           = mdfe_serie.
        mdfe.MdfeNumero          = mdfe_numero.
        mdfe.MdfeDtEmissao       = today.
        mdfe.MDFeHrEmissao       = time.
        mdfe.dtEncer             = ?.

    mdfe_forma_emissao = 1. /* 1-Normal, 2-Contingencia*/
     
    run mdfe/mdfegerachave.p 
        (input  recid(mdfe),
         input-output mdfe_forma_emissao,
         output mdfe_dv,
         output mdfe_chave).

    assign
        mdfe.mdfechave = mdfe_chave
        mdfe.mdfedv    = mdfe_dv
        mdfe.mdfeformaemi = mdfe_forma_emissao.

    for each mdfnfe of mdfviagem
        where
            mdfnfe.mdfecod = ? .

        vufemi = "**". vmunicemi = "**". vcidemi = ?.
        vufdes = "**". vmunicdes = "**". vciddes = ?.
    
        if mdfnfe.tabemite = "ESTAB" or 
           mdfnfe.tabemite = ""
        then do:
            find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
            if avail estab 
            then do:
                find first munic where munic.ufecod = estab.ufecod and
                                 munic.cidnom = estab.munic
                    no-lock no-error  .
                if avail munic
                then do:
                    vmunicemi = munic.cidnom.
                    vcidemi   = munic.cidcod.
                end.                
                vufemi = estab.ufecod.
                        
            end.    
        end.    
        if mdfnfe.tabemite = "FORNE"
        then do:        
            find forne where forne.forcod = mdfnfe.emite no-lock no-error.
            if avail forne 
            then do:
                find first munic where munic.ufecod = forne.ufecod and
                                 munic.cidnom = forne.formunic
                    no-lock no-error  .
                if avail munic
                then do:
                    vmunicemi = munic.cidnom.
                    vcidemi   = munic.cidcod.
                end.                
                vufemi = forne.ufecod.
            end. 
        end.            
 
        if mdfnfe.tabdesti = "ESTAB" or 
           mdfnfe.tabdesti = ""
        then     do:
            find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
            if avail estab 
            then     do:
                find first munic where munic.ufecod = estab.ufecod and
                                 munic.cidnom = estab.munic
                    no-lock no-error  .
                if avail munic
                then do:
                    vmunicdes = munic.cidnom.
                    vciddes   = munic.cidcod.
                end.                
                vufdes = estab.ufecod.
            end.            
        end.        
        
        if mdfnfe.tabdesti = "FORNE"
        then do:
            find forne where forne.forcod = mdfnfe.desti no-lock no-error.
            if avail forne 
            then do:
                find first munic where munic.ufecod = forne.ufecod and
                                 munic.cidnom = forne.formunic
                    no-lock no-error  .
                if avail munic
                then do:
                    vmunicdes = munic.cidnom.
                    vciddes   = munic.cidcod.
                end.                
                vufdes = forne.ufecod.
            end.            
        end.        
        
        if par-ufemi <> vufemi or
           par-ufdes <> vufdes or
           vcidemi = ? or
           vciddes = ?
        then next.    
        
        mdfnfe.mdfecod = mdfe.mdfecod.
                                
            
            
    end.
end.


