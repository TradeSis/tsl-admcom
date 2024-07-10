def temp-table tt-tbcartao like tbcartao.
def temp-table tt-cli 
    field clicod like clien.clicod.
def var varqcar as char.
update varqcar label "Arquivo" format "x(60)" with side-label.
if search(varqcar) = ?
then do:
    message color red/with
        "Arquivo nao encontrado."
        view-as alert-box.
    return.
end.        
def var vconf as log format "Sim/Nao".

message "Confirma gerar CARTAO LEBES para clientes do arquivo informado?"
    update vconf .
if not vconf then return.

input from value(varqcar).

repeat:
    create tt-cli.
    import tt-cli.clicod.
end.
input close.
def buffer btbcartao for tbcartao.
def var b as int.
def var a as int.
def var vnome as char.
for each tt-cli where tt-cli.clicod > 0:
    find last btbcartao use-index indx2 where
              btbcartao.codoper = 999 and
              btbcartao.clicod  = tt-cli.clicod
              no-lock no-error.
    if avail btbcartao then next.
    find clien where clien.clicod = tt-cli.clicod no-lock
            no-error.
    if not avail clien then next.        
    disp clien.clinom no-label with frame f-inc.
    pause 0.  
    create tt-tbcartao.
    tt-tbcartao.clicod = tt-cli.clicod.
    tt-tbcartao.dtinclu = today.
    tt-tbcartao.hrinclu = time.
    tt-tbcartao.validade = ?.
    tt-tbcartao.datexp = today.
 
    tt-tbcartao.nrocartao = "10" + string(clien.clicod,"9999999999").

    tt-tbcartao.contacli = dec(tt-tbcartao.nrocartao).
    tt-tbcartao.validade = date(month(tt-tbcartao.dtinclu),
                                    day(tt-tbcartao.dtinclu),
                            year(tt-tbcartao.dtinclu) + 5).
 
    assign
        tt-tbcartao.codoper = 999
        tt-tbcartao.situacao = "E"
        tt-tbcartao.trilha[1] = tt-tbcartao.nrocartao
        tt-tbcartao.trilha[2] = string(day(tt-tbcartao.validade),"99") +
                                string(month(tt-tbcartao.validade),"99") +
                                string(year(tt-tbcartao.validade),"9999") 
        tt-tbcartao.trilha[3] = string(tt-tbcartao.clicod).       
    b = 0 . a = 0.
    vnome = "".
    b = num-entries(clien.clinom," ").
    if length(clien.clinom) > 26
    then do a = 1 to b:
        if a = 1
        then vnome = entry(1,clien.clinom," ").
        else if a = b
            then vnome = vnome + " " + entry(b,clien.clinom," ").
            else vnome = vnome + " " + substr(entry(a,clien.clinom," "),1,1).
    end.
    else vnome = clien.clinom.
    
    tt-tbcartao.clinom  =  vnome.

    do transaction:
        create tbcartao.
        buffer-copy tt-tbcartao to tbcartao.
    end.  
end.