{admcab.i}

def var vok as log.
def input parameter p-etbcod like estab.etbcod.
def input parameter p-pladat as date.

def var varquivo as char.

def shared temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999" 
    field valdep    like depban.valdep 
    field datexp    like depban.datexp
    field extrato as char
    field arquivo as char
    index tt-arq  is primary    dephora asc
                                valdep asc.

def buffer bdepban for depban.
def buffer cdepban for depban.

def var vaster as char .
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.

def var vdatmov  like depban.datmov.
def var vvaldep  like depban.valdep.
def var vdephora like depban.dephora.
def var vbancod  like depban.bancod.
def var vetbcod  like estab.etbcod.
def var vdatexp  like plani.datexp format "99/99/9999".
def var envelope like depban.dephora format "99999999".


def var esqcom1         as char format "x(12)" extent 5
          initial ["Procura","Consulta","Alteracao","Inclusao","Exclusao"].

/*
def var esqcom1         as char format "x(12)" extent 5
          initial ["Procura","Consulta","","",""].
*/          
def var esqcom2         as char format "x(12)" extent 5
            initial ["Impressao","","","",""].


    form
        esqcom1
            with frame f-com1
                 row 8 no-box no-labels side-labels centered
                 .
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels centered.

form vaster format "x(20)" no-label
     depban.etbcod
     depban.bancod
     depban.dephora format "9999999" column-label "Envelope"
     depban.valdep 
     depban.datmov
     with frame frame-a 7 down centered 
          row 9 color white/cyan overlay. 
          
form vaster format "x(20)" no-label
     depban.etbcod
     depban.bancod
     depban.dephora format "9999999" column-label "Envelope"
     depban.valdep 
     depban.datmov
     with frame f-disp  down centered 
          . 

def var totvaldep as dec.

esqregua = yes.
esqpos1 = 1.
esqpos2 = 1.
recatu1 = ?.

def new shared temp-table tt-dep like fin.depban.
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
    else find depban where recid(depban) = recatu1.
    vinicio = yes.
    if not available depban
    then do:
        message "Nenhuma deposito para filial".
        pause.
        leave bl-princ.
    end.
    clear frame frame-a all no-pause.
    
    run totaliza.
    run disp-line.

    recatu1 = recid(depban).
    
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    
    repeat:

        find next depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
        if not available depban
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.

        if vinicio
        then down with frame frame-a.

        run disp-line.
        
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find depban where recid(depban) = recatu1.

        run color-message.
        choose field depban.dephora
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                
                find next depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
                if not avail depban
                then leave.
                recatu1 = recid(depban).

            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
                if not avail depban
                then leave.
                recatu1 = recid(depban).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
            if not avail depban
            then next.
            run color-normal.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-error.
            if not avail depban
            then next.
            run color-normal.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        /*
        hide frame frame-a no-pause.
          */
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            pause 0.
            if esqcom1[esqpos1] = "Procura"
            then do:
                prompt-for depban.dephora format "9999999" label "Envelope"
                        with frame f-procura 1 down centered
                        side-label row 11 overlay.
                find first cdepban where cdepban.etbcod = p-etbcod and
                                 cdepban.datmov = p-pladat and
                                 cdepban.dephora = input frame f-procura 
                                            depban.dephora no-lock no-error.
                if not avail cdepban
                then recatu1 = ?.
                else recatu1 = recid(cdepban). 
                next bl-princ.                           
            end.
            if esqcom1[esqpos1] = "Inclusao"
            then do transaction with frame f-inclui overlay 
                row 12 1 column centered side-label.
                create cdepban. 
                update cdepban.etbcod 
                   cdepban.bancod 
                   cdepban.dephora format "9999999" column-label "Envelope"
                   cdepban.valdep
                   cdepban.datmov 
                   with frame f-inclui.
                recatu1 = recid(cdepban).
                hide frame f-inclui no-pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame f-altera 
                overlay row 12 1 column centered side-label.
                
                run color-message.
                pause 0.
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
                       with frame f-altera.
                
                find cdepban where cdepban.etbcod  = vetbcod  and
                                   cdepban.dephora = vdephora and
                                   cdepban.datexp  = depban.datexp and
                                   cdepban.datmov  <> depban.datmov
                                        no-lock no-error.
                if avail cdepban
                then do:
                    message "Deposito ja incluido".
                    /*display cdepban.*/
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
                run disp-line.
            end. 

            if esqcom1[esqpos1] = "Exclusao"
            then do transaction:
            
                run color-message.
                sresp = no.
                message "Deseja excluir deposito" update sresp.
                if sresp
                then do:
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
                    run alt-filial.
                    delete depban.
                end.
                next bl-princ.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Impressao"
            then do transaction:
                            
                recatu2 = recatu1.

                varquivo = "/admcom/relat/mandep01." + STRING(time).

                {mdad.i
                    &Saida     = "value(varquivo)"  
                    &Page-Size = "64" 
                    &Cond-Var  = "80" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""titluc""
                    &Nom-Sis   = """SISTEMA FINANCEIRO"""
                    &Tit-Rel   = """DEPOSITO DA FILIAL "" + string(p-etbcod)
                                    + "" EM "" + string(p-pladat)"
                    &Width     = "80"
                    &Form      = "frame f-cabcab"}


                for each depban where depban.etbcod = p-etbcod and
                                 depban.datmov = p-pladat no-lock:
                        
                    vaster = " ".
                    find first tt-arq where 
                               tt-arq.dephora = depban.dephora and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if not avail tt-arq
                    then  find first tt-arq where 
                               tt-arq.dephora = 0 and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if avail tt-arq /* and depban.bancod <> 86*/
                    then do:
                        find first 
                            bdepban where bdepban.etbcod  = depban.etbcod and
                                          bdepban.dephora = depban.dephora and
                                          recid(bdepban) <> recid(depban)
                                           no-lock no-error.
                        if avail bdepban and bdepban.datmov > today - 30
                        then vaster = " " + 
                            string(bdepban.datmov,"99/99/9999") +
                                                " - #".
                        else vaster = "              *". 
                    end.
                    
                    
                    disp 
                         vaster 
                         depban.etbcod
                         depban.bancod
                         depban.dephora 
                         depban.valdep 
                         depban.datmov
                    with frame f-disp.
                    down with frame f-disp.
 
                end.

                down(2) with frame f-disp.
                
                run totaliza.
                
                output close.
                /*{mrod.i}*/
                run visurel.p(varquivo,"").
                
                recatu1 = recatu2.
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqregua = yes.
                 leave.
            end.

          end.
          view frame frame-a .
        end.
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.

        run disp-line.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(depban).
   end.
end.

procedure disp-line:
vaster = " ".
                    find first tt-arq where 
                               tt-arq.dephora = depban.dephora and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if not avail tt-arq
                    then find first tt-arq where 
                               tt-arq.dephora = 0 and
                               tt-arq.valdep  = depban.valdep and
                               tt-arq.datmov = depban.datexp no-error.
                    if avail tt-arq /*and depban.bancod <> 86*/
                    then do:
                        find first 
                            bdepban where bdepban.etbcod  = depban.etbcod and
                                          bdepban.dephora = depban.dephora and
                                          recid(bdepban) <> recid(depban)
                                           no-lock no-error.
                        if avail bdepban and bdepban.datmov > today - 30
                        then vaster = " " + 
                            string(bdepban.datmov,"99/99/9999") +
                                                " - #".
                        else vaster = "              *". 
                    end.
                    
                    
                    disp 
                         vaster 
                         depban.etbcod
                         depban.bancod
                         depban.dephora 
                         depban.valdep 
                         depban.datmov
                    with frame frame-a.
                     
end procedure.                         

procedure color-message.
color display message
        depban.etbcod
        depban.bancod
        depban.dephora
        depban.valdep
        depban.datmov
        with frame frame-a.
end procedure.
procedure color-normal.
color display wite/cyan
        depban.etbcod
        depban.bancod
        depban.dephora
        depban.valdep
        depban.datmov
        with frame frame-a.
end procedure.

procedure totaliza:
    totvaldep = 0.
    for each cdepban where cdepban.etbcod = p-etbcod and
                                 cdepban.datmov = p-pladat no-lock:
        totvaldep = totvaldep + cdepban.valdep.
    end.
    disp totvaldep label "Total....."  format ">>,>>>,>>9.99"
        with frame f-tot no-box 1 down row 20 side-label
            column 37.
end procedure.

procedure alt-filial:
    def var vfilial as int.
    def var vip as char.
    def var vstatus as char.
    
    for each tt-dep:
        delete tt-dep.
    end.
    create tt-dep.
    buffer-copy depban to tt-dep.
        
    message "Informe a Filial para conectar" update vfilial.
    
    if vfilial > 0
    then do:
    vip = "filial" + string(vfilial,"99").
    
    message "Conectando...>>>>>   " vip.
  
    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja.
    if not connected ("finloja")
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
    end.
    else do:        
        run mandep-mfil.p ( output vstatus, output vok ). 

        output to altifil.log.
            put today "   "  vip format "x(15)" skip   
                vstatus format "x(60)" skip
                .
        output close.
                 
        if connected ("finloja")
        then disconnect finloja.
    end.
    message color red/with
        vstatus view-as alert-box.
    end.
end procedure.

