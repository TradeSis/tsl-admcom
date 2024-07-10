/* helio 20122021 melhorias cr fase 2 */

def var vdtini as date format "99/99/9999".
def var vgeral as log  format "Todos/Novos".

vgeral = yes. /* helio - 08022024 - sempre subir tudo */
def var vtoday as date.
vtoday = today.
vdtini = date(month(vtoday),01,year(vtoday)) - 1. /* 04032021 helio */
vdtini = date(month(vdtini),01,year(vdtini)).

run /admcom/barramento/async/gerapagtorecebido.p   (vdtini,vgeral).

/* descontinuado run /admcom/barramento/async/geractbtrocacart.p  (vdtini,vgeral).*/

message "geracao Encerrada".
