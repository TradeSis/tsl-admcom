{admcab.i} 

{/admcom/progr/loja-com-ecf-def.i} 

def new shared var vALCIS-ARQ-ORECH   as int.
def var vsenha    as char.
def var vfuncod   like func.funcod.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)" /*like  plani.serie*/.
def var vopccod   like  plani.opccod.
def var vi as int.
def var vqtd        like movim.movqtm.
def var vtotal      like plani.platot.

form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    vnumero   colon 15
    vserie
    plani.pladat       colon 15
    plani.datexp format "99/99/9999"
      with frame f1 side-label color white/cyan width 80 row 4.

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.

    vsenha = "".
    update vfuncod label "Matricula"
           vsenha  label "Senha"
               blank with frame f-senh side-label centered row 10.
    find first func where func.funcod = vfuncod and
                          func.etbcod = 999      and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.
    hide frame f-senh no-pause.
 
def var vmoveis as log.
repeat:
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    
    prompt-for estab.etbcod label "Emitente" with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "estabelecimento nao cadastrado".
        undo, retry.
    end. 
    
    {/admcom/progr/loja-com-ecf.i estab.etbcod} 
    if p-loja-com-ecf 
    then vserie = "2".
    else vserie = "1".
    
    display estab.etbnom with frame f1.
    disp vserie  with frame f1.
    update vnumero with frame f1.
    if vserie = ""
    then update vserie with frame f1.
    
    find plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 6   and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.
    display plani.desti format ">>>>>>>99"
            plani.pladat
            plani.datexp with frame f1.

    vmoveis = yes.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod  and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat   no-lock:
        
        find produ where produ.procod = movim.procod no-lock.
        if produ.catcod = 41
        then vmoveis = no.
        disp produ.procod 
             produ.pronom format "x(25)"
             movim.movtdc 
             movim.movqtm format ">,>>9.99" column-label "Qtd"
             movim.movpc  format ">,>>9.99" column-label "Custo"
             ((movim.movpc * movim.movqtm) -
             ((movim.movpc * movim.movqtm) * (movim.movpdesc / 100)))
                    format ">>,>>9.99" column-label "TOTAL"
                            with frame f-produ2  9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
    end. 
    if not vmoveis
    then do:
        bell.
        message color red/with
        "Nota Fiscal possui produtos de MODA." skip
        "Impossivel continuar."
        view-as alert-box.
        undo.
    end.

   /* if plani.notsit 
    then message "Nota Fiscal ja Confirmada". 
    else do: */
        find first nottra where nottra.etbcod = plani.etbcod and
                                nottra.desti  = plani.desti  and
                                nottra.numero = plani.numero and
                                nottra.movtdc = plani.movtdc and
                                nottra.serie  = plani.serie no-error.
        if avail nottra 
        then do: 
            message "Nota Fiscal ja Confirmada".
            undo, retry.
        end.
         
        message "confirma nota fiscal" update sresp. 
        if sresp 
        then do transaction:
    
            create nottra.
            assign nottra.etbcod = plani.etbcod
                   nottra.desti  = plani.desti
                   nottra.movtdc = plani.movtdc
                   nottra.numero = plani.numero
                   nottra.serie  = plani.serie
                   nottra.datexp = today
                   nottra.livre  = func.funnom.
            /***       
            if (plani.desti = 996 or plani.desti = 995
                or plani.desti = 900) and
               plani.emite = 22
            then run ped22.p (input recid(plani)).
            
            if plani.desti = 993
            then do.
                if not connected ( "wms") 
                then do.
                    connect wms -N tcp -S 1920 
                            -H server.dep93 -cache ../wms/wms.csh.
                    if connected ( "wms")
                    then do.
                        run 30821.p (recid(plani)).
                        disconnect wms.
                    end.
                end.
                else do.
                    run 30821.p (recid(plani)).
                end.                
            end.
            ***/
        end.
        if sresp
        then do.
            if plani.desti = 900
            then do.
                hide message no-pause.
                bell. bell.
                message "GERAR INTERFACE PARA WMS ALCIS ?" update
                        sresp.
                if sresp
                then do:
                    run orech-993.p(recid(plani), "TR").
                end.
            end.
        end.
        
end.

