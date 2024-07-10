def var p-today as date.
def var vpropath as char.

p-today = date(SESSION:PARAMETER) no-error.
if p-today = ?
then p-today = if time <= 25000 /** 07:00 **/
               then today - 1
               else today.
message today "p-today" p-today.


input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.
propath = vpropath + ",\dlc".

message "NOVA VERSAO CYBER - Integracao " today p-today
        "INICIO:" string(time,"HH:MM:SS").



def var vprocessa_novacao as log format "Sim/   " label "NOV".
def var vprocessa_lp as log format "Sim/   " label "LP".
def var vprocessa_geral as log format "Sim/  " label "GER".
def var vprocessa_normal as log format "Sim/   " label "NOR".
def var vdias_novacao as int format "->>>" label "D_NOV".
def var vdias_lp  as int format "->>>" label "D_LP".
def var vdias as int format "->>>" label "Dias".

def var vtime as int.

def var xtime as int.

vtime = time.

pause 0 before-hide.

/**
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

    vdias  = int(tab_ini.valor).

    disp
        vprocessa_novacao
        vdias_novacao
        vprocessa_lp
        vdias_lp
        vprocessa_geral
        vprocessa_normal
        vdias.

    
    run cyb/novos.p (input p-today, 
                      input estab.etbcod,
                      input vprocessa_normal,
                      input vprocessa_novacao,
                      input vprocessa_lp,
                      input vdias,
                      input vdias_novacao,
                      input vdias_lp).

    run cyb/enviado.p (input p-today, input estab.etbcod,
                      input vprocessa_normal,
                      input vprocessa_novacao,
                      input vprocessa_lp,
                      input vdias,
                      input vdias_novacao,
                      input vdias_lp).


    /**
    if (vprocessa_normal or
        vprocessa_novacao or
        vprocessa_lp)
    then**/
    do:   
        run cyb/acompanhado.p (input p-today, input estab.etbcod,
                          input vprocessa_normal,
                          input vprocessa_novacao,
                          input vprocessa_lp,
                          input vdias,
                          input vdias_novacao,
                          input vdias_lp).
    end.

   
    
        xtime = time - vtime.
        disp "LOJA"
                estab.etbcod  string(xtime,"HH:MM:SS") @ xtime.

end.

run cyb/arrasto.p (input p-today).

**/

run cyb/termina_lote.p (input p-today).
xtime = time - vtime.    
message "FIM DE TUDO" string(xtime,"HH:MM:SS") string(time,"HH:MM:SS").
  
