/**************************************************************************
* PROGRAMA...: VARIAVEL.I
* FINALIDADE.: Include de definicoes de Variaveis Genericas
* PROGRAMADOR: Marcio Brener
* OBSERVACAO : NAO ALTERE NENHUM PARAMETRO, DEVIDO AO USO
*              GENERICO DESTA INCLUDE
* ATUALIZACAO: 10/10/1998
**************************************************************************/
/* Variaveis para os programas DataSul */
define new shared variable banco-teste  as logical no-undo.
define new shared variable c-opcao      as character.
define new shared variable l-saida      as logical format "Impressora/Arquivo"
        label "Saida" init yes.
define new shared variable c-saida      as character format "x(25)".
define new shared variable c-nome-imp   as character format "x(12)" init "default".
define new shared variable l-cd9005x    as logical.
define new shared variable l-xxxtmp     as logical.
define new shared variable c-yyytmp     as character.

/* Variaveis de Impressao */
define new shared variable v-saidas     as   character extent 3 
               init ["Tela", "Impressora", "Arquivo"] format "x(11)".
define new shared variable v-saida      as   character init "Impressora".
define new shared variable v-arquivo    as   character format "x(35)" label "Arquivo".

define new shared variable c-cod-impres as   character format "x(12)" init "default".
define new shared variable c-comprime   as   character.
define new shared variable c-normal     as   character.

/* Definicoes de Streams Genericas */
define new shared stream tela. output stream tela to terminal.
define new shared stream s-arquivo.
define new shared stream s-impressora.


/* Variavel de Confirmacao */
define variable l-confirma as logical format "Sim/Nao" init no.

/* Variavies Genericas */
define variable i          as integer.
define variable j          as integer.
define variable i-recid    as integer.
define variable h-funcoes  as handle.
define variable c-retorno  as character.
define variable l-retorno  as logical.
define variable i-retorno  as integer.
define variable d-retorno  as decimal.
define variable dt-retorno as date.

define variable c-temp  as character.
define variable i-temp  as integer.
define variable d-temp  as decimal.
define variable l-temp  as logical format "Sim/Nao".
define variable r-temp  as recid.
define variable dt-temp as date.

/* Funcoes */
function digito1 returns character (input numero as integer) in h-funcoes.
function login-windows returns character in h-funcoes.
function mes returns character (input i-mes as integer) in h-funcoes.
function retira-acento returns character(input texto as character) in h-funcoes.
function horas returns character
   (input p-datini as date,
    input p-horini as character,
    input p-datfim as date,
    input p-horfim as character) in h-funcoes.
function subtexto returns character
   (input texto  as character,
    input inicio as integer,
    input fim    as integer) in h-funcoes.

/* Variaveis das Funcoes de Graficos */
define new shared variable graf-valor  as decimal   format ">>9"   extent 12.
define new shared variable graf-cores  as integer   format ">>9"   extent 12.
define new shared variable graf-texto  as character format "x(15)" extent 12.
define new shared variable graf-titulo as character.

assign banco-teste = if session:param = "TESTE" then yes else no.

/* Biblioteca de funcoes */
run csp/acento.p persistent set h-funcoes no-error.


/* fim do programa*/
