{admcab.i new}
def var vok as log.
def var vsenha like func.senha.
def var i as int.
def var vfuncod like func.funcod.
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
def var vserie    like  plani.serie.
def var vopccod   like  plani.opccod.

/* def var vopfcod   like  plani.opfcod. */

def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.


form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">>>>99" column-label "Qtd"
     movim.movpc  format ">>,>>9.99" column-label "Custo"
     vtotger as dec format ">>>,>>9.99" label "Total"
                    with frame f-produ2 row 5 7 down overlay
                                    centered color message width 70.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(30)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom no-label
    vnumero   colon 15
    vserie
    /*plani.opccod   colon 15
    opcom.opcnom
    plani.opfcod   label "Op.Fiscal" colon 15
    opfis.opfnom  no-label */
    plani.pladat       colon 15
    /* plani.datexp  label "Data Exportacao" format "99/99/9999" */
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

repeat:

    
    vok = no.
    
    if estab.etbcod <> 22
    then do:
        vok = no.
        update vfuncod with frame f-senha centered row 4
                            side-label title " Seguranca ".
        find func where func.funcod = vfuncod and
                        func.etbcod = 999 no-lock no-error.
        if not avail func
        then do:
            message "Funcionario nao Cadastrado".
            undo, retry.
        end.
        disp func.funnom no-label with frame f-senha.
        if func.funfunc <> "ESTOQUE" and
           func.funfunc <> "CONTABILIDADE" and
           func.funfunc <> "CUSTOM"
        then do:
            bell.
            message "Funcionario sem Permissao".
            undo, retry.
        end.
        i = 0.
        repeat:
            i = i + 1.
            vok = no.
            update vsenha blank with frame f-senha.
            if vsenha = func.senha
            then do:
                vok = yes.
                leave.
            end.    
            if vsenha <> func.senha
            then do:
                bell.
                message "Senha Invalida".
            end.
            if i > 2
            then leave.
        end.
        if vsenha = ""
        then undo, retry.
    end.

    if vok = no
    then return.

 
    
    
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.

    prompt-for estab.etbcod label "Emitente" with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    vserie = "U".
    display estab.etbnom with frame f1.
    update vnumero
           vserie with frame f1.
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
    do on error undo, retry:
        update plani.pladat
                with frame f1.
    end.
    /*do on error undo, retry:
        update plani.bicms
               plani.icms with frame f2.
    end.
    plani.protot = plani.bicms.
    update
        plani.protot
        plani.frete
        plani.ipi
        plani.descpro
        plani.acfprod with frame f2.
        plani.platot = (plani.bicms + plani.frete + plani.ipi) - plani.descpro.
    update plani.platot with frame f2.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.*/
    clear frame f-produ2 all no-pause.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
    
        find produ where produ.procod = movim.procod no-lock.
        disp produ.procod
             produ.pronom format "x(30)" 
             movim.movqtm format ">>>>99" column-label "Qtd"
             movim.movpc  format ">>,>>9.99" column-label "Custo"
             (movim.movpc * movim.movqtm) @ vtotger
                            with frame f-produ2.
        down with frame f-produ2.

    end. 
    hide frame f1 no-pause. 
    hide frame f2 no-pause. 
    
    repeat with on endkey undo, leave on error undo, retry:
        view frame f-produ2.
        vprocod = 0.
        update vprocod with frame f-1  no-box color message centered
                                    side-label overlay width 71.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        disp produ.pronom no-label with frame f-1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            bell.
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.
        vmovseq = 0.
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.procod = produ.procod  no-lock:
            if movim.movseq > vmovseq
            then vmovseq = movim.movseq.
        end.
        find movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.procod = produ.procod  no-error.

        if not avail movim
        then do:
            sresp = no.
            message "Produto nao pertence a nota. Deseja Incluir ? " 
            update sresp.
            if not sresp
            then undo, retry.
            create movim.
            ASSIGN movim.movtdc = 6
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = 0
               movim.movpc  = estoq.estcusto
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time)
               movim.emite     = plani.emite
               movim.desti     = plani.desti
               movim.ocnum[1]  = 0 .    
        end.
        vmovqtm = movim.movqtm.
        update  
                movim.movqtm
              validate(movim.movqtm > 0,
                         "Quantidade Invalida") 
               with frame f-produ2.
        update movim.movpc with frame f-produ2.
        movim.desti = plani.desti.
        movim.emite = plani.emite.        
        movim.datexp = plani.datexp.
        
        if plani.emite = 22 and
           plani.desti = 996
        then.
        else run atuest.p(recid(movim),
                          input "I",
                          input 0).
        clear frame f-produ2 all no-pause.
        
        hide frame f-1.
        plani.platot = 0.
        plani.protot = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat:
            find produ where produ.procod = movim.procod no-lock.
            disp produ.procod
                 produ.pronom format "x(30)"
                 movim.movqtm format ">>>>99" column-label "Qtd"
                 movim.movpc  format ">>,>>9.99" column-label "Custo"
                 (movim.movpc * movim.movqtm) @ vtotger with frame f-produ2.
                    down with frame f-produ2.
                 pause 0.
             
                 plani.protot = plani.protot + (movim.movpc * movim.movqtm).
                 plani.platot = plani.platot + (movim.movpc * movim.movqtm).
                 plani.notobs[2] = "A".
        end.
     end.
     clear frame f-1 all no-pause.
     hide frame f-1.
end.
