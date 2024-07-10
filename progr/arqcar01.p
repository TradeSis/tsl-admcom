def input parameter p-acao like acao.acaocod.
def input parameter scar as log.
/*
def var scar as log.
scar = no.

run mensagem.p(input-output scar,
               input "!SIM = GERAR PARA TODOS OS PARTICIPANTES " +
                     "!NAO = GERAR PARA QUEM AINDA NAO TEM ",
               input " Arquivo para CARTAO ",
               input "   SIM",
               input "   NAO").
*/ 

def buffer btbcartao for tbcartao.

def var vdig as int.
def var varquivo as char.
def var v1 as int init 0.
def var v2 as int.
def var v3 as int.
def var vcartao as char.
def var vnome as char.
def var dt-validade as date format "99/99/9999".

def temp-table tt-tbcartao like tbcartao.

if opsys = "UNIX"
then varquivo = "/admcom/relat-cartao/cartao" + string(p-acao) + ".txt".
else varquivo = "l:~\relat-cartao~\cartao" + string(p-acao) + ".txt".


def stream smens.
output stream smens to terminal.
disp  stream smens "GERANDO ARQUIVO PARA CARTÃO... AGUARDE! "
        with frame f-arq 1 down no-box centered row 10 no-label
        color message.
pause 0. 
def var tem-cartao as log.
       
output to value(varquivo).

find first acao where acao.acaocod = p-acao no-lock.
for each acao-cli where acao-cli.acaocod = acao.acaocod no-lock,
    first clien where clien.clicod = acao-cli.clicod 
        no-lock by clien.cep[1].
    if not avail clien then next.
    
    /*29284*/
    find last fin.clispc where 
              fin.clispc.clicod = acao-cli.clicod no-lock no-error.

    if avail fin.clispc and
             fin.clispc.dtcanc = ?
             then next.                
    /*
    if scar = no
    then do:
        find first tbcartao where tbcartao.codoper = 999 and
                              tbcartao.clicod = clien.clicod and
                              tbcartao.situacao <> "C"
                              no-lock no-error.
        if avail tbcartao then next.
    end. 
    */               
    /*                          
    find first rfvcli where rfvcli.setor = 0 and
                            rfvcli.clicod = clien.clicod no-lock no-error.
    if not avail rfvcli then next.
    */
    vcartao = "".
    tem-cartao = no.
    find last btbcartao use-index indx2 where
              btbcartao.codoper = 999 and
              btbcartao.clicod  = clien.clicod
              no-lock no-error.
    if not avail btbcartao
    then vcartao = "10" + string(clien.clicod,"9999999999"). 
    else if btbcartao.situacao = "C"
        then do:
            if substr(btbcartao.nrocartao,1,1) = "0"
            then vdig = int(substr(btbcartao.nrocartao,2,2)).
            else vdig = int(substr(btbcartao.nrocartao,1,2)).
            vcartao = string(vdig + 10) +
                      string(clien.clicod,"9999999999").
        end.
        else do:
            vcartao = btbcartao.nrocartao.
            /***
            bell.
            message color red/with
            "Cliente " btbcartao.clicod " possui cartao " btbcartao.nrocartao
             " em situacao " btbcartao.situacao  skip
            "Nao sera criado novo cartao"
            /*view-as alert-box*/.
            ***/
            pause 0.
            tem-cartao = yes.
            if scar = no
            then next.
        end. 
    if vcartao = "" 
    then next.    
    v1 = v1 + 1.
    disp stream smens clien.clicod v1
        with frame f-arq.
    pause 0.     
    
    v2 = 0 . v3 = 0.
    vnome = "".
    v2 = num-entries(clien.clinom," ").
    if length(clien.clinom) > 26
    then do v3 = 1 to v2:
        if v3 = 1
        then vnome = entry(1,clien.clinom," ").
        else if v3 = v2
            then vnome = vnome + " " + entry(v2,clien.clinom," ").
            else vnome = vnome + " " + substr(entry(v3,clien.clinom," "),1,1).
    end.
    else vnome = clien.clinom.
    
    dt-validade = date(month(today), day(today),year(today) + 5).
    
    if tem-cartao = yes
    then assign
            vcartao = btbcartao.nrocartao
            vnome   = btbcartao.clinom
            dt-validade = btbcartao.validade
            .

    put string(v1,"99999")                      format "x(5)"
        ";"
        string(vcartao,"x(12)")                  format "x(12)"
        ";"
        string(clien.clicod)                     format "x(13)"
        ";"
        string(clien.clinom,"x(40)")             format "x(40)"
        ";"
        string(vnome,"x(26)")                    format "x(26)"
        ";"
        string(day(dt-validade),"99")  +
        string(month(dt-validade),"99") +
        string(year(dt-validade),"9999")         format "x(8)"
        ";"
        string("RUA","x(9)")                     format "x(9)"
        ";"
        string(clien.endereco[1],"x(60)")        format "x(60)"
        ";"
        (if clien.numero[1] <> ? then            /* antonio - sol.25935 */
        string(clien.numero[1],">>>>>>>>>9") else fill(" ",10))     
                                                 format "x(10)"
        ";"
        (if clien.compl[1] <> ?  then            /* antonio - sol.25935 */
        string(clien.compl[1],"x(35)") else fill(" ",35))          
                                                 format "x(35)"
        ";"
        (if clien.bairro[1] <> ? then           /* antonio - sol.25935 */
        string(clien.bairro[1],"x(30)") else fill(" ",30))         
                                                 format "x(30)"
        ";"
        (if clien.cep[1] <> ? then              /* antonio - sol.25935 */
        string(clien.cep[1],"x(8)") else fill(" ",8))             
                                                 format "x(8)"
        ";"
        (if clien.cidade[1] <> ? then           /* antonio - sol.25935 */
        string(clien.cidade[1],"x(30)") else fill(" ",30))          
                                                 format "x(30)"
        ";"
        (if clien.ufecod[1] <> ? then           /* antonio - sol.25935 */
        string(clien.ufecod[1],"x(2)") else "  ")          
                                                 format "x(2)"
        ";"
        string(vcartao,"x(29)")                  format "x(12)"
        ";"
        trim(string(day(dt-validade),"99")  +
             string(month(dt-validade),"99") +
             string(year(dt-validade),"9999"))   format "X(8)"
        ";" 
        skip.
    
    if tem-cartao = no
    then do:    
    create tt-tbcartao.
    assign
        tt-tbcartao.clicod = clien.clicod
        tt-tbcartao.dtinclu = today
        tt-tbcartao.hrinclu = time
        tt-tbcartao.nrocartao = vcartao
        tt-tbcartao.contacli = dec(vcartao)
        tt-tbcartao.validade = dt-validade
        tt-tbcartao.codoper = 999
        tt-tbcartao.situacao = "E"
        tt-tbcartao.trilha[1] = tt-tbcartao.nrocartao
        tt-tbcartao.trilha[2] = string(day(tt-tbcartao.validade),"99") +
                                string(month(tt-tbcartao.validade),"99") +
                                string(year(tt-tbcartao.validade),"9999") 
        tt-tbcartao.trilha[3] = string(tt-tbcartao.clicod,">>>>>>>>>9")
        tt-tbcartao.clinom  =  vnome
        .
    end.
end.
output close.
output stream smens close.

hide frame f-qra no-pause.
def var sresp as log init yes.
if search(varquivo) <> ?
then do:
    run mensagem.p(input-output sresp,
               input "!ARQUIVO GERADO  " +
                     "!" + STRING(VARQUIVO,"X(60)") +
                     "!!CONFIRMA GRAVAR OS REGISTROS DOS CARTÕES? ",
               input " Mensagem ",
               input "   SIM",
               input "   NAO").
  
    if sresp = yes
    then do:
        for each tt-tbcartao where tt-tbcartao.clicod > 0 no-lock:
            disp "GRAVANDO REGISTROS DOS CARTÕES... AGUARDE! "
                tt-tbcartao.clicod
                with frame f-cartao 1 down centered row 10
                no-box no-label color message.
            pause 0. 
            find first tbcartao where 
                       tbcartao.codoper = 999 and
                       tbcartao.contacli = tt-tbcartao.contacli
                       no-lock no-error.
            if not avail tbcartao
            then do:
                create tbcartao.
                buffer-copy tt-tbcartao to tbcartao.
            end.
        end.
        hide frame f-cartao no-pause.
    end.
            
end.
else do:
    sresp = yes.
    run mensagem.p(input-output sresp,
               input "!0 ARQUIVO NÃO FOI GERADO ! " +
                     "!FAVOR REPETIR O PROCEDIMENTO.",
               input " Mensagem ",
               input " REPETIR",
               input " REPETIR").
 
end.
