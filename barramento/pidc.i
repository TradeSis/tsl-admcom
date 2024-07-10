def var ts-meupid               as int. 
def var vlk        as char.

/* Funcao que gera o nome de arquivos externos utilizados */
FUNCTION arquivos return char
    (input par-variavel as char).

def var vresposta as char.

def var varq as char.

varq = "./ASYNCc".

     case par-variavel:
     when "pid" 
       then vresposta = varq + ".pid".
    when "ping" 
       then vresposta = varq + ".ping".
     when "ps" 
       then vresposta = varq + ".ps".
     when "lk"                                                         
       then vresposta = varq + ".lk".
     when "log" 
       then vresposta = varq + ".log".
    end case.
    
    return
        vresposta.
        
end function.     

function pid returns int
    (input par-acao       as char).


def var ts-arqpid as char.
def var ts-arqps  as char.

def var vpid      as int.
def var vpid-ps   as int.
def var aux-c     as char.
def var aux-i     as int.

ts-arqpid   = arquivos("pid").
ts-arqps    = arquivos("ps").

vpid = 0.

if par-acao = "registra"
then do:
    unix silent value("echo $PPID>" + ts-arqpid).
    input from value(ts-arqpid).
    import vpid.
    input close.
    return vpid.
end.

if par-acao = "verifica"
then do:
    if search(ts-arqpid) <> ?
    then do:
        input from value(ts-arqpid).
        import vpid.
        input close.
        unix silent value("ps -p" + string(vpid) + " >" + ts-arqps).

        aux-i = 0.

        input from value(ts-arqps).
        repeat.
            if aux-i = 1
            then import vpid-ps.
            else import aux-c.
            aux-i = aux-i + 1.
        end.    
        input close.
    end.

    if vpid = vpid-ps and
       vpid <> 0
    then do:
        return vpid.
    end.
    else return 0.
end.

END function.


function lk return log
    (input par-acao       as char,
     input par-texto      as char).
     
def var ts-lk    as char.
def var ts-arqlk as char.
ts-arqlk    = arquivos("lk").
file-info:file-name = ts-arqlk.
     
if par-acao = "registra"
then do: 
    message "MARCANDO LK COM " + par-texto. 
    output to value(ts-arqlk).
    export par-texto.
    output close.
end.

if par-acao = "FIM"
then do:
    input from value(ts-arqlk) no-echo.
    import ts-lk.
    input close.
    /*message "LK " ts-arqlk " CONTEM -> " + ts-lk  " - " today string(time,"HH:MM:SS"). */

    if ts-lk = "FIM" 
    then do:
        message "BYE! ". 
        quit.
    end.
    
end.
    
if par-acao = "EXECUTANDO"
then do:
    
    input from value(ts-arqlk) no-echo.
    import ts-lk.
    input close.
    message "LK CONTEM -> " + ts-lk. 
    
    if ts-lk = "FIM"  or
       ts-lk = "EXECUTANDO"
    then do:
        message "BYE! ". 
        quit.
    end.
     
end.

END function.



ts-meupid = pid("verifica") .
 
if ts-meupid <> 0
then do:
        message "Ja´ Processando... PID " + string(ts-meupid).
        quit.
end.

ts-meupid = pid("registra").
lk("registra","inicio").

/* Le novamente arquivo lk, para ver se nao foi disparado */
lk("FIM","").
lk("EXECUTANDO","").
lk("registra","EXECUTANDO").


