def var vmetodo as char.
def var vLOG as char.
def var vxml    as char.

def {1} shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    index x is unique primary child-num asc root asc tag asc valor asc.

function geraXmlNfe returns char
    (input p-tipo   as character,
     input p-campo  as character,
     input p-valor  as character).

    def var vxml as char.

    if p-tipo = "Inicio"
    then
        if p-campo = "envNotamax"
        then vxml = "envNotamax=" +
               "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
               " <envNotamax>" + 
               " <login>" +
               " <usuario>publico</usuario>" +
               " <senha>senha</senha>" +
               " </login>" +
               " <parametros>" .
        else
        if p-campo = "xml_mdfe"
        then vxml = vxml + "&" + "xml_mdfe=" +
/**                "<?xml version=\"1.0\" encoding=\"utf-8\"?>".**/ "".


        else vxml = "xmlDados=" +
               "<?xml version=\"1.0\"?>" +
               "<" + p-campo + ">" +
               " <dados usuario_notamax =\"publico\"" +
               " senha_notamax=\"senha\"".

    if p-tipo = "Item"
    then vxml = vxml + " " + p-campo + "=\"" + p-valor + "\"".

    if p-tipo = "Tag"
    then vxml = vxml + "<" + p-campo + ">" + p-valor + "</" + p-campo + ">".


    if p-tipo = "GrupoINI"
    then if p-valor <> ""
         then vxml = vxml + "<"  + p-campo + " " + p-valor + " >".
         else vxml = vxml + "<" + p-campo + ">". 
 
    if p-tipo = "GrupoFIM"
    then vxml = vxml + "</" + p-campo + ">". 
           
    if p-tipo = "Fim"
    then
        if p-campo = "envNotamax"
        then vxml = vxml + "</parametros>" + "</envNotamax>" + chr(10).
        else vxml = vxml + "/>" + "</" + p-campo + ">" + chr(10).

    return vxml.

end function.

