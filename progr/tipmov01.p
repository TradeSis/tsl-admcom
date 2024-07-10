/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var sresp           as log format "Sim/Nao".
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["","Inclusao","Alteracao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bTipMov       for TipMov.
def var vMovtdc         like TipMov.Movtdc.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
def var tem-itens as log label "Tem Itens" format "Sim/Nao".
def var char-itens as char.
def var modelo-documento as char label "Modelo Documento".
def var tipo-documento as char   label "Tipo Documento".
def var natureza-operacao as char label "Natureza da Operacao"
            format "x(60)".
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first TipMov where
            true no-error.
    else
        find TipMov where recid(TipMov) = recatu1.
    if not available TipMov
    then do:
        message "Cadastro de Tipos de Movimentacoes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create TipMov.
                update  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre modcod.
                next.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        TipMov.Movtdc
        TipMov.movtnom movtnat movtsig
        TipMov.movtnota movttitu
        TipMov.movtaut
        tipmov.movtdeb
        tipmov.movtcre modcod
            with frame frame-a 12 down  
            WIDTH 80 /*no-box*/.

    recatu1 = recid(TipMov).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.

    def var situacao as log format "Ativo/Inativo".
    
    repeat:
        find next TipMov where
                true.
        if not available TipMov
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            TipMov.Movtdc
            TipMov.movtnom movtnat movtsig
            TipMov.movtnota movttitu
            TipMov.movtaut
            tipmov.movtcre modcod
            tipmov.movtdeb
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find TipMov where recid(TipMov) = recatu1.

        choose field TipMov.movtnom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
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
            find next TipMov where
                true no-error.
            if not avail TipMov
            then next.
            color display normal
                TipMov.movtnom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev TipMov where
                true no-error.
            if not avail TipMov
            then next.
            color display normal
                TipMov.movtnom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create TipMov.
                update  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre 
                        modcod
                        modelo-documento
                        tipo-documento.
                if modelo-documento <> "" 
                then do:
                    modelo-documento = caps(modelo-documento).
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc
                        tipmovaux.nome_campo = "Modelo-Documento"
                        tipmovaux.valor_campo = modelo-documento
                        tipmovaux.tipo_campo = "char"
                        .
                end.
                if tipo-documento <> "" 
                then do:
                    tipo-documento = caps(tipo-documento).
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc
                        tipmovaux.nome_campo = "Tipo-Documento"
                        tipmovaux.valor_campo = tipo-documento
                        tipmovaux.tipo_campo = "char"
                        .
                end.         
                recatu1 = recid(TipMov).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 5 WIDTH 80 1 COLUMN.
                assign
                    modelo-documento = ""
                    tipo-documento = ""
                    tem-itens = no
                    char-itens = ""
                    situacao = yes
                    .
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "SITUACAO" and
                           tipmovaux.valor_campo = "INATIVO"
                           no-lock no-error.
                if avail tipmovaux
                then situacao = no.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then modelo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then tipo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "natureza-operacao"
                           no-lock no-error.
                if avail tipmovaux
                then natureza-operacao = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "TEM-ITENS" /*and
                           tipmovaux.valor_campo = "SIM" */
                           no-lock no-error.
                if avail tipmovaux 
                then char-itens = tipmovaux.valor_campo.
                if char-itens = "SIM"
                then tem-itens = yes.        

                disp  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre 
                        modcod
                        tem-itens
                        modelo-documento
                        tipo-documento
                        natureza-operacao
                        situacao
                        .
 
                update 
                        movtnom  
                        movtsig
                        modcod
                        tem-itens
                        modelo-documento
                        tipo-documento
                        natureza-operacao
                        situacao.

                if char-itens <> "" or
                   tem-itens = yes
                then do:
                     if tem-itens
                        then char-itens = "SIM".
                        else char-itens = "NAO".
                end.
                /***
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "natureza-operacao"
                           no-error.
                if avail tipmovaux
                then  tipmovaux.valor_campo = natureza-operacao.
                else do:
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc 
                        tipmovaux.nome_campo = "natureza-operacao"
                        tipmovaux.valor_campo = natureza-operacao.
                END.

                ***/
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "SITUACAO"
                           no-error.
                if avail tipmovaux
                then DO:
                    if situacao = yes
                    then tipmovaux.valor_campo = "ATIVO".
                    else tipmovaux.valor_campo = "INATIVO".
                END.
                else do:
                    if situacao = no
                    then do:
                        create tipmovaux.
                        assign
                            tipmovaux.movtdc = tipmov.movtdc
                            tipmovaux.nome_campo = "SITUACAO"
                            tipmovaux.valor_campo = "INATIVO"
                            tipmovaux.tipo_campo = "char"
                            .
                    end.
                end.
 
                modelo-documento = caps(modelo-documento).
                tipo-documento = caps(tipo-documento).
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "TEM-ITENS"
                           no-error.
                if not avail tipmovaux and
                    char-itens <> ""
                then do:
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc
                        tipmovaux.nome_campo = "TEM-ITENS"
                        tipmovaux.valor_campo = char-itens
                        tipmovaux.tipo_campo = "char"
                        .
                end.
                else if avail tipmovaux  and
                    tipmovaux.valor_campo <> char-itens
                then tipmovaux.valor_campo = char-itens.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-error.
                if not avail tipmovaux and
                   modelo-documento <> ""
                then do:
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc
                        tipmovaux.nome_campo = "Modelo-Documento"
                        tipmovaux.valor_campo = modelo-documento
                        tipmovaux.tipo_campo = "char"
                        .
                end.
                else if avail tipmovaux and
                    tipmovaux.valor_campo <> modelo-documento
                then tipmovaux.valor_campo = modelo-documento.

                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-error.
                if not avail tipmovaux and
                   tipo-documento <> ""
                then do:
                    create tipmovaux.
                    assign
                        tipmovaux.movtdc = tipmov.movtdc
                        tipmovaux.nome_campo = "Tipo-Documento"
                        tipmovaux.valor_campo = tipo-documento
                        tipmovaux.tipo_campo = "char"
                        .
                end.
                else if avail tipmovaux and
                    tipmovaux.valor_campo <> tipo-documento
                then tipmovaux.valor_campo = tipo-documento.     
                               
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-consulta overlay row 6 1 column centered.
                assign
                    modelo-documento = ""
                    tipo-documento = ""
                    situacao = yes
                    .
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "SITUACAO" and
                           tipmovaux.valor_campo = "INATIVO"
                           no-lock no-error.
                if avail tipmovaux
                then situacao = no.
                
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then modelo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then tipo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Natureza-Operacao"
                           no-lock no-error.
                if avail tipmovaux
                then natureza-operacao = tipmovaux.valor_campo.
  
                 disp  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre 
                        modcod
                        modelo-documento
                        tipo-documento
                        natureza-operacao
                        situacao.
                /*
                disp TipMov with frame f-consulta no-validate.
                */
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" TipMov.MovtNom update sresp.
                if not sresp
                then undo.
                find next TipMov where true no-error.
                if not available TipMov
                then do:
                    find TipMov where recid(TipMov) = recatu1.
                    find prev TipMov where true no-error.
                end.
                recatu2 = if available TipMov
                          then recid(TipMov)
                          else ?.
                find TipMov where recid(TipMov) = recatu1.
                delete TipMov.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                
                message "Confirma Impressao de TipMovcante" update sresp.
                if not sresp
                then next bl-princ.

                recatu2 = recatu1.

                run relatorio.

                recatu1 = recatu2.
                leave.
            end.

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
        display
                TipMov.Movtdc
                TipMov.movtnom movtnat movtsig
                TipMov.movtnota movttitu
                TipMov.movtaut
                tipmov.movtdeb
                tipmov.movtcre modcod
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(TipMov).
   end.
end.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/tipmov" + "."
                    + string(time).
    else varquivo = "..~\relat~\tipmov" + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""tipmov01"" 
                &Nom-Sis   = """MODULO CONTABIL/FISCAL""" 
                &Tit-Rel   = """ TIPOS DE DOCUMENTOS """ 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    for each tipmov no-lock:
        assign
                    modelo-documento = ""
                    tipo-documento = ""
                    .
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then modelo-documento = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then tipo-documento = tipmovaux.valor_campo.
 
        disp  tipmov.movtdc
                        movtnom movtnat movtsig
                        movtnota movttitu
                        movtaut
                        movtdeb
                        movtcre 
                        modcod
                        modelo-documento column-label "Modelo!Documento"
                        tipo-documento   column-label "Tipo!Documento"
                        with frame f-relat down width 100.
        down with frame f-relat.
 
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
