{/admcom/progr/admcab-batch.i}

if day(today) <> 20
then return.

FUNCTION mesfim returns date(input par-data as date).

  return ((DATE(MONTH(par-data),28,YEAR(par-data)) + 4) -     DAY(DATE(MONTH(par-data),28,YEAR(par-data)) + 4)).

end function.

def var vdti as date.
def var vdtf as date.

def var vcont as integer.

def var v-env-mail as char.
def var v-texto as char.

def var vdt-aux as date.

def var v-ok-email as logical.

def var vtexto1 as char.
def var vtexto2 as char.

def stream str-txt.

def stream str-relat.
                                                        
def output parameter varquivo as character.                                    
assign vdt-aux = mesfim(today) + 1.   
                                                    
assign vdtf = mesfim(vdt-aux)
       vdti = date(month(vdt-aux),01,year(vdt-aux)).

if opsys = "UNIX"
then varquivo = "/admcom/relat-auto/rlbonli1." + string(time) + ".txt".
else varquivo = "l:\relat-auto\rlbonli1." + string(time) + ".txt".
    
{mdad_stream.i
    &Saida     = "value(varquivo)"
    &Page-Size = "0"
    &Cond-Var  = "120"
    &Page-Line = "0"
    &Nom-Rel   = ""RLBONLI1""
    &Nom-Sis   = """SISTEMA DE CRM"""
&Tit-Rel = """LISTAGEM DE CLIENTES COM BONUS NAO UTILIZADOS QUE RECEBERAM E-MAIL - Período: "" + string(vdti,""99/99/9999"") + "" a "" + string(vdtf,""99/99/9999"") + ""."""
    &Width     = "138"
    &Form      = "frame f-cabcab"
    &Stream    = "stream str-relat"}
    

for each titulo where titulo.modcod = "BON"
                  and titulo.empcod = 19
                  and titulo.titnat   = yes
                  and titulo.titdtven >= vdti
                  and titulo.titdtven <= vdtf
                  and titulo.titsit = "LIB" no-lock,

    first clien where clien.clicod = titulo.clifor no-lock:

    find first acao where acao.acaocod = int(titulo.titobs[1]) no-lock no-error.

    assign v-texto = "/admcom/relat-auto/rlbonli1.p.tmp".
    
    output stream str-txt to value(v-texto).
        
    put stream str-txt unformatted
         "<table border='0'><tr><td><br>".

    if clien.sexo
    then assign vtexto1 = "Prezado "
                vtexto2 = " lembrá-lo ".
    else assign vtexto1 = "Prezada "
                vtexto2 = " lembrá-la ".

    put stream str-txt unformatted
         vtexto1 clien.clinom ",<br><br>Gostaríamos de " vtexto2 " que "
         "neste mês você possui um bônus para " 
         "gastar em qualquer Loja Lebes com "
         "validade até " string((vdt-aux - 1),"99/99/9999")                   ".</td></tr>"
         "<tr><td><br>Estamos aguardando você!<br><br></td></tr>" 
         "<tr><td>Atenciosamente,<br><br></td></tr> "
         "<tr><td>"
    "<img src = 'http://www.lebes.com.br/logo_lebes.jpg' alt='Lojas Lebes'> "             "</td></tr></table>"    . 
    
    output stream str-txt close.  
    
    assign v-ok-email = no.
    
    run pfval_mail2.p (input clien.zona, output v-ok-email).
                    
    if not v-ok-email or clien.zona = ?
    then next.

    v-env-mail = "/admcom/progr/mail.sh "
                + "~"" + "Lojas Lebes" + "~"" + " ~""
                + v-texto + "~"" + " ~""
                + clien.zona + "~""  
                + " ~"informativo@lebes.com.br~""
                + " ~"text/html~"".

    unix silent value(v-env-mail).
    
    display stream str-relat
            clien.clicod
            clien.clinom   format "x(30)"
            titulo.etbcod column-label "Fil"
            clien.zona format "x(30)" column-label "E-Mail"
            titulo.titvlcob  (total) column-label "Vl. Bonus"
            acao.acaocod when avail acao  format ">>>>>>9"
            acao.descricao when avail acao format "x(20)"
            titulo.titdtven
                                with frame f01 down width 145.
                            
end.
                            
output stream str-relat close.                            

output close.
/*
if opsys = "UNIX"
then do:
    message "Arquivo gerado: " varquivo. pause.
                                           
    run visurel.p (input varquivo, input "").
        
end.    
else do:
    {mrod.i}
end.    
*/ 
