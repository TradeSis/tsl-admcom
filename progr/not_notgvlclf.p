
def input  parameter par-tabela as char.
def input  parameter par-rec    as recid.
def output parameter par-ok     as log init yes.

def var vcgccpf as char.
def var vfone   as dec.
def buffer xestab for estab.
def buffer xclien for clien.
def buffer xforne for forne.
def var verr-ender as log.

if par-tabela = "estab"
then do.
    find xestab where recid(xestab) = par-rec no-lock.
    vcgccpf = trim(xestab.etbcgc).
    vcgccpf = replace(vcgccpf, ".", "").
    vcgccpf = replace(vcgccpf, "/", "").
    vcgccpf = replace(vcgccpf, "-", "").
            
    run cgc.p (vcgccpf, output par-ok).
    if par-ok = no 
    then message "CNPJ Invalido:" xestab.etbcgc view-as alert-box.

    vfone = dec(xestab.etbserie) no-error.
    
    if length(trim(xestab.endereco)) < 5 or
       num-entries(xestab.endereco) < 2 or
       length(xestab.munic) < 3 or
       xestab.etbcgc = xestab.etbinsc or
       xestab.etbinsc = "" or
       xestab.ufecod = "" or
       vfone = 0
    then do.
        verr-ender = length(trim(xestab.endereco)) < 5 or
                     num-entries(xestab.endereco) < 2.
        par-ok = no.
        disp
            xestab.etbcgc colon 18
            xestab.etbcod colon 18
            xestab.etbnom colon 18
            xestab.endereco colon 18
            verr-ender format "* Erro */"
            xestab.munic  colon 18
            length(trim(xestab.munic)) < 3   format "* <3 */"
            xestab.ufecod
            xestab.etbinsc colon 18
            xestab.etbinsc = "" or xestab.etbcgc = xestab.etbinsc format "***/"
            xestab.etbserie label "Fone"
            vfone = 0 format "***/"
            "*** Dados obrigatorios" colon 18
            with frame f-alerta-etb centered side-label
                 title "-> Atualize Dados Cadastrais Estabelecimento <-".
        pause.
        return.
    end.
end.

if par-tabela = "clien"
then do.
    find xclien where recid(xclien) = par-rec no-lock.

    vcgccpf = trim(xclien.ciccgc).
    vcgccpf = replace(vcgccpf, ".", "").
    vcgccpf = replace(vcgccpf, "/", "").
    vcgccpf = replace(vcgccpf, "-", "").

    if xclien.tippes
    then do.
        run cpf.p (vcgccpf, output par-ok).
        if par-ok = no 
        then message "CPF Invalido:" xclien.ciccgc view-as alert-box.
    end.
    else do.
        run cgc.p (vcgccpf, output par-ok).
        if par-ok = no
        then message "CNPJ Invalido:" xclien.ciccgc view-as alert-box.
    end.
    
    if length(trim(xclien.endereco[1])) < 5 or
       (xclien.numero[1] = ? or xclien.numero[1] = 0) or
       length(xclien.cidade[1]) < 3 or
       xclien.ciccgc = xclien.ciinsc or
       (xclien.cep[1] = ? or length(xclien.cep[1]) < 8) or
       xclien.ufecod[1] = ""
    then do.
        par-ok = no.
        disp
            xclien.ciccgc    colon 18
            xclien.clicod    colon 18
            xclien.clinom    colon 18
            xclien.endereco[1] colon 18 label "Endereco"
            length(trim(xclien.endereco[1])) < 5 format "* < 5 */"
            xclien.numero[1] colon 18 label "Numero"
            xclien.compl[1]  label "Compl"
            xclien.cep[1]    label "CEP"
            xclien.cidade[1] colon 18 label "Cidade"
            length(trim(xclien.cidade[1])) < 3   format "* <3 */"
            xclien.ufecod[1] label "UF"
            xclien.ciinsc    colon 18
            xclien.ciccgc = xclien.ciinsc format "***/"
            "*** Dados obrigatorios" colon 18
            with frame f-alerta-cli centered side-label
                 title "-> Atualize Dados Cadastrais Clientes <-".
        pause.
        return.
    end.
end.

if par-tabela = "forne"
then do.
    find xforne where recid(xforne) = par-rec no-lock.

    vcgccpf = trim(xforne.forcgc).
    vcgccpf = replace(vcgccpf, ".", "").
    vcgccpf = replace(vcgccpf, "/", "").
    vcgccpf = replace(vcgccpf, "-", "").            
    run cgc.p (vcgccpf, output par-ok).
    if par-ok = no 
    then message "CNPJ Invalido:" xforne.forcgc view-as alert-box.

    vfone = dec(xforne.forfone) no-error.
    
    if length(trim(xforne.forrua)) < 5 or
       /***num-entries(xforne.forrua) < 2 or***/
       length(xforne.formunic) < 3 or
       xforne.forcgc = xforne.forinest or
       vfone = 0 or
       xforne.ufecod = "" or
       xforne.ativo  = no
    then do.
        par-ok = no.
        disp
            xforne.forcgc colon 18
            xforne.forcod colon 18
            xforne.fornom colon 18
            xforne.forrua colon 18
            length(trim(xforne.forrua)) < 5 format "* <5 */"
            xforne.formunic colon 18
            length(trim(xforne.formunic)) < 3   format "* <3 */"
            xforne.ufecod
            xforne.forinest colon 18
            xforne.forcgc = xforne.forinest format "***/"
            xforne.forfone  vfone = 0 format "***/"
            xforne.ativo    colon 18 format "Sim/***"
            "*** Dados obrigatorios ou invalidos " colon 18
            with frame f-alerta-for centered side-label
                 title "-> Atualize Dados Cadastrais Fornecedores <-".
        pause.
        return.
    end.
end.

