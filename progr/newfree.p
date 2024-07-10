{admcab.i}

def var vetb like estab.etbcod.
def var v10 like plani.platot.
def var v15 like plani.platot.
def var v20 like plani.platot.
def var v25 like plani.platot.
def var vmes as char format "x(09)" extent 12.
def var vext1 as char format "x(40)".
def var vext2 as char format "x(40)".
def var vcomis as int.
def buffer bfree for free.
def var totqtd like free.fresal.
def var totpre like free.fresal.
def var x as i.
def var xx as i.
def var xxx as i.
def var vcre as int.
def var vpag as dec.
def var vetbi like plani.etbcod.
def var vetbf like plani.etbcod.
def var vdti like plani.pladat initial today.
def var vdtf like plani.pladat initial today.
def var totfil as int.
def var vcheque as int format ">>>>>>9".
def var varquivo as char.
def var vcont as int.

def temp-table wf-ven
    field etbcod like estab.etbcod
    field vencod like plani.vencod
    field qtd    like movim.movqtm
    field comis as dec
    field cheque as int.

def buffer bwf-ven for wf-ven.    
def var valpc as dec.
def var valpb as dec.
def var totcom as dec.
repeat:
    
    vmes[1]  = "Janeiro".
    vmes[2]  = "Fevereiro".
    vmes[3]  = "Marco".
    vmes[4]  = "Abril".
    vmes[5]  = "Maio".
    vmes[6]  = "Junho".
    vmes[7]  = "Julho".
    vmes[8]  = "Agosto".
    vmes[9]  = "Setembro".
    vmes[10] = "Outubro".
    vmes[11] = "Novembro".
    vmes[12] = "Dezembro".


    for each wf-ven:
        delete wf-ven.
    end.
    
    update vetbi label "Filial"  colon 18
           vetbf label "Filial" with frame f1 side-label width 80.

    update vdti label "Data Inicial" colon 18
           vdtf label "Data Final" with frame f1.

    update valpc label "Valor por unidade"
           valpb label "Valor por unidade PLANO BIS"
        with frame f1.
    if valpc = 0 and valpb = 0
    then do:
        message color red/with
        "Favor informar o Valor por unidade."
        view-as alert-box
        . undo.
    end.
    for each produ where fabcod = 5027 no-lock:
        if produ.procod = 469665
        then next.
        
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:

            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                                no-lock no-error.
                if not avail plani
                then next.
                find first wf-ven where wf-ven.etbcod = movim.etbcod and
                                        wf-ven.vencod = plani.vencod no-error.
                if not avail wf-ven
                then do:
                    create wf-ven.
                    assign wf-ven.etbcod = plani.etbcod
                           wf-ven.vencod = plani.vencod.
                end.
                
                wf-ven.qtd = wf-ven.qtd + movim.movqtm.
                
                find func where func.funcod = wf-ven.vencod and
                        func.etbcod = wf-ven.etbcod no-lock NO-ERROR.
                if not avail func
                then next.
            
                if func.funcod = 99
                then wf-ven.comis = wf-ven.comis +
                                    ((movim.movqtm / 300) * 10).
                else if (plani.pedcod <> 89 and
                        plani.pedcod <> 90 and
                        plani.pedcod <> 91) or
                        valpb = 0
                     then wf-ven.comis = wf-ven.comis + (movim.movqtm * valpc).
                     else wf-ven.comis = wf-ven.comis + (movim.movqtm * valpb).
                     
                /*if movim.movdat >= 04/27/2005 and
                   movim.movdat <= 05/31/2005
                then do:   
                    if movim.procod = 471934 or
                       movim.procod = 471924 or 
                       movim.procod = 471735 or
                       movim.procod = 471733 or
                       movim.procod = 473257 or
                       movim.procod = 473258 or
                       movim.procod = 471875 or
                       movim.procod = 471876 or
                       movim.procod = 473259 
                    then wf-ven.qtd = wf-ven.qtd + (movim.movqtm * 3).
                    else if movim.procod = 471938 or
                            movim.procod = 471939 or  
                            movim.procod = 471935 or 
                            movim.procod = 471929 or 
                            movim.procod = 471923 or 
                            movim.procod = 471919 or 
                            movim.procod = 471649 or 
                            movim.procod = 471650 or 
                            movim.procod = 467832 or 
                            movim.procod = 467828 or 
                            movim.procod = 467834 or 
                            movim.procod = 473256 or 
                            movim.procod = 473250 or 
                            movim.procod = 473251
                         then wf-ven.qtd = wf-ven.qtd + (movim.movqtm * 2).
                         else wf-ven.qtd = wf-ven.qtd + movim.movqtm.
                end.
                else wf-ven.qtd = wf-ven.qtd + movim.movqtm.
                */
                
                display plani.datexp format "99/99/9999"
                        movim.procod 
                        plani.etbcod
                        plani.vencod 
                        plani.numero format ">>>>>>>>9"
                        plani.serie with 1 down
                        frame f111
                        no-box color message .  pause 0. 
            end.
        end.
    end.

    hide frame f111.
    
    for each wf-ven break by wf-ven.etbcod:
    
        totfil = totfil + wf-ven.qtd.
        totcom = totcom + wf-ven.comis.
 
        if last-of(wf-ven.etbcod)
        then do: 
            create bwf-ven.
            assign bwf-ven.etbcod = wf-ven.etbcod 
                   bwf-ven.vencod = 99
                   bwf-ven.qtd    = totfil
                   bwf-ven.comis  = totcom * .25.
            totfil = 0.
            totcom = 0.
        end.    
    end. 
    
    
    display " V E N D A S    D E    P E C A S     N E W  F R E E "
                with frame f-cc side-label row 7 no-box centered.

    for each wf-ven break by wf-ven.etbcod
                          by wf-ven.vencod:
        
        if first-of(wf-ven.etbcod)
        then assign v10 = 0
                    v15 = 0
                    v20 = 0
                    v25 = 0.
             
        find func where func.funcod = wf-ven.vencod and
                        func.etbcod = wf-ven.etbcod no-lock NO-ERROR.
        if not avail func
        then next.

        /***********    
        if func.funcod = 99
        then vcomis = ((wf-ven.qtd / 300) * 10).
        else vcomis = wf-ven.qtd * valpc /*.42*/.
        /** vcomis = ((wf-ven.qtd / 75) * 10) **/
        *****************/
        vcomis = wf-ven.comis.
        if vcomis < 1
        then do:
            delete wf-ven.
            next.
        end.
        
        
        disp wf-ven.etbcod
             wf-ven.vencod
             func.funnom when avail func format "x(15)"
             wf-ven.qtd(total) column-label "Pecas"
             vcomis(total) 
                    column-label "Premio" format ">>,>>9.99"
                    with frame f3 down no-box
                        color white/red centered.

    end.    
    
    message "Emitir Listagem" update sresp.
    if sresp
    then do:
        update vcheque label "Numero do Cheque" 
                with frame f-cheque side-label centered.
        
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/fre" + string(time).
        else varquivo = "l:\relat\fre" +
                        string(day(vdti)) + string(month(vdti)).

        {mdad.i 
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"  
            &Cond-Var  = "160"  
            &Page-Line = "66" 
            &Nom-Rel   = ""newfree"" 
            &Nom-Sis   = """SISTEMA FINANCEIRO""" 
            &Tit-Rel   = """LISTAGEM DE CHEQUE NEW FREE "" + 
                         "" PERIODO "" + string(vdti,""99/99/9999"") 
                       + "" ATE "" +  string(vdtf,""99/99/9999"")" 
            &Width     = "160" 
            &Form      = "frame f-cabcab"}
        

        for each wf-ven break by wf-ven.etbcod 
                              by wf-ven.vencod:
            
            
            if first-of(wf-ven.etbcod)
            then assign v10 = 0 
                        v15 = 0 
                        v20 = 0 
                        v25 = 0.
                        
            find func where func.funcod = wf-ven.vencod and
                            func.etbcod = wf-ven.etbcod no-lock no-error.
            if not avail func
            then next.
          
            /***********
            if func.funcod = 99
            then vcomis = ((wf-ven.qtd / 300) * 10).
            else vcomis = wf-ven.qtd * valpc /*.42*/.
            /** vcomis = ((wf-ven.qtd / 75) * 10) **/
            ************/
            vcomis = wf-ven.comis.
            disp wf-ven.etbcod
                 wf-ven.vencod
                 func.funnom when avail func format "x(15)"
                 wf-ven.qtd(total by wf-ven.etbcod) column-label "Pecas"
                 vcomis(total by wf-ven.etbcod) column-label "Premio" 
                                                    format ">>>,>>9.99"
                 vcheque column-label "Cheque" format ">>>>>>9"
                              with frame f4 down width 200.

            wf-ven.cheque = vcheque.
            vcheque = vcheque + 1.
            
        end.    
            
        output close.  

        if opsys = "UNIX"
        then run visurel.p (input varquivo, input "").
        else {mrod.i}

    end.
    message "Emitir Planilha" update sresp.
    if sresp
    then do:
        update vcheque label "Numero do Cheque" 
                with frame f-cheque side-label centered.
        
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/plafre" + string(time).
        else varquivo = "l:\relat\plafre" + 
                        string(day(vdti)) +
                        string(month(vdti)).
   
        do vetb = vetbi to vetbf:         
        
        
            find first wf-ven where wf-ven.etbcod = vetb no-error.
            if not avail wf-ven
            then next.
            
            {mdad.i
                &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "160" 
                &Page-Line = "66" 
                &Nom-Rel   = ""newfree"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                &Tit-Rel   = """LISTAGEM DE COMISSAO NEW FREE "" + 
                    "" PERIODO "" + string(vdti,""99/99/9999"") + "" ATE "" + 
                    string(vdtf,""99/99/9999"")" 
                &Width     = "160" 
                &Form      = "frame f-cabcab2"}
        
            for each wf-ven where wf-ven.etbcod = vetb
                                  break by wf-ven.etbcod
                                        by wf-ven.vencod:
            
            
                if first-of(wf-ven.etbcod)
                then assign v10 = 0 
                            v15 = 0 
                            v20 = 0 
                            v25 = 0.
                        
                find func where func.funcod = wf-ven.vencod and
                                func.etbcod = wf-ven.etbcod no-lock no-error.
                if not avail func
                then next.
          
                /*************
                if func.funcod = 99
                then vcomis = ((wf-ven.qtd / 300) * 10).
                else vcomis = wf-ven.qtd * valpc /*.42*/.
                /** vcomis = ((wf-ven.qtd / 75) * 10) **/
                **************/
                vcomis = wf-ven.comis.
                disp wf-ven.etbcod
                     wf-ven.vencod
                     func.funnom when avail func format "x(15)"
                     wf-ven.qtd(total by wf-ven.etbcod) column-label "Pecas"
                     vcomis(total by wf-ven.etbcod) column-label "Premio" 
                                                    format ">>>,>>9.99"
                     vcheque column-label "Cheque" format ">>>>>>9"
                              with frame f5 down width 200.

                wf-ven.cheque = vcheque.
                vcheque = vcheque + 1.
            
            end.    
            output close. 

            if opsys = "UNIX"
            then run visurel.p (input varquivo, input "").
            else {mrod.i}
        
        end.
    
    end.
    
end.
