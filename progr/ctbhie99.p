{admcab.i new}

def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vano    as int format "9999".
def var vok as log.
def var vqtd as dec.
def var vcusto as dec.

def var vmes-hie as int.
def var vano-hie as int.
def var sal-ant as dec.
def var hiest-hiepcf as dec.
def var hiest-hiepvf as dec.

def var vi as int.

def buffer bctbhie for ctbhie.
def var vctomed as dec.

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

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
    if vetbcod > 0
    then do:
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
    end.       
    for each produ no-lock:
        disp produ.procod label "Produto"
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
            
            /****
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
            ***/
            
            run ver-hiest.
            
            vqtd = sal-ant.
            
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
            else vctomed = hiest-hiepcf.
            
            if estoq.estcusto = ? 
            then next.
            
            if vok = no
            then next.

            find bctbhie where bctbhie.etbcod = estab.etbcod and
                              bctbhie.procod = produ.procod and
                              bctbhie.ctbmes = vmes         and
                              bctbhie.ctbano = vano no-error.
            if not avail bctbhie
            then do transaction:
                create bctbhie.
                assign bctbhie.etbcod = estab.etbcod
                       bctbhie.procod = produ.procod
                       bctbhie.ctbmes = vmes
                       bctbhie.ctbano = vano
                       bctbhie.ctbest = vqtd
                       bctbhie.ctbcus = vctomed
                       bctbhie.ctbven = hiest-hiepvf.
            end.
            else do transaction:
                assign
                    bctbhie.ctbest = vqtd
                    bctbhie.ctbven = hiest-hiepvf
                    bctbhie.ctbcus = vctomed.
            end.
        end.
    end.
end.         

procedure ver-hiest:
    assign
        vmes-hie = 0
        vano-hie = 0
        sal-ant = 0
        hiest-hiepcf = 0
        hiest-hiepvf = 0
        .
        
    def var mi as int init 0.
    
    find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hieano = vano no-lock no-error.
    if not avail hiest
    then do:
        do mi = 1 to 10:
            find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = vano - mi
                               no-lock no-error.
            if avail hiest
            then do:
                assign sal-ant = hiest.hiestf
                        vmes-hie    = hiest.hiemes
                        vano-hie    = hiest.hieano
                        hiest-hiepcf = hiest.hiepcf
                        hiest-hiepvf = hiest.hiepvf
                        vok = yes
                        .
                leave.
            end.    
        end.
    end.
    else assign sal-ant = hiest.hiestf
                vmes-hie    = hiest.hiemes
                vano-hie    = hiest.hieano
                hiest-hiepcf = hiest.hiepcf
                hiest-hiepvf = hiest.hiepvf
                vok = yes
                .
end procedure.   
