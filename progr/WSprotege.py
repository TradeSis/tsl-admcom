#!/usr/bin/python

# by eduveks

import sys, httplib, array

try:
    method = ""        
    ccofre = ""
    dconsulta = ""
    dini = ""
    dfim = ""
    ceven = ""
    params = {}
    arqxml = ""

    for arg in sys.argv[1:]:
        if method == "" and arg.find("method=") == 0:
            method = arg[len("method="):]
        elif ccofre == "" and arg.find("ccofre=") == 0:
            ccofre = arg[len("ccofre="):]
        elif dconsulta == "" and arg.find("dconsulta=") == 0:
            dconsulta = arg[len("dconsulta="):]
        elif dini == "" and arg.find("dini=") == 0:
            dini = arg[len("dini="):]
        elif dfim == "" and arg.find("dfim=") == 0:
            dfim = arg[len("dfim="):]
        elif ceven == "" and arg.find("ceven=") == 0:
            ceven = arg[len("ceven="):]
        elif arqxml == "" and arg.find("arqxml=") == 0:
            arqxml = arg[len("arqxml="):]
        elif arg.find("param_") == 0:
            params[arg[len("param_"):arg.find("=")]] = arg[arg.find("=") + 1:]

    SOAP_Request =""
    SOAP_Request += "<?xml version='1.0' encoding='utf-8'?>"
    SOAP_Request += "<s:Envelope xmlns:s=\""
    SOAP_Request += "http://schemas.xmlsoap.org/soap/envelope/\">"
    SOAP_Request += "<s:Body><RetornarMovimentosCofreXML xmlns=\""
    SOAP_Request += "http://tempuri.org/\">"
    SOAP_Request += "<xmlEnvio>&lt;?xml version='1.0' "
    SOAP_Request += "encoding='utf-8'?&gt;&#xD;&lt;movimentos "
    SOAP_Request += "dataConsulta=\"" + dconsulta + "\""
    SOAP_Request += "&gt;&lt;login&gt;&lt;usuario&gt;drebes.financ&lt;"
    SOAP_Request += "/usuario&gt;&lt;senha&gt;1234&lt;/senha&gt;&lt;"
    SOAP_Request += "/login&gt;&lt;filtros&gt;&lt;codCofre"
    SOAP_Request += "&gt;" + ccofre + "&lt;/codCofre&gt;&lt;"
    SOAP_Request += "dtaDe&gt;" + dini + "&lt;/dtaDe&gt;&lt;"
    SOAP_Request += "dtaAte&gt;" + dfim + "&lt;/dtaAte&gt;&lt;"
    SOAP_Request += "tipEvento&gt;" + ceven + "&lt;/tipEvento&gt;&lt;"
    SOAP_Request += "/filtros&gt;&lt;/movimentos&gt;"
    SOAP_Request += "</xmlEnvio></RetornarMovimentosCofreXML>"
    SOAP_Request += "</s:Body></s:Envelope>"

    http = httplib.HTTP("177.11.253.55:8755")
    http.putrequest("POST", "/MovimentosCofre/")
    http.putheader("Host", "177.11.253.55:8755")
    http.putheader("User-Agent", "Python")
    http.putheader("Content-type", "text/xml")
    http.putheader("Content-length", "%d" % len(SOAP_Request))
    http.putheader("SOAPAction", "\"http://tempuri.org/IMovimentosCofre/RetornarMovimentosCofreXML\"")
    http.endheaders()
    http.send(SOAP_Request)

    http_response_statuscode, http_response_statusmessage, http_response_header = http.getreply()
    SOAP_Response = http.getfile().read()
    if http_response_statuscode == 200 and http_response_statusmessage == "OK":
        arquivo= open(arqxml,"w")
        arquivo.write(
                       SOAP_Response[SOAP_Response.find("<"+ method +"Result>") + len("<"+ method +"Result>"):SOAP_Response.find("</"+ method +"Result>")]
        )
        arquivo.close()
    else:
        print "### ERROR(1) ###############"
        if SOAP_Response.find("<faultstring>") > -1:
            print SOAP_Response[SOAP_Response.find("<faultstring>")  + len("<faultstring>"):SOAP_Response.find("</faultstring>")]
        print "Response: ", http_response_statuscode, http_response_statusmessage
        print http_response_header
        print SOAP_Response
        print SOAP_Request
except:
    print "### ERROR ###############(2)"
    for err in sys.exc_info():
        print err

