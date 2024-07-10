/*  cad_finan.p                                                              */
/*  06/2014 - Cadastramento de Planos - informar que é plano Bis             */
/*  Alterado em 22/09/2017 por Leote. Alterado format do fincod para 4 e buscar planos abaixo de 1000 para 3000 */

{admcab.i}

def var vplanobis   as log format "Sim/Nao" label "Plano Bis".
def var vcategoria  as log format "31-Moveis/41-Moda" label "Categoria".

def var varquivo as char.
def var vmarca   as char format "x"                          no-undo.

def temp-table wfin
    field wrec as recid.

for each wfin:
    delete wfin.
end.
for each cpag no-lock:
    find finan where finan.fincod = cpag.cpagcod no-lock no-error.
    if avail finan
    then do:
        create wfin.
        assign wfin.wrec = recid(finan).
    end.
end.
             
run versenha.p ("", "D.COMPRAS", " Seguranca ", output sresp).
if not sresp
then leave.    
    
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Marca "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" E-mail ", ""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bfinan       for finan.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find finan where recid(finan) = recatu1 no-lock.
    if not available finan
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(finan).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available finan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find finan where recid(finan) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(finan.finnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(finan.finnom)
                                        else "".
            run color-message.
            choose field finan.fincod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail finan
                    then leave.
                    recatu1 = recid(finan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail finan
                    then leave.
                    recatu1 = recid(finan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail finan
                then next.
                color display white/red finan.fincod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail finan
                then next.
                color display white/red finan.fincod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form finan
                 with frame f-finan color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-finan on error undo.
                
                    create finan.
                    UPDATE
                       FINAN.fincod format ">>>9"
                       FINAN.finnom format "x(50)"
                       FINAN.finent
                       FINAN.finnpc
                       FINAN.finfat
                       FINAN.datexp FORMAT "99/99/9999"
                       finan.txjurosmes
                       finan.txjurosano.
                    finan.finnom = caps(finan.finnom).
                    vplanobis = no.
                    update vplanobis.
                    if vplanobis
                    then do.
                        update vcategoria .
                        create tabaux.                           
                        ASSIGN tabaux.Tabela      = "PLANOBIZ"
                               tabaux.Nome_Campo  = if vcategoria
                                                    then "31"
                                                    else "41" 
                               tabaux.Valor_Campo = string(finan.fincod)
                               tabaux.datexp      = today
                               tabaux.exportar    = no
                               tabaux.Tipo_Campo  = "" .
                    end.
                    run email (esqcom1[esqpos1]).
                    recatu1 = recid(finan).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-finan.
                    disp finan. 
                    find first tabaux where 
                                tabaux.tabela = "PLANOBIZ" and
                                tabaux.valor_campo = string(finan.fincod)
                            no-lock no-error.    
                    vplanobis = avail tabaux.
                    disp vplanobis.
                    if vplanobis
                    then disp vcategoria.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-finan on error undo.
                    find finan where recid(finan) = recatu1 exclusive.
                    UPDATE
                       FINAN.fincod format ">>>9"
                       FINAN.finnom
                       FINAN.finent
                       FINAN.finnpc
                       FINAN.finfat
                       FINAN.datexp FORMAT "99/99/9999"
                       finan.txjurosmes
                       finan.txjurosano.
                    find first tabaux where 
                                tabaux.tabela = "PLANOBIZ" and
                                tabaux.valor_campo = string(finan.fincod)
                            no-lock no-error.    
                    vplanobis = avail tabaux.
                    update vplanobis when vplanobis = no.
                    if not avail tabaux and vplanobis
                    then do.
                        update vcategoria .
                        create tabaux.                           
                        ASSIGN tabaux.Tabela      = "PLANOBIZ"
                               tabaux.Nome_Campo  = if vcategoria
                                                    then "31"
                                                    else "41" 
                               tabaux.Valor_Campo = string(finan.fincod)
                               tabaux.datexp      = today
                               tabaux.exportar    = no
                               tabaux.Tipo_Campo  = "" .
                    end.
                    run email (esqcom1[esqpos1]).
                end.

                if esqcom1[esqpos1] = " Marca"
                then do:
                    find FIRST wfin where wfin.wrec = recid(finan) no-error.
                    if not avail wfin
                    then do:
                        create wfin.
                        create cpag.
                        assign wfin.wrec = recid(finan)
                               cpag.cpagcod = finan.fincod.
                        display "*" @ vmarca
                                with frame frame-a.
                    end.
                    else do on error undo.
                        delete wfin.
                        find cpag where cpag.cpagcod = finan.fincod.
                        delete cpag.
                        display "" @ vmarca
                                with frame frame-a.
                    end.
                end.
                if esqcom1[esqpos1] = " Listagem"
                then do:
                    message "Confirma Impressao?" update sresp.
                    if not sresp
                    then LEAVE.
                    
                    varquivo = "../relat/finan" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""cad_finan""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CADASTRO DE FINANCIAMENTOS"""
        &Width     = "135"
        &Form      = "frame f-cabcab"}
                
                    for each bfinan where bfinan.fincod < 800 no-lock:
                        display bfinan.fincod format ">>>9"
                                bfinan.finnom
                                bfinan.finent
                                bfinan.finnpc
                                bfinan.finfat
                                bfinan.datexp format "99/99/9999"
                                bfinan.txjurosmes
                                bfinan.txjurosano
                                vplanobis.
                                .
                    end.
                    output close.
                    run visurel.p(varquivo,"").
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " E-mail "
                then do:
                    run email (esqcom2[esqpos2]).
/***
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
***/
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(finan).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    find first wfin where wfin.wrec = recid(finan) no-error.
    def var vbis as log format "Bis/".
    find first tabaux where tabaux.tabela = "PLANOBIZ" and
                            tabaux.valor_campo = string(finan.fincod)
                            no-lock no-error.    
    vbis = avail tabaux.
    display if avail wfin then "*" else "" @ vmarca no-label
            finan.fincod format ">>>9"
            finan.finnom
            finan.finent   column-label "Ent"
            finan.finnpc   column-label "N.Pc"
            finan.finfat
            finan.txjurosmes format ">>9.99" column-label "Jur.Mes"
            finan.txjurosano format ">>9.99" column-label "Jur.Ano"
            vbis no-label
            tabaux.Nome_Campo when avail tabaux no-label format "xxx"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        finan.fincod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        finan.fincod
        with frame frame-a.
end procedure.


procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first finan where finan.fincod < 3000 no-lock no-error.
    else   find last finan  where finan.fincod < 3000 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next finan  where finan.fincod < 3000 no-lock no-error.
    else   find prev finan   where finan.fincod < 3000 no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then    find prev finan where finan.fincod < 3000  no-lock no-error.
    else    find next finan where finan.fincod < 3000 no-lock no-error.
        
end procedure.


procedure email.

    def input parameter par-oper as char.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char.

    find first wfin where wfin.wrec = recid(finan) no-error.
    find first func where func.funcod = sfuncod and func.etbcod = 999 no-error.

    assign
        vassunto = "Manutencao de Cadastro de Financiamentos"
        vdestino = "planosdepagamento@lebes.com.br;"
        /*vdestino = "lucas.leote@lebes.com.br;"*/
        varquivo = "/admcom/relat/email" + string(time) + ".html".

    output to value(varquivo).
    put "<html>" skip
        "<head>" skip
        "<meta http-equiv=~"Content-Languag~" content=~"pt-br~">" skip
        "<meta name=~"GENERATOR~" content=~"Microsoft FrontPage 5.0~">" skip
        "<meta name=~"ProgId~" content=~"FrontPage.Editor.Document~">" skip
        "<meta http-equiv=~"Content-Type~" content=~"text/html; ".
    put "charset=windows-1252~">" skip
        "<title>Nova pagina</title>" skip
        "</head>" skip
        "<body>" skip.
    put unformatted
        "<h1>Sistema Admcom</h1></p>"
        "<b>Operacao:</b> " par-oper "</p>"
        "<br><b>Plano Pagamento:</b> " finan.fincod " - " finan.finnom 
        (if avail wfin then " *" else "")
        "</p>"
        "<br><b>Funcionario:</b> " sfuncod " - " func.funnom " </p>"
        "<br><b>Entrada:</b> "  finan.finent format "Com/Sem" "</p>"
        "<br><b>N.Prest.:</b> " finan.finnpc "</p>"
        "<br><b>Fator:</b> "    finan.finfat     format ">>9.9999" "</p>"
        "<br><b>Jur.Mes:</b> "  finan.txjurosmes format ">>9.99" "</p>"
        "<br><b>Jur.Ano:</b> "  finan.txjurosano format ">>9.99" "</p>".
    put "</body>" skip.
    put "</html>" skip.
    
    output close.
        
    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~"". 
    unix silent value(varqmail).

end procedure.

