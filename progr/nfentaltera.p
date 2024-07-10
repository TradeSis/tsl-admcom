{admcab.i}
def var vforcod   like forne.forcod.
def var vmovqtm   like  movim.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .                         
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.

def new shared temp-table tt-movim
    field rec as recid 
    field procod    like movim.procod 
    field movqtm    like movim.movqtm 
    field movpc     like movim.movpc   
    field movalicms like movim.movalicms  
    field movicms   like movim.movicms    
    field movalipi  like movim.movalipi   
    field movipi    like movim.movipi     
    field movpdes   like movim.movpdes    
    field movdes    like movim.movdes     
    field movdev    like movim.movdev.   



form movim.procod column-label "Codigo" format ">>>>>9" 
     movim.movqtm format ">>>>9" column-label "Qtd"   
     movim.movpc  format ">>,>>9.99" column-label "Val.Unit" 
     movim.movalicms column-label "%ICMS" format ">9.99" 
     movim.movicms   column-label "ICMS"  format ">>,>>9.99" 
     movim.movalipi  column-label "%IPI"  format ">9.99" 
     movim.movipi    column-label "IPI"   format ">,>>9.99" 
     movim.movpdes   column-label "%Des" format ">9.99" 
     movim.movdes    column-label "Desc" format ">>,>>9.99" 
     movim.movdev    column-label "Frete" format ">,>>9.99"
        with frame f-produ1 row 11 8 down overlay
                   centered color white/cyan width 80.

form
    vetbcod label "Filial" colon 15
    estab.etbnom no-label skip
    vforcod colon 15
    forne.fornom no-label
    vnumero   colon 15
    vserie    at 32   label "Serie" format "x(03)"
    plani.opccod  label "Op.Fiscal" colon 15 format "9999"
    opcom.opcnom  no-label 
    plani.pladat       colon 15
    plani.dtinclu label "Dt.Receb." format "99/99/9999" 
    plani.datexp label "Dt.Digitacao" format "99/99/9999"
    plani.ufdes label "Chave NFE" format "x(50)" colon 15
      with frame f1 side-label color blue/cyan width 80 row 4.


form plani.bicms        column-label "Base Icms" at 01
     plani.icms         column-label "Valor Icms"
     plani.bsubst       column-label "Base Icms Subst" 
     plani.icmssubst    column-label "Valor Substituicao" 
     plani.protot      column-label "Tot.Prod." 
        with frame f-base1 row 12 overlay width 80
         color white/cyan.


form plani.frete     column-label "Frete"  at 01
     plani.seguro    column-label "Seguro"
     plani.desacess  column-label "Outras Desp. Acess."
     plani.ipi       column-label "IPI"
     plani.platot    column-label "Total Nota" format ">,>>>,>>9.99"
        with frame f2 overlay row 17 width 80 
         color white/cyan.
 

repeat:
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    hide frame f-base1 no-pause.
    
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock.
    disp forne.fornom no-label with frame f1.

    vserie = "U".
    update vnumero
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.movtdc = 4   and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-lock no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.
    display plani.opccod format "9999" with frame f1. 
    find opcom where opcom.opccod = string(plani.opccod) no-lock no-error.
    if not avail opcom
    then find opcom where opcom.opccod = string(plani.hiccod) no-lock no-error.

    display opcom.opcnom no-label when avail opcom with frame f1. 
    display plani.pladat 
            plani.dtinclu 
            plani.datexp format "99/99/9999"
            plani.ufdes
                    with frame f1.
                    
    display plani.bicms  
            plani.icms 
            plani.bsubst
            plani.icmssubst
            plani.protot   
                with frame f-base1.

    /*
    if plani.notsit = no
    then do:
        message color red/with
                "Nota Fiscal ja fechada impossivel alterar."
                view-as alert-box.
            
        undo, retry.
    end.
    */
    update  plani.bicms  
            plani.icms 
            plani.bsubst
            plani.icmssubst
            plani.protot   
                with frame f-base1.
            

    display plani.frete 
            plani.seguro 
            plani.desacess
            plani.ipi     
            plani.platot  
                with frame f2 overlay row 17 width 80.

    update plani.frete 
            plani.seguro 
            plani.desacess
            plani.ipi     
            plani.platot  
                with frame f2 overlay row 17 width 80.


    clear frame f-produ1 all no-pause.
    for each tt-movim:
        delete tt-movim.
    end.    

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
        find first tt-movim where tt-movim.rec = recid(movim) no-error.
        if not avail tt-movim
        then do:
            create tt-movim.
            assign tt-movim.rec = recid(movim)
                   tt-movim.procod = movim.procod  
                   tt-movim.movqtm = movim.movqtm  
                   tt-movim.movpc  = movim.movpc   
                   tt-movim.movalicms = movim.movalicms  
                   tt-movim.movicms = movim.movicms    
                   tt-movim.movalipi = movim.movalipi   
                   tt-movim.movipi = movim.movipi     
                   tt-movim.movpdes = movim.movpdes    
                   tt-movim.movdes = movim.movdes     
                   tt-movim.movdev = movim.movdev.   
        end.
        
     end.
     run tt-movim-altera.p.
     for each tt-movim no-lock:
        find movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.procod = tt-movim.procod
                         no-error.
        if avail movim                 
        then do:
            buffer-copy tt-movim to movim.
        end.
     end.       
     clear frame f-1 all no-pause.
end.
