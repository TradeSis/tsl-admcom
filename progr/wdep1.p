{admcab.i}

def var vdatmov  like depban.datmov.
def var vvaldep  like depban.valdep.
def var vdephora like depban.dephora.
def var vbancod  like depban.bancod.
def var vetbcod  like estab.etbcod.
def var vdatexp  like plani.datexp format "99/99/9999".
def var envelope like depban.dephora format "99999999".
def var vok  as log.
def var vtotconf like plani.platot.
def var vtot     like plani.platot.
def var vdep as char format "x(01)".

def shared var vdata   as date format "99/99/9999".

def buffer bdepban for depban.
def var vsenha as char format "x(08)".
def buffer bdeposito for deposito.
def var vaster as char.

def shared temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999"
    field valdep    like depban.valdep 
    field datexp    like depban.datexp
    index tt-arq is primary dephora asc
                            valdep asc.
def buffer btt-arq for tt-arq.

def shared temp-table tt-dep
   field  deprec      as recid
   field  Etbcod      like estab.Etbcod
   field  pladat      like plani.pladat
   field  cheque-dia  like plani.platot
   field  cheque-pre  like plani.platot
   field  pagam       like plani.platot
   field  deposito    like plani.platot
   field  situacao    as l format "Sim/Nao"
   field  altera      like deposito.depalt format "x(03)"
   field  datcon      like deposito.datcon
   field  ok          as char format "x(01)".


def var v-mar as dec.
def var vmarca          as char format "x"                          no-undo.
def temp-table wfin
    field wrec as recid.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.

def var v-ven  as dec.
def var v-con  as dec.
def var v-acr  as dec.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    if recatu1 = ?
    then
        find first tt-dep where
            true no-error.
    else
        find tt-dep where recid(tt-dep) = recatu1.
        vinicio = no.
    if not available tt-dep
    then do:
        bell.
        message "Nao existe deposito para esta filial".
        pause.
        return.
        /****
        form tt-dep
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de tt-depelecimento Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera:
                create tt-dep.
                update tt-dep.
                vinicio = yes.
        end.
        ****/
    end.
    clear frame frame-a all no-pause.
    find first wfin where wfin.wrec = recid(tt-dep) no-error.
    
    
    /*
    vdep     = "".
    vtotconf = 0.
    for each depban where depban.etbcod = tt-dep.etbcod and
                          depban.datmov = tt-dep.pladat no-lock.
                                            
        find first tt-arq where tt-arq.dephora = depban.dephora and
                                tt-arq.valdep  = depban.valdep  no-error.
        if not avail tt-arq
        then leave.
        find first bdepban where bdepban.etbcod  = depban.etbcod and
                                 bdepban.dephora = depban.dephora and
                                 recid(bdepban) <> recid(depban) 
                                        no-lock no-error.
        if avail bdepban
        then leave.

            
        vtotconf = vtotconf + depban.valdep.
    
    end.
    if vtotconf = tt-dep.deposito
    then vdep = "*".
    */                                                    
             
    
    display tt-dep.etbcod    column-label "Fl" format ">>9"
            tt-dep.deposito   column-label "Deposito" format ">>,>>9.99"
            tt-dep.ok column-label "D"
            tt-dep.cheque-dia column-label "Cheq Dia" format ">>,>>9.99"
            tt-dep.cheque-pre column-label "Cheq Pre" format ">>,>>9.99" 
            tt-dep.pagam      column-label "Pagamento" format ">>,>>9.99"
            tt-dep.situacao   column-label "Conf."
            tt-dep.altera     column-label "Alt."
            tt-dep.datcon     column-label "Dt.Conf"
                with frame frame-a 12 down centered color white/red.

    recatu1 = recid(tt-dep).
    repeat:
        find next tt-dep where
                true.
        if not available tt-dep
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down with frame frame-a.
        /*
        
        vdep     = "".
        vtotconf = 0.
        for each depban where depban.etbcod = tt-dep.etbcod and
                              depban.datmov = tt-dep.pladat no-lock.
                                            
                                                
            find first tt-arq where tt-arq.dephora = depban.dephora and
                                    tt-arq.valdep  = depban.valdep  no-error.
            if not avail tt-arq
            then leave.
            find first bdepban where bdepban.etbcod  = depban.etbcod and
                                     bdepban.dephora = depban.dephora and
                                     recid(bdepban) <> recid(depban) 
                                        no-lock no-error.
            if avail bdepban
            then leave.
            
            vtotconf = vtotconf + depban.valdep.
    
        end.
        if vtotconf = tt-dep.deposito
        then vdep = "*".
        
        
        */
        
        display tt-dep.etbcod    
                tt-dep.deposito  
                tt-dep.ok
                tt-dep.cheque-dia
                tt-dep.cheque-pre
                tt-dep.pagam     
                tt-dep.situacao 
                tt-dep.altera
                tt-dep.datcon
                    with frame frame-a 12 down centered color white/red.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-dep where recid(tt-dep) = recatu1.

        choose field tt-dep.etbcod
            go-on(cursor-down cursor-up
                  I i A a D d E e
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-dep where
                    true no-error.
                if not avail tt-dep
                then leave.
                recatu2 = recid(tt-dep).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-dep where
                    true no-error.
                if not avail tt-dep
                then leave.
                recatu1 = recid(tt-dep).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-dep where
                true no-error.
            if not avail tt-dep
            then next.
            color display white/red
                tt-dep.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-dep where
                true no-error.
            if not avail tt-dep
            then next.
            color display white/red
                tt-dep.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
            display tt-dep.etbcod  colon 10  column-label "Fl" format ">>9"
                tt-dep.deposito   column-label "Deposito" format ">>,>>9.99"
                tt-dep.cheque-dia column-label "Cheq Dia" format ">>,>>9.99"
                tt-dep.cheque-pre column-label "Cheq Pre" format ">>,>>9.99" 
            /* tt-dep.cheque-glo column-label "Cheq Glo" format ">>,>>9.99" */  
                tt-dep.pagam      column-label "Pagamento" format ">>,>>9.99"
                tt-dep.situacao   column-label "Conf."
                tt-dep.altera     column-label "Alterado" 
                with frame frame-aaa 1 down row 5 centered color white/red
                overlay no-box width 80.
            pause 0.
            disp "" format "x(80)" with frame ff 1 down no-box no-label
            color wite/red.
            pause 0.
            sresp = yes.
            message "Conferir os Depositos ? " update sresp. 
            if sresp
            then do:
                
                run mandep01.p ( tt-dep.etbcod, tt-dep.pladat ).
                
                /***************************
               for each depban where depban.etbcod = tt-dep.etbcod and
                                     depban.datmov = tt-dep.pladat no-lock:
                    vaster = " ".
                    find first tt-arq where 
                               tt-arq.dephora = depban.dephora and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if avail tt-arq
                    then do:
                        find first 
                            bdepban where bdepban.etbcod  = depban.etbcod and
                                          bdepban.dephora = depban.dephora and
                                          recid(bdepban) <> recid(depban)
                                           no-lock no-error.
                        if avail bdepban
                        then vaster = " " + 
                            string(bdepban.datmov,"99/99/9999") +
                                                " - #".
                        else vaster = "              *". 
                    end.
                    
                    
                    disp 
                         vaster format "x(20)" no-label
                         depban.etbcod
                         depban.bancod
                         depban.dephora format "9999999" column-label "Envelope"
                         depban.valdep (total)
                         depban.datmov
                    with down frame fff3 centered 
                         row 11 color white/cyan overlay.                      
                end.
                ***************/
            end.                          
            
            hide frame frame-a no-pause.
            
            
            vok = no.
            vtot = 0.
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat no-lock:
                vtot = vtot + depban.valdep.
            end.    
            if vtot = tt-dep.deposito
            then vok = yes.
            
            if tt-dep.situacao
            then do:
                message "Movimento ja confirmado".
                undo, retry.
            end.
            
            
            if vok 
            then update tt-dep.situacao with frame frame-a.
            
            update tt-dep.altera with frame frame-a.
                         
            find deposito where recid(deposito) = tt-dep.deprec no-error.
            
            do transaction:
                assign deposito.depsit = tt-dep.situacao.
            end.
            
            
            if deposito.depalt <> "SIM"
            then do transaction:
                
                vsenha = "".
                update vsenha label "Senha" 
                        blank with frame f-senha side-label 
                            centered row 15 overlay.
                
                hide frame f-senha no-pause.
                if vsenha <> "443212" and
                   vsenha <> "DAC"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            


                update tt-dep.deposito  
                       tt-dep.cheque-dia
                       tt-dep.cheque-pre
                   /*  tt-dep.cheque-glo */
                       tt-dep.pagam with frame frame-a.
                assign 
                       deposito.depdep = tt-dep.deposito  
                       deposito.chedia = tt-dep.cheque-dia
                       deposito.chedre = tt-dep.cheque-pre
                  /*   deposito.cheglo = tt-dep.cheque-glo */
                       deposito.deppag = tt-dep.pagam
                       deposito.depalt = "SIM".
                view frame frame-a.

            end.

            do transaction:
                assign deposito.depsit = tt-dep.situacao.
                if tt-dep.situacao 
                then deposito.datcon = today.
            end.
            
            view frame frame-a .
        end.
        
        /***
        if keyfunction (lastkey) = "i" or
           keyfunction (lastkey) = "I"
        then do transaction:
            
            create depban. 
            update depban.etbcod 
                   depban.bancod 
                   depban.dephora format "9999999" column-label "Envelope"
                   depban.valdep
                   depban.datmov  
                        with frame f-inclu 2 column
                            centered overlay side-label.
                     
            hide frame f-inclu no-pause.

        end.    
        
        if keyfunction (lastkey) = "D" or
           keyfunction (lastkey) = "d"
        then do transaction:
            
            create deposito.
            assign deposito.datmov = tt-dep.pladat
                   deposito.depalt = "SIM".
            update deposito.etbcod label "Filial"
                   deposito.datmov 
                   deposito.chedia 
                   deposito.chedre 
                   deposito.cheglo 
                   deposito.deppag 
                   deposito.depdep 
                   deposito.depsit  label "Conf."
                   deposito.depalt  format "x(03)"
                        with frame f-inclu2 2 column
                            centered overlay side-label.
            if deposito.depsit 
            then deposito.datcon = today.
            hide frame f-inclu2 no-pause.
            return. 
        end.    

         
        if keyfunction (lastkey) = "A" or
           keyfunction (lastkey) = "a"

        then do transaction:
            
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat:

                
                assign vetbcod = depban.etbcod
                       vbancod = depban.bancod
                       vdephora = depban.dephora
                       vvaldep = depban.valdep
                       vdatmov = depban.datmov.
                
                update vetbcod 
                       vbancod 
                       vdephora format "9999999" column-label "Envelope"
                       vvaldep
                       vdatmov 
                            with frame f-alt down centered.
                
                find bdepban where bdepban.etbcod  = vetbcod  and
                                   bdepban.dephora = vdephora and
                                   bdepban.datexp  = depban.datexp and
                                   bdepban.datmov  <> depban.datmov
                                        no-lock no-error.
                if avail bdepban
                then do:
                    message "Deposito ja incluido".
                    display bdepban.
                    pause.
                    undo, retry.
                end.    
                else do:
                   
                    find bkpdep where bkpdep.etbcod  = depban.etbcod and
                                      bkpdep.datexp  = depban.datexp and
                                      bkpdep.dephora = depban.dephora 
                                            no-error.
                    if not avail bkpdep
                    then do:
                        create bkpdep. 
                        assign bkpdep.etbcod  = depban.etbcod
                               bkpdep.datexp  = depban.datexp
                               bkpdep.dephora = depban.dephora.
                    end.

                    
                    assign depban.etbcod = vetbcod 
                           depban.bancod = vbancod
                           depban.dephora = vdephora
                           depban.valdep = vvaldep
                           depban.datmov = vdatmov.
                

                end.
                                   
            end.         
            
            hide frame f-alt no-pause.
            
        
        end.    
         
        if keyfunction (lastkey) = "E" or
           keyfunction (lastkey) = "e"

        then do transaction:
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat:

               display depban.etbcod 
                       depban.bancod 
                       depban.dephora format "99999999" 
                            column-label "Envelope"
                       depban.valdep
                       depban.datmov 
                       depban.datexp column-label "Data Inf."
                                with frame f-con centered 7 down.
     
            end.         
            
            envelope = 0.

            update vetbcod  label "Loja"
                   vdatexp  label "Data Inf."
                   envelope label "Envelope" with frame f-exc side-label 
                       centered color message row 20 no-box.
     
            find first bdepban where bdepban.etbcod  = vetbcod and
                                     bdepban.datexp  = vdatexp and
                                     bdepban.dephora = envelope no-error.
            if avail bdepban
            then do:
                message "Deseja excluir deposito" update sresp.
                if sresp
                then do:
                    find bkpdep where bkpdep.etbcod  = bdepban.etbcod and
                                      bkpdep.datexp  = bdepban.datexp and
                                      bkpdep.dephora = bdepban.dephora 
                                            no-error.
                    if not avail bkpdep
                    then do:
                        create bkpdep. 
                        assign bkpdep.etbcod  = bdepban.etbcod
                               bkpdep.datexp  = bdepban.datexp
                               bkpdep.dephora = bdepban.dephora.
                    end.
                    delete bdepban.
                end.
            end.

                               
            
            hide frame f-con no-pause.
            
        end.    
        ******/
     
      
        
        
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.
        find first wfin where wfin.wrec = recid(tt-dep) no-error.

        
        /*
        vdep     = "".
        vtotconf = 0.
        for each depban where depban.etbcod = tt-dep.etbcod and
                              depban.datmov = tt-dep.pladat no-lock.
                                            
                                                
            find first tt-arq where tt-arq.dephora = depban.dephora and
                                    tt-arq.valdep  = depban.valdep  no-error.
            if not avail tt-arq
            then leave.
            find first bdepban where bdepban.etbcod  = depban.etbcod and
                                     bdepban.dephora = depban.dephora and
                                     recid(bdepban) <> recid(depban) 
                                           no-lock no-error.
            if avail bdepban
            then leave.

             
            
            vtotconf = vtotconf + depban.valdep.
    
        end.
        if vtotconf = tt-dep.deposito
        then vdep = "*".
        */
         
        
        display tt-dep.etbcod  
                tt-dep.deposito
                tt-dep.ok
                tt-dep.cheque-dia
                tt-dep.cheque-pre
                tt-dep.pagam     
                tt-dep.situacao 
                tt-dep.altera 
                tt-dep.datcon
                
                    with frame frame-a 12 down centered color white/red.


        recatu1 = recid(tt-dep).
   end.
end.

