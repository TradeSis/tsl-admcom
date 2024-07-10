{admcab.i}
  
def new shared temp-table tt-titulo
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/9999"
    field titdtven like titulo.titdtven format "99/99/9999"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">>>,>>9.99"
    field titdtpag like titulo.titdtpag format "99/99/9999"
    field titvljur like titulo.titvljur 
    field titvldes like titulo.titvldes
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor
    field titbanpag like titulo.titbanpag
    field dtvenori like titulo.titdtven
    index ind-1 titdtemi desc.

def var vdt like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.

def var esqpos1         as int.
def var esqpos2         as int.

def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["","  Altera","  Relatorio","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-titulo       for tt-titulo.
def var vmodcod         like tt-titulo.modcod.

    
form
        esqcom1
            with frame f-com1
                 row 5 no-box no-labels side-labels column 1.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.

form with frame frame-a 
    10 down centered row 6.

def buffer bplani for plani.
def var i as i.
def var vcob like titulo.titvlcob.
def var vpag like titulo.titvlcob.
def var vforcod like forne.forcod.
def var i-serie as int.
repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.
    update vforcod with frame f1 side-label width 80 no-box centered.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrato".
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1 width 80 no-box.
    for each titulo where titulo.clifor = forne.forcod and
                          titulo.titnat = yes and
                          titulo.titsit <> "PAG" no-lock
                          use-index iclicod:
        if titulo.modcod = "BON" or
           titulo.modcod = "DEV" or
           titulo.modcod = "CHP" then next.
        create tt-titulo.
        assign tt-titulo.clifor   = titulo.clifor
               tt-titulo.titnum   =  titulo.titnum 
               tt-titulo.titpar   =  titulo.titpar 
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.titdtemi = titulo.titdtemi 
               tt-titulo.titdtven = titulo.titdtven 
               tt-titulo.titvlcob = titulo.titvlcob 
               tt-titulo.titvlpag = titulo.titvlpag 
               tt-titulo.titdtpag = titulo.titdtpag 
               tt-titulo.titsit   = titulo.titsit
               tt-titulo.etbcod   = titulo.etbcod
               tt-titulo.clifor   = titulo.clifor
               tt-titulo.titbanpag = titulo.titbanpag
               tt-titulo.dtvenori = titulo.titdtven
               .
               
        
        if titulo.titsit <> "pag"       
        then tt-titulo.titvlcob = (titulo.titvlcob + 
                                   titulo.titvljur -
                                   titulo.titvldes).
                        
                                  
        find first  hiscampotb where
                        hiscampotb.xtabela = "titulo" and
                        hiscampotb.xcampo  = "titdtven" and
                        hiscampotb.rowreg = string(rowid(titulo)) 
                        no-lock no-error.
        if avail hiscampotb
        then tt-titulo.dtvenori = date(hiscampotb.valor_campo). 
        
        vcob = vcob + tt-titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.

        find last bplani use-index pladat where bplani.movtdc = 4 and
                               bplani.emite = titulo.clifor  and
                               bplani.etbcod = titulo.etbcod and
                               bplani.pladat <= titulo.titdtemi
                               no-lock no-error.
        if not avail bplani
        then                       
        do i-serie = 1 to 50:
            find last plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = string(i-serie) and
                          plani.numero = int(titnum)
                          no-lock no-error.
            if avail plani
            then do:
                tt-titulo.titdtemi = plani.pladat.                  
                leave.
            end.
        end.
        else do:
            find last plani where  plani.movtdc = 4 and
                                    plani.etbcod = titulo.etbcod and
                                    plani.emite  = titulo.clifor and
                                    plani.serie  = bplani.serie and
                                    plani.numero = int(titnum)
                                    no-lock no-error.
            if avail plani
            then tt-titulo.titdtemi = plani.pladat.    
                                
       end. 
        
    end.
    run al-tit-for.
end.

procedure al-tit-for:

assign
    esqregua  = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
     
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
        find first tt-titulo where
            true no-error.
    else
        find tt-titulo where recid(tt-titulo) = recatu1.
    
    vinicio = yes.
    
    if not available tt-titulo
    then do:
        hide frame f-com1 no-pause.
        hide frame f-com2 no-pause.
        bell.
        message color red/with
        "Nenum registro encontrato."
         view-as alert-box.
        return.
    end.
    clear frame frame-a all no-pause.
    
    display tt-titulo.titnum    format "x(7)"
            tt-titulo.titpar    format "99" 
            tt-titulo.modcod    
            tt-titulo.titdtemi  format "99/99/9999" 
                    column-label "Emissao NF"
            tt-titulo.dtvenori  format "99/99/9999"  
                    column-label "Vcto Antes"
            tt-titulo.titdtven  format "99/99/9999" 
                    column-label "Vcto Atual"
            tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            tt-titulo.titsit    
            tt-titulo.etbcod   column-label "FL" format ">>9"
                with frame frame-a 10 down centered
                row 6.

    recatu1 = recid(tt-titulo).
    
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    
    repeat:
        find next tt-titulo where
                true.
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
            
        display tt-titulo.titnum    format "x(7)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/9999" 
                tt-titulo.dtvenori
                tt-titulo.titdtven  format "99/99/9999" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                    format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1.

        on f7 recall.
        choose field tt-titulo.titnum 
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            
            prompt-for tt-titulo.titnum colon 10.
            
            find last tt-titulo where tt-titulo.titnum = 
                                       input tt-titulo.titnum no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave. 
            
       end. 
       on f7 help.
       
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first tt-titulo where tt-titulo.titdtven <= vdt no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave.
        end. 
        if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                next.
            end.



        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "  Altera"
            then do with frame f-altera overlay row 6 1 column centered.
                find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar and
                                  titulo.titdtven = tt-titulo.titdtven
                                  no-error.
                if avail titulo
                then do transaction:
                    disp tt-titulo.titnum
                         tt-titulo.modcod 
                         tt-titulo.titdtemi
                         tt-titulo.dtvenori label "Vcto Antes"
                         tt-titulo.titdtven label "Vcto Atual"
                         tt-titulo.titvlcob
                         tt-titulo.titsit 
                         tt-titulo.etbcod
                         .
                           
                    update tt-titulo.titdtven .
                    
                    if tt-titulo.titdtven <> titulo.titdtven
                    then do:
                        create hiscampotb.
                        assign
                            hiscampotb.xtabela = "titulo"
                            hiscampotb.xcampo  = "titdtven"
                            hiscampotb.data    = today
                            hiscampotb.hora    = time
                            hiscampotb.etbusuario = setbcod
                            hiscampotb.codusuario = sfuncod
                            hiscampotb.rowreg = string(rowid(titulo))
                            hiscampotb.valor_campo = string(titulo.titdtven)
                            .
                        raw-transfer titulo to hiscampotb.registro.
                            
                    end.
                    
                    find first  hiscampotb where
                        hiscampotb.xtabela = "titulo" and
                        hiscampotb.xcampo  = "titdtven" and
                        hiscampotb.rowreg = string(rowid(titulo)) 
                        no-lock no-error.
                    if avail hiscampotb
                    then tt-titulo.dtvenori = date(hiscampotb.valor_campo). 
        

                    titulo.titdtven = tt-titulo.titdtven.

                    

                end.    
                
                recatu1 = recid(tt-titulo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alt.Setor"
            then do : 
                

                display tt-titulo.titnum    format "x(7)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/9999" 
                tt-titulo.dtvenori
                tt-titulo.titdtven  format "99/99/9999" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                            format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a1 1 down row 7.
 
                update tt-titulo.titbanpag label "Setor"
                 with frame f-alset overlay 
                 no-validate centered row 12 side-label.
 

                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar
                                  no-error.
                if avail titulo
                then do transaction:
                    titulo.titbanpag = tt-titulo.titbanpag.
                    for each titudesp where
                             titudesp.empcod  = 19 and
                             titudesp.titnat = yes and
                             titudesp.clifor  = titulo.clifor and
                             titudesp.titnum  = titulo.titnum and
                             titudesp.titpar  = titulo.titpar
                             :
                        titudesp.titbanpag = titulo.titbanpag.
                    end.
                end. 
                hide frame frame-a1 no-pause.
                hide frame f-alset no-pause.                
            end.
            
            if esqcom1[esqpos1] = " GERA CTB"
            then do:
                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar
                                  no-lock no-error.
                if avail titulo
                then run gera-ctb.p(input recid(titulo)).
            end.
            if esqcom1[esqpos1] = "  Relatorio"
            then do:
                run relatorio.
                recatu1 = recid(tt-titulo).
                leave.
            end.
          end.
          
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end. 
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
                
        display tt-titulo.titnum    format "x(7)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/9999" 
                tt-titulo.dtvenori
                tt-titulo.titdtven  format "99/99/9999" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                    format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        
        recatu1 = recid(tt-titulo).
   end.
end.
    

end procedure.

procedure relatorio:

    def var varquivo as char.
    
    varquivo = "/admcom/relat/altitfor."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""altitfor"" 
                &Nom-Sis   = """FINANCEIRO""" 
                &Tit-Rel   = """Fornecedor: "" + string(vforcod) + "" - "" +
                                forne.fornom " 
                &Width     = "100"
                &Form      = "frame f-cabcab"}


    for each tt-titulo no-lock by titnum:
    
        display tt-titulo.titnum    format "x(7)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/9999" 
                tt-titulo.dtvenori
                tt-titulo.titdtven  format "99/99/9999" 
                tt-titulo.titvlcob(total)  column-label "Vl.Cobrado" 
                    format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-rel down width 100.
                    
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

    varquivo = "/admcom/relat/altitfor"
                        + string(time) + ".csv" .
    output to value(varquivo).   
    
    put "Fornecedor;Numero;Parcela;Modalidade;Emissao;VctoOrigem;VctoAtual;Valor;Situaca
o;Filial" skip.
    
    for each tt-titulo no-lock by titnum:
    
        put tt-titulo.clifor     
            ";"
            tt-titulo.titnum    format "x(15)" 
            ";"
            tt-titulo.titpar    format "99"  
            ";"
            tt-titulo.modcod 
            ";"   
            tt-titulo.titdtemi  format "99/99/9999" 
            ";"
            tt-titulo.dtvenori
            ";"
            tt-titulo.titdtven  format "99/99/9999" 
            ";"
            tt-titulo.titvlcob  format ">>>,>>9.99" 
            ";"
            tt-titulo.titsit
            ";"    
            tt-titulo.etbcod    format ">>9"
            skip
            .
                    
    end.
    output close.

    message color red/with
    "Arquivo excel" skip
    varquivo
    view-as alert-box.
    
end procedure.
