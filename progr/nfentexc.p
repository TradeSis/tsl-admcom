{admcab.i}
def var vfuncod like func.funcod.
def var i as int.
def var vsenha as char.
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
def var vserie    as    char format "x(06)".
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
def var vforcod     like forne.forcod.

def temp-table tt-plani like plani.
def temp-table tt-movim like movim.
def temp-table tt-titulo like titulo.

form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movalicms column-label "ICMS"
     movim.movalipi  column-label "IPI"
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    estab.etbcod   label "Filial" colon 15
    estab.etbnom   no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero   colon 15
    vserie label "Serie"
/*    plani.opccod   colon 15
    opcom.opcnom              */
    plani.pladat       colon 15
      with frame f1 side-label width 80 row 3.

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.

/*
prompt-for func.funcod
           func.senha blank with frame f-func side-label centered.
find func where func.funcod = input func.funcod and
                func.senha  = input func.senha no-lock no-error.
if not avail func
then do:
    message "Funcionario Invalido".
    undo, retry.
end.
if func.senha <> "0701" and func.senha <> "100"
then do:
    message "Funcionario Invalido".
    undo, retry.
end.
*/

def var satuest as log format "Sim/Nao".
l1:
repeat:
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    hide  frame f-produ1 no-pause.
    clear frame f-senha all.
    
    do:
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
        if func.funfunc <> "CONTABILIDADE"
        then do:
            bell.
            message "Funcionario sem Permissao".
            undo, retry.
        end.
        i = 0.
        repeat:
            i = i + 1.
            update vsenha blank label "Senha" with frame f-senha.
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
    end.

    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.

    update vnumero 
           vserie with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = forne.forcod and
                     (plani.movtdc = 4 or
                      plani.movtdc = 74) and
                     plani.serie = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.
    do on error undo, retry:
        find tipmov where tipmov.movtdc = plani.movtdc no-lock.
        display plani.pladat with frame f1.
    end.
    display plani.bicms
            plani.icms
            plani.protot
            plani.frete
            plani.ipi
            plani.descpro
            plani.acfprod
            plani.platot with frame f2.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc no-lock:
        find produ where produ.procod = movim.procod no-lock.
         disp produ.procod
              produ.pronom format "x(20)"
              movim.movqtm format ">,>>9.99" column-label "Qtd"
              movim.movalicms column-label "ICMS"
              movim.movalipi  column-label "IPI"
              movim.movpc  format ">,>>9.99" column-label "Custo"
              (movim.movpc * movim.movqtm) format ">>,>>>,>>9.99"
                                    column-label "TOTAL"
                            with frame f-produ2 row 5 9 down  overlay
                              centered /*color message*/ width 80.
                down with frame f-produ2.
     end.

     sresp = no.
     message "Confirma excluir a Nota Fiscal?" 
     update sresp.
     if sresp
     then do:
        
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        for each tt-titulo: delete tt-titulo. end.
        
        satuest = no.
                      
        if plani.notsit = no
        then satuest = yes.
        else satuest = no.
        
        if satuest
        then do on error undo:
            for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc no-lock:
                run atuest.p (input recid(movim),
                          input "E",
                          input 0).
            end.
        end.

        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc:
            create tt-movim.
            buffer-copy movim to tt-movim.
            delete movim.
        end.

        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero).
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
            delete titulo.
        end.
        find fiscal where fiscal.emite = plani.emite and
                          fiscal.desti = plani.desti and
                          fiscal.movtdc = plani.movtdc and
                          fiscal.numero = plani.numero and
                          fiscal.serie = plani.serie
                          no-error.
        if avail fiscal
        then delete fiscal.                  
        
        create tt-plani.
        buffer-copy plani to tt-plani.
        
        delete plani.

        run deleta-registros-xml(tt-plani.ufdes).
     end.

     find first plani where plani.numero = vnumero and
                     plani.emite  = forne.forcod and
                     (plani.movtdc = 4 or
                      plani.movtdc = 74)  and
                     plani.serie = vserie and
                     plani.etbcod = estab.etbcod no-error.
     if not avail plani
     then do:
        output to /admcom/logs/exclui-plani.log append.
        for each tt-plani where
                 tt-plani.etbcod <> 0:
            put "PLANI;" + string(tt-plani.numero,">>>>>>>>9") +
                ";FORNECEDOR;" + string(tt-plani.emite,">>>>>>>>>9") +
                ";DATA;" + string(today)
                format "x(80)"
                skip.

            export tt-plani.

        end.
        for each tt-movim:
            put "MOVIM;" + string(tt-movim.procod) +
                ";QUANTIDADE;" + string(tt-movim.movqtm)
                format "x(80)"
                skip.
            
            export tt-movim.

            run retorna-ultimo-custo.
            
        end.
        for each tt-titulo:
            put "TITULO;" + string(tt-titulo.titnum) +
                ";VENCIMENTO;" + string(tt-titulo.titdtven)
                format "x(80)"
                skip.
            export tt-titulo.
        end.        

        output close.

        message color red/with 
            "Nota Fiscal EXCLUIDA"
            view-as alert-box.
        LEAVE.
     end.
end.

procedure retorna-ultimo-custo:
    def var vdata as date.
    
    vdata = date(month(tt-movim.datexp),01,year(tt-movim.datexp)).
     
    for each mvcusto where
             mvcusto.procod = tt-movim.procod and
             mvcusto.dativig >= vdata /*and
             mvcusto.dativig <= movim.datexp*/
             :
        delete mvcusto.
    end.
    run /admcom/progr/calctom-pro.p(input tt-movim.procod,
                                    input vdata,
                                    input today,
                                    input "REPROCESSAMENTO").
                          
    find last mvcusto where mvcusto.procod = tt-movim.procod no-lock no-error.
    if avail mvcusto
    then do:
        for each estoq where estoq.procod = mvcusto.procod:
            estoq.estcusto = dec(acha("VALPRODU",mvcusto.char2)).
        end.    
    end.
end procedure.

procedure deleta-registros-xml:
    def input parameter p-chave as char.
    find a01_infnfe where a01_infnfe.chave = p-chave no-error.
    if avail a01_infnfe
    then do:

        for each B01_IdeNFe where B01_IdeNFe.chave = a01_infnfe.chave: 
            delete B01_IdeNFe.
        end.    
        for each c01_emit where c01_emit.chave = a01_infnfe.chave:
            delete c01_emit.
        end. 
        for each e01_dest where e01_dest.chave = a01_infnfe.chave:
            delete e01_dest.
        end. 
        for each i01_prod where i01_prod.chave = a01_infnfe.chave:
            for each n01_icms where n01_icms.chave = a01_infnfe.chave and
                                n01_icms.nitem = i01_prod.nitem
                                :
                delete n01_icms.
            end.
            for each o01_ipi where o01_ipi.chave = a01_infnfe.chave and
                               o01_ipi.nitem = i01_prod.nitem 
                               :
                delete o01_ipi.                    
            end.
            for each q01_pis where q01_pis.chave = a01_infnfe.chave and
                               q01_pis.nitem = i01_prod.nitem 
                               :
                delete q01_pis.                   
            end.
            for each s01_cofins where s01_cofins.chave = a01_infnfe.chave and
                                  s01_cofins.nitem = i01_prod.nitem 
                                  :
                delete s01_cofins.                      
            end.
        end.
        for each w01_total where w01_total.chave = a01_infnfe.chave:
            delete w01_total.
        end.    
    
        for each x01_transp where x01_transp.chave = a01_infnfe.chave:
            delete x01_transp.
        end.
        for each y01_cobr where y01_cobr.chave = a01_infnfe.chave:
            delete y01_cobr.
        end.
    end.

end procedure.