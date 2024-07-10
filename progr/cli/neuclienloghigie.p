def input parameter par-cpf             like neuclien.cpf.
def input parameter par-tabela          like neuclienhigie.tabelaalt.
def input parameter par-recid           as recid.
def input parameter par-campo           like neuclienhigie.campoalt.
def input parameter par-dadonovo        like neuclienhigie.dadonovo.

def var p-dadoori as char.
def var p-camposchave as char.
def var p-dadoschave  as char.

def var vtime as int.
def buffer bneuclien for neuclien.
def var vtroca as log.

if par-tabela = "NEUCLIEN"
then do on error undo:
    find neuclien where recid(neuclien) = par-recid no-lock no-error.
    if avail neuclien
    then do:
        p-camposchave = "CPF".
        p-dadoschave  = string(neuclien.cpf).
        find neuclien where recid(neuclien) = par-recid exclusive 
        no-wait no-error.
        if avail neuclien
        then do:
            if par-campo = "CLICOD"
            then do: 
                vtroca = yes.            
                find bneuclien where 
                        bneuclien.clicod = int(par-dadonovo) 
                    exclusive no-error. 
                if avail bneuclien 
                then do: 
                    if bneuclien.cpf = ? 
                    then do: 
                        delete bneuclien.
                    end. 
                    else do:
                        vtroca = no.
                    end.
                end.    
                if vtroca = no
                then p-dadoori = "JA EXISTE NEUCLIEN " +
                                 par-dadonovo.
                else do:
                   p-dadoori = string(neuclien.clicod).
                   neuclien.clicod = int(par-dadonovo).
                end.
            end.
        end.                
    end.
end.
else
if par-tabela = "CLIEN"
then do on error undo:
    find clien where recid(clien) = par-recid exclusive.
    p-camposchave = "CLICOD".
    p-dadoschave  = string(clien.CLICOD).
    
    if par-campo = "CICCGC"
    then do:
        p-dadoori   = clien.ciccgc.
        clien.CICCGC = par-dadonovo.
    end.
end.
else
if par-tabela = "PLANI"
then do on error undo:
    find plani where recid(plani) = par-recid exclusive.
    if par-campo = "DESTI"
    then do:
        p-dadoori  = string(plani.desti).
        plani.desti = int(par-dadonovo).
    end.
end.

if p-camposchave = ""
then do:
    p-dadoori = "CAMPO NAO MAPEADO".
end.    
else do:
    if p-dadoori = ""
    then do:
        p-dadoori = "REG NAO DISPONIVEL".
    end.
end.

vtime = time.
find first neuclienhigie where 
        neuclienhigie.cpfcnpj = par-cpf and
        neuclienhigie.data    = today   and
        neuclienhigie.hora    = vtime
        no-lock no-error.
        
if avail neuclienhigie
then do:
    pause 1 no-message.
    vtime = time.
end.    

CREATE NEUCLIENhigie.
DO:
  ASSIGN
    NeuClienHigie.CpfCnpj     = par-Cpf
    NeuClienHigie.Data        = today
    NeuClienHigie.Hora        = vtime
    NeuClienHigie.TabelaAlt   = par-tabela
    NeuClienHigie.CamposChave = p-CamposChave
    NeuClienHigie.DadosChave  = p-DadosChave
    NeuClienHigie.CampoAlt    = par-campo
    NeuClienHigie.DadoOri     = p-DadoOri
    NeuClienHigie.DadoNovo    = par-DadoNovo.
END.