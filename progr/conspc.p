/* #1 ajuste impressao */
{admcab.i}   /******** novo reldep.p ***********/

def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vcan    as int.
def var vreg    as int.
def var varquivo as char.

def temp-table tt-cli no-undo
    field etbcod like estab.etbcod
    field can    as int
    field reg    as int.

def temp-table tt-con no-undo
    field tipo as char
    field clicod like clien.clicod
    field contnum like contrato.contnum
    index i1 tipo clicod contnum.
    
repeat:
    for each tt-cli:
        delete tt-cli.
    end.
    for each tt-con.
        delete tt-con.
    end.

    vcan = 0.
    vreg = 0.
    update vdti label "Data Inicial"
           vdtf label "Data Finan"
            with frame f-dat centered width 80 side-label
                        color blue/cyan.
    for each clispc where clispc.dtcan >= vdti and
                          clispc.dtcan <= vdtf no-lock:

        find contrato where contrato.contnum = clispc.contnum no-lock no-error.
        if not avail contrato
        then do:
            create tt-con.
            assign
                tt-con.tipo = "NÃO CANCELOU"
                tt-con.clicod = clispc.clicod
                tt-con.contnum = clispc.contnum.
            next.
        end.
        
        find first tt-cli where tt-cli.etbcod = contrato.etbcod no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign tt-cli.etbcod = contrato.etbcod.
        end.
        tt-cli.can = tt-cli.can + 1.
        
        vcan = vcan + 1.        
    end.

    for each clispc where clispc.dtneg >= vdti and
                          clispc.dtneg <= vdtf no-lock:
        
        find contrato where contrato.contnum = clispc.contnum no-lock no-error.
        if not avail contrato
        then do:
            create tt-con.
            assign
                tt-con.tipo = "NÃO REGISTROU"
                tt-con.clicod = clispc.clicod
                tt-con.contnum = clispc.contnum.
            next.
        end.

        find first tt-cli where tt-cli.etbcod = contrato.etbcod no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign tt-cli.etbcod = contrato.etbcod.
        end.
        tt-cli.reg = tt-cli.reg + 1.
        
        vreg = vreg + 1.            
    end.
    
    /* 
    disp vcan label "Clientes Cancelados"
         vreg label "Clientes Registrados"
            with frame f2 side-label.
            
    */        
    for each tt-cli by tt-cli.etbcod:
        disp "FILIAL" no-label 
             tt-cli.etbcod no-label 
             tt-cli.reg(total) column-label "Registrados"
             tt-cli.can(total) column-label "Cancelados" 
                with frame f3 down centered color white/black.
    end.

    for each tt-con use-index i1:
        disp tt-con.tipo      no-label                   format "x(15)"
             tt-con.clicod    column-label "Cliente"     format ">>>>>>>>>9"
             tt-con.contnum   column-label "Contrato"    format ">>>>>>>>>9"
             with frame f-prob down.
        down with frame f-prob.
    end.
    
    message "Deseja imprimir?" update sresp.
    if not sresp
    then next.

    varquivo = "/admcom/relat/conspc." + string(mtime).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""conspc""
        &Nom-Sis   = """AdmCom"""
        &Tit-Rel   = """QUANTIDADE DE CLIENTE POR PERIODO "" + string(vdti) + 
                  "" A "" + string(vdtf)"
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    for each tt-cli by tt-cli.etbcod:
        disp "FILIAL" no-label 
             tt-cli.etbcod no-label                       
             tt-cli.reg(total) column-label "Registrados" 
             tt-cli.can(total) column-label "Cancelados" 
             with frame f4 down centered color white/black.
    end.
    
    for each tt-con use-index i1:
        disp tt-con.tipo      no-label                  format "x(15)"
             tt-con.clicod    column-label "Cliente"    format ">>>>>>>>>9"
             tt-con.contnum   column-label "Contrato"   format ">>>>>>>>>9"
             with frame f-prob1 down.
        down with frame f-prob1.
    end.

    output close.
    run visurel.p(varquivo,"").
end.
