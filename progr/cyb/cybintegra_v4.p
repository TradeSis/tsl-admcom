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
if cybversao <> 4 /* #4 */
then do:
    message "Programa cyb/cybintegra_v4.p cybversao=" cybversao.
    return.
end.    



def var vprocessa_novacao as log format "Sim/   " label "NOV".
def var vprocessa_lp as log format "Sim/   " label "LP".
def var vprocessa_geral as log format "Sim/  " label "GER".
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


for each estab no-lock.

    disp p-today estab.etbcod.
    
    vprocessa_novacao = no.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_novacao = yes.
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_novacao = yes.
        else vprocessa_novacao = no.


    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_NOVACAO"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_novacao = no.

    vdias_novacao = int(tab_ini.valor).
    
    vprocessa_lp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_lp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_lp = yes.
        else vprocessa_lp = no.


    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_LP"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_lp = no.

    vdias_lp = int(tab_ini.valor).

    /** #2       PROCESSA CP **/
    vprocessa_cp = no.
    vdias_cp = 0.
    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_cp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_cp = yes.
        else vprocessa_cp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
    /** #2 FIM - PROCESSA CP */

    /** #1 **/
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_BOLETO"
                       no-lock no-error.
    if not avail tab_ini
    then vdias_boleto = 0.
    else do:
        vdias_boleto = int(tab_ini.valor).
    end.


    vprocessa_geral = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_geral = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_geral = yes.
        else vprocessa_geral = no.


    vprocessa_normal = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_normal = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_normal = yes.
        else vprocessa_normal = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_normal = no.

    vdias  = int(tab_ini.valor) no-error.
    if vdias = ?
    then vdias = 0.


    /** #6       PROCESSA EF Elegiveis Feirao **/
    vprocessa_ef = no.
    vef_modcod = "".
    vef_dias   = 0.
    vef_dataemi = today    .
    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_EF"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_ef = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_EF"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_ef = yes.
        else vprocessa_ef = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_EF"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vef_dias = int(tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_NDIAS_EF"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vef_dias = int(tab_ini.valor).
    end.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_DATAEMI_EF"
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
                             tab_ini.parametro = "CYBER_DATAEMI_EF"
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
                             tab_ini.parametro = "CYBER_MODCOD_EF"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vef_modcod = (tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_MODCOD_EF"
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
        vprocessa_geral
        vprocessa_normal
        vdias
        vprocessa_cp
        vdias_cp 
        vprocessa_ef 
        vef_modcod 
        vef_dias 
        vef_dataemi .

    message "cyb/novos_v4.p".    
    run cyb/novos_v4.p (input p-today, 
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
    message "cyb/enviado_v4.p".    

    run cyb/enviado_v4.p (input p-today, 
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


    message "cyb/acompanhado_v4.p".    
   
        run cyb/acompanhado_v4.p (input p-today, 
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

run cyb/arrasto.p (input p-today).

/* #5 - Atualiza Percentuais de Pagamento */
run cyb/cybverclien_v4.p (input p-today).

run cyb/gera_lote_v4.p (input p-today).
xtime = time - vtime.    
message "FIM DE TUDO" string(xtime,"HH:MM:SS") string(time,"HH:MM:SS").
  
