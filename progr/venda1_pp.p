/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.


def shared temp-table tt-plani
    field plarec as recid
    field desti  like clien.clicod
    field platot like plani.platot
        index ind-1 desti
        
        index ival-cres platot
        index ival-decr platot desc.
        

def var vtitulo as char.
 

def var varquivo        as char.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(16)" extent 4
    initial ["Consulta/Produto","Observacao","Acao/Listagem","Ordenar"].

def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var vordem as int.
def var vordenar        as char format "x(22)" extent 3
            initial ["1. Codigo             ",
                     "2. Valor - Crescente  ",
                     "3. Valor - Decrescente"].

def buffer btt-plani    for tt-plani.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1 width 80.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
                 
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

vordem = 1.
def var vrelat as log format "Sim/Nao".
def var vacao as log format "Sim/Nao".


bl-princ:
repeat:

    disp esqcom1 with frame f-com1. pause 0.
    disp esqcom2 with frame f-com2. pause 0.
    if recatu1 = ?
    then do:

        if vordem = 1
        then 
            find first tt-plani use-index ind-1 where true no-error.
        else
        if vordem = 2
        then
            find first tt-plani use-index ival-cres where true no-error.
        else
        if vordem = 3
        then
            find first tt-plani use-index ival-decr where true no-error.
        
    end.    
    else
        find tt-plani where recid(tt-plani) = recatu1.

    vinicio = yes.
    
    if not available tt-plani
    then do:
        message "nenhum registro encontrato".
        return.
    end.

    clear frame frame-a all no-pause.
    find plani where recid(plani) = tt-plani.plarec no-lock.
    find clien where clien.clicod = plani.desti no-lock no-error.
    vtitulo = "DATA :" + string(plani.pladat).
    
    display plani.notobs[2] no-label format "x(78)" 
                        with frame f-obs no-box row 20 centered
                                    color message side-label.
                                 pause 0.
    display
        tt-plani.desti column-label "Cliente"
        clien.clinom when avail clien format "x(28)" 
        clien.fone   when avail clien
        plani.platot format ">>,>>9.99"
        plani.numero format ">>>>>>9"
        plani.serie column-label "Sr"
            with frame frame-a 12 down centered title vtitulo.

    recatu1 = recid(tt-plani).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        
        if vordem = 1
        then 
            find next tt-plani use-index ind-1 where true no-error.
        else
        if vordem = 2
        then
            find next tt-plani use-index ival-cres where true no-error.
        else
        if vordem = 3
        then
            find next tt-plani use-index ival-decr where true no-error.
        
        
        if not available tt-plani
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        if vinicio
        then down
            with frame frame-a.

    find plani where recid(plani) = tt-plani.plarec no-lock.
    find clien where clien.clicod = plani.desti no-lock no-error.
    
    display plani.notobs[2]  
                        with frame f-obs no-box row 20 centered
                                    color message side-label.

    display
        tt-plani.desti
        clien.clinom when avail clien 
        clien.fone   when avail clien
        plani.platot
        plani.numero
        plani.serie
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-plani where recid(tt-plani) = recatu1.
        

        choose field tt-plani.desti
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 4
                          then 4
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
                
                if vordem = 1
                then 
                    find next tt-plani use-index ind-1 where true no-error.
                else
                if vordem = 2
                then
                    find next tt-plani use-index ival-cres where true no-error.
                else
                if vordem = 3
                then
                    find next tt-plani use-index ival-decr where true no-error.
                
                if not avail tt-plani
                then leave.
                recatu1 = recid(tt-plani).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):

                if vordem = 1
                then 
                    find prev tt-plani use-index ind-1 where true no-error.
                else
                if vordem = 2
                then
                    find prev tt-plani use-index ival-cres where true no-error.
                else
                if vordem = 3
                then
                    find prev tt-plani use-index ival-decr where true no-error.
                
                
                if not avail tt-plani
                then leave.
            
                recatu1 = recid(tt-plani).
        
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
        
            if vordem = 1
            then 
                find next tt-plani use-index ind-1 where true no-error.
            else
            if vordem = 2
            then
                find next tt-plani use-index ival-cres where true no-error.
            else
            if vordem = 3
            then
                find next tt-plani use-index ival-decr where true no-error.
            
            if not avail tt-plani
            then next.

            color display normal
                tt-plani.desti.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            
            if vordem = 1
            then 
                find prev tt-plani use-index ind-1 where true no-error.
            else
            if vordem = 2
            then
                find prev tt-plani use-index ival-cres where true no-error.
            else
            if vordem = 3
            then
                find prev tt-plani use-index ival-decr where true no-error.
            

            if not avail tt-plani
            then next.
            
            color display normal
                tt-plani.desti.
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

            if esqcom1[esqpos1] = "Ordenar"
            then do:
                
                view frame frame-a. pause 0.
            
                disp  vordenar[1] skip    
                      vordenar[2] skip  
                      vordenar[3]  
                      with frame f-ordem title "Ordenar por" row 7
                             centered no-label overlay. 
    
                    choose field vordenar auto-return with frame f-ordem.
                    vordem = frame-index.

                    clear frame f-ordem no-pause.
                    hide frame f-ordem no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
            end.
            
            if esqcom1[esqpos1] = "Observacao"
            then do with frame f-observacao overlay 
                        side-label no-box row 21.
                find plani where recid(plani) = tt-plani.plarec no-error.
                update plani.notobs[2] no-label format "x(78)".
                hide frame f-observacao no-pause.
            end.


            if esqcom1[esqpos1] = "Consulta/Produto"
            then do with frame f-consulta overlay row 6 down centered.
                for each movim where movim.etbcod = plani.emite  and
                                     movim.placod = plani.placod and
                                     movim.movdat = plani.pladat and
                                     movim.movtdc = plani.movtdc no-lock.
                                     
                    find produ where produ.procod = movim.procod 
                                            no-lock no-error.
                    display movim.procod
                            produ.pronom format "x(30)"
                            movim.movpc column-label "Pr.Custo"
                            movim.movqtm column-label "Qtd"
                            (movim.movpc * movim.movqtm)(total)
                                    column-label "Total".
                                             
                end.
            end.
            if esqcom1[esqpos1] = "Acao/Listagem"
            then do:
                vrelat = no . vacao = no.
    
                update vrelat label "Relatorio"
                        vacao   label "Acao"
                        with frame f-tipo 1 down centered row 7 side-label.
                if vrelat = no and vacao = no
                then leave.
 
                recatu2 = recatu1.

                if vrelat = yes
                then do:
                varquivo = "..\relat\vndcli" + string(time). 
                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "63"
                    &Cond-Var  = "120"
                    &Page-Line = "66"
                    &Nom-Rel   = ""venda1_p""
                    &Nom-Sis   = """SISTEMA COMERCIAL"""
                    &Tit-Rel   = """VENDAS DA "" +
                                ""FILIAL "" + string(plani.etbcod) +
                                ""  - Data: "" + string(plani.pladat)"
                    &Width     = "120"
                    &Form      = "frame f-cabcab"}

 
                if vordem = 1
                then do:
                    for each tt-plani use-index ind-1:
                        find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                        if not avail plani or plani.notobs[2] = ""
                        then next.
                        find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                        if not avail clien then next.
                        display plani.numero format ">>>>>>9"
                                clien.clicod
                                clien.clinom format "x(30)"
                                clien.fone
                                plani.notobs[2] no-label format "x(78)"
                                    with frame f2-ind-1 down width 200.
                    end.                
                end.
                else
                if vordem = 2        
                then do:
                    for each tt-plani use-index ival-cres:
                        find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                        if not avail plani or plani.notobs[2] = ""
                        then next.
                        find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                        if not avail clien then next.
                        display plani.numero format ">>>>>>9"
                                clien.clicod
                                clien.clinom format "x(30)"
                                clien.fone
                                plani.notobs[2] no-label format "x(78)"
                                    with frame f2-ival-cres down width 200.
                    end.                
                
                end.
                else
                if vordem = 3
                then do:
                    for each tt-plani use-index ival-decr:
                        find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                        if not avail plani or plani.notobs[2] = ""
                        then next.
                        find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                        if not avail clien then next.
                        display plani.numero format ">>>>>>9"
                                clien.clicod
                                clien.clinom format "x(30)"
                                clien.fone
                                plani.notobs[2] no-label format "x(78)"
                                    with frame f2-ival-decr down width 200.
                    end.                
                
                end.
                
                
                
                
                output close.
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:    
                    {mrod.i}
                end.
                end.
                if vacao = yes
                then do:
                    run gera-acao.
                end.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            /**
            if esqcom2[esqpos1] = "Gera Acao"
            then do:
                run gera-acao.
            end. **/
            leave.
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        
        find plani where recid(plani) = tt-plani.plarec no-lock.
        find clien where clien.clicod = plani.desti no-lock no-error.
        
        
        display plani.notobs[2] 
                        with frame f-obs no-box row 20 centered
                                    color message side-label.

        display tt-plani.desti
                clien.clinom when avail clien 
                clien.fone   when avail clien
                plani.platot
                plani.numero
                plani.serie with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-plani).
   end.
end.

procedure gera-acao:
    if connected ("crm")
        then disconnect crm.

        /*** Conectando Banco CRM no server CRM ***/
        connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
        if not connected ("crm")
        then do:
            message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
            pause.
            leave.
        end.

        if vordem = 1
        then do:
            for each tt-plani use-index ind-1:
                find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                if not avail plani or plani.notobs[2] = ""
                then next.
                find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                if not avail clien then next.
                find first tt-cli where
                           tt-cli.clicod = clien.clicod
                           no-error.
                if not avail tt-cli
                then do:           
                    create tt-cli.
                    tt-cli.clicod = clien.clicod.
                    tt-cli.clinom = clien.clinom.
                end.
            end.
        end.
        else if vordem = 2        
        then do:
            for each tt-plani use-index ival-cres:
                find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                if not avail plani or plani.notobs[2] = ""
                then next.
                find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                if not avail clien then next.
                find first tt-cli where
                           tt-cli.clicod = clien.clicod
                           no-error.
                if not avail tt-cli
                then do:           
                    create tt-cli.
                    tt-cli.clicod = clien.clicod.
                    tt-cli.clinom = clien.clinom.
                end.
            end.                
        end.
        else if vordem = 3
        then do:
            for each tt-plani use-index ival-decr:
                find plani where recid(plani) = tt-plani.plarec
                                                no-lock no-error.
                if not avail plani or plani.notobs[2] = ""
                then next.
                find clien where clien.clicod = plani.desti 
                                        no-lock no-error.
                if not avail clien then next.
                find first tt-cli where
                           tt-cli.clicod = clien.clicod
                           no-error.
                if not avail tt-cli
                then do:           
                    create tt-cli.
                    tt-cli.clicod = clien.clicod.
                    tt-cli.clinom = clien.clinom.
                end.
            end.                
                
        end.

        sresp = no.
        message "Confirma GERAR ACAO ?   " update sresp.
        if sresp
        then do:
            
            run rfv000-brw.p.
                                            
            message color red/with
                 "       ACAO GERADA      " view-as alert-box.

        end.
        if connected ("crm")
        then disconnect crm.
 
end.
