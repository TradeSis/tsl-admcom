/***********************************************************
Nome: leb-etiq-imprime.p
Descricao: imprime etiqueta no novo layout Lebes
Autor: Rafael A. (Kbase IT)
Forma uso: 
    run leb-etiq-imprime.p (input <recid-produ>,
                            input <qtd>,
                            input <tam>,
                            input <fila>).

Utilizado em: leb-etiq-call.p
              leb-etiq-new-free.p
              leb-etiq-deposito.p
Alteracoes: Rafael A. (Kbase IT) - 29/06/2015 - Criacao
***********************************************************/

def input parameter p-rec    as   recid no-undo.
def input parameter p-qtd    as   int   no-undo.
def input parameter p-tam    as   char  no-undo.
def input parameter fila     as   char  format "x(20)" no-undo.

def var varquivo       as char no-undo.
def var varquivo-sobra as char no-undo.
def var vlinha         as int  no-undo.
def var vvezes         as int  no-undo.
def var vqtdetiq       as int  no-undo.
def var vsobraetiq     as int  no-undo.
def var vpos           as int  no-undo.
def var vvalor         as char no-undo.

def temp-table tt-etiq
    field procod        like produ.procod
    field temp-cod      like produ.temp-cod
    field tempnom       like temporada.tempnom
    field estacao       as   char
    field pronom        like produ.pronom
    field prorefter     like produ.prorefter
    field corcod        like produ.corcod
    field cornom        like cor.cornom
    field colorido      as   char
    field preco         like estoq.estvenda
    field setor         as   char
    field localizacao   as   char
    field entrada       as   char
    index idx01 procod asc.
    
def temp-table tt-layout-etiq
    field conteudo as char
    field linha    as int
    .

create tt-etiq.

/* inicio busca dados */
find first produ where recid(produ) = p-rec no-lock no-error.

if avail produ then do:
    assign tt-etiq.procod   = produ.procod
           tt-etiq.temp-cod = produ.etccod
           /*tt-etiq.temp-cod = produ.temp-cod*/ .
    
    /* estacao/ano - temp-cod + tempnom */
    /*find first temporada 
         where temporada.temp-cod = tt-etiq.temp-cod no-lock no-error.
         
    if avail temporada then
        tt-etiq.tempnom = temporada.tempnom.
    else
        tt-etiq.tempnom = "Temporada Invalida".*/
        
    find first estac
         where estac.etccod = tt-etiq.temp-cod
               no-lock no-error.
    if avail estac then
        assign tt-etiq.tempnom = estac.etcnom.
    else
        assign tt-etiq.tempnom = "Estacao Invalida".
        
    tt-etiq.estacao = tt-etiq.tempnom.
    
    /* codigo - procod */
    
    /* descricao - pronom */
    tt-etiq.pronom = produ.pronom.
    
    /* referencia - prorefter */    
    tt-etiq.prorefter = if produ.prorefter <> "" then produ.prorefter
                        else "          ".
    
    /* cor - corcod + cornom */
    find first cor where cor.corcod = tt-etiq.corcod no-lock no-error.
    
    if avail cor then
        tt-etiq.cornom = cor.cornom.
    else
        tt-etiq.cornom = "Cor Invalida".
    
    tt-etiq.colorido = if tt-etiq.corcod <> "" then
                       string(tt-etiq.corcod, "99") + " " + tt-etiq.cornom
                       else "              ".
        
    /* preco */
    find first estoq 
         where estoq.etbcod = 999 
           and estoq.procod = produ.procod no-lock no-error.
           
    if avail estoq then
        tt-etiq.preco = estoq.estvenda.
    else
        tt-etiq.preco = 0.0.
    
    /**** 
    setor       - carcod = 002
    localizacao - carcod = 011
    entrada     - carcod = 071
    ****/
    
    assign tt-etiq.setor       = " "
           tt-etiq.localizacao = " "
           tt-etiq.entrada     = " ".
    
    for each procaract 
        where procaract.procod = tt-etiq.procod no-lock:
        find first subcaract
             where subcaract.subcod = procaract.subcod no-lock no-error.
             
        if avail subcaract then do:
            if subcaract.carcod = 2 then do:
                tt-etiq.setor = subcaract.subdes.
            end.
            else if subcaract.carcod = 11 then do:
                tt-etiq.localizacao = subcaract.subdes.
            end.
            else if subcaract.carcod = 71 then do:
                tt-etiq.entrada = subcaract.subdes.
            end.
            else
                next.
        end.
    end.        
end.
/* Busca de Dados concluida */

/* carrega GRF */
/*
if opsys = "UNIX" then do:
    os-command silent /admcom/progr/cupszebra.sh  value(fila).
    os-command silent "lpr " value(fila) "/admcom/zebra/LEBES_S.GRF".
end.
else do:
    output to "c:\temp\etique.bat" append.
    put "c:\windows\command\mode com1:9600,e,7,2,r" skip
        "copy L:\zebra\LEBES_S.grf com1" skip.
    output close.
end.
*/

/* carrega layout */
if opsys = "UNIX" then varquivo = "/admcom/progr/etiq-moda.d".
else varquivo = "l:\progr\etiq-moda.d".

input from value(varquivo) no-echo.
vlinha = 0.
repeat:
    create tt-layout-etiq.
    import tt-layout-etiq.conteudo.
    
    vlinha = vlinha + 1.
    tt-layout-etiq.linha = vlinha.
end.
input close.
varquivo = "".
/* fim carrega layout */

/* calcula qtd */
vvezes     = truncate(p-qtd / 2,0).
vvezes     = vvezes * 2.
vqtdetiq   = vvezes / 2.
vsobraetiq = p-qtd - vvezes.

if vqtdetiq > 0 then do:
    
    run p-insere-dados.
    
    if opsys = "UNIX" then do:
        varquivo = "".
        varquivo = if avail produ then
                   "/admcom/zebra-fila/cris" + string(produ.procod) +
                   string(time)
                   else "/admcom/zebra-fila/cris00" + string(time) .
                     
        output to value (varquivo).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.
        
        os-command silent /admcom/progr/cupszebra.sh  value(fila).
        os-command silent "lpr " value(fila) value(varquivo).
        
        run p-gera-arq-fornec(input varquivo,
                              input string(produ.procod)).        
    end.
    else do:
        output to value("c:\temp\cris" + string(produ.procod)).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.
                                                
        output to "c:\temp\etique.bat" append.
        put trim(" type c:\temp\cris"
                 + string(produ.procod) /*+ string(vtime)*/
                 + " > com1") format "x(40)" skip.
        output close.
        
        run p-gera-arq-fornec(
                input "c:\temp\cris" + string(produ.procod),
                input string(produ.procod)
                ).
    end.
end.

if vsobraetiq > 0 then do:
    run p-insere-dados.
    
    if opsys = "UNIX" then do:
        varquivo-sobra = "".
        varquivo-sobra = if avail produ then
                         "/admcom/zebra-fila/crissob" + string(produ.procod) +
                         string(time)
                         else  "/admcom/zebra-fila/crissob00" + string(time).

        output to value(varquivo-sobra).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.
                            
        os-command silent /admcom/progr/cupszebra.sh  value(fila).
        os-command silent "lpr " value(fila) value(varquivo-sobra).
        
        run p-gera-arq-fornec(input varquivo-sobra, 
                              input string(produ.procod)).
    end.
    else do:
        output to value("c:\temp\crissob" + string(produ.procod)).
        for each tt-layout-etiq no-lock break by tt-layout-etiq.linha:
            put unformatted tt-layout-etiq.conteudo skip.
        end.
        output close.

        output to "c:\temp\etique.bat" append.
        put trim(" type c:\temp\crissob" +
                 string(produ.procod) /* + string(vtime)*/
                 + " > com1") format "x(40)" skip.
        output close.
        
        run p-gera-arq-fornec(
                input "c:\temp\crissob" + string(produ.procod),
                input string(produ.procod)
                ).
    end.
end.

procedure p-insere-dados:
    
    for each tt-layout-etiq break by linha:
        /* controla coluna a escrever */
        case tt-layout-etiq.linha:
            when 3 then
                vpos = 4.
            
            when 9 then /* Estacao/Ano */
                vpos = 22.
                
            when 35 then /* Estacao/Ano */
                vpos = 23.
            
            when 10 or when 36 then /* Codigo */
                vpos = 24.
            
            when 12 then /* Descricao - 1.1 */
                vpos = 22.
            
            when 13 or when 14 then /* Descricao - 1.2 e 1.3 */
                vpos = 23.
                
            when 38 then /* Descricao - 2.1 */
                vpos = 23.
            
            when 39 or when 40 then /* Descricao - 2.2 e 2.3 */
                vpos = 24.
                
            when 15 then /* Referencia - 1 */
                vpos = 28.
                
            when 41 then /* Referencia - 2 */
                vpos = 29.
                
            when 16 then /* Colorido - 1 */
                vpos = 23.
                
            when 42 then /* Colorido - 2 */
                vpos = 24.
            
            when 19 or when 45 then /* Tamanho */
                vpos = 24.
                
            when 21 then /* Codigo de Barras - 1 */
                vpos = 34.
                
            when 47 then /* Codigo de Barras - 2 */
                vpos = 35.
                
            when 25 then /* Preco - 1 */
                vpos = 23.
                
            when 51 then /* Preco - 2 */
                vpos = 24.
                
            when 27 then /* Setor - 1 */
                vpos = 23.
                
            when 53 then /* Setor - 2 */
                vpos = 24.
                
            when 28 then /* Localizacao - 1 */
                vpos = 23.
                
            when 54 then /* Localizacao - 2 */
                vpos = 24.
                
            when 29 then /* Entrada - 1 */
                vpos = 23.
                
            when 55 then /* Entrada - 2 */
                vpos = 24.
                                        
            otherwise
                vpos = 1.
        end case.
        
        /* controla o que escrever */
        case tt-layout-etiq.linha:
            when 3 then
                vvalor = string(vqtdetiq, ">>>9").
            
            when 9 or when 35 then
                vvalor = string(tt-etiq.estacao, "x(14)").
            
            when 10 or when 36 then
                vvalor = string(tt-etiq.procod, ">>>>99").
            
            when 12 or when 38 then
                vvalor = string(substr(tt-etiq.pronom, 1, 20), "x(20)").
                
            when 13 or when 39 then
                vvalor = string(substr(tt-etiq.pronom, 21, 14), "x(14)").
                
            when 14 or when 40 then
                vvalor = string(substr(tt-etiq.pronom, 35, 14), "x(14)").
            
            when 15 or when 41 then
                vvalor = string(tt-etiq.prorefter, "x(9)").
                
            when 16 or when 42 then
                vvalor = string(tt-etiq.colorido, "x(14)").
                
            when 19 or when 45 then
                vvalor = string(caps(p-tam), "x(2)").
                
            when 21 or when 47 then
                vvalor = string(tt-etiq.procod, ">>>>99").
                
            when 25 or when 51 then
                vvalor = string(tt-etiq.preco, ">>9.99").
                
            when 27 or when 53 then
                vvalor = string(tt-etiq.setor, "x(24)").
                
            when 28 or when 54 then
                vvalor = string(tt-etiq.localizacao, "x(24)").
                
            when 29 or when 55 then
                vvalor = string(tt-etiq.entrada, "x(24)").
                
            otherwise
                vvalor = "-1".
        end case.
        
        if vvalor <> "-1" then
            substr(tt-layout-etiq.conteudo,vpos) = vvalor.
    end.
end procedure.

procedure p-gera-arq-fornec:
    /* Gera arquivos de impressao de etiquetas
       para serem enviados aos fornecedores    */
        
    def input parameter p-arquivo as char no-undo.
    def input parameter p-procod  as char no-undo.
    
    def var vetiq                 as char no-undo.
    
    vetiq = "c" + p-procod + "." + p-tam.
    
    if opsys = "UNIX" then
        unix silent value("cp " + p-arquivo    +
                          " /admcom/zebra/05/" + 
                          vetiq).        
    else
        dos silent value("copy " + p-arquivo   +
                         " l:~\zebra~\05~\"    +
                         vetiq).
            
    if opsys = "UNIX"
    then varquivo = "/admcom/zebra/05/eti-05.bat".
    else varquivo = "l:~\zebra~\05~\eti-05.bat" .
    
    output to value(varquivo) append.
        put trim(" type c:~\drebes~\" +
                 vetiq                +
                 " > prn") format "x(40)" skip.
    output close.
                          
end procedure.
