{admcab.i}
def var vpago like fin.titulo.titvlpag.
def var vdesc like fin.titulo.titvlpag.
def var vjuro like fin.titulo.titvlpag.
 
def var vtotcomp    like fin.titulo.titvlcob.
def var ventrada    like fin.titulo.titvlcob.
def var vdata       like fin.titulo.titdtemi.

def input parameter vetbcod like estab.etbcod.
def input parameter vdti like fin.titulo.titdtemi.
def input parameter vdtf like fin.titulo.titdtemi.

def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .

def temp-table tt-titulo like fin.titulo.

def shared temp-table tt-salexporta
    field etbcod like estab.etbcod
    field saldat as date
    field praloj as dec
    field pramat as dec
    field pradif as dec
    field preloj as dec
    field premat as dec
    field predif as dec
    field entloj as dec
    field entmat as dec
    field entdif as dec
    index i1 etbcod
    .
    
for each estab where (if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod) and
                          estab.etbnom begins "DREBES-FIL" no-lock.
        
    assign ventrada = 0
           vtotcomp = 0
           vpago = 0
           vdesc = 0
           vjuro = 0.
    
    do vdata = vdti to vdtf:
            
        assign ventrada = 0
               vtotcomp = 0
               vpago = 0
               vdesc = 0
               vjuro = 0.

        for each fin.contrato where fin.contrato.etbcod = estab.etbcod and
                                        fin.contrato.dtinicial = vdata
                                         no-lock.
                assign ventrada = ventrada + contrato.vlentra
                       vtotcomp = vtotcomp + contrato.vltotal .
        end.

        for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                      fin.titulo.titnat = no and
                                      fin.titulo.modcod = "CRE" and
                                      fin.titulo.titdtpag = vdata and
                                      fin.titulo.etbcobra = estab.etbcod
                                            no-lock use-index etbcod:
                if fin.titulo.titpar = 0
                then next.
                if fin.titulo.etbcobra <> estab.etbcod or fin.titulo.clifor = 1
                then next.
                create tt-titulo.
                buffer-copy fin.titulo to tt-titulo.
                assign vpago = vpago + fin.titulo.titvlcob /*
                              - fin.titulo.titjuro + fin.titulo.titdesc  */
                       vjuro = vjuro + if fin.titulo.titjuro = 
                                          fin.titulo.titdesc
                                       then 0
                                       else fin.titulo.titjuro
                       vdesc = vdesc + if fin.titulo.titjuro = 
                                          fin.titulo.titdesc
                                       then 0
                                       else fin.titulo.titdesc .
        
        end.
        
        for each d.titulo where d.titulo.empcod = wempre.empcod and
                                    d.titulo.titnat = no      and
                                    d.titulo.modcod = "CRE"   and
                                    d.titulo.titdtpag = vdata and
                                    d.titulo.etbcobra = estab.etbcod
                                                no-lock use-index etbcod:
                if d.titulo.titpar = 0
                then next.
                if d.titulo.etbcobra <> estab.etbcod or d.titulo.clifor = 1
                then next.
                find first  tt-titulo where 
                            tt-titulo.empcod = d.titulo.empcod and
                            tt-titulo.titnat = d.titulo.titnat and
                            tt-titulo.modcod = d.titulo.modcod and
                            tt-titulo.etbcod = d.titulo.etbcod and
                            tt-titulo.clifor = d.titulo.clifor and
                            tt-titulo.titnum = d.titulo.titnum and
                            tt-titulo.titpar = d.titulo.titpar no-error.
                if avail tt-titulo
                then next.
                              
            
                assign vpago = vpago + d.titulo.titvlcob /*
                              - d.titulo.titjuro + d.titulo.titdesc   */
                       vjuro = vjuro + if d.titulo.titjuro = d.titulo.titdesc
                                       then 0
                                       else d.titulo.titjuro
                       vdesc = vdesc + if d.titulo.titjuro = d.titulo.titdesc
                                       then 0
                                       else d.titulo.titdesc.
        end.
        
        find first tt-salexporta where 
                   tt-salexporta.etbcod = estab.etbcod and
                   tt-salexporta.saldat   = vdata no-error.
        if not avail tt-salexporta
        then do:
            
            create tt-salexporta.
            assign tt-salexporta.etbcod = estab.etbcod
                   tt-salexporta.saldat   = vdata
                   .
        end.
        assign           
            tt-salexporta.pramat    = vtotcomp
            tt-salexporta.premat    = vpago
            tt-salexporta.entmat    = ventrada.
        assign ventrada = 0
               vtotcomp = 0
               vpago = 0
               vdesc = 0
               vjuro = 0.

        for each    finloja.contrato where 
                    finloja.contrato.etbcod = estab.etbcod and
                    finloja.contrato.dtinicial = vdata no-lock.
                assign ventrada = ventrada + finloja.contrato.vlentra
                       vtotcomp = vtotcomp + finloja.contrato.vltotal .
        end.


        for each    finloja.titulo where 
                    finloja.titulo.empcod = wempre.empcod and
                    finloja.titulo.titnat = no and
                    finloja.titulo.modcod = "CRE" and
                    finloja.titulo.titdtpag = vdata and
                    finloja.titulo.etbcobra = estab.etbcod
                    no-lock use-index etbcod:
            if finloja.titulo.titpar = 0
            then next.
            if finloja.titulo.etbcobra <> estab.etbcod or 
                    finloja.titulo.clifor = 1
            then next.

            assign vpago = vpago + finloja.titulo.titvlcob /*
                         - finloja.titulo.titjuro + finloja.titulo.titdesc  */
                   vjuro = vjuro + if finloja.titulo.titjuro = 
                                          finloja.titulo.titdesc
                                       then 0
                                       else finloja.titulo.titjuro
                   vdesc = vdesc + if finloja.titulo.titjuro = 
                                      finloja.titulo.titdesc
                                       then 0
                                       else finloja.titulo.titdesc .
        
        end.
        assign           
            tt-salexporta.praloj    = vtotcomp
            tt-salexporta.preloj    = vpago
            tt-salexporta.entloj    = ventrada.
 
    end.            
end.
