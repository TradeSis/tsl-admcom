{admcab.i}
def var vnumero like glopre.numero.
def var vgrupo  like glopre.grupo.
def var vcota   like glopre.cota.
def var vv as int.

repeat:

    vnumero = 0.
    update vnumero label "Numero" with frame f1 side-label width 80.
    
    for each glopre where glopre.numero = vnumero break by glopre.clicod:
    
        if first-of(glopre.clicod)
        then do:
            vgrupo = 0.
            vcota  = 0.
            
            find clien where clien.clicod = glopre.clicod no-lock no-error.
            display glopre.clicod label "Cliente"
                    clien.clinom no-label with frame f1.
            update vgrupo label "Grupo"
                   vcota  label "Cota" with frame f2 centered side-label.
            message "Confirma Grupo e Cota" update sresp.
            if not sresp
            then leave.
            hide frame f2 no-pause.
        end.
        assign glopre.datexp = today
               glopre.grupo  = vgrupo
               glopre.cota   = vcota.

        display glopre.parcela column-label "Pr"
                glopre.grupo   column-label "Grupo"
                glopre.cota    column-label "Cota"
                glopre.dtven
                glopre.valpar  column-label "Vl.Prest." format ">>,>>9.99"
                                with frame f3 down color white/cyan centered.
    end.
end.
                               
    
        
    

