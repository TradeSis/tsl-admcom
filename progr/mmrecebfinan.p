def temp-table tt-arq
    field numlinha as int
    field linha as char
    field valor as char extent 50
    index i1 numlinha
    .

/* recebimentosjunho2015.csv */
def var varquivo as char .
def var vdirarq as char format "x(28)".
def var vnomarq as char format "x(35)".
vdirarq = "/admcom/financeira/addmoeda/".

message color red/with
    "Somente arquiv CSV separador ;"
    view-as alert-box.
    
disp vdirarq label "Arquivo" 
     vnomarq no-label
     with frame f-arq 1 down side-label row 5.
update vnomarq with frame f-arq.

/*
if num-entries(vnomarq,".") > 1
    and entry(2,vnomarq,".") <> "CSV"
then.
else do:
    message color red/with
    "Somente arquivo CSV"
    view-as alert-box.
    return.
end. */
varquivo = vdirarq + vnomarq.

if search(varquivo) = ?
then return.

def var vcolcontrato as int format ">>9".
def var vcolparcela as int  format ">>9".

update vcolcontrato at 1 label "Coluna contrato"
       vcolparcela  at 1 label "Coluna parcela "
       with frame f-col side-label.

def var qlinha as int.
def var vi as int.
def var vlinha as char.
def var vnumentry as int.

def stream stela.
output stream stela to terminal.

disp stream stela "Aguarde  importando informações"
    with frame f-msg color message 5 down row 15 width 80
    no-label.
pause 0.

def var vok-arq as log.
vok-arq = no.

input from value(varquivo).
repeat :
    import unformatted vlinha.
    /*
    message vlinha num-entries(vlinha,";").
    pause.
    */
    vnumentry =  num-entries(vlinha,";").
    
    qlinha = qlinha + 1.
    
    create tt-arq.
    tt-arq.numlinha = qlinha. 
    tt-arq.linha = vlinha.
    do vi = 1 to vnumentry:
        tt-arq.valor[vi] = entry(vi,vlinha,";").
    end.

    if qlinha = 1
    then do:
        if entry(vcolcontrato,vlinha,";") = "Contrato"
            and entry(vcolparcela,vlinha,";") = "Parcela"
        then vok-arq = yes.
        else leave.
    end.
    disp stream stela qlinha format ">>>>>>>>9" 
        "  registros" with frame f-msg.
    pause 0.
end.
input close.

if vok-arq = no
then do:
    hide frame f-msg no-pause.
    bell.
    message color red/with
    "Verificar valor coluna contrato " vcolcontrato "e/ou valor coluna parcela"
    vcolparcela "do arquivo informado"
    view-as alert-box.
    return.
end.

disp stream stela skip  "Aguarde processando informações"
        with frame f-msg.
for each tt-arq.
    find contrato where contrato.contnum = int(tt-arq.valor[vcolcontrato])
            no-lock no-error.
    if avail contrato
    then do:
        find first titulo where
               titulo.clifor = contrato.clicod and
               titulo.titnum = string(contrato.contnum) and
               titulo.titpar = int(tt-arq.valor[vcolparcela])
               no-lock no-error.
        if avail titulo /*and titulo.moecod = "NOV" */
        then do:
            if titulo.moecod <> ""
            then tt-arq.valor[vnumentry + 1] = titulo.moecod. 
            else tt-arq.valor[vnumentry + 1] = string(titulo.etbcobra).
        end.                  
    end.
    disp stream stela tt-arq.numlinha format ">>>>>>>>9" 
            "  registros" with frame f-msg.
end.

disp stream stela skip "Aguarde  gerando  novo  arquivo"
        with frame f-msg.
pause 0.
        
def var vnumlinha as int.

varquivo = entry(1,varquivo,".") + "-moeda.csv". 
output to value(varquivo).
for each tt-arq:
    do vi = 1 to (vnumentry + 1):
        put unformatted tt-arq.valor[vi]. 
        if vi <> (vnumentry + 1)
        then put ";". 
    end.
    put skip.
    vnumlinha = tt-arq.numlinha.
    disp stream stela vnumlinha format ">>>>>>>>9" 
            "  registros" with frame f-msg.
end.
output close.

disp stream stela skip "FIM"
    with frame f-msg.
    
message color red/with
    "Arquivo gerado " skip 
    varquivo
    view-as alert-box.
    
    
