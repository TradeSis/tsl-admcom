/** #1 - Projeto Boletos - Parametro dias para titulo associado a boleto **/
/** #2 **/ /** Proj Parametros CP - Cyber 19.129.2017
               Parametro para Contrato CP
                          **/
/** #3 **/ /** 27.02.2018 Versionamento **/
/** #4 **/ /** 20.03.2018 Ajuste para CP */
/*  #5  */ /* Atualiza Percentuais de Pagamento */
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inlcui Elegiveis Feirao */

def new global shared var cybversao as int. /*#3*/
def input parameter p-today as date.

/* v3 */
if cybversao <> 188 /* #4 */
then do:
    message "Programa csl/integra_v188.p cybversao=" cybversao.
    return.
end.    



def var vprocessa_novacao as log format "Sim/   " label "NOV".
def var vprocessa_lp as log format "Sim/   " label "LP".
def var vprocessa_cslog as log format "Sim/  " label "CSL".
def var vprocessa_normal as log format "Sim/   " label "NOR".
def var vdias_novacao as int format "->>>" label "D_NOV".
def var vdias_lp  as int format "->>>" label "D_LP".
def var vdias_boleto  as int format "->>>" label "D_BOL".

def var vprocessa_cp   as log format "Sim/ " Label "CP".
def var vdias_cp       as int format "->>>" label "D_CP".

def var vdias as int format "->>>" label "Dias".
def var vprocessa_ef as log.
def var vef_modcod as char.
def var vef_dataemi as date.
def var vef_dias as int.

def var vtime as int.

def var xtime as int.

vtime = time.

pause 0 before-hide.


for each estab no-lock with width 200.

    disp p-today estab.etbcod .

    vprocessa_cslog = no.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_PROCESSA"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_cslog = yes.
        else vprocessa_cslog = no.
    
    disp vprocessa_cslog.
        
    if vprocessa_cslog = no
    then next.
    
    vprocessa_novacao = no.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_novacao = yes.
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_novacao = yes.
        else vprocessa_novacao = no.


    vdias_novacao = 0.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS_NOVACAO"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_novacao = no.
    else vdias_novacao = int(tab_ini.valor).
    
    vprocessa_lp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_lp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_lp = yes.
        else vprocessa_lp = no.

    vdias_lp = 0.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS_LP"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_lp = no.
    else vdias_lp = int(tab_ini.valor).

    /** #2       PROCESSA CP **/
    vprocessa_cp = no.
    vdias_cp = 0.
    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_cp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_cp = yes.
        else vprocessa_cp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
    /** #2 FIM - PROCESSA CP */

    /** #1 **/
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS_BOLETO"
                       no-lock no-error.
    if not avail tab_ini
    then vdias_boleto = 0.
    else do:
        vdias_boleto = int(tab_ini.valor).
    end.




    vprocessa_normal = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_normal = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_normal = yes.
        else vprocessa_normal = no.

    vdias = 0.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_normal = no.
    else vdias  = int(tab_ini.valor) no-error.
    if vdias = ?
    then vdias = 0.


    /** #6       PROCESSA EF Elegiveis Feirao **/
    vprocessa_ef = no.
    vef_modcod = "".
    vef_dias   = 0.
    vef_dataemi = today    .
    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_REGRA_EF"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_ef = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_REGRA_EF"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_ef = yes.
        else vprocessa_ef = no.

    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_NDIAS_EF"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vef_dias = int(tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_NDIAS_EF"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vef_dias = int(tab_ini.valor).
    end.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_DATAEMI_EF"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        if num-entries(tab_ini.valor,"/") = 3
        then do:
            vef_dataemi = date(int(entry(2,tab_ini.valor,"/")),
                               int(entry(1,tab_ini.valor,"/")),
                               int(entry(3,tab_ini.valor,"/")))
                               no-error.
            if vef_dataemi = ?
            then vef_dataemi = today.
        end.    
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_DATAEMI_EF"
                       no-lock no-error.
    if avail tab_ini
    then do:
        if num-entries(tab_ini.valor,"/") = 3
        then do:
            vef_dataemi = date(int(entry(2,tab_ini.valor,"/")),
                               int(entry(1,tab_ini.valor,"/")),
                               int(entry(3,tab_ini.valor,"/")))
                               no-error.
            if vef_dataemi = ?
            then vef_dataemi = today.
        end.        
    end.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CSLOG_MODCOD_EF"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vef_modcod = (tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CSLOG_MODCOD_EF"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vef_modcod = (tab_ini.valor).
    end.
    

    /** #6 FIM - PROCESSA EF */



    disp
        vprocessa_novacao
        vdias_novacao
        vprocessa_lp
        vdias_lp
        vdias_boleto
        vprocessa_cslog
        vprocessa_normal
        vdias
        vprocessa_cp
        vdias_cp 
        vprocessa_ef 
        vef_modcod 
        vef_dias 
        vef_dataemi .

    message "csl/novos_v4.p".    
    run csl/novos_v4.p (input p-today, 
                      input estab.etbcod,
                      input vprocessa_normal,
                      input vprocessa_novacao,
                      input vprocessa_lp,
                      input vprocessa_cp,
                      input vdias,
                      input vdias_novacao,
                      input vdias_lp,
                      input vdias_boleto,
                      input vdias_cp,
                      input vprocessa_ef,
                      input vef_modcod,
                      input vef_dataemi,
                      input vef_dias).
    message "csl/enviado_v4.p".    

    run csl/enviado_v4.p (input p-today, 
                      input estab.etbcod,
                      input vprocessa_normal,
                      input vprocessa_novacao,
                      input vprocessa_lp,
                      input vprocessa_cp,
                      input vdias,
                      input vdias_novacao,
                      input vdias_lp,
                      input vdias_boleto,
                      input vdias_cp,
                      input vprocessa_ef,
                      input vef_modcod,
                      input vef_dataemi,
                      input vef_dias).


    message "csl/acompanhado_v4.p".    
   
        run csl/acompanhado_v4.p (input p-today, 
                          input estab.etbcod,
                          input vprocessa_normal,
                          input vprocessa_novacao,
                          input vprocessa_lp,
                          input vprocessa_cp,
                          input vdias,
                          input vdias_novacao,
                          input vdias_lp,
                          input vdias_boleto,
                          input vdias_cp,
                      input vprocessa_ef,
                      input vef_modcod,
                      input vef_dataemi,
                      input vef_dias).


   
    
        xtime = time - vtime.
        disp "LOJA"
                estab.etbcod  string(xtime,"HH:MM:SS") @ xtime.

end.

run csl/arrasto.p (input p-today).

/* #5 - Atualiza Percentuais de Pagamento */
run csl/cybverclien_v4.p (input p-today).

run csl/gera_lote_v4.p (input p-today).
xtime = time - vtime.    
message "FIM DE TUDO" string(xtime,"HH:MM:SS") string(time,"HH:MM:SS").
  
