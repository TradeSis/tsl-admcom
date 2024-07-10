/* *
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vfunnom like func.funnom.
def var vtipo as char format "x(15)" extent 2 initial["Codigo","Nome"].
def var vfuncod like func.funcod.
def var reccont         as int.
def var vinicio        as logical.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Devedores","","","",""].


def buffer btotcli       for totcli.
def var vempcod         like totcli.empcod.


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

def temp-table tt-titche
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field clinom like clien.clinom
    field cheque like clien.clinom
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titdtven like titulo.titdtven
    field titvlcob like titulo.titvlcob
    field atraso as int
                .

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first totcli where
            true no-error.
    else
        find totcli where recid(totcli) = recatu1.
    vinicio = no.
    if not available totcli    then do:
        message "Tabela de Operacoes Fiscais Vazia".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 1 column centered no-validate.
                create totcli.
                update  totcli.empcod
                        totcli.totcli.    
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    find clien where clien.clicod = totcli.empcod no-lock no-error.
    display
        totcli.totcli format "999" column-label "Fl"
        totcli.empcod format ">>>>>>>>>99" column-label "Codigo"
        ( if avail clien
            then clien.clinom else "Desconhecido")
        @ clien.clinom
    with frame frame-a 12 down centered.

    recatu1 = recid(totcli).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next totcli where
                true.
        if not available totcli        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.

        if vinicio = no
        then down with frame frame-a.
        
        find clien where clien.clicod = totcli.empcod
                no-lock no-error.


        display
            totcli.totcli format "999" column-label "Fl"
            totcli.empcod
            ( if avail clien
            then clien.clinom else "Desconhecido")
            @ clien.clinom
                 with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find totcli where recid(totcli) = recatu1.

        choose field totcli.empcod
            go-on(cursor-down cursor-up
                  page-down page-up
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next totcli where true no-error.
                if not avail totcli                then leave.
                recatu1 = recid(totcli).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev totcli where true no-error.
                if not avail totcli                then leave.
                recatu1 = recid(totcli).
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
            find next totcli where
                true no-error.
            if not avail totcli then next.
            color display normal
                totcli.empcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev totcli where
                true no-error.
            if not avail totcli            then next.
            color display normal
                totcli.empcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo,leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay 
                    row 6 1 column centered no-validate.
                create totcli.
                update totcli.empcod label "Codigo" format ">>>>>>>>>9"
                       totcli.totcli label "Filial".
                        
                /* clien.clinom = caps(clien.clinom). */
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera no-validate
                    overlay row 6 1 column centered.
                update totcli.empcod label "Codigo" format ">>>>>>>>>9"
                       totcli.totcli label "Filial" format ">>9"
                            with frame f-altera .
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp totcli with frame f-consulta .
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                find clien where clien.clicod = totcli.empcod no-lock no-error.
                if not avail clien
                then do:
                    message "Funcionario na cadastrado em Cliente"
                    view-as alert-box.
                    undo, retry.
                end.
                message "Confirma Exclusao de" clien.clinom update sresp.
                if not sresp
                then leave.
                find next totcli where true no-error.
                if not available totcli
                then do:
                    find totcli where recid(totcli) = recatu1.
                    find prev totcli where true no-error.
                end.
                recatu2 = if available totcli  
                          then recid(totcli)
                          else ?.
                find totcli where recid(totcli) = recatu1.
                delete totcli.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                /*
                message "Confirma Impressao - Tab. de Op. Fiscais" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each totcli:
                    display totcli.
                end.
                output close.
                recatu1 = recatu2.
                leave.
                */
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 side-label centered.
                display vtipo no-label with frame f-tipo centered.
                choose field vtipo with frame f-tipo.
                if frame-index = 1
                then do:
                    vfuncod = 0.
                    update vfuncod label "Codigo" format ">>>>>>>>>999".
                    find first totcli where /*totcli.totcli = 0 and*/
                                            totcli.empcod = vfuncod 
                                                    no-lock no-error.
                    if not avail totcli
                    then do:
                        message "Funcionario nao cadastrado".
                        leave.
                    end.
                    else recatu1 = recid(totcli).
                end.
                else recatu1 = recid(totcli).

                if frame-index = 2
                then do:
                    vfunnom = "".
                    update vfunnom label "Nome".
                    for each clien where clinom begins vfunnom no-lock:
                        find first totcli where /*totcli.totcli = 0 and */
                                                totcli.empcod = clien.clicod 
                                                    no-lock no-error.
                        if not avail totcli
                        then next.
                        display clien.clicod
                                clien.clinom with frame f-nome down centered.
                        recatu1 = recid(totcli).        
                    end.
                end.    
                leave.
            end.

           end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Devedores"
            then do:
                run devedores.
                leave.
            end.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        
        find clien where clien.clicod = totcli.empcod no-lock no-error.

        display
                totcli.totcli label "Fl" format "999"
                totcli.empcod
                ( if avail clien
                  then clien.clinom else "Desconhecido")
                @ clien.clinom
        with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(totcli).
   end.
end.
procedure devedores:
    def var vdias as int.
    def var sub-total as dec.
    def var sub-dias  as int.
    def var varquivo as char.
    def var vetbcod like estab.etbcod.
    def var vdescheque as char.
    def buffer bestab for estab.
    vetbcod = 0.
    do on error undo:
    message "Devedores da Filial " update vetbcod.
    if vetbcod > 0
    then do:
        find bestab where bestab.etbcod = vetbcod no-lock no-error.
        if not avail bestab
        then do:
            message color red/with
            "Filial nao cadastrada."
            view-as alert-box.
            undo.
        end.
     end.       
    end.
    def buffer  btotcli for totcli.
    for each btotcli no-lock /*by totcli*/:
        find clien where clien.clicod = btotcli.empcod no-lock no-error.
        if not avail clien
        then next.

        if vetbcod > 0 and
           btotcli.totcli <> vetbcod
        then next.     

        find first titulo where titulo.clifor = clien.clicod
                    and titulo.titdtven < today
                    and titulo.titsit = "LIB"
                    and titulo.modcod = "CRE"
                    no-lock no-error.
        if not avail titulo
        then do:
            find first cheque where cheque.clicod = clien.clicod
                        and cheque.chesit = "LIB"
                        no-lock no-error.
            if not avail cheque then next.
        end.

        disp "Processando..." 
            clien.clicod no-label
            with frame fdd 1 down centered row 10
            no-box color message.
        pause 0.    
        for each  titulo where titulo.clifor = clien.clicod
                    and titulo.titdtven < today
                    and titulo.titsit = "LIB"
                    and titulo.modcod = "CRE"
                    no-lock .
            vdias = today - titulo.titdtven.
            create tt-titche.
            assign
                tt-titche.etbcod = btotcli.totcli
                tt-titche.clicod = clien.clicod
                tt-titche.clinom = clien.clinom
                /*tt-titche.cheque = clien.clinom*/
                tt-titche.titnum = titulo.titnum
                tt-titche.titpar = titulo.titpar
                tt-titche.titdtven = titulo.titdtven
                tt-titche.titvlcob = titulo.titvlcob
                tt-titche.atraso = vdias
                .
        end.
        for each cheque where
                 cheque.clicod = clien.clicod and
                 cheque.chesit = "LIB"
                 no-lock :
            vdias = today - cheque.cheven.
            vdescheque = "     CHEQUE filial origem " +
                    string(cheque.cheetb).
            create tt-titche.
            assign
                tt-titche.etbcod = btotcli.totcli
                tt-titche.clicod = clien.clicod
                tt-titche.clinom = clien.clinom
                tt-titche.cheque = vdescheque
                tt-titche.titnum = string(cheque.chenum)
                tt-titche.titpar = 0
                tt-titche.titdtven = cheque.cheven
                tt-titche.titvlcob = cheque.cheval
                tt-titche.atraso = vdias
                .
    
        end.         
    end.  
    if opsys = "UNIX"
    then varquivo = "../relat/funfildv." + string(time).
    else varquivo = "l:\relat\funfildv." + string(time).
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """CREDIARIO"""
            &Tit-Rel   = """RELATORIO FUNCIONARIOS EM ATRASO "" +
                            "" -  FILIAL "" + STRING(VETBCOD) "
            &Width     = "100"
            &Form      = "frame f-cabcab"}
            
    for each tt-titche no-lock
                break by tt-titche.etbcod
                      by tt-titche.clicod
                :

        if first-of(tt-titche.clicod)
        then do:
            disp tt-titche.etbcod column-label "Fil" format ">>9"
                 tt-titche.clicod column-label "Codigo"   format ">>>>>>>>>>9"                    tt-titche.clinom column-label "Nome"  format "x(30)"
                     with frame f-disp down width 120.
            if tt-titche.cheque <> ""
            then down with frame f-disp.         
             
        end.
        if tt-titche.cheque <> ""
        then disp tt-titche.cheque @ tt-titche.clinom  with frame f-disp.
        disp tt-titche.titnum   column-label "Numero"
             tt-titche.titpar     column-label "Par"
             tt-titche.titdtven   column-label "Vencimento"
             tt-titche.titvlcob (total by tt-titche.clicod)
                column-label "Valor" 
                                format ">>,>>>,>>9.99"
             tt-titche.atraso column-label "Dias"
                     with frame f-disp. 
        down with frame f-disp.
        sub-total = sub-total + tt-titche.titvlcob.
        sub-dias  = sub-dias  + tt-titche.atraso.
        /*
        end.         
        disp sub-total @ titulo.titvlcob
             
             with frame f-disp.
        down with frame f-disp.     
        */
    end.    
    output close.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i} .
        end.

end procedure.

