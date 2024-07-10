disable triggers for load of nfeloja.a01_infnfe.
def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.
def var vnumero             like com.plani.numero.
def var vnum                like com.plani.numero.
def var sresp as log format "Sim/Nao".


for each nfe.A01_infnfe where nfe.A01_infnfe.etbcod = vetbcod no-lock,

    first nfe.B01_IdeNFe of nfe.A01_infnfe
          where nfe.B01_IdeNFe.demi >= vdti
            and nfe.B01_IdeNFe.demi <= vdtf  no-lock.

    release nfeloja.A01_infnfe.
    find first nfeloja.A01_infnfe
         where nfeloja.A01_infnfe.emite  = nfe.A01_infnfe.emite
           and nfeloja.A01_infnfe.serie  = nfe.A01_infnfe.serie
           and nfeloja.A01_infnfe.numero = nfe.A01_infnfe.numero
                                      no-lock no-error.

    if not avail nfeloja.A01_infnfe
    then do:

        create nfeloja.A01_infnfe.

        buffer-copy nfe.A01_infnfe to nfeloja.A01_infnfe.

    end.
    /*
    find first nfe.B01_IdeNFe of nfe.A01_infnfe no-lock no-error.
    if avail nfe.B01_IdeNFe
    then do:
    */  find first nfeloja.B01_IdeNFe of nfe.A01_infnfe no-lock no-error.
        if not avail nfeloja.B01_IdeNFe
        then do:
            create nfeloja.B01_IdeNFe.
            buffer-copy nfe.B01_IdeNFe to nfeloja.B01_IdeNFe.
        end.
    /*
    end.
    */
    for each nfe.B12_NFref of nfe.A01_infnfe no-lock:
        find first nfeloja.B12_NFref of nfe.A01_infnfe no-lock no-error.
        if not avail nfeloja.B12_NFref
        then do:
            create nfeloja.B12_NFref.
            buffer-copy nfe.B12_NFref to nfeloja.B12_NFref.
        end.
    end.
    find nfe.C01_Emit of nfe.A01_infnfe no-lock no-error.
    if avail nfe.C01_Emit
    then do:
        find first nfeloja.C01_Emit of nfe.A01_infnfe no-lock no-error.
        if not avail nfeloja.C01_Emit then do:
            create nfeloja.C01_Emit.
            buffer-copy nfe.C01_Emit to nfeloja.C01_Emit.
        end.
    end.
    for each nfe.docrefer where
             nfe.docrefer.etbcod = nfe.A01_infnfe.etbcod and
             nfe.docrefer.serieori  = nfe.A01_infnfe.serie  and
             nfe.docrefer.numori = nfe.A01_infnfe.numero
             no-lock:

        find first nfeloja.docrefer
             where nfeloja.docrefer.etbcod   = nfe.docrefer.etbcod
               and nfeloja.docrefer.codedori = nfe.docrefer.codedori
               and nfeloja.docrefer.serieori = nfe.docrefer.serieori
               and nfeloja.docrefer.numori   = nfe.docrefer.numori
                           no-lock no-error.
        if not avail nfeloja.docrefer
        then do:
            create nfeloja.docrefer.
            buffer-copy nfe.docrefer to nfeloja.docrefer.
        end.
    end.
    find nfe.E01_Dest of nfe.A01_infnfe no-lock no-error.
    if avail nfe.E01_Dest
    then do:
        find first nfeloja.E01_Dest of nfe.A01_infnfe no-lock no-error.
        if not avail nfeloja.E01_Dest
        then do:
            create nfeloja.E01_Dest.
            buffer-copy nfe.E01_Dest to nfeloja.E01_Dest.
        end.
    end.
    for each nfe.I01_Prod of nfe.A01_infnfe no-lock:
        find first nfeloja.I01_Prod of nfe.I01_Prod no-lock no-error.
        if not avail nfeloja.I01_Prod
        then do:
            create nfeloja.I01_Prod.
            buffer-copy nfe.I01_Prod to nfeloja.I01_Prod.
        end.
    end.
    for each nfe.N01_icms of nfe.A01_infnfe no-lock:
        find first nfeloja.N01_icms of nfe.N01_icms no-lock no-error.
        if not avail nfeloja.N01_icms
        then do:
            create nfeloja.N01_icms.
            buffer-copy nfe.N01_icms to nfeloja.N01_icms.
        end.
    end.
    for each nfe.O01_IPI of nfe.A01_infnfe no-lock:
        find first nfeloja.O01_IPI of nfe.O01_IPI no-lock no-error.
        if not avail nfeloja.O01_IPI
        then do:
            create nfeloja.O01_IPI.
            buffer-copy nfe.O01_IPI to nfeloja.O01_IPI.
        end.
    end.
    for each nfe.Q01_PIS of nfe.A01_infnfe no-lock:
        find first nfeloja.Q01_PIS of nfe.Q01_PIS no-lock no-error.
        if not avail nfeloja.Q01_PIS
        then do:
            create nfeloja.Q01_PIS.
            buffer-copy nfe.Q01_PIS to nfeloja.Q01_PIS.
        end.
    end.
    for each nfe.S01_cofins of nfe.A01_infnfe no-lock:
        find first nfeloja.S01_cofins of nfe.S01_cofins no-lock no-error.
        if not avail nfeloja.S01_cofins
        then do:
            create nfeloja.S01_cofins.
            buffer-copy nfe.S01_cofins to nfeloja.S01_cofins.
        end.
    end.
    find nfe.W01_total of nfe.A01_infnfe no-lock no-error.
    if avail nfe.W01_total
    then do:
        find first nfeloja.W01_total of nfe.W01_total no-lock no-error.
        if not avail nfeloja.W01_total
        then do:
            create nfeloja.W01_total.
            buffer-copy nfe.W01_total to nfeloja.W01_total.
        end.
    end.
    for each nfe.X01_Transp of nfe.A01_infnfe no-lock:
        find first nfeloja.X01_Transp of nfe.X01_Transp no-lock no-error.
        if not avail nfeloja.X01_Transp
        then do:
            create nfeloja.X01_Transp.
            buffer-copy nfe.X01_Transp to nfeloja.X01_Transp.
        end.
    end.
    find nfe.Z01_InfAdic of nfe.A01_infnfe no-lock no-error.
    if avail nfe.Z01_InfAdic
    then do:
        find first nfeloja.Z01_InfAdic of nfe.Z01_InfAdic no-lock no-error.
        if not avail nfeloja.Z01_InfAdic
        then do:
            create nfeloja.Z01_InfAdic.
            buffer-copy nfe.Z01_InfAdic to nfeloja.Z01_InfAdic.
        end.
    end.
end.
         



