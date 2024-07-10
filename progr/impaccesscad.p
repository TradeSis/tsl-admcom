/* Layout arquivo acionamentos e atualizacoes cadastrais */
{admcab.i}

def input parameter par-reclotcre  as recid.

def temp-table tt-detalhe01
    field tiporeg           as int format 9 initial 1
    field tipodetalhe       as int
    field cpfcnpj           as int
    field tipoender         as char
    field logradouro        as char
    field numero            as int
    field complemento       as char
    field bairro            as char
    field cidade            as char
    field uf                as char
    field cep               as int
    field dddresid          as int
    field foneresid         as int
    field dddcel            as int
    field fonecel           as int
    field localtrab         as char
    field cargo             as char
    field dddcomer          as int
    field fonecomer         as int.
    

def var vdir        as char.
def var varq        as char.
def var vlinha      as char.
def var vtime       as int.
def var vct         as int.
def var vretorno    as char.
def var vcodbarras  as char.

if opsys = "unix"
then vdir = "/admcom/custom/nede/arquivos/".
else vdir = "l:~\access~\titulos~\".

do on error undo with frame f-filtro side-label
            title " Atualizacoes Cadastrais - Access ".
    disp vdir label "Diretorio" colon 15 format "x(45)".
    update vdir.
    update varq label "Arquivo" colon 15 format "x(45)".
end.

if search(vdir + varq) = ?
then do.
    message "Arquivo nao encontrado:" vdir + varq view-as alert-box.
    return.
end.

sresp = no.
message "Processar o retorno  ?" update sresp.
if sresp <> yes
then return.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vtime = time.
for each tt-detalhe01.
    delete tt-detalhe01.
end.


input from value(vdir + varq).
repeat on error undo, next.
    import unformatted vlinha.

    vct = vct + 1.
    disp vct with frame f-proc no-label centered.
    pause 0.

    find first tt-detalhe01  no-lock no-error.
    if not avail tt-detalhe01
    then do:
    
        /* Detalhe 01 */
        if substr(vlinha,1,1) = "1"
        then
            assign 
            tt-detalhe01.tiporeg        = int(substr(vlinha,1,1))
            tt-detalhe01.tipodetalhe    = int(substr(vlinha,2,2))
            tt-detalhe01.cpfcnpj        = int(substr(vlinha,4,14))
            tt-detalhe01.tipoender      = substr(vlinha,18,10)
            tt-detalhe01.logradouro     = substr(vlinha,28,50)
            tt-detalhe01.numero         = int(substr(vlinha,78,10))
            tt-detalhe01.complemento    = substr(vlinha,88,20)
            tt-detalhe01.bairro         = substr(vlinha,108,30)
            tt-detalhe01.cidade         = substr(vlinha,138,30)
            tt-detalhe01.uf             = substr(vlinha,168,2)
            tt-detalhe01.cep            = int(substr(vlinha,170,8))
            tt-detalhe01.dddresid       = int(substr(vlinha,178,3))
            tt-detalhe01.foneresid      = int(substr(vlinha,181,8))
            tt-detalhe01.dddcel         = int(substr(vlinha,189,3))
            tt-detalhe01.fonecel        = int(substr(vlinha,192,8)) 
            tt-detalhe01.localtrab      = substr(vlinha,200,30)  
            tt-detalhe01.cargo          = substr(vlinha,230,15) 
            tt-detalhe01.dddcomer       = int(substr(vlinha,245,3))  
            tt-detalhe01.fonecomer      = int(substr(vlinha,248,8))  .

    end.

for each tt-detalhe01 no-lock.
    
    find clien where clien.ciccgc = string(tt-detalhe01.cpfcnpj)
    no-lock no-error.
    
    if avail clien
    then do:

        /* Atualiza a tabela cliente */
        assign
            clien.ciccgc    = string(tt-detalhe01.cpfcnpj) 
            clien.endereco  = tt-detalhe01.tipoender + tt-detalhe01.logradouro 
            clien.numero    = int(tt-detalhe01.numero) 
            clien.compl     = tt-detalhe01.complemento  
            clien.bairro    = tt-detalhe01.bairro 
            clien.cidade    = tt-detalhe01.cidade 
            clien.ufecod    = tt-detalhe01.uf 
            clien.cep       = string(tt-detalhe01.cep)
            clien.fone      = string(tt-detalhe01.dddresid) +                                                   string(tt-detalhe01.foneresid)
            clien.reftel    = string(tt-detalhe01.dddcel) +                                 string(tt-detalhe01.fonecel) 
            clien.proemp    = tt-detalhe01.localtrab.  
            clien.protel    = string(tt-detalhe01.dddcomer) +                                                  string(tt-detalhe01.fonecomer). 
    end.
end.
end.
input close.
/*
message "Arquivo processado: Corretos=" vok "Com erro=" verro
        view-as alert-box.
*/
