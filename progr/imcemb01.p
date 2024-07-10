
{admcab.i}

def temp-table tt-campanha like campanha.
def var varq as char.
def var varq1 as char.
def var vcampanha like campanha.acaocod.
def var vqtd as int.
def var vconfirma as log format "Sim/Nao".
find last acao where acao.acaocod >= 15000 and
                     acao.acaocod <  16000
                     no-lock no-error.
if avail acao
then vcampanha = acao.acaocod + 1.
else vcampanha = 15000.                     
varq = "/admcom/embrace/".
update  vcampanha validate( vcampanha > 0,"Campanha deve ser informada")
        label "Campanha"
        vqtd   label "Quantidade de registros importar" 
        help "Informe 0 para todo o arquivo"
        varq label "Arquivo"  format "x(65)"
        with frame f-arq 1 down centered side-label.

if search(varq) = ?
then do:
    bell.
    message "Arquivo nao encontrado".
    pause.
    return.
end.

find first acao where acao.acaocod = vcampanha no-error.
if not avail acao
then do transaction:
    sresp = no.
    message "CRIAR ACAO " VCAMPANHA " ?" update sresp.
    if not sresp then return.
    create acao.
    assign
        acao.acaocod = vcampanha
        acao.dtini   = today.
    update acao.descricao 
           acao.dtini at 1 label "Validade de"
           acao.dtfin label "Ate" with frame f-arq.
end.
else do transaction:
    update acao.descricao 
           acao.dtini at 1 label "Validade de"
           acao.dtfin label "Ate" with frame f-arq.
end. 

varq1 = varq + ".quo".

if opsys = "UNIX"
then unix silent value("quoter -d % " +  varq  + " > " + varq1).
else dos  value("c:\dlc\bin\quoter -d % " +  varq  + " > " + varq1).


if search(varq1) <> ?
then.
else return.

def var vlinha as char.
def var vv as int.
def var va as int.
def var vb as int.
def var vc as int.
def var vd as int.
def var vvalor as char extent 30.
def var v-leng as int.
def var vimp as int.
def var vlucro as dec decimals 8.
 
input from value(varq1).
repeat:
    import vlinha.
    vb = 1.
    vc = 1.
    vd = 1.
    if vv >= 1   and substr(vlinha,1,1) <> ";"
    then do:
        do va = 1 to 200:
            if substr(vlinha,va,1) = ";" or
               substr(vlinha,va,1) = " "
            then do:
                vc = va - vb.
                vvalor[vd] = substr(vlinha,vb,vc).
                vb = va + 1.
                vd = vd + 1.
            end.
            if substr(vlinha,va,1) = ""
            then leave.
        end.
        create tt-campanha.
        assign
            tt-campanha.acaocod = vcampanha
            tt-campanha.clicod = int(vvalor[1])
            tt-campanha.crmcod = int(vvalor[2])
            tt-campanha.etbcod = int(vvalor[3])
            tt-campanha.segmentacao = int(vvalor[4])
            tt-campanha.publico = int(vvalor[5])
            tt-campanha.perfil = int(vvalor[6])
            tt-campanha.departamento = int(vvalor[7])
            tt-campanha.setor = int(vvalor[8])
            tt-campanha.produto = int(vvalor[9])
            tt-campanha.apelo = int(vvalor[10])
            tt-campanha.canal = int(vvalor[11])
            tt-campanha.lucro_medio = dec(trim(vvalor[12])) / 100
            vimp = vimp + 1
             .
            
        disp tt-campanha.acaocod
             tt-campanha.clicod
             tt-campanha.crmcod
             tt-campanha.lucro_medio
             vimp
             with frame f-disp down no-label centered
             title " Improtando "
             .
        pause 0.     
    end.

    vv = vv + 1.
    
    if vqtd > 0 and vimp >= vqtd
    then leave.
end.
input close.

disp "Registros selecionados...      " format "x(40)" vimp
    with frame f-ms row 10 centered no-label no-box.
disp "Confirma Atualizar Registros ? " format "x(40)" "      "
    with frame f-ms1 row 12 centered no-label no-box.
update vconfirma with frame f-ms1.
if vconfirma
then do: 
    disp "Atualizando Regsitros... Aguarde! "  format "x(40)"
    with frame f-ms2 row 14 centered no-label no-box.
    vimp = 0.
    for each tt-campanha where tt-campanha.acaocod > 0 no-lock:
        find first campanha where 
                   campanha.acaocod = tt-campanha.acaocod and
                   campanha.crmcod  = tt-campanha.crmcod and
                   campanha.clicod  = tt-campanha.clicod
                   no-error.
        if not avail campanha
        then create campanha.
        buffer-copy tt-campanha to campanha. 
        find first acao-cli where
                   acao-cli.acaocod = tt-campanha.acaocod and
                   acao-cli.clicod  = tt-campanha.clicod
                    no-error.
        if not avail acao-cli
        then do:            
            create acao-cli.
            assign
                acao-cli.acaocod = tt-campanha.acaocod
                acao-cli.clicod  = tt-campanha.clicod
                .
        end.
        vimp = vimp + 1.
        disp vimp with frame f-ms2.
    end.
    disp "Rgistros Atualizados...      " format "x(40)" vimp
    with frame f-ms3 row 16 centered no-label no-box.
end.
return.
