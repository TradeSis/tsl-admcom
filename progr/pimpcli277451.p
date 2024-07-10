/* #04112022 helio - ID 151546 - Cadastros em lote pelo ADMCOM - formatar cpf*/ 
/* #08082022 helio - https://trello.com/c/qkHafMnr/29-carine-cadastro-clientes-atualiza%C3%A7%C3%A3o (carine.schmidt) Cadastro clientes - Atualização */

/*
hELIO 16/11/2021
Melhoria 277451 - Menu de importação para Leads de Captação de cliente
        CRIA CADASTRO DE CLIENTES A PARTIR DE PLANILHA
LayOut:
TIPO PESSOA;NOME COMPLETO;CPF;NOME DA MÃE;GENERO;CATEGORIA;DATA DE NASCIMENTO;CELULAR;EMAIL;CIDADE;OPTIN SMS;OPTIN WHATSAPP;OPTIN EMAIL;LOJA ORIGEM
*/

{admcab.i}
 

def var pcpf        like neuclien.cpf.
def var pclicod     like clien.clicod.
def var pok         as log.
def var vdestino as char.
def var varqdest   as char.

{/admcom/progr/api/acentos.i}
function trata-numero returns character
    (input par-num as char).
    
        def var par-ret as char. 
        def var j as int. 
        def var t as int. 
        def var vletra as char.  
        t = length(par-num). 
        do j = 1 to t: 
            vletra = substr(par-num,j,1). 
            if vletra = "0" or 
                vletra = "1" or 
                vletra = "2" or 
                vletra = "3" or 
                vletra = "4" or 
                vletra = "5" or 
                vletra = "6" or 
                vletra = "7" or 
                vletra = "8" or 
                vletra = "9" 
            then assign par-ret = par-ret + vletra. 
        end. 
        return par-ret.  

end function.
        
def temp-table ttcadas no-undo
    field tipopessoa    as char
    field nome          as char
    field cpf           as char format "x(14)"
    field nomemae       as char
    field genero        as char
    field categoria     as char
    field datanasc      as char
    field celular       as char
    field email         as char
    field cidade        as char
    field optinsms      as char
    field optinwhats    as char
    field optinemail    as char
    field lojacad       as char
    field situacao      as char format "x(20)"
    field clicod        like clien.clicod.

def temp-table ttclien no-undo
    field tippes        like neuclien.tippes /* F/J */
    field clinom        like clien.clinom
    field cpf           like neuclien.cpf
    field nome_mae      like neuclien.nome_mae
    field sexo          like clien.sexo  /* M/F */
    field catprof       like neuclien.catprof
    field dtnasc        like clien.dtnasc
    field celular       like clien.fax
    field email         like clien.zona format "x(40)"
    field cidade        like clien.cidade[1]
    field optinsms      as log 
    field optinwhats    as log
    field optinemail    as log
    field lojacad       like neuclien.etbcod.
    
    

def var varquivo as char format "x(50)" label "Arquivo CSV (;)" .

run   /admcom/progr/get_file.p ("/admcom/tmp/clientes/", "csv", output varquivo) .

disp varquivo
    with row 3
        centered.
if search(varquivo) = ?
then do:
    message "arquivo nao encontrado"
        view-as alert-box.
    return.
end.            
hide message no-pause.
message "aguarde....".
def var vconta as int. 
input from value(varquivo) no-echo.
repeat.
    vconta = vconta + 1.
    create ttcadas.
    import delimiter ";" ttcadas.
    
    if vconta = 1
    then do:
        if trim(ttcadas.tipopessoa) <>   "TIPO PESSOA" and
           trim(ttcadas.nome)       <>   "NOME COMPLETO" and
           trim(ttcadas.cpf)        <>   "CPF"
        then do:
            leave.
        end.        
    end.    
    ttcadas.cpf = trata-numero(ttcadas.cpf). 
    if ttcadas.cpf = "" then do:
        delete ttcadas.
        next.
    end.
    pcpf =  dec(ttcadas.cpf).
    run cpf.p (string(pcpf,"99999999999"), output pok).
    if not pok
    then do:
        ttcadas.situacao = "CPF INVALIDO".
    end.
    if ttcadas.nome = ""
    then do:
        ttcadas.situacao = "CLIENTE SEM NOME". 
    end.
    if ttcadas.genero = "MASCULINO" or ttcadas.genero = "FEMININO"
    then.
    else ttcadas.situacao = "GENERO INVALIDO".
    def var vdata as date.
    vdata    = date(ttcadas.datanasc) no-error.
    if vdata = ?
    then ttcadas.situacao = "DATA NASCIMENTO INVALIDA".
    find estab where estab.etbcod = int(ttcadas.lojacad) no-lock no-error.
    if not avail estab
    then do:
        ttcadas.situacao = "LOJA INVALIDA".
    end.

    if lookup(trim(ttcadas.categoria),"AG - Agricultor,AP - Aposentado,AS - Assalariado,AU - Autonomo,L - Profissional Liberal") > 0
    then.
    else ttcadas.situacao = "CATEGORIA INVALIDA".
    
    if ttcadas.situacao = ""
    then do:
    
        release clien.
        find neuclien where neuclien.cpf = pcpf no-lock no-error.
        if avail neuclien
        then do:
            find clien where clien.clicod = neuclien.clicod no-lock no-error.
        end.    
        pclicod  = if avail clien
                  then clien.clicod
                  else if avail neuclien
                       then neuclien.clicod
                       else ?.
        create ttclien.
        ttcadas.situacao    = if avail clien 
                              then "JA CADASTRADO"
                              else if avail neuclien
                                   then if neuclien.clicod <> ?
                                        then "CODIGO INVALIDO NO NEUCLIEN"
                                        else ""
                                   else "".
        ttcadas.clicod      = pclicod.
 
        ttclien.tippes      = if ttcadas.tipopessoa = "JURIDICA" 
                              then no  
                              else yes.
        ttclien.clinom        = caps(RemoveAcento(ttcadas.nome)).
        ttclien.cpf         = dec(ttcadas.cpf)  .
        ttclien.nome_mae     = RemoveAcento(ttcadas.nomemae).
        ttclien.sexo        = if ttcadas.genero = "MASCULINO" then true else false.
        ttclien.catprof   = removeAcento(ttcadas.categoria).
        ttclien.dtnasc      = date(ttcadas.datanasc).
        ttclien.celular     = ttcadas.celular.
        ttclien.email       = ttcadas.email.
        ttclien.cidade      = caps(removeAcento(ttcadas.cidade)).
        ttclien.optinsms    = if ttcadas.optinsms   = "SIM" then true else false.
        ttclien.optinwhats  = if ttcadas.optinwhats = "SIM" then true else false.
        ttclien.optinemail  = if ttcadas.optinemail = "SIM" then true else false.
        ttclien.lojacad     = int(ttcadas.lojacad).
    
        /* #08082022 */
        if avail clien
        then do:
            if ttcadas.celular <> clien.fax or 
               ttcadas.email   <> clien.zona
            then do:
                ttcadas.situacao = "ATUALIZAR".
            end.    
        end.

    end.
    if ttcadas.situacao = ""
    then run pneuclien.    
    else do:
        /* #08082022 */
        if ttcadas.situacao = "ATUALIZAR"
        then do:
            run patualizar.
        end.
    end.
    
end.
input close.
if vconta <= 1
then do.
    hide message no-pause.
    message "Arquivo com LayOut ERRADO!"
        view-as alert-box.
    return.    
        
end.
def var vi as int.
vi = 0.
vdestino = "".
do while true:
    vi = vi + 1.
    if vi = num-entries(varquivo,"/")
    then do:
        varqdest = entry(vi,varquivo,"/").
        leave.
    end.    
    vdestino = vdestino + entry(vi,varquivo,"/") + "/".
end.    

varqdest = vdestino + entry(1,varqdest,".") + "_RESULTADO_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + "." + entry(2,varqdest,"."). 
output to value(varqdest).
put unformatted
"TIPO PESSOA;NOME COMPLETO;CPF;NOME DA MÃE;GENERO;CATEGORIA;DATA DE NASCIMENTO;CELULAR;EMAIL;CIDADE;OPTIN SMS;OPTIN WHATSAPP;OPTIN EMAIL;LOJA ORIGEM" +
    ";CODIGO CLIENTE;STATUS;"
    skip.


for each ttcadas.  
    put unformatted
     ttcadas.tipopessoa    ";"
     ttcadas.nome          ";"
     ttcadas.cpf           ";" 
     ttcadas.nomemae       ";"
     ttcadas.genero        ";"
     ttcadas.categoria     ";"
     ttcadas.datanasc      ";"
     ttcadas.celular       ";"
     ttcadas.email         ";"
     ttcadas.cidade        ";"
     ttcadas.optinsms      ";"
     ttcadas.optinwhats    ";"
     ttcadas.optinemail    ";"
     ttcadas.lojacad       ";"
     ttcadas.clicod        ";"
     ttcadas.situacao      ";" 
        skip     .
end.    
output close.
hide message no-pause.
message "importacao encerrou. arquivo gerado" varqdest.
pause 30.
return.


procedure pneuclien.
def var pstatus as char.

    if ttcadas.clicod = ? /*and ttcadas.situacao = ""   */
    then do:
        
        if not avail neuclien
        then do on error undo: 
            create neuclien.  
            neuclien.cpfcnpj        = pcpf. 
            neuclien.tippes         = ttclien.tippes.
            neuclien.sit_credito    = "".  
            neuclien.etbcod         = ttclien.lojacad.
            neuclien.dtcad          = today.  
            neuclien.nome_pessoa    = ttclien.clinom.
            neuclien.dtnasc         = ttclien.dtnasc.  
            neuclien.nome_mae       = ttclien.nome_mae.
            neuclien.catprof        = ttclien.catprof.
        end.

        run neuro/gravaclien.p
                    (recid(neuclien),
                     "PLANILHA",
                     ttclien.lojacad,
                     pcpf,
                     output pclicod,
                     output pstatus).
                     
        if pclicod = ?
        then do on error undo: 
            ttcadas.situacao = "ERRO NO CADASTRAMENTO".
        end.
        else do on error undo:              
            find clien where clien.clicod = pclicod.
            ttcadas.clicod  = pclicod.
            ttcadas.situacao = "NOVO CADASTRO".
            
            clien.tippes    = neuclien.tippes.
            clien.clinom    = neuclien.nome_pessoa.

            if neuclien.tippes = yes        /* #04112022 */
            then clien.ciccgc    = string(neuclien.cpf,"99999999999").
            else clien.ciccgc    = string(neuclien.cpf,"99999999999999").
            
            clien.mae       = neuclien.nome_mae.            
            clien.sexo      = ttclien.sexo.
            clien.dtnasc    = neuclien.dtnasc.
            clien.fax       = ttclien.celular.
            clien.zona      = ttclien.email.
            clien.cidade[1] = ttclien.cidade.
            clien.etbcad    = ttclien.lojacad.

        end.
        
    end.    
    do on error undo:
        find clien where clien.clicod = ttcadas.clicod no-lock no-error.
        if avail clien
        then do:
            find cpclien of clien exclusive no-wait no-error.
            if avail cpclien
            then do:
                cpclien.emailpromocional = ttclien.optinemail.
            end.
        end.
    end.    
    
end procedure.



procedure patualizar. /* #08082022 */

do on error undo:

    find clien where clien.clicod = pclicod . 
    ttcadas.clicod  = pclicod.  
    ttcadas.situacao = "ATUALIZADO".
        
    clien.fax       = ttclien.celular. 
    clien.zona      = ttclien.email.
    
            find cpclien of clien exclusive no-wait no-error.
            if avail cpclien
            then do:
                cpclien.emailpromocional = ttclien.optinemail.
            end.
    
end.


end procedure.