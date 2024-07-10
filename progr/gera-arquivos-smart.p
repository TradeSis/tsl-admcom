{/admcom/progr/admcab-batch.i new}

pause 5.
pause 0 before-hid.

def var varqlog as char.
def var dt-ini as date.
def var dt-aux as date.
def var vetbcod like estab.etbcod.
def var varquivo as char.
def var log-caminho as char.

find first tbcntgen where tbcntgen.etbcod = 1041 no-lock no-error.
if not avail tbcntgen  or 
        (tbcntgen.validade <> ? and
        tbcntgen.validade < today)
then do:
        message "Controle para INFORMATIVO nao cadastrado ou desativado".
        pause 0.
        return.
end.
log-caminho = acha("LOG",tbcntgen.campo3[3]).

varqlog = log-caminho .

dt-aux = today - 1.
dt-ini = date (month(dt-aux),01,year(dt-aux)).

def var par-exec as char format "x(80)".
par-exec = "000" + string(dt-ini,"99999999") +
    string(dt-aux,"99999999").

output to value(varqlog) append.
put "Inicio Processamento: " + string(time,"hh:mm:ss") format "x(50)" skip
    "Data inicio: "  string(dt-ini,"99/99/9999") 
    " Data fim: "  string(dt-aux,"99/99/9999") skip
    "Parametro: " par-exec skip.
output close.

/***************************************/    
/**** PRODUTOS E SERVIÇOS ****/
output to value(varqlog) append.
put "Produtos: /admcom/progr/pro_aud.p" skip
    "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip
    .
output close.    

run /admcom/progr/pro_aud.p.

output to value(varqlog) append.
put "Fim: " + string(time,"hh:mm:ss") format "x(50)" skip.
output close.

/**** NF ENTRADAS ****/
output to /admcom/audit/param_nfe.
put par-exec skip.
output close.

output to value(varqlog) append.
put "Entradas: /admcom/progr/entd_aud.p" skip.
output close.
 
if search("/admcom/audit/param_nfe") <> ?
then do:
    output to value(varqlog) append.
    put "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    
    run /admcom/progr/entd_aud.p.

    output to value(varqlog) append.
    put "Fim: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    unix silent value("rm /admcom/audit/param_nfe").
end.
else do:
    output to value(varqlog) append.
    put "/admcom/audit/param_nfe não encontrado" skip.
    output close.
end.
     
/**** NF SAIDAS ****/
output to /admcom/audit/param_nfs.
put par-exec skip.
output close.

output to value(varqlog) append.
put "Saidas: /admcom/progr/said_aud.p" skip.
output close.

if search("/admcom/audit/param_nfs") <> ?
then do:
    output to value(varqlog) append.
    put "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    
    run /admcom/progr/said_aud.p.

    output to value(varqlog) append.
    put "Fim: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    unix silent value("rm /admcom/audit/param_nfs").
end.
else do:
    output to value(varqlog) append.
    put "/admcom/audit/param_nfs não encontrado" skip.
    output close.
end.
/****************/

/**** CUPOM FISCAL E MAPA RESUMO ****/
output to /admcom/audit/param_mr.
put par-exec skip.
output close.

if search("/admcom/audit/param_mr") <> ?
then do:
    output to value(varqlog) append.
    put "Atu Mapa: /admcom/progr/gera-map.p" skip
        "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    
    run /admcom/progr/gera-map.p.
    
    output to value(varqlog) append.
    put "Fim: " + string(time,"hh:mm:ss")  format "x(50)" skip.
    output close.
    
    pause 2 no-message.

    output to value(varqlog) append.
    put "Cupom: /admcom/progr/ven_aud.p" skip
        "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    
    run /admcom/progr/ven_aud.p.
    
    output to value(varqlog) append.
    put "Fim: " + string(time,"hh:mm:ss")  format "x(50)" skip.
    output close.
    
    pause 2 no-message.
    
    output to value(varqlog) append.
    put "Mapa Resumo: /admcom/progr/ecf_aud2.p" skip
        "Inicio: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    
    run /admcom/progr/ecf_aud2.p.

    output to value(varqlog) append.
    put "Fim: " + string(time,"hh:mm:ss") format "x(50)" skip.
    output close.
    unix silent value("rm /admcom/audit/param_mr").
end.
else do:
    output to value(varqlog) append.
    put "/admcom/audit/param_mr não encontrado" skip.
    output close.
end.

output to value(varqlog) append.
put "Fim Processamento: " + string(time,"hh:mm:ss") format "x(50)" skip.
output close.

def var varqtexto as char.
def var vaspas as char.
def var e-mail as char.
def var vassunto as char.

varqtexto = "/admcom/relat/email" + string(time).
output to value(varqtexto).
put unformatted
    "Segue em anexo log exportador Smart  " skip(1)
     .
output close.

vaspas   = chr(34).

vassunto = "Log-exp-Smart-" + string(dt-aux,"99999999").

if search(varqlog) <> ?
then do:
    run /admcom/progr/envia_info_anexo.p(input "1041", input varqtexto,
                input varqlog, input vassunto).
end.
 
