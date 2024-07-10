{admcab.i}
def var varquivo as char.
def var fila as char.
def var recimp as recid.
def var vmail as char format "x(50)".

repeat:

    prompt-for estab.etbcod
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod
                with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    
    if opsys = "unix" then do:
        update vmail label "E-mail " with frame f3 side-label centered color white/red row 15.
        
        if entry (2,vmail,"@") <> "lebes.com.br"  then do:
            message "E-mail inválido, favor verificar." view-as alert-box.
            leave.
        end.
        
    end.
        
    {confir.i 1 "Posicao de Estoque"}
    
    if opsys = "unix"
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.
         
            varquivo = "/admcom/relat/poses" + string(time) + ".txt".
    end.                    
    else assign fila = "" 
                varquivo = "l:\relat\poses" + string(time) + ".txt". 

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """PRECOLI"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom "
        &Width     = "80"
        &Form      = "frame f-cab"}

    for each produ where produ.catcod = categoria.catcod no-lock by pronom.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        if estoq.estatual = 0
        then next.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                estoq.estatual (TOTAL) column-label "Qtd." format "->>>>9"
                estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                (estoq.estatual * estoq.estcusto) (TOTAL) column-label "Total"
                                                       format "->,>>>,>>9.99"
                with frame f2 down width 80.
    end.
    output close.
    
    if opsys = "unix"
    then os-command silent lpr value(" " + fila + " " + varquivo).
    else os-command silent type value(varquivo) > prn.

    if opsys = "unix" and vmail <> "" then
        run p-enviamail.
    
end.

procedure p-enviamail:

def var vassunto    as char.
def var varq-log    as char.


assign varq-log = "/admcom/logs/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
              string(year(today),"9999") + "." + string(time).

assign vassunto = "ARQUIVO_CONTROLE_ESTOQUE".

unix silent value("/admcom/progr/mail.sh "
                             + "~"" + vassunto + "~" "
                             + varquivo
                             + " "
                             + vmail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + varq-log
                             + " 2>&1 ").                                   

/***********************************************
unix silent value("/admcom/progr/mail_anexo.sh "
                             + "~"ARQUIVO_CONTROLE_ESTOQUE~""
                             + " ~""
                             + varquivo
                             + "~" "
                             + vmail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zipar~""
                             + " > "
                             + "/admcom/logs/mail.sh" +
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time)                    ~                              + " 2>&1 ").   

    message "E-MAIL ENVIADO PARA " vmail "!". pause 3.
    message "ZIPANDO E ENVIANDO ARQUIVO POR RCP...".
    
    unix silent value("zip " + varquivo + ".z " + varquivo + ";chmod 777 " + 
    varquivo).

    unix silent value("sudo rcp -p " + varquivo + ".z" +
                        " filial" + string(estab.etbcod,"99") +
                        ":/usr/admcom/relat/poses").
     ****************************************************/
                                           
                                           
    message "PROCESSO TOTAL FINALIZADO! PRESSIONE QUALQUER TECLA P SAIR.".
    PAUSE.
end.
