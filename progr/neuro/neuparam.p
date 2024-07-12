{admcab.i}
{setbrw.i}                                                                      

def input parameter p-tipo as char.
def input parameter p-grupo as int.
def input parameter p-descri as char.
def input parameter p-aplicacao as char. /* POLITICA */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" INCLUI","  ALTERA","","",""].
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

def temp-table tt-tabparam like tabparam.



        def var vok as log.
        
        vok = no.
        
        
        
        if p-aplicacao = "P1" or
           p-aplicacao = "P2"
        then do:
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SUBMETER?"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = yes
                tt-tabparam.condicao   = "="
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
        
            vok = yes.
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "QUANTIDADE CONTRATOS EXISTENTES"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao   = "="
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
        end.
        if p-aplicacao = "P3" 
        then do:
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SUBMETER?"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = yes
                tt-tabparam.condicao   = "="
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .

            vok = yes.
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "DIAS ULTIMA COMPRA"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = ">"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "DIAS ULTIMO PAGAMENTO"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = ">"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "DIAS ULTIMA ATUALIZACAO"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = ">"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "PERCENTUAL PARCELAS PAGAS"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = "<"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "QUANTIDADE PARCELAS PAGAS"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = "<"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .

                
        end.
        if p-aplicacao = "P4" 
        then do:
            vok = yes.
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SUBMETER ATUALIZACAO LIMITES?"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao   = "="
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
        end.
        
        if p-aplicacao = "P5" or
           p-aplicacao = "P6" or
           p-aplicacao = "P7" or
           p-aplicacao = "P8" 
        then do:
            vok = yes.
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SUBMETER?"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = yes
                tt-tabparam.condicao   = "="
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .

            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "VALOR VENDA > SALDO LIMITE"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ""
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SALDO ABERTO"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ">"
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .     
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "VALOR VENDA"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ">"
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SPC - DIAS ATRASO"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ">"
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SPC - MESES ULTIMA COMPRA"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ">"
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "SPC - PERC VLR MAIOR CONTRATO"
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.condicao   = ">"
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "PERCENTUAL PARCELAS PAGAS"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = "<"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = "QUANTIDADE PARCELAS PAGAS"
                tt-tabparam.valor      = 0
                tt-tabparam.condicao = "<"
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .

                

        end.

        
        if vok = no
        then do:
            create tt-tabparam.    
            assign
                tt-tabparam.tipo   = p-tipo 
                tt-tabparam.grupo  = p-grupo
                tt-tabparam.aplicacao = p-aplicacao
                tt-tabparam.parametro  = ""
                tt-tabparam.valor      = 0
                tt-tabparam.bloqueio   = no
                tt-tabparam.dtexp = today
                tt-tabparam.dtinclu = today .
        end.
   
        for each tt-tabparam
            where tt-tabparam.parametro <> "".
            find first tabparam where
                       tabparam.tipo  = tt-tabparam.tipo and
                       tabparam.grupo = tt-tabparam.grupo and
                       tabparam.aplicacao = tt-tabparam.aplicacao and
                       tabparam.parametro = tt-tabparam.parametro
                       no-error.
            if not avail tabparam
            then do:
                create tabparam. 
                buffer-copy tt-tabparam to tabparam.           
            end.
        end.                    
         
        for each tabparam where
             tabparam.tipo = p-tipo and
             tabparam.grupo = p-grupo and
             tabparam.aplicacao = p-aplicacao
             no-lock.
            find tt-tabparam where
                       tt-tabparam.tipo  = tabparam.tipo and
                       tt-tabparam.grupo = tabparam.grupo and
                       tt-tabparam.aplicacao = tabparam.aplicacao and
                       tt-tabparam.parametro = tabparam.parametro
                no-error.
            if avail tt-tabparam
            then do:
                tt-tabparam.valor      = tabparam.valor.
                tt-tabparam.condicao   = tabparam.condicao.
                tt-tabparam.bloqueio   = tabparam.bloqueio.
                tt-tabparam.dtexp      = tabparam.dtexp.
                tt-tabparam.dtinclu    = tabparam.dtinclu.
            end.
        
        end.                


form 
     tt-tabparam.aplicacao  column-label "Poli!tica"  format "x(5)"
     tt-tabparam.parametro  column-label "Parametro"
     tt-tabparam.condicao   column-label "Sin!al"   format "x(3)"
     tt-tabparam.valor      column-label "Valor"
     tt-tabparam.bloqueio    column-label "Submete!Neurot"
     with frame f-linha down color with/cyan 
     centered row 8 overlay
     title " parametros do grupo " + string(p-grupo) + " ".
                                                                         
                                                                                
def var i as int.


l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-tabparam  
        &cfield = tt-tabparam.parametro
        &noncharacter = /* */ 
        &ofield = " tt-tabparam.valor
                    tt-tabparam.bloqueio
                    tt-tabparam.condicao
                    tt-tabparam.aplicacao."  
        &aftfnd1 = " "
        &where  = " tt-tabparam.tipo   = p-tipo and
                    tt-tabparam.grupo = p-grupo  and
                    tt-tabparam.aplicacao = p-aplicacao "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  esqcom1[esqpos1] = ""  INCLUI"".
                         run aftselect.
                         esqcom1[esqpos1] ="""".
                         /*if keyfunction(lastkey) = ""END-ERROR""
                         THEN LEAVE l1.
                         ELSE*/ 
                         next l1.
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
    THEN DO on error undo, return:
        
         
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo:
        update  tt-tabparam.condicao
                tt-tabparam.valor
                   tt-tabparam.bloqueio
            with frame f-linha
        .
        find first tabparam where
                   tabparam.tipo  = tt-tabparam.tipo and
                   tabparam.grupo = tt-tabparam.grupo and
                   tabparam.aplicacao = tt-tabparam.aplicacao and
                   tabparam.parametro = tt-tabparam.parametro
                   no-error.

        if not avail tabparam
        then create tabparam. 
            buffer-copy tt-tabparam to tabparam.           
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
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

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.
