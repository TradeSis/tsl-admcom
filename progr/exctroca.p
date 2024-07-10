{admcab.i}
def var vtipo   as log format "Entrada/Saida".
def var vmovtdc like tipmov.movtdc.
def var i as int.
def var vfuncod like func.funcod.
def var vsenha  as char.
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
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     vtotger as dec format ">,>>9.99" column-label "Custo"
                    with frame f-produ2 row 11 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.


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
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide  frame f2 no-pause.
    hide  frame f-produ2 no-pause.
         
    
    
             
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
    if func.funfunc <> "ESTOQUE"
    then do:
        bell. 
        message "Funcionario sem Permissao". 
        undo, retry. 
    end.
    i = 0. 
    repeat: 
        i = i + 1.
        update vsenha blank with frame f-senha.
        if vsenha = func.senha 
        then leave. 
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
                  
    
    
    clear frame f-produ2 no-pause.
    update vtipo   label "Troca " at 1
           vetbcod label "Filial" at 1 
              with frame f1 side-label 
                    color white/cyan width 80 row 4.
    
    if vtipo
    then vmovtdc = 17.
    else vmovtdc = 18.
    
                
                    

    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    vserie = "TR".
    display estab.etbnom no-label with frame f1.
        
    update vnumero at 1 format ">>>>>9" with frame f1.

    find plani where plani.numero = vnumero      and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = vmovtdc      and
                     plani.serie  = vserie       and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.


    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
                                                    
        find produ where produ.procod = movim.procod no-lock.
        
        disp produ.procod
             produ.pronom format "x(30)"
             movim.movqtm format ">,>>9.99" column-label "Qtd"
             movim.movpc  format ">,>>9.99" column-label "Custo"
             (movim.movpc * movim.movqtm) @ vtotger
                            with frame f-produ2 down.
        
     end.
     
     message "Confirma Exclusao da Troca" plani.numero
     update sresp.
     if sresp
     then do:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat:
                                                           
            run atuest.p (input recid(movim),
                          input "E",
                          input 0).
            delete movim.
        
        end.
        delete plani.
        hide frame f-produ2 no-pause.
     end.
     hide frame f-produ2 no-pause.
     return.
end.
