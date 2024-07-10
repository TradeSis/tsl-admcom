{admcab.i}

disable triggers for load of comloja.plani.

def var recpla as recid.
def var recmov as recid.
def var v-ok as log.
def var vemite    like  estab.etbcod.
def var vtrans    like  clien.clicod.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  comloja.plani.alicms format ">9,99".
def var vpladat   like  comloja.plani.pladat.
def var vnumero   like  comloja.plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  comloja.plani.bicms.
def var vicms     like  comloja.plani.icms .
def var vprotot   like  comloja.plani.protot.
def var vprotot1  like  comloja.plani.protot.
def var vdescpro  like  comloja.plani.descpro.
def var vacfprod  like  comloja.plani.acfprod.
def var vfrete    like  comloja.plani.frete.
def var vseguro   like  comloja.plani.seguro.
def var vdesacess like  comloja.plani.desacess.
def var vipi      like  comloja.plani.ipi.
def var vplatot   like  comloja.plani.platot.
def var vetbcod   like  comloja.plani.etbcod.
def var vserie    like  comloja.plani.serie.
def var vopccod   like  comloja.plani.opccod.


def var vdown as i.
def var vant as l.
def var vi as int.
def var vplacod     like comloja.plani.placod.
def var vtotal      like comloja.plani.platot.
def buffer bestab for estab.
def buffer bplani for comloja.plani.
def buffer xestab for estab.



form
    vetbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vserie  colon 15
    vnumero
    opcom.opccod  format "9999" colon 15
    opcom.opcnom no-label
    vpladat       colon 15
      with frame f1 side-label color white/cyan width 80 row 4.

repeat:

    
    clear frame f1 all no-pause.
    clear frame f2 all no-pause.
    clear frame f-exclusao all no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-exclusao no-pause.
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    /*
    if vetbcod < 900 and
     {conv_difer.i vetbcod} 
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.
    */
    display estab.etbnom no-label with frame f1.
    
    /******** Pega a ultima nota e gera a numero *****/
    vnumero = 0. 
    vserie = "U".
    for each com.tipmov no-lock: 
        find last bplani use-index nota 
                            where bplani.movtdc = com.tipmov.movtdc and
                                  bplani.etbcod = estab.etbcod  and
                                  bplani.emite  = estab.etbcod  and
                                  bplani.serie  = "U" no-lock no-error.
        if not avail bplani 
        then next. 
        if vnumero < bplani.numero 
        then vnumero = bplani.numero.
    end. 
    if vnumero = 0 
    then vnumero = 1. 
    else vnumero = vnumero + 1.
    /************************************************/

 
    display vserie 
            vnumero with frame f1.
    find last opcom where opcom.movtdc = 6 no-lock.
    display opcom.opccod 
            opcom.opcnom no-label with frame f1.
    find first comloja.plani where comloja.plani.numero = vnumero and
                     comloja.plani.emite  = estab.etbcod and
                     comloja.plani.serie  = vserie and
                     comloja.plani.etbcod = estab.etbcod and
                     comloja.plani.movtdc = 6  no-error.
    if avail comloja.plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end. 
    vpladat = today.
   
    display vpladat with frame f1.
    message "Confirma Nota Fiscal " vnumero update sresp.
    if sresp = no
    then undo, retry.
    
    do on error undo:
        create comloja.plani.
        assign comloja.plani.etbcod   = estab.etbcod
               comloja.plani.placod   = int(string("210") + 
                                        string(vnumero,"9999999"))
               comloja.plani.emite    = estab.etbcod
               comloja.plani.serie    = vserie
               comloja.plani.numero   = vnumero
               comloja.plani.movtdc   = 22
               comloja.plani.desti    = estab.etbcod
               comloja.plani.pladat   = vpladat
               comloja.plani.modcod   = "DUP"
               comloja.plani.opccod   = int(opcom.opccod)
               comloja.plani.dtinclu  = vpladat
               comloja.plani.horincl  = time
               comloja.plani.notsit   = no
               comloja.plani.hiccod   = int(opcom.opccod)
               comloja.plani.exportado = yes.

        recpla = recid(comloja.plani).
        release comloja.plani.
        
    end.

    find comloja.plani where recid(comloja.plani) = recpla no-lock.
    
    do transaction:
        find com.plani where 
                   com.plani.etbcod = comloja.plani.etbcod and
                   com.plani.placod = comloja.plani.placod and
                   com.plani.serie  = comloja.plani.serie no-error.
        if not avail com.plani
        then do: 
            create com.plani.  
            assign com.plani.etbcod   = estab.etbcod
                   com.plani.placod   = int(string("210") + 
                                            string(vnumero,"9999999"))
                   com.plani.emite    = estab.etbcod
                   com.plani.serie    = vserie
                   com.plani.numero   = vnumero
                   com.plani.movtdc   = 22
                   com.plani.desti    = estab.etbcod
                   com.plani.pladat   = vpladat
                   com.plani.modcod   = "DUP"
                   com.plani.opccod   = int(opcom.opccod)
                   com.plani.dtinclu  = vpladat
                   com.plani.horincl  = time
                   com.plani.notsit   = no
                   com.plani.hiccod   = int(opcom.opccod).
            
        end. 
    end.
    
end.
