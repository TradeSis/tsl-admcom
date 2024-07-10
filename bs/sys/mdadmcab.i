/*******************************************************************************
*  Programador(a)...: Mesquita                         Data....: 24/07/1992    *
*  Descricao Sumaria:                                                          *
*       - Cabecalho Padrao do Sistema Comercial                                *
*------------------------------------------------------------------------------*
* Parametros   | Usual          | Opcoes           | Comentario                *
*--------------|----------------|----------------------------------------------*
* &Saida     = | Printer        | Terminal/Arquivo | Meio de Saida             *
* &Page-Size = | 60             | Numero           | Linhas por Pagina         *
* &Append    = | Nao Usar       | Append           | Extender Arquivo          *
* &Cond-Var  = |  "80""         |  "80"  ate "160" | No. de Caracteres no Frame*
* &Page-Line = | 0              | Numero           | Formata Imp p/ n Linhas   *
* &Nom-Rel   = | """XXXXXXXX""" | Texto Livre      | Nome do Relatorio (8 Pos) *
* &Nom-Sis   = | """XXXXXXXX""" | Texto Livre      | Nome do Sistema           *
* &Tit-Rel   = | """XXXXXXXX""" | Texto Livre      | Titulo Relatorio Centrado *
* &Width     = | 80             | Numero           | Tamanho da linha          *
* &Form      = | frame xxxxxxx  | Texto            | Nome do Frame do cabe‡alho*
*******************************************************************************/

    def buffer menu1 for menu.
    def buffer menu3 for menu.
    def buffer apl1  for aplicativo.
    def var vcaminho as char.
    def var vcopias as int.

if true /**simpress = ""*/
then do:
    {sys/selimpre.i}.
end.

message color normal "IMPRESSORA SELECIONADA " SIMPRESS.
 
form header
    wempre.emprazsoc                                            +
        fill(" ",({&width} - length(wempre.emprazsoc) - 21))    +
    caps({&Nom-Rel})                                            +
        fill(" ",(21 - length({&Nom-Rel}) - 10))                +
    "PAG.: "                                                    +
    string(page-number,">>>9") format "x(248)"
    skip
    {&Nom-Sis}                                                  +
        fill(" ",({&width} - length({&Nom-Sis}) - 21))          +
    string(day(today),"99")                                     +
        " "                                                     +
    caps(vmesabr[month(today)])                                 +
        " "                                                     +
    string(year(today),"9999")                                  +
        " "                                                     +
        "  "                                                    +
        "  "                                                    +
    string(time,"hh:mm")
            format "x(248)"
    
    skip

    {&Centered}
    fill(" ",integer(string(truncate((({&width} -
        length({&Tit-Rel})) / 2),0),"999")))                    +
    caps({&Tit-Rel})
            format "x(248)" at 1
    skip
    /{&Centered}**/

    {&Tit-Rel1}
    

    fill ("-",{&width})
            format "x(248)"
    with {&Form}
        page-top
        no-box
        width 250.

if num-entries(varqsai,"~\") > 0
then do:
    def var varqsaiaux as char.
    def var varqsaixxx as int.
    varqsaiaux = "".
    do varqsaixxx = 1 to num-entries(varqsai,"~\"):
        varqsaiaux = varqsaiaux + 
                (if varqsaiaux = ""
                then ""
                else "/")
                + entry(varqsaixxx,varqsai,"~\") .
    end.
    varqsai = varqsaiaux.
end.

if simpress <>  "VISUALIZADOR WINDOWS" 
then  output to {&Saida} page-size {&Page-Size} 
        {&Append} no-convert.

if simpress =  "VISUALIZADOR WINDOWS" 
then do:
    output to {&Saida} page-size 0
        {&Append} no-convert.
    
    find first menu3 where menu3.menpro = 
        substr(program-name(1),1,length(program-name(1)) - 2) 
        no-lock no-error.
    if avail menu3 
    then do :
        find first menu1 where menu1.menord = menu3.ordsup
                            and menu1.menniv = menu3.menniv - 1
                           and menu1.aplicod = menu3.aplicod no-lock no-error.
    end.
    find first apl1 where apl1.aplicod = menu3.aplicod no-lock no-error.
    if avail apl1
    then
    vcaminho = apl1.aplinom + "-" + menu1.mentit + "-" + 
               menu3.mentit.
    else if avail menu1
        then
        vcaminho =  menu1.mentit + "-" +  menu3.mentit.
        else if avail menu3
            then
            vcaminho =  menu3.mentit.

           
         
     scabrel = trim(varqsai)          + "@" +
          trim(wempre.emprazsoc) + "@" +
          trim({&tit-rel})       + "@" +
          trim({&nom-rel})       + "@" +
          trim(vcaminho)       + "@" .
    
    if "{&disp}" = ""
    then
        display with {&form}.
    else
        put unformatted skip(1).

end.
else do:
    /** ADMCOM        **/
    find first impress where impress.nomeimp = simpress no-lock no-error.
    if avail impreSS
    then do:
        /*find impti of impre no-lock no-error.
        if avail impti
        then*/ do:
            if impress.nomeimp = "LASER"
            then do:
                put unformatted 
                        chr(27) + "E" + 
                         chr(27) + "&l00" + 
                         chr(27) + "&l26A" + 
                         chr(27) + "&a1L" +
                         chr(27) + "&a1E" + 
                         chr(27) + "&l1X" +
                         chr(27) + "&l0S" +
                         chr(27) + "&l85F" +
                         chr(27) +  "(s0p18h14V" +
                         chr(27) + "&l8D".
            end.
        end.
    end.
    
    if {&Page-Line} <> 0
    then
        put unformatted chr(27) + "C" + chr({&Page-Line}).

    if {&Cond-Var} >  137
    then
        put unformatted chr(27) + "M" + chr(15).

    if {&Cond-Var} >  96  and {&Cond-Var} <=  137
    then
        put unformatted chr(27) + "P" + chr(15).

    if {&Cond-Var} >  80  and {&Cond-Var} <=  96
    then
        put unformatted chr(27) + "M" + chr(18).

    if {&Cond-Var} <=  80
    then
        put unformatted chr(27) + "P" + chr(18).


    if "{&disp}" = ""
    then
        display with {&form}.
end.

/*
else do :
    
    find first menu3 where menu3.menpro = 
        substr(program-name(1),1,length(program-name(1)) - 2) 
        no-lock no-error.
    if avail menu3 
    then do :
        find first menu1 where menu1.menord = menu3.ordsup
                            and menu1.menniv = menu3.menniv - 1
                           and menu1.aplicod = menu3.aplicod no-lock no-error.
    end.
    find first apl1 where apl1.aplicod = menu3.aplicod no-lock no-error.
    if avail apl1
    then
    vcaminho = apl1.aplinom + "-" + menu1.mentit + "-" + 
               menu3.mentit.
    else if avail menu1
        then
        vcaminho =  menu1.mentit + "-" +  menu3.mentit.
        else if avail menu3
            then
            vcaminho =  menu3.mentit.

           


    scabrel = trim(varqsai)          + "@" +
          trim(wempre.emprazsoc) + "@" +
          trim({&tit-rel})       + "@" +
          trim({&nom-rel})       + "@" +
          trim(vcaminho)       + "@" .

end.          
*/

