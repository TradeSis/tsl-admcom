{admcab.i}  

def var recimp as recid.
def var fila as char format "x(20)".
   
def var vimp as char format "x(20)" 
            extent 2 initial ["Consulta","Relatorio"]. 

def temp-table tt-tipmov
    field movtdc as integer
    field movtnom as char
        index idx01 movtdc.

def var vtitdtven like titulo.titdtven.
def var vplatot as dec.

def buffer bplani for plani.
def var vcon as char.
def var vrel as char.
def var vobs as char.
def var vv as int.
def var vsp as char initial ";".
def var vopccod as integer format ">>>9".
def var vdesti  as integer format ">>>>>>>>>>>>9".
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "9999".
def var vfiltro-tipmov as log.
def var vetbcod like plani.etbcod.
def var varquivo as char.
def var varquivo1 as char.
def var varq-csv  as char.
def var p-catcod like produ.catcod.
def var vnforigem as char.
def stream str-csv .

def var vnumero-ass as int format ">>>>>>>>9".
def var vicmsst-ass as dec.
repeat:
    vrel = "".
    vcon = "".
    
    empty temp-table tt-tipmov.
    
    update vetbcod label "Filial" colon 16 
        with frame f1 side-label width 80.
    if vetbcod > 0
    then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    end.
    update vmovtdc label "Tipo de Nota" colon 16
        with frame f1 side-label.
    if vmovtdc = 0
    then do:
        display "GERAL" @ tipmov.movtnom with frame f1.
        assign vfiltro-tipmov = no.
    end.    
    else do:
        find tipmov where tipmov.movtdc = vmovtdc no-lock.
        disp tipmov.movtnom no-label with frame f1.

        assign vfiltro-tipmov = yes.
        
        run p-carrega-tt-tipmov.
        
        hide frame f-tipmov.
        
    end.

    update vopccod label "CFOP" colon 16    
           vdesti label "Destinatario" colon 50
           vdti label "Data Inicial" colon 16
           vdtf label "Data Final"  colon 50
                with frame f1 side-label.
     
    def var vcatcod as int format ">>9".
        
    update vcatcod at 4 label "Departamento" 
            help "Informe o codigo do Departamento."
            with frame f1.
    if vcatcod <> 0
    then do:
        find categoria where categoria.catcod = vcatcod no-lock no-error.
        if not avail categoria
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrado para departamento" vcatcod
            view-as alert-box.
            undo.
        end.
        disp categoria.catnom no-label with frame f1.
    end.
    else disp "Todos os Departamentos" @ categoria.catnom with frame f1.

    display vimp no-label with frame fimp.
    choose field vimp with frame fimp  centered.
    if frame-index = 1
    then vv = 1.
    else vv = 2.
    
    if opsys = "unix"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
       
       varquivo = "/admcom/relat/conf" + string(time).
       
       varq-csv = "/admcom/relat/conf" + string(time) + ".csv".
                   
       output stream str-csv to value(varq-csv).
                   
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""confmov""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTO FILIAL - "" + 
                            string(estab.etbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "250"
            &Form      = "frame f-cabcab"}
           
    end.                    
    else do:
    
        assign fila = "" 
                varquivo = "l:\relat\conf" + string(time).
                

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""confmov""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """MOVIMENTO FILIAL - "" + 
                            string(estab.etbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "250"
            &Form      = "frame f-cabcab1"}
                    
    end.
    
    put stream str-csv unformatted
        "Saida Relat;T.Doc;Movimento;Estab;Emitente;Razao Social;"
        "Desti;Oper.Fiscal;Nota;"
        "Data;Valor NF;Base Icms;Val Icms;Val IPI;"
        "NroRessarcimento;ICMSSTRessarcimento" skip.
    
    for each tipmov  no-lock:
    
        if vfiltro-tipmov
        then do:
        
            find first tt-tipmov where tt-tipmov.movtdc = tipmov.movtdc
                            no-lock no-error.
            if not avail tt-tipmov
            then next.
        
        end.
        
        for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                              else true) no-lock,      
            each plani where plani.etbcod = estab.etbcod and
                             plani.emite  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock by plani.numero:
                 
            find first opcom where opcom.opcant = string(plani.hiccod)
                                no-lock no-error.
            
            find first a01_infnfe where a01_infnfe.etbcod = plani.etbcod
                                    and a01_infnfe.placod = plani.placod
                                                no-lock no-error.
            
            if vopccod > 0
                and plani.opccod <> vopccod
            then next.
            
            if vdesti > 0
                and plani.desti <> vdesti
            then next.

            if vcatcod <> 0
            then do:
                p-catcod = 0.
                run pla-depto.
                if p-catcod <> vcatcod then next.
            end.

            vnumero-ass = 0.
            vicmsst-ass = 0.
            find first bplani where 
                       bplani.movtdc = 27 and
                       bplani.desti = plani.desti and
                       bplani.pladat = plani.pladat and
                       bplani.notass = plani.numero
                       no-lock no-error.
            if avail bplani
            then assign
                    vnumero-ass = bplani.numero
                    vicmsst-ass = bplani.platot
                    .
            
            /*****
            put stream str-csv unformatted
                "1"
                vsp
                plani.movtdc
                vsp
                tipmov.movtnom
                vsp
                plani.etbcod
                vsp
                plani.emite
                vsp
                /*Razão Social do Fornecedor*/
                vsp
                plani.desti
                vsp
                plani.opccod
                vsp
                plani.numero
                vsp
                plani.datexp
                vsp
                plani.platot
                vsp
                plani.bicms
                vsp
                plani.icms
                vsp
                plani.ipi
                vsp
                vnumero-ass
                vsp
                vicmsst-ass
                skip.
            *****/
                
            find opcom where opcom.opccod = string(plani.opccod)
             no-lock no-error. 
            
            vtitdtven = ?  .
            vplatot = 0.
            vnforigem = "".
            
            if tipmov.movtdc = 13
            then do:
                find first forne where forne.forcod = plani.desti no-lock
                            no-error.
                vplatot = 0.
                vnforigem = entry(1,plani.notobs[1],",").
                if vnforigem <> "" and num-entries(vnforigem,":") = 2
                then do:
                vnforigem = trim(entry(2,vnforigem,":")).
                find first bplani where bplani.etbcod = plani.emite and
                                        bplani.emite  = plani.desti and
                                        bplani.numero = int(vnforigem)
                                        no-lock no-error.
                if avail bplani
                then vplatot = bplani.platot.
                                            
                find first titulo where
                     titulo.empcod = 19 and
                     titulo.titnat = yes and
                     titulo.modcod = "DUP" and
                     titulo.etbcod = plani.emite and
                     titulo.clifor = plani.desti and
                     titulo.titnum = vnforigem 
                     no-lock no-error.
                if avail titulo
                then assign
                        vtitdtven = titulo.titdtven
                        vobs = titulo.titobs[1] .
                end.   
                else vnforigem = "".  
            end.
            disp plani.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 opcom.opccod when avail opcom
                 plani.numero format ">>>>>>>9"
                 plani.emite column-label "Emit"
                 plani.desti format ">>>>>>>>99"
                 forne.fornom when avail forne format "x(20)"
                 plani.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot format ">>>,>>>,>>9.99" (total)
                 plani.bicms(total) 
                 plani.icms(total)
                 plani.ipi (total)
                 vnumero-ass column-label "NroRessar"
                 vicmsst-ass(total) column-label  "ICMSST"
                 a01_infnfe.situacao when avail a01_infnfe format "x(15)"
                                        label "Sit.NFe"  
                 /*entry(1,plani.notobs[1],",") when plani.movtdc = 13 
                    format "x(25)"*/
                 vnforigem when plani.movtdc = 13
                            format "x(10)" column-label "NFOri"
                 vplatot   when plani.movtdc = 13
                            column-label "TotNFOri"
                 vtitdtven when plani.movtdc = 13
                                column-label "Vencimento"
                 vobs      when plani.movtdc = 13 format "x(50)"
                  with frame f2 down width 290.
        end.
 
        for each nottra where nottra.desti  = estab.etbcod  and
                              nottra.movtdc = tipmov.movtdc and
                              nottra.datexp >= vdti         and
                              nottra.datexp <= vdtf no-lock:
            
            find plani where plani.etbcod = nottra.etbcod and
                             plani.emite  = nottra.etbcod and
                             plani.movtdc = nottra.movtdc and
                             plani.serie  = nottra.serie  and
                             plani.numero = nottra.numero no-lock no-error.
            
            if not avail plani
            then next.

            if vopccod > 0
                and plani.opccod <> vopccod
            then next.

            if vdesti > 0
                and plani.desti <> vdesti
            then next.
            
            if vcatcod <> 0
            then do:
                p-catcod = 0.
                run pla-depto.
                if p-catcod <> vcatcod then next.
            end.

            find first a01_infnfe where a01_infnfe.etbcod = plani.etbcod
                                    and a01_infnfe.placod = plani.placod
                                       no-lock no-error.
            /**                                    
            put stream str-csv unformatted
                "2"
                vsp
                nottra.movtdc
                vsp
                tipmov.movtnom
                vsp
                plani.etbcod
                vsp
                plani.emite
                vsp
                /*Razão Social do Fornecedor*/
                vsp
                nottra.desti
                vsp
                plani.opccod
                vsp
                plani.numero
                vsp
                nottra.datexp
                vsp
                plani.platot
                vsp
                plani.bicms
                vsp
                plani.icms
                vsp
                plani.ipi
                vsp
                skip.
            **/ 
            
            
            disp nottra.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 nottra.numero
                 nottra.etbcod
                 nottra.desti format ">>>>>>>>99"
                 nottra.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot format ">>>,>>>,>>9.99" (total)
                 a01_infnfe.situacao when avail a01_infnfe format "x(15)"
                                        label "Sit.NFe" at 130
                                        
                        with frame f3 down width 200.
        
        end.
        
        /*Ignorar filial 1 para ignorar tb notas de venda para cliente a vista*/
        if tipmov.movtdc <> 6  
        then
        for each plani where plani.desti  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock:
            if tipmov.movtdc = 5 and
               estab.etbcod = 1
            then next. 

            if vopccod > 0
                and plani.opccod <> vopccod
            then next.

            if vdesti > 0
                and plani.desti <> vdesti
            then next.

            if vcatcod <> 0
            then do:
                p-catcod = 0.
                run pla-depto.
                if p-catcod <> vcatcod then next.
            end.

            find first a01_infnfe where a01_infnfe.etbcod = plani.etbcod
                                    and a01_infnfe.placod = plani.placod
                                               no-lock no-error.
            /*
            if plani.movtdc = 6
            then next.
            
            if plani.movtdc = 5
            then next.
            */
            
            if plani.movtdc = 4
            then find forne where forne.forcod = plani.emite no-lock no-error.
            
            put stream str-csv unformatted
                "3"
                vsp
                plani.movtdc
                vsp
                tipmov.movtnom
                vsp
                plani.etbcod
                vsp
                plani.emite
                vsp.
            
            if avail forne
            then put stream str-csv unformatted
                    forne.forfant.
            /**        
            put stream str-csv unformatted
                vsp
                plani.desti
                vsp
                plani.opccod
                vsp
                plani.numero
                vsp
                plani.datexp
                vsp
                plani.platot
                vsp
                plani.bicms
                vsp
                plani.icms
                vsp
                plani.ipi
                vsp
                skip.
            **/
            disp plani.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 plani.numero format ">>>>>>>>>9"
                 plani.emite
                 forne.forfant format "X(20)" when avail forne
                 plani.desti format ">>>>>>>>99"
                 plani.datexp format "99/99/9999" column-label "Data Mov."
                 plani.platot format ">>>,>>>,>>9.99" (total)
                 a01_infnfe.situacao when avail a01_infnfe format "x(15)"
                                        label "Sit.NFe" at 130
                        with frame f4 down width 200.

            if plani.movtdc = 4
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc no-lock:
                    find produ where produ.procod = movim.procod no-lock. 
                                    
                    if vcatcod <> 0 and
                       vcatcod <> produ.catcod
                    then next.
                       
                    display movim.procod
                            produ.pronom
                            movim.movqtm
                            movim.movpc
                                with frame f5 down width 200.
                end.                 
                            
            
            end.
                 
        end.
        

    end.
    
    output stream str-csv close.
    output close.

    if opsys = "UNIX"
    then do:
    
        /*
        vcon = "more " + string(varquivo).
        vrel = "lpr "  + string(fila) + " " + string(varquivo).
       
        if vv = 1 
        then os-command value(vcon). 
        else os-command value(vrel).
        */
        
       /* Message "Arquivo Excel gerado em: "
                varq-csv  skip(1)
                "Tecle enter para visualizar o relatório."
                 view-as alert-box.
        
        run visurel.p (input varq-csv, input "").*/
        
        run visurel.p (input varquivo, input "").
        
        sresp = no.
        message "Deseja enviar a impressora ?" update sresp.
        if sresp
        then do:
        /*
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    
          */
        os-command silent lpr value(fila + " " + varquivo).
        end.

    
    end.
                
    else do:
        {mrod.i}
    end.
end.


procedure pla-depto:
    for each movim where movim.etbcod = plani.etbcod and
                           movim.placod = plani.placod and
                           movim.movtdc = plani.movtdc
                           no-lock.
        find first produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        
        if produ.catcod = vcatcod
        then do:
            p-catcod = produ.catcod.
            leave.
        end.
    end.            
end procedure.

procedure p-carrega-tt-tipmov:

    find first tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    
    if avail tipmov
    then do:
    
        create tt-tipmov.
        assign tt-tipmov.movtdc = vmovtdc
               tt-tipmov.movtnom = tipmov.movtnom.
               
        assign vmovtdc = 0.       
        
    end.
    
    repeat on error undo, leave:
              
        for each tt-tipmov.
        
            display tt-tipmov.movtdc   format ">>>>9" label "Cod"
                    tt-tipmov.movtnom  format "x(25)" label "Movimento"
                            with frame f03 down centered overlay
                                title "Tipos de Movimento já Incluidos".
                    

        end.

        update vmovtdc format ">>>9" help "Pressione F4
        para continuar."
                with frame f-tipmov overlay side-labels.
        
        find first tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    
        if avail tipmov and vmovtdc > 0
        then do:

            find first tt-tipmov where tt-tipmov.movtdc = vmovtdc
                        no-lock no-error.
    
            if not avail tt-tipmov
            then do:
                        
                create tt-tipmov.
                assign tt-tipmov.movtdc = vmovtdc
                       tt-tipmov.movtnom = tipmov.movtnom.
               
                assign vmovtdc = 0.       
            
            end.
        end.
    end.

end procedure.



