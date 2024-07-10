/*
*
*           consulta de contratos por clientes
*/
{admcab.i}
if connected ("d") 
then disconnect d.
def var vsit as char format "x(06)".
def var vatr            as log.
def var vpag as log.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(18)" extent 4
    initial [" Parcelas "," Extrato ","Consulta/Extrato","    Nota Fiscal"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def new shared temp-table tt-contrato   like fin.contrato.
def new shared temp-table tt-titulo     like fin.titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def new shared temp-table tt-contnf     like fin.contnf.
def new shared temp-table tt-plani      like plani.
def new shared temp-table tt-movim      like movim.

def temp-table ttcon
    field ttrec as recid
    field dtinicial like tt-contrato.dtinicial
    index ind1 dtinicial desc.

def buffer bcontrato     for tt-contrato.
def var vcontnum         like tt-contrato.contnum.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.

repeat:
    clear frame frame-a all.
    for each ttcon.
        delete ttcon.
    end.
    for each tt-contrato.
        delete tt-contrato.
    end.
    for each tt-titulo.
        delete tt-titulo.
    end.        
    for each tt-contnf.
        delete tt-contnf.
    end.        
    for each tt-plani.
        delete tt-plani.
    end.
    for each tt-movim.
        delete tt-movim.
    end.        
    
    prompt-for clien.clicod colon 15
               with frame fclien centered
                color white/cyan row 5 side-label.
    find clien using clicod no-lock no-error .
    if not avail clien
    then do:
        message "Cliente Nao cadastrado".
        undo.
    end.
    display clien.clinom no-label
            with frame fclien.

    run p-cria-tts.    

    def new shared buffer btitulo for tt-titulo.

    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.
    pause 0.
    
    for each tt-contrato where tt-contrato.clicod = clien.clicod no-lock.
        find first ttcon where ttcon.ttrec = recid(tt-contrato) no-error.
        if not avail ttcon
        then do:
            create ttcon.
            assign ttcon.ttrec     = recid(tt-contrato)
                   ttcon.dtinicial = tt-contrato.dtinicial.
        end.
    end.
def var vcartao-lebes as char.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then find first ttcon no-error.
    else find ttcon where recid(ttcon) = recatu1 no-error.
    vinicio = yes.
    if not available ttcon
    then do:
        message "Nenhum Contrato Para o Cliente".
        leave bl-princ.
    end. 
    clear frame frame-a all no-pause.
    vpag = yes.
    vatr = no.
    find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock.
    for each tt-titulo where tt-titulo.empcod = wempre.empcod             and
                          tt-titulo.titnum = string(tt-contrato.contnum)  and
                          tt-titulo.titnat = no                        and
                          tt-titulo.etbcod = tt-contrato.etbcod           and
                          tt-titulo.clifor = tt-contrato.clicod           and
                          (tt-titulo.modcod = "CRE"
                           or tt-titulo.modcod = "CP0"
                           or tt-titulo.modcod = "CP1")  
                                    no-lock by tt-titulo.titpar.
                          
        if tt-titulo.titsit = "LIB"
        then do:
            vpag = no.
            if tt-titulo.titdtven < today
            then vatr = yes.
            leave.
        end.
    end.


    find estab where estab.etbcod = tt-contrato.etbcod no-lock.
    
    vsit = "".
    if vpag
    then vsit = "PAG".
    if vatr
    then vsit = "ATR".
/***    
        for each tt-titulo where tt-titulo.empcod = wempre.empcod          and
                            tt-titulo.titnum = string(tt-contrato.contnum)  and
                            tt-titulo.titnat = no                        and
                            tt-titulo.etbcod = tt-contrato.etbcod           and
                            tt-titulo.clifor = tt-contrato.clicod           and
                            (tt-titulo.modcod = "CRE"
                             or
                             tt-titulo.modcod = "CP0" 
                             or
                             tt-titulo.modcod = "CP1") no-lock.
for each btitulo where btitulo.empcod = tt-titulo.empcod
                    and btitulo.titnat = tt-titulo.titnat
                    and (btitulo.modcod = "CRE"
                    or btitulo.modcod = "CP1" 
                    or btitulo.modcod = "CP0")
                    and btitulo.titdtemi = tt-titulo.titdtpag
                    and btitulo.etbcod = tt-titulo.etbcod
                    and btitulo.clifor = tt-titulo.clifor no-lock.
    if tt-titulo.moecod = "NOV" or tt-titulo.etbcod > 900
        then do:
        vsit = "NOV".
        end.
end.        
end.
***/




    pause 0.
    display
        tt-contrato.contnum     FORMAT ">>>>>>>>>9"        LABEL "Contrato"
        estab.etbnom    column-label "Estabelecimento" format "x(15)"
        tt-contrato.modcod column-label "Modcod" format "x(3)"   
        tt-contrato.dtinicial   FORMAT "99/99/9999"     column-LABEL "Data Emis"
        tt-contrato.vltotal     FORMAT ">>,>>9.99" LABEL "Valor total"
        tt-contrato.vlentra     FORMAT ">>,>>9.99" LABEL "Vl Entrada"
        vsit            no-label    
        with frame frame-a 14 down centered 
            title " Cod. " + string(clien.clicod) + " " + clien.clinom + " ".

    recatu1 = recid(ttcon).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next ttcon no-error.
        if not available ttcon
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down with frame frame-a.
        vpag = yes.
        vatr = no.
        find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock.
        
        for each tt-titulo where tt-titulo.empcod = wempre.empcod          and
                            tt-titulo.titnum = string(tt-contrato.contnum)  and
                            tt-titulo.titnat = no                        and
                            tt-titulo.etbcod = tt-contrato.etbcod           and
                            tt-titulo.clifor = tt-contrato.clicod           and
                            (tt-titulo.modcod = "CRE"
                            or tt-titulo.modcod = "CP0"
                            or tt-titulo.modcod = "CP1")
                                       no-lock.
            if tt-titulo.titsit = "LIB"
            then do:
                vpag = no.
                if tt-titulo.titdtven < today
                then vatr = yes.
                leave.
            end.
        end.
        find estab where estab.etbcod = tt-contrato.etbcod no-lock.
        
        vsit = "".
        if vpag
        then vsit = "PAG".
        if vatr
        then vsit = "ATR".

/***
        for each tt-titulo where tt-titulo.empcod = wempre.empcod          and
                            tt-titulo.titnum = string(tt-contrato.contnum)  and
                            tt-titulo.titnat = no                        and
                            tt-titulo.etbcod = tt-contrato.etbcod           and
                            tt-titulo.clifor = tt-contrato.clicod           and
                            (tt-titulo.modcod = "CRE"
                         or  tt-titulo.modcod = "CP0"
                         or  tt-titulo.modcod = "CP1")    
                                  no-lock.
        for each btitulo where btitulo.empcod = tt-titulo.empcod
                    and btitulo.titnat = tt-titulo.titnat
                    and (btitulo.modcod = "CRE"
                    or btitulo.modcod = "CP1"
                    or btitulo.modcod = "CP0")  
                    and btitulo.titdtemi = tt-titulo.titdtpag
                    and btitulo.etbcod = tt-titulo.etbcod
                    and btitulo.clifor = tt-titulo.clifor no-lock.
    if tt-titulo.moecod = "NOV" or tt-titulo.etbcod > 900
        then do:
        vsit = "NOV".
        end.
end.
end. /* for each tt-titulo */
***/
    
        display
            tt-contrato.contnum
            estab.etbnom
            tt-contrato.dtinicial
            tt-contrato.vltotal
            tt-contrato.vlentra
            vsit       
                 with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcon where recid(ttcon) = recatu1.
        find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock.


        choose field tt-contrato.contnum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  PF4 F4 ESC return).
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
                find next ttcon no-error.
                if not avail ttcon
                then leave.
                recatu1 = recid(ttcon).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev ttcon no-error.
                if not avail ttcon
                then leave.
                recatu1 = recid(ttcon).
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
            find next ttcon no-error.
            find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock.

            if not avail ttcon
            then next.
            color display normal
                tt-contrato.contnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev ttcon no-error.
            find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock no-error.

            if not avail tt-contrato
            then next.
            color display normal
                tt-contrato.contnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo,leave.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "    Nota Fiscal"
            then do:

                for each tt-contnf where tt-contnf.etbcod  = tt-contrato.etbcod                         and tt-contnf.contnum = tt-contrato.contnum 
                                                    no-lock:
                    vcartao-lebes = "".
                    for each tt-plani where tt-plani.etbcod = tt-contrato.etbcod                                         and tt-plani.placod = tt-contnf.placod
                                        and tt-plani.serie = "V"
                                          no-lock.
                        if acha("CARTAO-LEBES",TT-PLANI.NOTOBS[1]) <> ?
                        then vcartao-lebes = 
                            acha("CARTAO-LEBES",tt-plani.notobs[1]).
                        display tt-plani.numero label "Numero" format ">>>>>>9"
                                             colon 20
                                tt-plani.serie  label "Serie"
                                tt-plani.pladat label "Data"
                                tt-plani.platot label "Valor da Nota"   colon 20
                                vcartao-lebes label "Cartao Lebes"
                                        format "x(13)"
                                tt-plani.vlserv label "Valor Devolucao" colon 20
                                tt-plani.biss   label "Valor C/ Acrescimo"
                                                        colon 20
                                    with frame fnota side-label centered
                                            color message.
                        find finan where finan.fincod = tt-plani.pedcod no-lock
                                                        no-error.
                        display tt-plani.pedcod label "Plano" colon 20
                                finan.finnom no-label when avail finan
                                        with frame fnota.
                        find func where func.etbcod = tt-plani.etbcod and
                                        func.funcod = tt-plani.vencod 
                                                no-lock no-error.
                        display tt-plani.vencod label "Vendedor"colon 20
                                func.funnom no-label when avail func 
                                        with frame fnota side-label.
                       for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                                           and tt-movim.placod = tt-plani.placod                                            and tt-movim.movtdc = tt-plani.movtdc                                            and tt-movim.movdat = tt-plani.pladat
                                                        no-lock:
                            find produ where produ.procod = tt-movim.procod 
                                                        no-lock no-error.
                            display tt-movim.procod
                                    produ.pronom when avail produ 
                                            format "x(21)"
                                    tt-movim.movqtm column-label "Qtd" 
                                            format ">>>>9"
                                    tt-movim.movpc format ">>,>>9.99" 
                                            column-label "Preco" 
                                    (tt-movim.movqtm * tt-movim.movpc)
                                            column-label "Total"
                                        with frame fmov down centered
                                                        color blue/message.
                        
                        end.                                
                    end.                     
                end.                                
            end.     
            
            if esqcom1[esqpos1] = " Parcelas "
            then do:
                run parcco11.p (input recid(tt-contrato)).
            end.

            if esqcom1[esqpos1] = " Extrato "
            then do:
                message "Confirma a emissao do extrato do cliente"
                        clien.clinom "?" update sresp.
                if not sresp
                then leave.
                
                /**   Programa extrato.p já trata anita ou admcom
                if opsys = "UNIX" then
                 run extrato1.p (input recid(clien)).
                else
                **/ 
                
                run extratoc.p (input recid(clien)).
                leave.
             end.
             
             if esqcom1[esqpos1] = "Consulta/Extrato"
             then run extrato31.p (input recid(clien)).

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        find tt-contrato where recid(tt-contrato) = ttcon.ttrec no-lock.
        find estab of tt-contrato no-lock.
        vpag = yes.
        vatr = no.
        for each tt-titulo where tt-titulo.empcod = wempre.empcod                                 and tt-titulo.titnum = string(tt-contrato.contnum)  
                    and tt-titulo.titnat = no                        
                    and tt-titulo.etbcod = tt-contrato.etbcod           
                    and tt-titulo.clifor = tt-contrato.clicod       
                    and (tt-titulo.modcod = "CRE"
                       or tt-titulo.modcod = "CP1" 
                       or tt-titulo.modcod = "CP0")
                                     no-lock.
            if tt-titulo.titsit = "LIB"
            then do:
                vpag = no.
                if tt-titulo.titdtven < today
                then vatr = yes.
                leave.
            end.
        end.
        
        vsit = "".
        if vpag
        then vsit = "PAG".
        if vatr
        then vsit = "ATR".

/***
        for each tt-titulo where tt-titulo.empcod = wempre.empcod          and
                            tt-titulo.titnum = string(tt-contrato.contnum)  and
                            tt-titulo.titnat = no                        and
                            tt-titulo.etbcod = tt-contrato.etbcod           and
                            tt-titulo.clifor = tt-contrato.clicod           and
                            (tt-titulo.modcod = "CRE"
                          or tt-titulo.modcod = "CP1"
                          or tt-titulo.modcod = "CP0")   
                             
                             
                             no-lock.
for each btitulo where btitulo.empcod = tt-titulo.empcod
                    and btitulo.titnat = tt-titulo.titnat
                    and btitulo.modcod = "CRE"
                    and btitulo.titdtemi = tt-titulo.titdtpag
                    and btitulo.etbcod = tt-titulo.etbcod
                    and btitulo.clifor = tt-titulo.clifor no-lock.
    if tt-titulo.moecod = "NOV" or tt-titulo.etbcod > 900
        then do:
        vsit = "NOV".
        end.
end.        
end.
***/
    
        display
            tt-contrato.contnum
            estab.etbnom
            tt-contrato.dtinicial
            tt-contrato.vltotal
            tt-contrato.vlentra
            vsit
             with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttcon).
   end.
end.
end.

procedure p-cria-tts.
    for each titulo where titulo.clifor = clien.clicod 
                    no-lock by titulo.titnum by titulo.titpar.
        if titulo.empcod <> 19 then next. 
        if titulo.titnat = yes then next.
        if titulo.modcod <> "CRE" then next. 
        if titulo.titsit = "EXC" then next.
        
        find first contrato where
             contrato.clicod = int(titulo.clifor) and
             contrato.contnum = int(titulo.titnum) no-lock no-error.
        if not avail contrato
        then do:
            find first tt-contrato where
                       tt-contrato.contnum = int(titulo.titnum)
                       no-error.
            if not avail tt-contrato
            then do:           
                create tt-contrato.
                assign
                tt-contrato.etbcod = titulo.etbcod 
                tt-contrato.contnum = int(titulo.titnum)
                tt-contrato.dtinicial = titulo.titdtemi
                tt-contrato.clicod = titulo.clifor
                .
            end.
            tt-contrato.vltotal  = tt-contrato.vltotal + titulo.titvlcob.
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
        end.
    end.
    for each contrato where contrato.clicod = clien.clicod no-lock.    
        create tt-contrato.
        buffer-copy contrato to tt-contrato.
        for each titulo where titulo.empcod = wempre.empcod             
                          and titulo.titnum = string(contrato.contnum)  
                          and titulo.titnat = no                        
                          and titulo.etbcod = contrato.etbcod           
                          and titulo.clifor = contrato.clicod          
                          and titulo.modcod = "CRE" no-lock by titulo.titpar.  
            if titulo.titsit = "EXC" then next.
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
        end.
        for each contnf where contnf.etbcod  = contrato.etbcod 
                          and contnf.contnum = contrato.contnum 
                              no-lock:
            create tt-contnf.
            buffer-copy contnf to tt-contnf.
            for each plani where plani.etbcod = contrato.etbcod
                             and plani.placod = contnf.placod
                             and plani.serie = "V"
                                 no-lock.
                find first tt-plani where
                           tt-plani.etbcod = contrato.etbcod and
                           tt-plani.placod = contnf.placod and
                           tt-plani.serie = "V"
                           no-error.
                if not avail tt-plani 
                then do:           
                create tt-plani.
                buffer-copy plani to tt-plani.
                end.
                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movtdc = plani.movtdc 
                                 and movim.movdat = plani.pladat
                                     no-lock:
                    find first tt-movim where tt-movim.etbcod = plani.etbcod and
                               tt-movim.placod = plani.placod and
                               tt-movim.movtdc = plani.movtdc and
                               tt-movim.movdat = plani.pladat and
                               tt-movim.procod = movim.procod
                               no-error.
                    if not avail tt-movim
                    then do:           
                    create tt-movim.
                    buffer-copy movim to tt-movim.
                    end.
                end.                          
            end.
        end.
    end.

    connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld d.

    run /admcom/progr/contco1d.p (clien.clicod).

    if connected ("d") 
    then disconnect d.
    
end procedure.
