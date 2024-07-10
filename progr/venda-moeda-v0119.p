{admcab.i}

def var vetbcod like estab.etbcod.
def var vdata as date format "99/99/9999".

update vetbcod vdata.

def temp-table tt-moeda
    field moecod as char
    field valor as dec.

def temp-table acum-moeda
    field moecod as char
    field valor as dec.
    
form with frame fdisp down.
form with frame fdisp1 down.


def var varquivo as char.
varquivo = "/admcom/relat/venda-moeda." + string(time).

def var vmoenom as char.

output to value(varquivo).

put "Filial: " vetbcod    
    "    Data: " vdata
    skip.
    
put skip.

put "Fil  Data      Numero    Serie       Total       Moeda        Valor "
skip.
for each plani where movtdc = 5 and
                     pladat = vdata and
                     etbcod = vetbcod /*and
                     /*crecod = 2 and */
                     length(serie) < 5*/ no-lock.

    put  plani.etbcod space(1)
         plani.pladat space(1)
         plani.numer  space(1)
         plani.serie format "x(10)"  space(1)
         plani.platot space(1)
         .     

    for each tt-moeda. delete tt-moeda. end.
    
    run paga-venda-vista(input recid(plani)).
    for each tt-moeda .
        find moeda where moeda.moecod = tt-moeda.moecod no-lock no-error.
        if avail moeda
        then vmoenom = moeda.moenom.
        else vmoenom = "".
        put tt-moeda.moecod to 60 space(1) 
            vmoenom space(1)
             tt-moeda.valor 
             skip.
        find first acum-moeda where
                   acum-moeda.moecod = tt-moeda.moecod
                   no-error.
        if not avail acum-moeda
        then do:
            create acum-moeda.
            acum-moeda.moecod = tt-moeda.moecod.
        end.           
        acum-moeda.valor = acum-moeda.valor + tt-moeda.valor.           
    end. 
end.

for each acum-moeda:
    find moeda where moeda.moecod = acum-moeda.moecod no-lock no-error.
    disp acum-moeda.moecod
         moeda.moenom when avail moeda
         acum-moeda.valor(total)
         .
end.

output close.

run visurel.p(varquivo, "").

procedure paga-venda-vista:
    def input parameter rec-plani as recid.
    def var vtroco as dec.
    def buffer bplani for plani.
    def var vv as dec.
    find bplani where recid(bplani) = rec-plani no-lock.
    
    for each pdvdoc where pdvdoc.etbcod = bplani.etbcod and
                      pdvdoc.placod = bplani.placod and
                      pdvdoc.datamov = bplani.pladat
                      no-lock:
        find pdvmov of pdvdoc no-lock.
        for each pdvmoeda of pdvmov no-lock.
            vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco)).
    
            vv = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot).
 
            if vv = ? then vv = 0.
            
            find first tt-moeda where
                       tt-moeda.moecod = pdvmoe.moecod
                       no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = pdvmoe.moecod.
            end.
            if pdvmoe.moecod = "REA"
            then tt-moeda.valor = tt-moeda.valor + 
                        (pdvmoe.valor - pdvmov.valortroco).
            else tt-moeda.valor = tt-moeda.valor + pdvmoe.valor.
                       
         end.
    end.
end procedure.  
