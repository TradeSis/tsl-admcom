/***********************************************************************
* Programa.....: infrepd1.p
* Funcao.......: Informativo de reposicao de produtos semana anterior
* Data.........: 25/04/2007
* Autor........: Gerson L S Mathias
********************************************************************* */
pause 0 no-message.

def temp-table tt-proemail
    field procod like produ.procod.

def buffer bf-cadmetasfunc for cadmetasfunc.

def var i_diasem   as inte                    init 0.
def var t_dtasem   as date form "99/99/9999".
def var c_dia      as char form "99"          init "".
def var c_mes      as char form "99"          init "".
def var i_hoje     as inte form "9999"        init 0.

assign i_diasem = 2                                 /* Segunda feira */
       t_dtasem = today.                            /* Hoje */

assign c_dia  = string(day(t_dtasem),"99")
       c_mes  = string(month(t_dtasem),"99")
       i_hoje = inte(c_dia + c_mes).

for each tt-proemail:
      delete tt-proemail.
end.    

for each cadmetasfunc where
         cadmetasfunc.codmeta <> 0    and
         cadmetasfunc.etbcod  =  999  exclusive-lock:

     create tt-proemail.
     assign tt-proemail.procod = cadmetasfunc.codmeta.
        
     assign cadmetasfunc.etbcod  = 999.
     
end.

run infrepd3.p (input table tt-proemail).

find first cadmetasfunc where
           cadmetasfunc.codmeta = 0 and
           cadmetasfunc.etbcod  = 0 exclusive-lock no-error.
if avail cadmetasfunc
then do:
        assign cadmetasfunc.funcod = i_hoje.
end.                     
