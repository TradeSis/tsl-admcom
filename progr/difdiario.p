def var vjuro as dec. 
def var vpaga as dec.
def var vvend as dec.
def var vdt   as date.
def var vdti  as date format "99/99/9999" initial 12/01/2001. 
def var vdtf  as date format "99/99/9999" initial 12/10/2001.

def var vsobra as dec.

repeat:

    update vdti vdtf with frame f1 side-label.
    

output to /admcom/work/dif.ctb.

do vdt = vdti to vdtf:

vjuro = 0.
vvend = 0.
vpaga = 0.
vsobra = 0.

find diario where diario.data = vdt no-lock no-error.
if not avail diario
then next.
 
for each lanca where lanca.landat = vdt no-lock:


    if lanca.lannat = "V"
    then vvend = vvend + lanca.lanval.


    if lanca.lannat = "P"
    then vpaga = vpaga + lanca.lanval.


    if lanca.lannat = "J"
    then vjuro = vjuro + lanca.lanval.

    vsobra = vsobra + lanca.lanobs.


end.
def var vtot like titulo.titvlcob.
vtot = 0.
/* 
for each titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = "cre" and
                       titulo.titdtpag = vdt:
                         
    vtot = vtot + (titulo.titvlcob).
                         
end.                         
*/



display diario.data
        diario.venda   column-label "Venda Ctb" 
                       when diario.venda <> vvend
                       
        vvend          column-label "Venda Inf"
                       when diario.venda <> vvend
                       
        ((vvend / diario.venda) * 100) format ">>9.99%  "
                       when diario.venda <> vvend
 
        diario.pagamento column-label "Pagto Ctb"
                       when diario.pagamento <> vpaga
                        
        vpaga            column-label "Pagto Inf"
                       when diario.pagamento <> vpaga
 
        ((vpaga / diario.pagamento) * 100) format ">>9.99%  "
                       when diario.pagamento <> vpaga
 
        diario.juro      column-label "Juro Ctb"
                       when diario.juro <> vjuro 
        vjuro            column-label "Juro Inf"
                       when diario.juro <> vjuro 

        ((vjuro / diario.juro) * 100) format ">>9.99%"
                       when diario.juro <> vjuro 

                with frame f2 down width 180.
        down with frame f2.

end.
end.
output close.