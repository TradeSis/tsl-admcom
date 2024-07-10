def var vetbcod like ger.estab.etbcod.
def var vhab     as integer.
def var vdti     as date format "99/99/9999" initial today.
def var vdtf     as date format "99/99/9999" initial today.
def var vqtd as int.

repeat:

    update vetbcod label "Filial"
           vdti    label "Periodo"
           vdtf    no-label with frame f1 side-label width 80.

    for each admloja.habil where admloja.habil.etbcod = vetbcod
                             and admloja.habil.habdat >= vdti
                             and admloja.habil.habdat <= vdtf no-lock:

        find adm.habil where adm.habil.ciccgc  = admloja.habil.ciccgc
                         and adm.habil.celular = admloja.habil.celular
                         no-error.
                                    
        if not avail adm.habil
        then do transaction:
            create adm.habil.
            buffer-copy admloja.habil to adm.habil.
            vhab = vhab + 1.
        end.
        
    end.                                            
    display vetbcod  label "Filial......"
            vhab     label "Habilitacoes"
                with frame f3 1 column side-label width 80.
    vqtd = 0.    
    for each admloja.ctdevven where admloja.ctdevven.dtexp >= vdti
                                and admloja.ctdevven.dtexp <= vdtf
                                and admloja.ctdevven.etbcod = vetbcod:
        do transaction:
            find first adm.ctdevven where 
                       adm.ctdevven.movtdc = admloja.ctdevven.movtdc and
                       adm.ctdevven.etbcod = admloja.ctdevven.etbcod and
                       adm.ctdevven.placod = admloja.ctdevven.placod  and
                    adm.ctdevven.movtdc-ori = admloja.ctdevven.movtdc-ori and
                    adm.ctdevven.etbcod-ori = admloja.ctdevven.etbcod-ori and
                    adm.ctdevven.placod-ori = admloja.ctdevven.placod-ori and
                    adm.ctdevven.movtdc-ven = admloja.ctdevven.movtdc-ven and
                    adm.ctdevven.etbcod-ven = admloja.ctdevven.etbcod-ven and
                    adm.ctdevven.placod-ven = admloja.ctdevven.placod-ven
                       no-error.
            if not avail adm.ctdevven
            then do:
                create adm.ctdevven.
            end. 
            buffer-copy admloja.ctdevven to adm.ctdevven.
            adm.ctdevven.exportado = yes.
            admloja.ctdevven.exportado = yes.
            find current adm.ctdevven no-lock no-error.
            vqtd = vqtd + 1.
        end.
    end.

    display vetbcod  label "Filial......"
            vqtd     label "Controle devolucões venda"
                with frame f3 1 column side-label width 80.
            
    vqtd = 0.
    for each admloja.mapcxa where 
                 admloja.mapcxa.etbcod = vetbcod and
                 admloja.mapcxa.datmov >= vdti and
                 admloja.mapcxa.datmov <= vdtf
                 no-lock:
            find adm.mapcxa where
                 adm.mapcxa.etbcod = admloja.mapcxa.etbcod and
                 adm.mapcxa.datmov = admloja.mapcxa.datmov
                 no-lock no-error.
            if not avail adm.mapcxa
            then do:
                create adm.mapcxa.
                buffer-copy admloja.mapcxa to adm.mapcxa.
            end.
            else do:
                next.
            end.         
            vqtd = vqtd + 1.
    end.
    display vetbcod  label "Filial......"
            vqtd     label "Mapa de Caixa"
                with frame f3 1 column side-label width 80.
 
end.


