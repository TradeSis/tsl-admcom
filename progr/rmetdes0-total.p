{admcab.i new}
           
def new shared temp-table wgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    field apagar as dec
    index i1 wset wmod wano wmes.


def var vdt  as date.
def var vdti as date.
def var vdtf as date.
def var vct  as int.
def var vtotal-apagar as dec format "->>>>,>>>,>>9.99".

assign
    vdti = date(month(today),01,year(today))
    vdtf = today.
def var vsetcod like setaut.setcod.

update vsetcod label "Setor" with frame f-sel.

if vsetcod <> 0
then do:
    find setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-sel.
end.
else disp "Relatorio geral" @ setaut.setnom with frame f-sel.

update vdti at 1 label "Periodo de"  format "99/99/9999"
       vdtf label "Ate"  format "99/99/9999"
       with frame f-sel 1 down side-label width 80.

def var varqsai as char.
update varqsai at 1 label "Arquivo Saida" format "x(60)"
        with frame f-sel.
        
    if connected ("banfin")
    then disconnect banfin.
                       
    if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
    then connect banfin -H dbr -S sbanfin_r -N tcp -ld banfin.
    else connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    run rmetdes111-total.p (vsetcod, vdti, vdtf, varqsai).
    
    disconnect banfin.
         
