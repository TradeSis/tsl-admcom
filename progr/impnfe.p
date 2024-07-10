def var vetbcod like estab.etbcod.
def var vnumero like plani.numero.

update vetbcod label "Filial"
with frame f1 1 down side-label.


repeat:

    update vnumero label "NFe Numero" with frame f1.

    run impnfe2.p (vetbcod, vnumero).

    leave.
    
end.
