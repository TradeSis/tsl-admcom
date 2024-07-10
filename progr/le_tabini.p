def input parameter p-etbcod as int.
def input parameter p-cxacod as int.
def input parameter p-parametro as char.
def output parameter p-valor as char.

find first tab_ini where tab_ini.etbcod = p-etbcod  and
                  tab_ini.cxacod = p-cxacod and
                  tab_ini.parametro = p-parametro
                  no-lock no-error.
if not avail tab_ini
then find first tab_ini where tab_ini.etbcod = 0 and
                  tab_ini.cxacod = p-cxacod and
                  tab_ini.parametro = p-parametro
                  no-lock no-error.

if avail tab_ini
then p-valor = tab_ini.valor.
else p-valor = "".