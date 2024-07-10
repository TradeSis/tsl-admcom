def input parameter par-arqlog as char.

/*
    Geral e envia o relatorio de SSC
*/
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
 
def var varqsai   as char.
/*def var vaspas    as char.*/
def var vassunto  as char.
/*def var me-mail   as char extent 6.*/
def var vct       as int.

do vct = 1039 to 1040.

    find first tbcntgen where
               tbcntgen.tipcon = 1 and
               tbcntgen.etbcod = vct and
               tbcntgen.numini = "INFORMATIVO"
           no-lock.

    if vct = 1039
    then assign
            varqsai   = "/admcom/relat/30diasnoposto" + string(time) + ".html"
            /*varqzip   = "/admcom/relat/30diasnoposto" + string(time) + ".zip"*/
            .
    else assign
            varqsai   = "/admcom/relat/30diasgeral" + string(time) + ".html"
            /*varqzip   = "/admcom/relat/30diasgeral" + string(time) + ".zip"*/
            .

    /*vaspas    = chr(34).*/
    vassunto  = tbcntgen.campo1[1].
    /*varqtexto = "/admcom/relat/email" + string(time).*/

    output to value(varqsai).
    put unformatted
        "<HTML>" skip.

    put unformatted
        "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
        " summary=~"DREBES & CIA LTDA~">" skip
        "<CAPTION><b>" + tbcntgen.campo1[1] + "</CAPTION>" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<COLGROUP align=~"left~">" skip
        "<THEAD valign=~"top~">" skip
        "<TR>" 
        "<TH><b>Estab</TH>" skip
        "<TH><b>OS</TH>" skip
        "<TH><b>Produto</TH>" skip
        "<TH><b>Descricao</TH>" skip
        "<TH><b>Envio</TH>" skip
        "<TH><b>Posto</TH>" skip
        "<TH><b>Dias</TH>" skip
        "</TR> </THEAD>" skip 
        "<TBODY>" skip.

    for each estab no-lock.
        if vct = 1039
        then
            for each asstec where asstec.etbcod = estab.etbcod
                              and asstec.dtenvass <> ?
                              and asstec.dtretass = ?
                              and asstec.dtsaida = ?
                              and today - asstec.dtenvass > 30
                            no-lock.
                run linha.
            end.
        else
            for each asstec where asstec.etbcod = estab.etbcod
                              and asstec.dtsaida = ?
                              and today - asstec.datexp > 30
                            no-lock.
                run linha.
            end.
    end.

    put "</TBODY> </TABLE></HTML>" skip.
    output close.

/***
    assign
        me-mail[1] = acha("email1",tbcntgen.campo3[1]) 
        me-mail[2] = acha("email2",tbcntgen.campo3[1])
        me-mail[3] = acha("email3",tbcntgen.campo3[1])
        me-mail[4] = acha("email4",tbcntgen.campo3[1])
        me-mail[5] = acha("email5",tbcntgen.campo3[1])
        me-mail[6] = acha("email6",tbcntgen.campo3[1]).
***/

/***
varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varqsai + "~"" +
                        " ~"" + me-mail + "~"" /***+
                        " ~"" + me-mail + "~"" +
                        " ~"text/html~"" ***/.
***/

/***
varqmail = "/admcom/progr/mail.sh " +
           vaspas + vassunto + vaspas + " " +
           varqsai + " " +
           me-mail + " " +
           "informativo@lebes.com.br" + " " +
           "~"zip~""
                  /*           + " > "
                             + varquivo
                             + " 2>&1 " */.
unix silent value(varqmail). 
***/

/***
varquivo = "/admcom/relat/log".
run envia_info_anexo.p(input "1039", input varquivo,
                input varqsai, input vassunto).
    
***/

/***nao funciona no root
def var varqtexto as char.
def var varqzip   as char.
    output to value(varqtexto).
    put unformatted "Segue relatorio em anexo.".
    output close.

    unix silent value ("zip -9Dq " + varqzip + " " + varqsai).
 
    unix silent value(
        "echo | mutt -s " + 
        vaspas + vassunto + vaspas +
        " -a " + varqzip   +
        " -i " + varqtexto +
        " -- " + me-mail[1]  + " " +
        (if me-mail[2] <> ? then me-mail[2] else "") + " " +
        (if me-mail[3] <> ? then me-mail[3] else "") + " " +
        (if me-mail[4] <> ? then me-mail[4] else "") + " " +
        (if me-mail[5] <> ? then me-mail[5] else "") + " " +
        (if me-mail[6] <> ? then me-mail[6] else "") ).

    unix silent value ("rm -f  " + varqsai).
***/
    run /admcom/progr/envia_info_anexo.p(string(vct),
                                input par-arqlog,
                                input varqsai,
                                input vassunto).
                               

end.

procedure linha.

    def var vdias     as int.
    if vct = 1039
    then vdias = today - asstec.dtenvass.
    else vdias = today - asstec.datexp.

        find produ of asstec no-lock no-error.
        put unformatted
            "<TR>"
            "<TD>" asstec.etbcod "</TD>"
            "<TD>" asstec.oscod  "</TD>"
            "<TD>" asstec.procod "</TD>"
            "<TD>" if avail produ then trim(produ.pronom) else "" "</TD>"
            "<TD>" asstec.dtenvass "</TD>"
            "<TD>" asstec.forcod "</TD>"
            "<TD>" vdias "</TD>"
            "</TR>" skip.

end procedure.
