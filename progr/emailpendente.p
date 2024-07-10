/*  emailpendente.p                                                        */
/*  Projeto Melhorias Mix - Luciano      */

def var varquivo as char.
def buffer liped_pend for liped.

 def var vaspas as char format "x(1)".
vaspas = chr(34).


def temp-table ttliped like liped
        field rec as recid.

for each ttliped.
    delete ttliped.
end.

for each repexporta where repexporta.TABELA  = "LIPED_PENDENTE" and
                          repexporta.DATAEXP = ?   .
    find liped where recid(liped) = repexporta.Tabela-Recid no-lock no-error.
    if not avail liped 
    then do.       
        repexporta.DATAEXP = today.
        next.
    end.
    find first tabaux where tabaux.tabela       = "EMAIL_FILIAL"       and
                            tabaux.Nome_Campo   = string(liped.etbcod) and
                            tabaux.valor_Campo  <> ""
                            no-lock no-error.
    if not avail tabaux 
    then next.
    create ttliped.
    buffer-copy liped to ttliped.
    ttliped.rec = recid(liped).
    repexporta.DATAEXP = today.
end.
    

for each ttliped break by ttliped.etbcod.
    
    if first-of(ttliped.etbcod)
    then do.
        find estab where estab.etbcod = ttliped.etbcod no-lock.
        find first tabaux where tabaux.tabela       = "EMAIL_FILIAL"       and
                                tabaux.Nome_Campo   = string(estab.etbcod) and
                                tabaux.valor_Campo  <> ""
                                no-lock no-error.
        varquivo = "../relat/emailpendente_" + string(estab.etbcod) + "_" +
                        string(time) + ".html" .
        output to value(varquivo).
        /* cabecalho email  */
        put "<html>" skip
               "<body>" skip
               skip
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=1350 align=center><b><h2> " today "   -   "
                string(time,"hh:mm:ss") 
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
         "<td width=1350 align=center><b>STATUS PEDIDOS PENDENTES NO CORTE - " 
         " FILIAL "
         string(estab.etbcod) " - "  estab.etbnom
               "</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Pedido</b></td>" skip
               "<td width=100 align=left><b>Tipo</b></td>" skip
               "<td width=100 align=left><b>Produto</b></td>" skip
               "<td width=400 align=left><b>Descricao</b></td>" skip
               "<td width=100 align=left><b>Quantidade</b></td>" skip
               "<td width=300 align=left><b>Motivo</b></td>" skip
               "<td width=300 align=left><b>Status</b></td>" skip
               "</tr>" skip.
        /*                  */
    end.
    find liped where recid(liped) = ttliped.rec no-lock.
    find pedid of liped no-lock.
    def var ped-tipo as char. 
    if com.pedid.modcod = "PEDA"
    then ped-tipo = "Automatico".
    else if com.pedid.modcod = "PEDM"
        then ped-tipo = "Manual".
        else if com.pedid.modcod = "PEDR"
           then ped-tipo = "Reposicao".
           else if com.pedid.modcod = "PEDE"
               then ped-tipo = "Especial".
               else if com.pedid.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if com.pedid.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if com.pedid.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if com.pedid.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if com.pedid.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if com.pedid.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".

    find produ of liped no-lock.
    /*
    disp pedid.pednum           
         ped-tipo           format "x(15)" column-label "Tipo"               
         liped.procod
         produ.pronom       format "x(30)" column-label "Descricao"
         liped.lipqtd       format ">>>>9" column-label "Quant"
         liped.PendMotivo   format "x(30)" column-label "Motivo"   
         liped.lip_status   format "x(50)" column-label "Status"
         with frame flin down
                    width 250.
    down with frame flin .
    */

/**/
        put unformatted skip
                    "<tr>"
                    skip
                    "<td width=100 align=right>" pedid.pednum
                    "</td>"
                    skip
                    "<td width=100 align=right>" ped-tipo 
                    "</td>"
                    skip
                    "<td width=100 align=right>" 
                                            liped.procod
                    "</td>"
                    skip
                    "<td width=400 align=right>" 
                                       produ.pronom
                    "</td>"
                    skip.

                    put unformatted 
                            "<td width=100 align=right>"
                                    liped.lipqtd.
                    put "</td>" skip.
                    put "<td width=300 align=right>".
                                 put unformatted   liped.PendMotivo.
                    put "</td>" skip.
                    put "<td width=300 align=right>".
                                 put unformatted  liped.lip_status.
                    put "</td>" skip.
                    put "</tr>" skip.

/**/    
    
    

    if last-of(ttliped.etbcod)
    then do. 
        /*put skip(4).*/
        put "</table>" skip
               "</body>"  skip
                              "</html>".

        output close.
        def var vassunto as char.
        vassunto = "STATUS PEDIDOS PENDENTES NO CORTE - FILIAL " +
                                string(ttliped.etbcod).
        def var vemails as char.
        vemails = trim(tabaux.valor_Campo + 
            ","  + "naoatendidos@lebes.com.br" 
            
            ).
        
        def var varqlog as char.
        varqlog = "../relat/log_emailpendente.log".
        
        /***********
        
        unix silent value("mail -s PEDIDO_PENDENTE_FILIAL_" + 
                                                string(ttliped.etbcod) + 
                " " + vemails + " < " + varquivo
                            ).
        
        *************/
        
        do:   
        
            def var varqdg as char.
            varqdg = "/admcom/progr/mail.sh " 
                        + "~"" + vassunto + "~"" + " ~"" 
                        + varquivo + "~"" + " ~"" 
  + vemails + "~"" 
                        + " ~"Linx~""
                        + " ~"text/html~"". 
                        
            unix silent value(varqdg).
            pause 2 no-message.
        end.
    end.
end.
