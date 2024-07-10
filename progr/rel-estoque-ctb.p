{admcab.i}

def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vano    as int format "9999".
def var vok as log.
def var vqtd as dec.
def var vcusto as dec.

def var vi as int.

def buffer bctbhie for ctbhie.
def var vctomed as dec.
def var varquivo as char.
def var varquivo-csv as char.
def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

def var por-filial as log.
def temp-table tt-inven
    field etbcod like estab.etbcod
    field procod like produ.procod format ">>>>>>>>9"
    field pronom like produ.pronom
    field qtdest as dec format "->>>,>>>9.99"
    index i1 etbcod procod.
    
form "Processando... " with frame f-dd
    row 10 centered side-label.

repeat:
    /*
    vmes = 12.
    vano = year(today) - 1.
    */
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
   
    find last ctbhie where ctbhie.etbcod = vetbcod no-lock no-error.
    if avail ctbhie
    then assign
            vmes = ctbhie.ctbmes
            vano = ctbhie.ctbano
            .

    update vmes label "MES"
           vano label "ANO" with frame f1.

    /*
    find first ctbhie where
               ctbhie.etbcod = vetbcod and
               ctbhie.ctbmes = vmes and
               ctbhie.ctbano = vano
               no-lock no-error.
    if avail ctbhie
    then do:
        bell.
        message color red/with
         "Ja existe inventario para mes " vmes " ano " vano
         view-as alert-box
         .
        undo. 
    end. 
    ***/
    por-filial = no.     
    if vetbcod = 0
    then do:
        message "Por filial?" update por-filial.
    end.          
    for each produ no-lock:
        disp produ.procod label "Produto" format ">>>>>>>>9"
                with frame f-dd 1 down no-box color message.
        pause 0.        
        
        for each estab where (if vetbcod > 0
                              then estab.etbcod = vetbcod else true)
                         no-lock:
            
            if estab.etbcod = 981 then next.
             
            disp estab.etbcod label "Filial" with frame f-dd.
            pause 0.

            vqtd = 0.
            vok = no.
            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                assign vqtd = hiest.hiestf
                       vok = yes.
            end.
            else do:
                for each tthiest: delete tthiest. end.
                
                for each hiest where hiest.etbcod = estab.etbcod 
                                 and hiest.procod = produ.procod no-lock:

                    if hiest.hieano > vano 
                    then next.
                       
                    if hiest.hiemes > vmes and
                       hiest.hieano = vano
                    then next. 
                    
                    find last tthiest where tthiest.etbcod = estab.etbcod 
                                        and tthiest.procod = produ.procod 
                                        and tthiest.hiemes = hiest.hiemes 
                                        and tthiest.hieano = hiest.hieano
                                        no-error.
                    if not avail tthiest 
                    then do:
                        create tthiest.
                        buffer-copy hiest to tthiest.
                    end.
        
                end.

                find last tthiest use-index i-ano-mes 
                                  no-lock no-error.
                if avail tthiest
                then do:
                    find hiest where hiest.etbcod = tthiest.etbcod 
                                 and hiest.procod = tthiest.procod 
                                 and hiest.hiemes = tthiest.hiemes 
                                 and hiest.hieano = tthiest.hieano 
                                 no-lock no-error.
                    if avail hiest 
                    then do: 

                        assign vqtd = hiest.hiestf 
                        vok = yes. 
                    end.
                end.
                
            end.

            if vqtd < 0
            then vqtd = 0.
            
            if vqtd = 0 then next.
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = produ.procod and
                 ctbhie.ctbano = vano and
                 ctbhie.ctbmes = vmes 
                 no-lock no-error.
            if not avail ctbhie
            then do vi = 1 to 10:
                find last ctbhie use-index ind-2 where
                     ctbhie.etbcod = 0 and
                     ctbhie.procod = produ.procod and
                     ctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail ctbhie
                then do:
                    leave.
                end.
            end.     
            if avail ctbhie and ctbhie.ctbcus <> ?
            then vctomed = ctbhie.ctbcus.
            else vctomed = hiest.hiepcf.
            
            if estoq.estcusto = ? 
            then next.
            
            if vok = no
            then next.

            find first tt-inven where
                       tt-inven.etbcod = estab.etbcod and
                       tt-inven.procod = produ.procod
                       no-error.
            if not avail tt-inven
            then do:
                create tt-inven.
                assign
                    tt-inven.etbcod = estab.etbcod
                    tt-inven.procod = produ.procod
                    tt-inven.pronom = produ.pronom
                    .
            end.
            tt-inven.qtdest = tt-inven.qtdest + vqtd. 
            find first tt-inven where
                       tt-inven.etbcod = 0 and
                       tt-inven.procod = produ.procod
                       no-error.
            if not avail tt-inven
            then do:
                create tt-inven.
                assign
                    tt-inven.etbcod = 0
                    tt-inven.procod = produ.procod
                    tt-inven.pronom = produ.pronom
                    .
            end.
            tt-inven.qtdest = tt-inven.qtdest + vqtd. 
      
        end.
    end.
    
    hide frame f-dd no-pause.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/est_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + ".txt".
    else varquivo = "l:\relat\est_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + ".txt".
            
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = """."""
        &Nom-Sis   = """."""
        &Tit-Rel   = """Filial: "" + string(vetbcod) + ""  "" +
                        "" Periodo: "" + string(vmes,""99"") +
                        ""/"" + string(vano,""9999"")"
        &Width     = "100"
        &Form      = "frame f-cab"}

    if por-filial = no and vetbcod = 0
    then do:
        for each tt-inven where tt-inven.etbcod = 0:
            disp tt-inven.procod
                 tt-inven.pronom
                 tt-inven.qtdest(total)
                 with frame f-disp down width 100.
        end.
    end.
    else if por-filial = no and vetbcod > 0
        then do:
            for each tt-inven where tt-inven.etbcod = vetbcod:
                disp tt-inven.procod
                     tt-inven.pronom
                     tt-inven.qtdest(total)
                     with frame f-disp1 down width 100.
            end.
        end.
        else if por-filial = yes and vetbcod = 0
            then do:
                for each tt-inven where tt-inven.etbcod > vetbcod:
                    disp tt-inven.etbcod
                         tt-inven.procod
                         tt-inven.pronom
                         tt-inven.qtdest(total)
                         with frame f-disp2 down width 100.
                end.
            end.

    output close. 

    varquivo-csv = "/admcom/relat/est_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + ".csv".
 
    output to value(varquivo-csv).
    put "Filial;" vetbcod ";Periodo;" string(vmes,"99") +
                            "/" + string(vano,"9999")
        skip.
        
    put "Filial;Produto;Descricao;Estoque" skip.
    
    if por-filial = no and vetbcod = 0
    then do:
        for each tt-inven where tt-inven.etbcod = 0:
            put  tt-inven.etbcod ";"
                 tt-inven.procod  ";"
                 tt-inven.pronom ";"
                 tt-inven.qtdest
                skip.
        end.
    end.
    else do:
        for each tt-inven where tt-inven.etbcod > 0:
            put  tt-inven.etbcod ";"
                 tt-inven.procod  ";"
                 tt-inven.pronom ";"
                 tt-inven.qtdest
                skip.
        end.
    end.
    output close.
    
    varquivo-csv = "L:~\relat~\est_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + ".csv".

    message color red/with
        "Arquivo CSV gerado " varquivo-csv
         view-as alert-box
         .
         
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
     
end.         
   
