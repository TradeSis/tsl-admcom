#!/usr/bin/python

# by eduveks

import sys, httplib, array

from xml.etree.ElementTree import Element, ElementTree

import xml.etree.cElementTree as et
        

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
    SOAP_Request += "<soap:Envelope"
    SOAP_Request += " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
    SOAP_Request += " xmlns:xsd=\"http://www.w3.org/2001/XMLShema\""
    SOAP_Request += "             xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    SOAP_Request += "<soap:Body>"
    SOAP_Request += "<listarDepositosCofre"
    SOAP_Request += " xmlns=\"http://wwws.brinks.com.br/cwc\">"
    SOAP_Request += "<strNumeroSerial>" + ccofre + "</strNumeroSerial>"
    SOAP_Request += "<strDataIni>" + dini + "</strDataIni>"
    SOAP_Request += "<strDataFim>" + dfim + "</strDataFim>"
    SOAP_Request += "<strUsuario>ERIKAMULLER</strUsuario>"
    SOAP_Request += "<strSenha>Menezes.26</strSenha>"
    SOAP_Request += "</listarDepositosCofre>"
    SOAP_Request += "</soap:Body></soap:Envelope>"

    http = httplib.HTTP("wwws.brinks.com.br")
    http.putrequest("POST", "/wsCompusafeReceive/service.asmx")
    http.putheader("Host", "wwws.brinks.com.br")
    http.putheader("User-Agent", "Python")
    http.putheader("Content-type", "text/xml; charset=utf-8")
    http.putheader("Content-length", "%d" % len(SOAP_Request))
    http.putheader("SOAPAction", "\"http://wwws.brinks.com.br/cwc/listarDepositosCofre\"")
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

        arqtxt = arqxml + ".txt"
        fd = open(arqxml)
        parsedXML = et.parse(fd)
        Depositos = parsedXML.findall('Deposito')
        arquivo= open(arqtxt,"w")
        for depositoNode in Depositos:
            deposito = dict((attr.tag, attr.text) for attr in depositoNode)
            arquivo.write(deposito['ID'] + ";")
            arquivo.write(deposito['CODIGOCOFRE'] + ";")
            arquivo.write(deposito['NUM_RECIBO'] + ";")
            arquivo.write(deposito['VALOR'] + ";")
            arquivo.write(deposito['DATA_DEPOSITO'])
            arquivo.write("\n")
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

