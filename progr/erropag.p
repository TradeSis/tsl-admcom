{admcab.i}
def var vsit like titulo.titsit.
def temp-table tt-tit
    field clicod like clien.clicod
    field etbcod like estab.etbcod
    field titnum like titulo.titnum.
    
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
    
repeat:    
    update vdti label "Data Inicial"
           vdtf label "Data Final"
                with frame f2 side-label width 80.
     
    message "Deseja imprimir relatorio" update sresp.
    if sresp = no
    then leave.
    for each tt-tit:
        delete tt-tit.
    end.
    for each clispc where clispc.dtcanc = ?    and
                          clispc.dtneg >= vdti and
                          clispc.dtneg <= vdtf no-lock by clispc.dtneg:
        find contrato where contrato.contnum = clispc.contnum no-lock no-error.
        if not avail contrato
        then next.
        vsit = "PAG".
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE"  and
                              titulo.etbcod = contrato.etbcod          and
                              titulo.clifor = clispc.clicod            and
                              titulo.titnum = string(contrato.contnum) 
                                        no-lock by titulo.titpar.

        
            if titulo.titsit = "lib"
            then vsit = titulo.titsit.
            
            if vsit = "LIB" and titulo.titsit = "PAG"
            then do:
                find first tt-tit where tt-tit.clicod = titulo.clifor and
                                        tt-tit.titnum = titulo.titnum and
                                        tt-tit.etbcod = titulo.etbcod 
                                                    no-error.
                if not avail tt-tit
                then do:
                    create tt-tit.
                    assign tt-tit.clicod = titulo.clifor
                           tt-tit.titnum = titulo.titnum
                           tt-tit.etbcod = titulo.etbcod.
                end.          
            end.
            display titulo.etbcod
                    titulo.clifor
                    titulo.titnum
                    titulo.titpar 
                    clispc.dtneg format "99/99/9999"
                        with 1 down. pause 0.
                         
        end. 
    end.
    {mdadmcab.i
            &Saida     = "printer" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""erropag""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """PAGAMENTOS COM PROBLEMA - PERIODO "" +
                            string(vdti,""99/99/9999"") +  "" "" +
                            string(vdtf,""99/99/9999"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}
            
    for each tt-tit:
        disp tt-tit.etbcod column-label "Filial"
             tt-tit.clicod column-label "Cliente"
             tt-tit.titnum column-label "Contrato"
                    with frame f1 down width 200.
    end.
    output close.
end.                    
             




              
    
 