{admcab.i}
def var i as i.
def var vest as char format "x(100)".
def var vfilial as dec format "->>>>>9" extent 100. 
def stream stela.
def var varquivo as char format "x(20)".
def var vqtd like movim.movqtm.
def var vcatcod like produ.catcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def temp-table tt-fabri
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom.
repeat:
    for each tt-fabri:
        delete tt-fabri.
    end.
    update vcatcod label "Departamento" with frame f1 side-label
                                                width 80.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f1.

    update vdti label "Data Inicial" colon 13
           vdtf label "Data Final" with frame f1.

    for each produ where produ.catcod = vcatcod no-lock break by produ.fabcod:
        disp "Criando Arquivo..." 
              produ.procod with frame  stela 1 down side-label centered. 
              pause 0.
        if first-of(produ.fabcod)
        then do:
            find first tt-fabri where tt-fabri.fabcod = produ.fabcod no-error.
            if not avail tt-fabri
            then do:
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                create tt-fabri.
                assign tt-fabri.fabcod  = produ.fabcod
                       tt-fabri.fabnom  = fabri.fabnom.
            end.
        end.
    end.

    hide frame stela no-pause.
    for each produ where produ.catcod = vcatcod no-lock:
        
        disp "Gerando Relatorio...." 
             produ.procod 
                    with frame f2 1 down side-label centered. pause 0.
        find first movim where movim.procod = produ.procod and
                               movim.movtdc = 5            and
                               movim.movdat >= vdti        and
                               movim.movdat <= vdtf no-lock no-error.
        if avail movim
        then do:
            find first tt-fabri where tt-fabri.fabcod = produ.fabcod no-error.
            if avail tt-fabri
            then delete tt-fabri.
        end.
    end.

        
    varquivo = "i:\admcom\relat\fab" + STRING(day(today)) +
                              STRING(month(today)) +
                string(categoria.catcod,"99").

    {mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""fabnao""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """FORNECEDORES NAO MOVIMENTADOS "" +
                           categoria.catnom + 
                          ""  PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}
    for each tt-fabri no-lock by tt-fabri.fabnom.
        vqtd = 0.
        do i = 1 to 100:
            vfilial[i] = 0.
        end.
        vest = "".
        for each produ where produ.catcod = vcatcod and
                             produ.fabcod = tt-fabri.fabcod no-lock.
            output stream stela to terminal.
                display stream stela "AGUARDE...." produ.procod with 1 down.
                pause 0.
            output stream stela close.
            for each estoq where estoq.procod = produ.procod no-lock:
                vqtd = vqtd + estoq.estatual.
                if estoq.estatual <> 0
                then 
                vfilial[estoq.etbcod] = vfilial[estoq.etbcod] + estoq.estatual. 
            end.
        end.
        do i = 1 to 100:
            if vfilial[i] <> 0
            then vest = vest + string(i,"99") + ",".  
        end.
        
        if vqtd <> 0
        then disp tt-fabri.fabcod column-label "Codigo"
                  tt-fabri.fabnom column-label "Descricao"
                  vqtd column-label "Qtd.Estoque" format "->>,>>9.99" 
                  vest column-label "Filiais" format "x(100)" 
                        with frame f-print width 200 down.
    end.

    output close.
    message "Confirma Emissao do relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").  


end.
