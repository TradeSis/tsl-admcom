{admcab.i}
{setbrw.i}                                                                      

def input parameter p-clase like classe.
def input parameter p-loja like classe.
def input parameter v-titscla as char.
def output parameter p-sclase like classe.

def temp-table tt-fabri
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field fabcod    like fabri.fabcod
    field clacod    like plani.placod 
    index valor1     platot desc.


def shared temp-table ttsclase 
    field platot    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.

def shared temp-table tresu
    field etbcod      like estab.etbcod
    field etbnom      like estab.etbnom
    field platot      like plani.platot
    field qtd         like movim.movqtm
    field perc-val    as dec format "->>9.99"
    field perc-qtd    as dec format "->>9.99"
    field geral       as dec.

def buffer sclase for clase.
def var v-perdia as dec.
def var v-perc as dec.

def shared temp-table ttprodu
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def buffer bttprodu for ttprodu.

def var v-titpro as char.
def var vnomabr as char.

form
    ttprodu.procod  column-label "Cod" 
    help "ENTER=Estoque  F8=Imagem  I=Imprime  P=Informacoes Filiais"
    vnomabr    format "x(25)" 
    ttprodu.qtd     format "->>9" column-label "Qtd" 
    /* v-perdev  format ">9.99" column-label "% Dev"  */
    ttprodu.pladia  format "->>>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttprodu.platot  format "->>>,>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ
        width 80
        down 
        title v-titpro.
 
def var v-perdev as dec.

form
    tt-fabri.fabcod  column-label "Cod" 
    vnomabr    format "x(17)"
    tt-fabri.qtd     format ">>>>>9" column-label "Qtd" 
    v-perdev  format ">9.99" column-label "% Dev"  
    tt-fabri.pladia  format "->>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    tt-fabri.platot  format ">,>>>,>>9.99"   column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-fabri
       /* width 80*/
        down 
        title v-titpro.


form
    ttsclase.clacod
    help "P = Informacoes Filiais"
    sclase.clanom    format "x(16)" 
    ttsclase.qtd        column-label "Qtd"   format "->>>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->>,>>>,>>9.99" 
    v-perdia         format "->>9.99" column-label "% Dia" 
    ttsclase.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc           format "->>9.99" column-label "% Acum" 
    with frame frame-a
        centered
        down 
        title v-titscla
        row 7 overlay.


def var v-titulo as char.

def var vsenha like func.senha.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.

def buffer bttsclase for ttsclase.
def buffer cttsclase for ttsclase.
def buffer bimpress     for impress.
def var vcodimp         like impress.codimp.


    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def var v-ttger as dec.
def var v-totdia as dec.
def var v-totger  as dec.
bl-princ:
repeat:
    
    v-totdia = 0.
    v-totger = 0.
    
    for each ttsclase where ttsclase.etbcod = p-loja 
                        and ttsclase.clasup = p-clase :
       assign v-totdia = v-totdia + ttsclase.pladia
              v-totger = v-totger + ttsclase.platot.
    end.  
    
    if recatu1 = ?
    then
        find first ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
    else
        find ttsclase where recid(ttsclase) = recatu1 no-lock no-error.
    vinicio = yes.
   
    if not available ttsclase
    then return.
    clear frame frame-a all no-pause.

    find first sclase where sclase.clacod = ttsclase.clacod
                no-lock no-error.
                
    assign  
        v-perc = (if ttsclase.platot > 0
                  then ttsclase.platot * 100 / v-totger
                  else 0)                        
        v-perdia = (if ttsclase.pladia > 0
                    then ttsclase.pladia * 100 / v-totdia
                    else 0).     
    
    disp ttsclase.clacod 
         sclase.clanom  when avail sclase
         ttsclase.pladia 
         v-perc 
         v-perdia 
         ttsclase.qtd 
         ttsclase.platot
         with frame frame-a
         .
 
    recatu1 = recid(ttsclase).

    hide message no-pause.
    if avail sclase then message sclase.clanom.
    
    repeat:
        find next ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
        find first sclase where 
                   sclase.clacod = ttsclase.clacod no-lock no-error.
        
        if not available ttsclase
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

        assign  
            v-perc = (if ttsclase.platot > 0
                  then ttsclase.platot * 100 / v-totger
                  else 0)                        
            v-perdia = (if ttsclase.pladia > 0
                    then ttsclase.pladia * 100 / v-totdia
                    else 0). 
        disp ttsclase.clacod 
         sclase.clanom when avail sclase
         ttsclase.pladia 
         v-perc 
         v-perdia 
         ttsclase.qtd 
         ttsclase.platot
         with frame frame-a
         .
         hide message no-pause.
         if avail sclase then message sclase.clanom.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

       
        find ttsclase where recid(ttsclase) = recatu1 no-lock no-error.
        find first sclase where 
                   sclase.clacod = ttsclase.clacod no-lock no-error.
        
        hide message no-pause.
        if avail sclase then message sclase.clanom.
        
        choose field ttsclase.clacod
            go-on(cursor-down cursor-up
                  page-down page-up
                  PF4 F4 ESC return P p).

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
                find first sclase where 
                           sclase.clacod = ttsclase.clacod no-lock
                           no-error.
        
                if not avail ttsclase
                then leave.
                recatu1 = recid(ttsclase).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
                find first sclase where 
                            sclase.clacod = ttsclase.clacod no-lock
                            no-error.
        
                if not avail ttsclase
                then leave.
                recatu1 = recid(ttsclase).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
            find first sclase where sclase.clacod = ttsclase.clacod no-lock
                        no-error.
        

            if not avail ttsclase
            then next.

            color display normal
                ttsclase.clacod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
            hide message no-pause.
            if avail sclase then message sclase.clanom.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev ttsclase where 
                   ttsclase.etbcod = p-loja and
                   ttsclase.clasup = p-clase 
                   no-lock no-error.
            find first sclase where sclase.clacod = ttsclase.clacod no-lock
                no-error.
        
            if not avail ttsclase
            then next.
            color display normal
                ttsclase.clacod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
            hide message no-pause.
            if avail sclase then message sclase.clanom.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide message no-pause.
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.

            hide message no-pause.
            p-sclase = ttsclase.clacod.

            run produ-fabcod.
            
        end.
        
        IF KEYFUNCTION(LASTKEY) = "CUT"
           or keyfunction(lastkey) = "p"
           or keyfunction(lastkey) = "P"
        THEN DO:
            for each tresu. delete tresu. end.
            find clase where clase.clacod = ttsclase.clacod no-lock no-error.
                                   
            for each cttsclase where
                     cttsclase.clacod = clase.clacod.
                find first tresu where tresu.etbcod = cttsclase.etbcod no-error.
                if not avail tresu
                then do:
                     v-ttger = 0.
                     for each bttsclase where 
                              bttsclase.etbcod = cttsclase.etbcod  and                                        bttsclase.clasup = p-clase :
                        v-ttger = v-ttger + bttsclase.platot.
                     end.          
                     create tresu.
                     assign tresu.etbcod = cttsclase.etbcod
                            tresu.qtd = cttsclase.qtd
                            tresu.platot = cttsclase.platot
                            tresu.geral = v-ttger.
                end.
            end.
              
            hide frame f-etb no-pause.
            hide frame f-sclase no-pause.
            v-titulo = ' '.
            v-titulo = string(clase.clacod) + ' - ' + clase.clanom.
                                     
            run perf_brw.p(input v-titulo).
            next bl-princ.
        END.

        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        
        assign  
            v-perc = (if ttsclase.platot > 0
                  then ttsclase.platot * 100 / v-totger
                  else 0)                        
            v-perdia = (if ttsclase.pladia > 0
                    then ttsclase.pladia * 100 / v-totdia
                    else 0). 
                        
        disp ttsclase.clacod 
         sclase.clanom when avail sclase
         ttsclase.pladia 
         v-perc 
         v-perdia 
         ttsclase.qtd 
         ttsclase.platot
         with frame frame-a.
         hide message no-pause.
         if avail sclase then message sclase.clanom.
        recatu1 = recid(ttsclase).
   end.
end.

{anset.i}

procedure produ-fabcod:
    def var v-imagem as char.
    def var vdti as date.
    def var vdtf as date.
    def var vindex as int.
    def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].
 
 
            disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay.
            choose field vfapro 
                            with frame f-esc  .

            vindex = frame-index.
                            
                         clear frame f-esc all.
                         hide frame f-esc.

                         if vindex = 1 
                         then do : 
                            l1:
                            repeat with frame f-produ:
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> 0
                                then
                                find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "PRODUTOS DA SUBCLASSE " + 
                                    /*string(clase.clanom)*/
                                    string(sclase.clacod)
                                     + " - LOJA " + 
                                    if p-loja <> 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod:
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                
                                {anbrowse.i
                                    &File   = ttprodu
                                    &CField = ttprodu.procod
                                    &color  = write/cyan
                                    &Ofield = " ttprodu.platot vnomabr
                                        ttprodu.qtd v-perc
                                        v-perdia ttprodu.pladia "
                                    &Where = "ttprodu.etbcod = p-loja and
                                              ttprodu.clacod = p-sclase "
                                    &NonCharacter = /*
                                    &AftFnd = " find first produ where 
                                       produ.procod = ttprodu.procod no-lock
                                       no-error.
                                       if avail produ
                                       then vnomabr = produ.pronom.
                                       else vnomabr = ' '.    
                                v-perc = (if ttprodu.platot > 0
                                          then ttprodu.platot * 100 / v-totger
                                          else 0).
                                v-perdia = (if ttprodu.pladia > 0
                                   then ttprodu.pladia * 100 / v-totdia
                                   else 0)."
                                   &AftSelect1 = "run convgen-est.p
                                            (input string(ttprodu.procod),
                                             input vdti, input vdtf ).
                                        next keys-loop."
                                    &otherkeys = "
                                    IF keyfunction(lastkey) = ""p""
                                    or keyfunction(lastkey) = ""P""
                                    THEN DO: 
                                   find ttprodu where
                                        recid(ttprodu) = an-seerec[frame-line]
                                        no-error.

                                   find produ where produ.procod = 
                                        ttprodu.procod no-lock no-error.

                                      hide frame f-etb no-pause.
                                      hide frame f-produ no-pause.
                                      run pro-cut-ttprodu.
                                      
                                      next l1.
                                    END.         
                                        if keyfunction(lastkey) = ""I"" or
                                           keyfunction(lastkey) = ""i""
                                        then do:
                                            run imp-pro (input ""ttprodu"",
                                                         input p-loja,
                                                         input p-sclase).
                                        end.
                                        
                                        if keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                           find ttprodu where
                                                recid(ttprodu) =
                                                an-seerec[frame-line]
                                                no-error.

                                           v-imagem = ""l:\pro_im\"" + 
                                           trim(string(ttprodu.procod)) +
                                           "".jpg"".
                                
                                           os-command silent start
                                                      value(v-imagem).
                                                               
                                           next keys-loop.   
                                        end."
                                    &LockType = "use-index valor"
                                    &Form = " frame f-produ" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l1.
                            end.
                        end.
                        else do :
                            l2:
                            repeat :
                                for each tt-fabri: delete tt-fabri. end.    
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if p-loja <> 0 
                                then
                                    find first estab where 
                                           estab.etbcod = p-loja no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "FABRICANTES DA SUBCLASSE " + 
                                    /*string(sclase.clanom)*/
                                     string(sclase.clacod) + " - LOJA " + 
                                    if p-loja <> 0
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                                
                                for each ttprodu where ttprodu.etbcod = p-loja
                                           and ttprodu.clacod = sclase.clacod:
                                    find first produ where 
                                               produ.procod = ttprodu.procod
                                               no-lock.
                                    find first tt-fabri where
                                               tt-fabri.fabcod = produ.fabcod 
                                               no-error.
                                    if not avail tt-fabri
                                    then do:
                                        create tt-fabri.
                                        tt-fabri.fabcod = produ.fabcod.
                                    end.
                                    assign
                                        tt-fabri.platot = tt-fabri.platot + 
                                                ttprodu.platot
                                        tt-fabri.qtd    = tt-fabri.qtd + 
                                                ttprodu.qtd
                                        tt-fabri.pladia = tt-fabri.pladia + 
                                                ttprodu.pladia.
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                
                                {anbrowse.i
                                    &File   = tt-fabri
                                    &CField = tt-fabri.fabcod
                                    &color  = write/cyan
                                    &Ofield = " tt-fabri.platot vnomabr
                                        tt-fabri.qtd /* v-perdev */ v-perc
                                        v-perdia tt-fabri.pladia "
                                    &Where = " true "
                                    &NonCharacter = /*
                                    &AftFnd = " find first fabri where 
                                       fabri.fabcod = tt-fabri.fabcod no-lock
                                       no-error.
                                       if avail fabri
                                       then vnomabr = fabri.fabnom.
                                       else vnomabr = ' '.    
                                v-perc = (if tt-fabri.platot > 0
                                          then tt-fabri.platot * 100 / v-totger
                                          else 0).
                                v-perdia = (if tt-fabri.pladia > 0
                                   then tt-fabri.pladia * 100 / v-totdia
                                   else 0). "
                                    &AftSelect1 = "next keys-loop."
                                    &LockType = " use-index valor "
                                    &Form = " frame f-fabri" 
                                }.
                                if keyfunction(lastkey) = "END-ERROR"
                                then leave l2.
                            end.
                        end.


end procedure.

procedure pro-cut-ttprodu:

                                    for each tresu. delete tresu. end.
                                   for each ttprodu where
                                            ttprodu.procod = produ.procod.
                                       find first tresu where tresu.etbcod = 
                                            ttprodu.etbcod no-error.
                                       if not avail tresu
                                       then do:
                                           v-ttger = 0.
                                           for each bttprodu where 
                                            bttprodu.etbcod = ttprodu.etbcod
                                           and bttprodu.clacod = sclase.clacod:
                                        v-ttger = v-ttger + bttprodu.platot.
                                end.      
                                           create tresu.
                                           assign tresu.etbcod = ttprodu.etbcod
                                                  tresu.qtd    = ttprodu.qtd
                                                tresu.platot = ttprodu.platot
                                                tresu.geral = v-ttger.
                                       end.
                                   end.
                                   hide frame f-etb no-pause.
                                   hide frame f-produ no-pause.
                                   v-titulo = ' '.
                                   v-titulo = string(produ.procod) + 
                                             ' - ' + produ.pronom.
                                   run perf_brw.p (input v-titulo).


end procedure.

procedure pro-cut-ttaux-produ:

    for each tresu. 
        delete tresu. 
    end.

    for each ttprodu where 
             ttprodu.procod = produ.procod:
        
        find first tresu where tresu.etbcod = ttprodu.etbcod no-error.
        
        if not avail tresu
        then do:
            v-ttger = 0.
            for each bttprodu where bttprodu.procod = produ.procod and
            bttprodu.etbcod = ttprodu.etbcod:
            v-ttger = v-ttger + bttprodu.platot.
            end.
            create tresu. 
            assign tresu.etbcod = ttprodu.etbcod 
                   tresu.qtd    = ttprodu.qtd 
                   tresu.platot = ttprodu.platot
                   tresu.geral = v-ttger.
        end.
    end. 
    
    hide frame f-etb no-pause. 
    hide frame f-produ-aux no-pause. 
    
    v-titulo = ' '. 
    v-titulo = string(produ.procod) + ' - ' + produ.pronom. 
    /*
    run perf_brw.p (input v-titulo, p-sclase).
    */
    run perf_brw.p (input v-titulo).
end procedure.

