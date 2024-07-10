def var vjuro as dec. 
def var vpaga as dec.
def var vvend as dec.
def var vdt   as date.
def var vdti  as date format "99/99/9999" initial 12/01/2001. 
def var vdtf  as date format "99/99/9999" initial 12/10/2001.

def var vsobra as dec.
def temp-table tt-dif
    field data   as date
    field difjur as dec
    field difpag as dec
    field difven as dec
        index ind-1 data.
    
    
repeat:

    update vdti vdtf with frame f1 side-label.
    
/*
output to /admcom/work/dif.ctb. 
*/
do vdt = vdti to vdtf:

vjuro = 0.
vvend = 0.
vpaga = 0.
vsobra = 0.

find finctb.diario where diario.data = vdt no-lock no-error.
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


    find first tt-dif where tt-dif.data = diario.data no-error.
    if not avail tt-dif 
    then do: 
        create tt-dif.
        assign tt-dif.data = diario.data.
    end.
    if diario.venda <> vvend
    then difven = diario.venda -  vvend.
    if diario.pagamento <> vpaga
    then difpag = diario.pagamento - vpaga.
    if diario.juro <> vjuro
    then difjur = diario.juro - vjuro.
 
    if difjur = 0 and
       difpag = 0 and
       difven = 0
    then next.

       
    display diario.data
            diario.venda   column-label "Venda Ctb"
            when difven > 0    
            vvend          column-label "Venda Inf"
            when difven > 0
            tt-dif.difven  column-label "DIF"
            when difven > 0
/*         ((vvend / diario.venda) * 100) format ">>9.99%  " */

            diario.pagamento column-label "Pagto Ctb"
            when difpag > 0
            vpaga            column-label "Pagto Inf"
            when difpag > 0
            tt-dif.difpag    column-label "DIF"
            when difpag > 0
/*          ((vpaga / diario.pagamento) * 100) format ">>9.99%  "  */

            diario.juro      column-label "Juro Ctb"
            when difjur > 0
            vjuro            column-label "Juro Inf"
            when difjur > 0
            tt-dif.difjur    column-label "DIF"
            when difjur > 0
       
/*          ((vjuro / diario.juro) * 100) format ">>9.99%"   */

                with frame f2 down width 130.
        down with frame f2.

end.
end.
/*
output close.
*/ 