{admcab.i}

def var vok-arq as log.
def var vdiretorio as char.
def var varquivo as char.
def var val-bonus as dec.
def var vdt-ven as date.
def var vcod-acao as int.
def var vdes-acao as char.

vdiretorio = "/admcom/relat-crm/".


form vdiretorio     label "Local  do Arquivo" format "x(30)"
     varquivo  at 1 label "Nome   do arquivo" format "x(30)"
     vcod-acao at 1 label "Codigo    da acao"
     vdes-acao at 1 label "Descricao da acao"
     val-bonus at 1 label "Valor    do Bonus"
     vdt-ven   at 1 label "Data   vencimento"
     with frame f-bon 1 down side-label width 80.

update vdiretorio 
           varquivo with frame f-bon.     
def var varq as char.
varq = vdiretorio + varquivo.
if search(varq) = ?
then do:
    message color red/with
        "Arquivo " varq "nao encontrado."
        view-as alert-box
        .
    undo.    
end. 

repeat on error undo:
    update
         vcod-acao 
         vdes-acao validate(vdes-acao <> "","") format "x(40)"
         val-bonus validate(val-bonus <> 0,"")
         vdt-ven   validate(vdt-ven <> ? and vdt-ven > today,"")
         with frame f-bon.
    leave.
end.
if keyfunction(lastkey) = "END-ERROR"
then return.

sresp = no.    
message "Confirma os dados informados?" update sresp.
if not sresp then return.


def temp-table tt-arq no-undo
    field linha as int
    field campo1 as char
    field campo2 as char 
    index i1 linha
    .

def temp-table tt-titulo like titulo.
     
def var vl as int.
def var vlinha as char.

vok-arq = no.

disp "Importando e validando arquivo"
    with frame f-log no-label width 80.

input from value(varq).
repeat:
    import unformatted vlinha.
    if num-entries(vlinha,";") <> 2
    then do:
        vok-arq = no.
        leave.
    end.
    vok-arq = yes.
    create tt-arq.
    assign
        tt-arq.campo1 = entry(1,vlinha,";")
        tt-arq.campo2 = entry(2,vlinha,";")
        .
end.
input close.

if not vok-arq
then do:
    bell.
    message color red/with
    "Arquivo com problema de layout." skip
    "Importacao cancelada."
    view-as alert-box.
    return.
end.    

def var vtitnum like titulo.titnum.

disp "Extraindo e validando os dados do arquivo"
    with frame f-log1 no-label width 80.

for each tt-arq where tt-arq.campo1 <> "" and
                      tt-arq.campo2 <> ""
                      :
    find clien where clien.clicod = int(tt-arq.campo1) no-lock no-error.
    if not avail clien
    then do:
        message color red/with
        "Cliente " tt-arq.campo1 "nao encontrado na base do Admcom."
        view-as alert-box.
    end.
    else do:
        find estab where estab.etbcod = int(tt-arq.campo2) no-lock no-error.
        if not avail estab
        then do:
            message color red/with
            "Filial " tt-arq.campo2 "nao encontrada na base do Admcom."
            view-as alert-box.
        end.
        else do:
            if vcod-acao > 0
            then
            vtitnum = string(int(tt-arq.campo1)) +
                      string(int(vcod-acao),"99999999").
            else
            vtitnum = string(int(tt-arq.campo1)) +
                      string(today,"99999999").
            create tt-titulo.
            assign
                tt-titulo.empcod = 19
                tt-titulo.titnat = yes
                tt-titulo.modcod = "BON"
                tt-titulo.etbcod = int(tt-arq.campo2)
                tt-titulo.clifor = int(tt-arq.campo1)
                tt-titulo.titnum = vtitnum
                tt-titulo.titpar = 1
                tt-titulo.titdtemi = today
                tt-titulo.titdtven = vdt-ven
                tt-titulo.titvlcob = val-bonus
                tt-titulo.titsit   = "LIB"
                tt-titulo.moecod   = "BON"
                tt-titulo.titobs[1] = string(vcod-acao)
                tt-titulo.titobs[2] = "BONUS=" + vdes-acao + "|"
                .
        end.
    end.
end.

disp "Gravando os dados na base do Admcom"
    with frame f-log2 no-label width 80.

for each tt-titulo:
    create titulo.
    buffer-copy tt-titulo to titulo.
end.    

disp "FIM"
    with frame f-log3 no-label width 80.

