{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  FECHA","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "         CONTROLE DE TESOURARIA     " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-fluxo
    field data as date
    field sal_ini as dec
    field val_ent as dec
    field val_sai as dec
    field sal_fin as dec
    field val_dif as dec
    field log_sit as log format "Aberto/Fechado"  init yes
    index i1 data descending.
    
form tt-fluxo.data label "Data"
     tt-fluxo.sal_ini label "Saldo Inicial"
     tt-fluxo.val_ent label "Entradas"
     tt-fluxo.val_sai label "Saidas"
     tt-fluxo.sal_fin label "Saldo Final"
     tt-fluxo.val_dif label "Diferença"
     tt-fluxo.log_sit label "Situação"
     with frame f-linha down.
    
def buffer bcxmov for cxmov.

def var dt-comp as date.

find last cxmov where cxmov.etbcod = 999 and
                      cxmov.cxacod = 1 and
                      cxmov.nota = yes
                      no-lock no-error.
if avail cxmov
then do:
    dt-comp = cxmov.cxmdat.
    disp dt-comp with frame f1. 
end.
else do on error undo, return:
    find last cxmov where cxmov.etbcod = 999 and
                      cxmov.cxacod = 1 and
                      cxmov.nota = no
                      no-lock no-error.
    if avail cxmov
    then dt-comp = cxmov.cxmdat.
    else dt-comp = today.                  
    update dt-comp   label "Data caixa" format "99/99/9999"
        with frame f1 side-label.
end.

def var v-data as date.

l1: repeat:

    for each tt-fluxo: delete tt-fluxo. end.
    
    create tt-fluxo.
    tt-fluxo.data = dt-comp.

    find last cxmov where cxmov.etbcod = 999 and
                          cxmov.cxacod = 1 and
                          cxmov.cxmdat < dt-comp and
                          cxmov.evecod = 9
                          no-lock no-error.
    if not avail cxmov
    then do on error undo, return:
        update tt-fluxo.sal_ini label "Informe o saldo inicial"
            format ">>>,>>>,>>9.99"
            with frame f-salini side-label 1 down.
        if tt-fluxo.sal_ini > 0
        then do:
            create cxmov.
            assign
                cxmov.etbcod = 999
                cxmov.cxacod = 1
                cxmov.cxmdat = dt-comp - 1
                cxmov.evecod = 9
                cxmov.moecod = "SAL"
                cxmov.cxmvalor = tt-fluxo.sal_ini
                cxmov.nota = no
                .
        end.
    end.
    else do:
        tt-fluxo.sal_ini = cxmov.cxmvalor.     
        if cxmov.nota = yes
        then do:
            dt-comp = cxmov.cxmdat.   
            delete tt-fluxo.   
        end.
    end.
                            
    do v-data = dt-comp - 7 to dt-comp:
    for each cxmov where    cxmov.etbcod = 999 and
                            cxmov.cxacod = 1 and
                            cxmov.cxmdat = v-data 
                            no-lock:

        find first tt-fluxo where tt-fluxo.data = cxmov.cxmdat no-error.
        if not avail tt-fluxo
        then do:
            create tt-fluxo.
            tt-fluxo.data = cxmov.cxmdat.
            find last bcxmov where    bcxmov.etbcod = 999 and
                                      bcxmov.cxacod = 1 and
                                      bcxmov.cxmdat < cxmov.cxmdat and
                                      bcxmov.evecod = 9 and
                                      bcxmov.moecod = "SAL"
                                      no-lock no-error.
            if avail bcxmov
            then tt-fluxo.sal_ini = bcxmov.cxmvalor .
        end.
        if cxmov.moecod = "ENT"
        then tt-fluxo.val_ent = cxmov.cxmvalor.
        if cxmov.moecod = "SAI"
        then tt-fluxo.val_sai = cxmov.cxmvalor.
        tt-fluxo.log_sit = cxmov.nota.
    end.    
    end.
    for each tt-fluxo:
        if tt-fluxo.sal_ini = 0
        then delete tt-fluxo.
        else
        tt-fluxo.sal_fin = 
            tt-fluxo.sal_ini + tt-fluxo.val_ent - tt-fluxo.val_sai.
    end.        
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-fluxo  
        &cfield =  tt-fluxo.data
        &noncharacter = /* 
        &ofield = " tt-fluxo.sal_ini
                    tt-fluxo.val_ent
                    tt-fluxo.val_sai
                    tt-fluxo.sal_fin
                    tt-fluxo.val_dif
                    tt-fluxo.log_sit
                  "  
        &aftfnd1 = " "
        &where  = " true use-index i1 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  FECHA""
                        then do:
                            leave l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        UPDATE tt-fluxo.sal_ini when tt-fluxo.sal_ini = 0
               tt-fluxo.val_ent
               tt-fluxo.val_sai
               tt-fluxo.sal_fin
               with frame f-linha.
        if tt-fluxo.val_ent > 0 or
           tt-fluxo.val_sai > 0 or
           tt-fluxo.sal_fin > 0
        then do:
            run altera.
        end.   
    END.
    if esqcom1[esqpos1] = "  FECHA"
    THEN DO:
        sresp = no.
        message color red/with
             "Confirma fechamento " tt-fluxo.data " ? " update sresp.
        if sresp
        then do:
            run fecha.
            run relatorio.
        end.     
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
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
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:
    def var sal-final as dec.
    def var val-difer as dec.
    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/salfinan." + string(time).
    else varquivo = "..~\relat~\salfinan." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                &Tit-Rel   = """ FECHAMENTO - "" +
                        string(dt-comp,""99/99/9999"") " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    find first tt-fluxo where
             tt-fluxo.data = dt-comp no-lock no-error.
    if avail tt-fluxo
    then do:
        sal-final = tt-fluxo.sal_ini + tt-fluxo.val_ent - tt-fluxo.val_sai.
        val-difer = sal-final -  tt-fluxo.sal_fin.
        put skip(4)
            "  Saldo Inicial" tt-fluxo.sal_ini format "->>,>>>,>>9.99"
            skip(1)
            "       Entradas" tt-fluxo.val_ent format "->>,>>>,>>9.99"
            skip(1)
            "         Saidas" tt-fluxo.val_sai format "->>,>>>,>>9.99"
            skip(1)
            "    Saldo Final" sal-final        format "->>,>>>,>>9.99"
            skip(1)
            "Saldo Informado" tt-fluxo.sal_fin format "->>,>>>,>>9.99"
            skip(1)
            "      Diferença" val-difer        format "->>,>>>,>>9.99"
            skip
             .
        put skip(4)
            "______________________________       ____________________________"
            skip
            "         Tesoureiro                        Gerente Financeiro    "
            skip.

    end.         
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure altera:
    if tt-fluxo.val_ent > 0
    then do:
        find first cxmov where cxmov.etbcod = 999  and
                               cxmov.cxacod = 1        and
                               cxmov.cxmdat = tt-fluxo.data  and
                               cxmov.cxmhora = "0"     and
                               cxmov.evecod = 1        and
                               cxmov.moecod = "ENT" no-error.
        if not avail cxmov
        then do:                   
            create cxmov.
            assign
                cxmov.etbcod = 999
                cxmov.cxacod = 1
                cxmov.cxmdat = tt-fluxo.data
                cxmov.cxmhora = "0"
                cxmov.evecod = 1
                cxmov.moecod = "ENT"
                .
        end.
        cxmov.cxmvalor = tt-fluxo.val_ent.
    end.
       
    if tt-fluxo.val_sai > 0
    then do:
        find first cxmov where cxmov.etbcod = 999  and
                               cxmov.cxacod = 1        and
                               cxmov.cxmdat = tt-fluxo.data     and
                               cxmov.cxmhora = "0"     and
                               cxmov.evecod = 2        and
                               cxmov.moecod = "SAI" no-error.
        if not avail cxmov
        then do:                   
            create cxmov.
            assign
                cxmov.etbcod = 999
                cxmov.cxacod = 1
                cxmov.cxmdat = tt-fluxo.data
                cxmov.cxmhora = "0"
                cxmov.evecod = 2
                cxmov.moecod = "SAI"
                .
        end.
        cxmov.cxmvalor = tt-fluxo.val_sai.
    end.    
    if tt-fluxo.sal_fin > 0
    then do:
        tt-fluxo.val_dif = (tt-fluxo.Sal_ini + tt-fluxo.val_ent +
                tt-fluxo.val_sai) - tt-fluxo.sal_fin.
        disp tt-fluxo.val_dif with frame f-linha.
    end. 
end procedure.
procedure fecha:
    def var saldo-final as dec.
    find first cxmov where cxmov.etbcod = 999  and
                               cxmov.cxacod = 1        and
                               cxmov.cxmdat = tt-fluxo.data  and
                               cxmov.cxmhora = "0"     and
                               cxmov.evecod = 9        and
                               cxmov.moecod = "SAL" no-error.

    if not avail cxmov
    then do:
        create cxmov.
        assign
            cxmov.etbcod = 999
            cxmov.cxacod = 1
            cxmov.cxmdat = tt-fluxo.data
            cxmov.cxmhora = "0"
            cxmov.evecod = 9 
            cxmov.moecod = "SAL"
            .
    end.
    
        saldo-final = tt-fluxo.sal_ini.
        for each bcxmov where
                 bcxmov.etbcod = 999  and
                 bcxmov.cxacod = 1        and
                 bcxmov.cxmdat = tt-fluxo.data  and
                 bcxmov.cxmhora = "0"     and
                 bcxmov.evecod <> 9 no-lock.
            if bcxmov.moecod = "ENT"
            then saldo-final = saldo-final + bcxmov.cxmvalor.
            else if bcxmov.moecod = "SAI"
                then saldo-final = saldo-final - bcxmov.cxmvalor.      
        end.
        cxmov.cxmvalor = saldo-final.
        for each cxmov where cxmov.etbcod = 999  and
                             cxmov.cxacod = 1        and
                             cxmov.cxmdat = tt-fluxo.data  
                             :
            cxmov.nota = no.
        end. 
                            
end procedure.
