{admcab.i}

def temp-table tt-cli
    field clicod like clien.clicod.

def buffer bcontrato for contrato.
def var vsaldo as dec.
def var vcarteira as dec.
def var vpct as dec.
def var vok as log.
def var vqtd as int.
def var vqtdcont as int.
def var vnovacao as log format "Sim/Nao" init no.
def var vplano as int.
form vcre as log format  "Geral/Facil" label "Cliente"  at 4
     help "Informe [G]eral ou [F]acil"
     vetbcod like estab.etbcod label "Filial" at 5
     estab.etbnom no-label
     vdti as date format "99/99/9999" label "Periodo de" at 1
     vdtf as date format "99/99/9999" label "Ate"
     vcat as int  format ">>9"        label "Categoria"       at 2
     categoria.catnom no-label
     vcla as int  format ">>>>>9"     label "Classe"          at 5
     clase.clanom no-label   
     vpro as int  format ">>>>>>>>9"  label "Produto"         at 4
     produ.pronom no-label
     vplano                           label "Plano"  at 6
     vqtdcont                         label "Qtd. Contratos"
     vnovacao                         label "Novacoes?"
     with frame f1 side-label width 80.

vcre = yes.
update vcre with frame f1.

update vetbcod with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial nao cadastrada."
        view-as alert-box.
        undo.
    end.
    disp estab.etbnom with frame f1.
end.
else disp "Todas " @ estab.etbnom with frame f1
.
do on error undo:

    update vdti vdtf with frame f1.
    if vdti = ? or vdtf = ? or vdti > vdtf
    then do:
        bell.
        message color red/with
        "Periodo invalido para processamento."
        view-as alert-box.
        undo.
    end.
    do on error undo:
        update vcat with frame f1.
        if vcat > 0
        then do:
            find categoria where categoria.catcod = vcat no-lock no-error.
            if not avail categoria
            then do:
                bell.
                message color red/with
                "Categoria nao cadatrada"
                view-as alert-box.
                undo.
            end.
            disp categoria.catnom with frame f1.
        end.
        else disp "Todas " @ categoria.catnom with frame f1.  
        do on error undo:
            update vcla with frame f1.
            if vcla > 0
            then do:
                find clase where clase.clacod = vcla no-lock no-error.
                if not avail clase
                then do:
                    bell.
                    message color red/with
                    "Classe nao cadastrada."
                    view-as alert-box.
                    undo.
                end.
                disp clase.clanom with frame f1.
            end.
            else disp "Todas " @ clase.clanom with frame f1.
            do on error undo:
                update vpro with frame f1.
                if vpro > 0
                then do:
                    find produ where produ.procod = vpro no-lock no-error.
                    if not avail produ
                    then do:
                        bell.
                        message color red/with
                        "Produto nao cadatrado."
                        view-as alert-box.
                        undo.
                    end.
                    disp produ.pronom with frame f1.
                end.
                else disp "Todos " @ produ.pronom with frame f1.
            end.
        end. 
    end. 
    update vplano vqtdcont vnovacao with frame f1 .  
end. 
pause 0.
def var vdata as date.

form with frame f-disp.
def temp-table tit-etb
    field etbcod like fin.titulo.etbcod
    field valor-vs like fin.titulo.titvlcob
    field valor-vi like fin.titulo.titvlcob
    field vtot-par like fin.titulo.titpar format ">>>>>9"
    field vtot-con as int.

def temp-table tt-inadim
       field etbcod like estab.etbcod
       field catcod like categoria.catcod
       field clacod like clase.clacod
       field procod like produ.procod
       field val-vi as dec
       field val-vs as dec
       field qtdtit as int
       field qtdcon as int
       index i1 catcod clacod procod
       .
       
    if vcre = no
    then do:
    
        for each tt-cli:
            delete tt-cli.
        end.
      
      
        for each clien where clien.classe = 1 no-lock:
    
            display clien.clicod
                    clien.clinom
                    clien.datexp format "99/99/9999" with 1 down. pause 0.
    
            create tt-cli.
            assign tt-cli.clicod = clien.clicod.
        end.
    end.
    do vdata = vdti to vdtf:
        
        disp    "Processamdo AGUARDE.... >> "
                vdata with frame ff1.
        pause 0.
        if vcre 
        then do:
            for each estab where if vetbcod > 0
                        then estab.etbcod = vetbcod else true , 
                each titulo where fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = no and
                                  fin.titulo.modcod = "CRE" and
                                  fin.titulo.etbcod = estab.etbcod and
                                  fin.titulo.titdtven = vdata no-lock:

                disp fin.titulo.etbcod fin.titulo.titnum fin.titulo.titdtemi 
                        with frame ff1 1 down no-box no-label.
                pause 0.
                if vnovacao and 
                   fin.titulo.titpar < 30
                then next.    

                vqtd = 0.
                if vqtdcont > 0
                then do:
                    for each bcontrato where 
                             bcontrato.clicod = fin.titulo.clifor
                             no-lock:
                        vqtd = vqtd + 1.
                    end.   
                    if vqtd > vqtdcont
                    then next.      
                end.
                find contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.

                find first tit-etb where
                    tit-etb.etbcod = fin.titulo.etbcod no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = fin.titulo.etbcod.
                end. 
                
                find first contnf where contnf.etbcod = fin.titulo.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock no-error.

                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                        if vcat > 0 and
                           vcat <> produ.catcod
                        then next.
                        if vcla > 0 and
                           vcla <> produ.clacod
                        then next.
                        if vpro > 0 and
                           vpro <> produ.procod
                        then next.
                        vok = yes.   
                        find first tt-inadim where 
                                   tt-inadim.etbcod = fin.titulo.etbcod and 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.etbcod = fin.titulo.etbcod
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if fin.titulo.titsit = "LIB" and
                           fin.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                        tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
               
                        if fin.titulo.titsit = "LIB" and
                            fin.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + fin.titulo.titvlcob.
                        end.
                    end.
                end.
            end.
        end.
        else do:
            for each tt-cli,
                each titulo use-index iclicod where 
                                  fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = no and
                                  fin.titulo.modcod = "CRE" and
                                  fin.titulo.clifor = tt-cli.clicod and
                                  fin.titulo.titdtven = vdata no-lock:
                
                disp fin.titulo.etbcod fin.titulo.titnum fin.titulo.titdtemi 
                    with frame ff1 1 down centered row 15 no-box
                    no-label.
                pause 0.
                if vnovacao and 
                   fin.titulo.titpar < 30
                then next.  
                if vetbcod > 0 and fin.titulo.etbcod <> vetbcod
                then next.
                
                find first tit-etb where
                    tit-etb.etbcod = fin.titulo.etbcod no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = fin.titulo.etbcod.
                end.   
                tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
                if fin.titulo.titsit = "LIB" and
                   fin.titulo.titdtpag = ?
                then do:
                    tit-etb.valor-vi = tit-etb.valor-vi + fin.titulo.titvlcob.
                 
                find contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.
                    
                find first contnf where contnf.etbcod = fin.titulo.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock no-error.
                find contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.
                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                        if vcat > 0 and
                           vcat <> produ.catcod
                        then next.
                        if vcla > 0 and
                           vcla <> produ.clacod
                        then next.
                        if vpro > 0 and
                           vpro <> produ.procod
                        then next.
                        vok = yes.  
                        find first tt-inadim where 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if fin.titulo.titsit = "LIB" and
                           fin.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                        tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
               
                        if fin.titulo.titsit = "LIB" and
                        fin.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + fin.titulo.titvlcob.
                        end.
                    end.
                end.
                end.
            end.
        end.
    end.

    def var varquivo as char.
    if opsys = "UNIX"
    then  varquivo = "../relat/cartl" + string(day(today)).
    else  varquivo = "..\relat\cartw" + string(day(today)).
 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""inadin01""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE INADINPLENCIA"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    DISP WITH FRAME F1.
    vcarteira = 0. vsaldo = 0. vpct = 0.
    for each tit-etb by tit-etb.etbcod:
        find estab where estab.etbcod = tit-etb.etbcod no-lock.
        vpct = (tit-etb.valor-vi / tit-etb.valor-vs) * 100 .
        
        disp tit-etb.etbcod 
             estab.etbnom no-label
             tit-etb.valor-vs column-label "Carteira"  format ">>,>>>,>>9.99"
             tit-etb.valor-vi column-label "Saldo" format ">>,>>>,>>9.99"
             vpct format ">>>,>>9.99%"
             with frame f-disp down width 120.
        down with frame f-disp.
        vcarteira = vcarteira + tit-etb.valor-vs.
        vsaldo    = vsaldo    + tit-etb.valor-vi.
        /**
        for each tt-inadim where
                 tt-inadim.etbcod = tit-etb.etbcod
                 break by tt-inadim.catcod by tt-inadim.clacod 
                 :
            find produ where produ.procod = tt-inadim.procod
                    no-lock.
            disp tt-inadim.catcod column-label "Cat"               
                 tt-inadim.clacod column-label "Classe"
                 tt-inadim.procod column-label "Produto"
                 produ.pronom no-label   
                 /*tt-inadim.val-vi (sub-total by tt-inadim.catcod)
                    column-label "Valor" format ">>>,>>9.99" */
                 with frame f-disp.
            down with frame f-disp.
        end.        
        **/
    end.
    down(2) with frame f-disp.
    disp vcarteira @ tit-etb.valor-vs
         vsaldo    @ tit-etb.valor-vi
         (vsaldo / vcarteira) * 100   @ vpct
              with frame f-disp.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.  


 
