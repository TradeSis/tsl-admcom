/*
#1 04/19 - Projeto ICMS Efetivo
*/
def input  parameter par-etbcod    as int.
def input  parameter par-chave     as char.
def output parameter par-ok        as log init yes.

def var par-root as char.
def var par-banco as char.
def var par-item as char.

def var cgc-admcom as char.
def var vserie as char.
def var vnumero as int.

assign cgc-admcom = substring(par-chave,7,14)
       vserie     = string(int(substring(par-chave,23,3)))
       vnumero    = int(substring(par-chave,26,9)).
                              
find estab where estab.etbcod = par-etbcod no-lock.
find first forne where forne.forcgc = cgc-admcom no-lock.

def var par-cnpj as char.

par-cnpj = estab.etbcgc .
par-cnpj = replace(par-cnpj,".","").
par-cnpj = replace(par-cnpj,"/","").
par-cnpj = replace(par-cnpj,"-","").

def new shared temp-table tt-tablexml no-undo
    field root   as char
    field banco  as char
    field tabela as char
    field campo  as char
    field valor  as char
    .

def var varqlog as char.
def var varqretorno as char.
def var p-conecta as log.
def var v-metodo as char.
def var par-metodo as char.
def var par-xml as char.
def var vretorno as longchar.
def var vusuario as char init "publico".
def var vsenha as char init "senha".

v-metodo = "NFeRecebimentoConsultarXMLDistribuicao".
par-metodo = "/notamax/services/wsNotamax.asmx/" + v-metodo.

varqlog = "/admcom/relat/" + v-metodo + "." + string(mtime).

varqretorno = "/admcom/relat/" + v-metodo + "_"
                + string(mtime) + ".xml".

par-xml =  "envNotamax=<?xml version='1.0'?><envNotamax><login>" +
               "<usuario>" + vusuario + "</usuario>" +
               "<senha>" + vsenha + "</senha>" +
               "</login>" +
               "<parametros>" + 
               "<chNfe>" + trim(par-chave) + "</chNfe>" +
               "<download>S</download>" +
               "<download_cnpj_dest>" + par-cnpj + "</download_cnpj_dest>" +
               "</parametros>" + 
               "</envNotamax>"
                .

run client_socket_notamax_recebimento.p(
                    input "10.2.0.121",
                    input "80",
                    input par-metodo,
                    input par-xml,
 /*Content-Type*/   input "application/x-www-form-urlencoded",
                    input varqlog,
                    input varqretorno,
                    output p-conecta,
                    output vretorno).

pause 1 no-message. 

output to value("/admcom/relat/retorno-notarec." + string(mtime)+ ".txt").
export vretorno.
output close.

run p-retorno.

/*
for each tt-tablexml.
    disp tt-tablexml.
end.
return.    
*/

def temp-table tt-y01_cobr like y01_cobr.

def buffer btt-tablexml for tt-tablexml.
def buffer ctt-tablexml for tt-tablexml.
find first tt-tablexml where tt-tablexml.tabela = "infnfe" no-error.
if avail tt-tablexml
then do:
    find a01_infnfe where a01_infnfe.chave = par-chave no-error.
    if not avail a01_infnfe
    then do:
        create a01_infnfe.
        assign
            a01_infnfe.chave = par-chave
            a01_infnfe.emite = ? 
            a01_infnfe.serie = ?
            a01_infnfe.numero = ?
            a01_infnfe.etbcod = ?
            a01_infnfe.placod = ?
            . 
    end.
    for each btt-tablexml where btt-tablexml.tabela = "infnfe" no-lock:
        if btt-tablexml.campo = "ID"
        then a01_infnfe.id = replace(btt-tablexml.valor,"~"","").
        if btt-tablexml.campo = "versao"
        then a01_infnfe.versao = dec(replace(btt-tablexml.valor,"~"","")).
                                
    end.         

    find B01_IdeNFe where B01_IdeNFe.chave = par-chave no-error.
    if not avail B01_IdeNFe
    then do:
        create B01_IdeNFe.
        B01_IdeNFe.chave = par-chave.
    end.    
    
    for each btt-tablexml where btt-tablexml.tabela = "ide" no-lock:
        case btt-tablexml.campo:
            when "cuf" then B01_IdeNFe.cuf = int(btt-tablexml.valor).
            when "cnf" then B01_IdeNFe.cnf = int(btt-tablexml.valor).
            when "natop" then B01_IdeNFe.natop = btt-tablexml.valor.
            when "indpag" then B01_IdeNFe.indpag = int(btt-tablexml.valor).
            when "mod" then B01_IdeNFe.mod = btt-tablexml.valor.
            when "serie" then B01_IdeNFe.serie = int(btt-tablexml.valor).
            when "dhemi"
            then B01_IdeNFe.demi = date(int(substr(btt-tablexml.valor,6,2)),
                                    int(substr(btt-tablexml.valor,9,2)),
                                    int(substr(btt-tablexml.valor,1,4))).
            when "dhsaiEnt"
            then B01_IdeNFe.dsaiEnt = date(int(substr(btt-tablexml.valor,6,2)),
                                       int(substr(btt-tablexml.valor,9,2)),
                                       int(substr(btt-tablexml.valor,1,4))).
            when "hsaient" 
            then B01_IdeNFe.hsaient = substr(btt-tablexml.valor,12,14).
            when "tpnf" then B01_IdeNFe.tpnf = int(btt-tablexml.valor).
            when "cmunfg" then B01_IdeNFe.cmunfg = int(btt-tablexml.valor).
            when "tpImp" then B01_IdeNFe.tpImp = btt-tablexml.valor.
            when "TpEmis" then B01_IdeNFe.TpEmis = int(btt-tablexml.valor).
            when "Cdv" then B01_IdeNFe.Cdv = int(btt-tablexml.valor).
            when "IdAmb" then B01_IdeNFe.IdAmb = int(btt-tablexml.valor).
            when "FinNFe" then B01_IdeNFe.FinNFe = int(btt-tablexml.valor).
            when "VerProc" then B01_IdeNFe.VerProc = btt-tablexml.valor.
            when "DtHoraCont" then B01_IdeNFe.DtHoraCont = btt-tablexml.valor.
            when "xJust" then B01_IdeNFe.xJust = btt-tablexml.valor.
            when "nNF" then B01_IdeNFe.nNF = int(btt-tablexml.valor).
            when "procemi" then B01_IdeNFe.procemi = int(btt-tablexml.valor).
            when "TEmite" then B01_IdeNFe.TEmite = btt-tablexml.valor.
            when "TDesti" then B01_IdeNFe.TDesti = btt-tablexml.valor.
            when "hemi" then B01_IdeNFe.hemi = int(btt-tablexml.valor).
            when "indPres" then B01_IdeNFe.indPres = int(btt-tablexml.valor).
            when "idDest" then B01_IdeNFe.idDest = int(btt-tablexml.valor).
            when "indFinal" then B01_IdeNFe.indFinal = int(btt-tablexml.valor).
         end case.
                 
    end.
    
    find c01_emit where c01_emit.chave = par-chave no-error.
    if not avail c01_emit
    then do:
        create c01_emit.
        c01_emit.chave = par-chave.
    end. 
    
    for each btt-tablexml where btt-tablexml.tabela = "emit" or
                                btt-tablexml.tabela = "enderEmit" 
                                no-lock:
        case btt-tablexml.campo:
            when "cnpj" then c01_emit.cnpj = btt-tablexml.valor.
            when "cpf" then c01_emit.cpf = btt-tablexml.valor.
            when "xnome" then c01_emit.xnome = btt-tablexml.valor.
            when "xFant" then c01_emit.xFant = btt-tablexml.valor.
            when "xLgr" then c01_emit.xLgr = btt-tablexml.valor.
            when "Nro" then c01_emit.Nro = btt-tablexml.valor.
            when "xCpl" then c01_emit.xCpl = btt-tablexml.valor.
            when "xBairro" then c01_emit.xBairro = btt-tablexml.valor.
            when "cMun" then c01_emit.cMun = int(btt-tablexml.valor).
            when "xMun" then c01_emit.xMun = btt-tablexml.valor.
            when "uf" then c01_emit.uf = btt-tablexml.valor.
            when "cep" then c01_emit.cep = int(btt-tablexml.valor).
            when "cpais" then c01_emit.cpais = int(btt-tablexml.valor).
            when "xPais" then c01_emit.xPais = btt-tablexml.valor.
            when "fone" then c01_emit.fone = dec(btt-tablexml.valor).
            when "IE" then c01_emit.IE = btt-tablexml.valor.
            when "iest" then c01_emit.iest = btt-tablexml.valor.
            when "im" then c01_emit.im = btt-tablexml.valor.
            when "cnae" then c01_emit.cnae = btt-tablexml.valor.
            when "crt" then c01_emit.crt = int(btt-tablexml.valor).
        end case.
    end. 
 
    find e01_dest where e01_dest.chave = par-chave no-error.
    if not avail e01_dest
    then do:
        create e01_dest.
        e01_dest.chave = par-chave.
    end. 
    
    for each btt-tablexml where btt-tablexml.tabela = "dest" or
                                btt-tablexml.tabela = "enderDest" 
                                no-lock:
        case btt-tablexml.campo:
            when "cnpj" then e01_dest.cnpj = btt-tablexml.valor.
            when "cpf" then e01_dest.cpf = btt-tablexml.valor.
            when "xnome" then e01_dest.xnome = btt-tablexml.valor.
            when "xLgr" then e01_dest.xLgr = btt-tablexml.valor.
            when "Nro" then e01_dest.Nro = btt-tablexml.valor.
            when "xCpl" then e01_dest.xCpl = btt-tablexml.valor.
            when "xBairro" then e01_dest.xBairro = btt-tablexml.valor.
            when "cMun" then e01_dest.cMun = int(btt-tablexml.valor).
            when "xMun" then e01_dest.xMun = btt-tablexml.valor.
            when "uf" then e01_dest.uf = btt-tablexml.valor.
            when "cep" then e01_dest.cep = int(btt-tablexml.valor).
            when "cpais" then e01_dest.cpais = int(btt-tablexml.valor).
            when "xPais" then e01_dest.xPais = btt-tablexml.valor.
            when "fone" then e01_dest.fone = dec(btt-tablexml.valor).
            when "IE" then e01_dest.IE = btt-tablexml.valor.
            when "isuf" then e01_dest.isuf = btt-tablexml.valor.
            when "email" then e01_dest.email = btt-tablexml.valor.
            when "indIEDest" then e01_dest.indIEDest = int(btt-tablexml.valor).
            when "idEstrangeiro" 
            then e01_dest.idEstrangeiro = btt-tablexml.valor.
        end case.
    end.  

    for each btt-tablexml where btt-tablexml.tabela = "det" no-lock:
        case btt-tablexml.campo:
            when "nitem"
            then do:
                find first i01_prod where
                           i01_prod.chave = par-chave and
                           i01_prod.nitem = int(btt-tablexml.valor)
                           no-error.
                if not avail i01_prod
                then do:
                    create i01_prod.
                    assign
                        i01_prod.chave = par-chave
                        i01_prod.nitem = int(btt-tablexml.valor)
                        .
                end.
                /*i01_prod.procod = 0.*/
                for each ctt-tablexml where
                         ctt-tablexml.banco = btt-tablexml.valor no-lock:
                    case ctt-tablexml.tabela:
                        when "Prod"
                        then do:
                            case ctt-tablexml.campo:
                                when "cProd" 
                                then i01_prod.cProd = ctt-tablexml.valor.
                                when "cEAN" 
                                then i01_prod.cEAN = ctt-tablexml.valor.
                                when "xProd" 
                                then i01_prod.xProd[1] = ctt-tablexml.valor.
                                when "NCM" 
                                then i01_prod.NCM = ctt-tablexml.valor.
                                when "EXTIPI" 
                                then i01_prod.EXTIPI = ctt-tablexml.valor.
                                when "cfop" 
                                then i01_prod.cfop = int(ctt-tablexml.valor).
                                when "Ucom" 
                                then i01_prod.Ucom = ctt-tablexml.valor.
                                when "qCom" 
                                then i01_prod.qCom = dec(ctt-tablexml.valor).
                                when "VUnCom" 
                                then i01_prod.VUnCom = dec(ctt-tablexml.valor).
                                when "Vprod" 
                                then i01_prod.Vprod = dec(ctt-tablexml.valor).
                                when "cEANtrib" 
                                then i01_prod.cEANtrib = ctt-tablexml.valor.
                                when "uTrib" 
                                then i01_prod.uTrib = ctt-tablexml.valor.
                                when "qTrib" 
                                then i01_prod.qTrib = dec(ctt-tablexml.valor).
                                when "VUnTrib" then 
                                    i01_prod.VUnTrib = dec(ctt-tablexml.valor).
                                when "Vfrete" 
                                then i01_prod.Vfrete = dec(ctt-tablexml.valor).
                                when "VSeg" 
                                then i01_prod.VSeg = dec(ctt-tablexml.valor).
                                when "VDesc" 
                                then i01_prod.VDesc = dec(ctt-tablexml.valor).
                                when "VOutro" 
                                then i01_prod.VOutro = dec(ctt-tablexml.valor).
                                when "IndProd" 
                                then i01_prod.IndProd = ctt-tablexml.valor.
                                when "infAdProd" 
                                then i01_prod.infAdProd = ctt-tablexml.valor.
                                when "genero" 
                                then i01_prod.genero = ctt-tablexml.valor.
                                when "CEST" 
                                then i01_prod.CEST = ctt-tablexml.valor.
                                when "movpc" 
                                then i01_prod.movpc = dec(ctt-tablexml.valor).
                            end case.
                        end.
                        OTHERWISE do:
                            run impostos.
                        end.
                    end case.    
                end.
            end.
        end case.
    end.
    
    find w01_total where w01_total.chave = par-chave no-error.
    if not avail w01_total
    then do:
        create w01_total.
        w01_total.chave = par-chave.
    end.    
    
    for each btt-tablexml where btt-tablexml.tabela = "ICMSTot" no-lock:
        case btt-tablexml.campo:
            when "vBC" then w01_total.vBC = dec(btt-tablexml.valor).
            when "vICMS" then w01_total.vICMS = dec(btt-tablexml.valor).
            when "vBCST" then w01_total.vBCST = dec(btt-tablexml.valor).
            when "vST" then w01_total.vST = dec(btt-tablexml.valor).
            when "Vprod" then w01_total.Vprod = dec(btt-tablexml.valor).
            when "Vfrete" then w01_total.Vfrete = dec(btt-tablexml.valor).
            when "VSeg" then w01_total.VSeg = dec(btt-tablexml.valor).
            when "VDesc" then w01_total.VDesc = dec(btt-tablexml.valor).
            when "vII" then w01_total.vII = dec(btt-tablexml.valor).
            when "vIPI" then w01_total.vIPI = dec(btt-tablexml.valor).
            when "vPIS" then w01_total.vPIS = dec(btt-tablexml.valor).
            when "vCOFINS" then w01_total.vCOFINS = dec(btt-tablexml.valor).
            when "vOutro" then w01_total.vOutro = dec(btt-tablexml.valor).
            when "vNF" then w01_total.vNF = dec(btt-tablexml.valor).
            when "vFCP" then w01_total.vFCP = dec(btt-tablexml.valor).
            when "vFCPST" then w01_total.vFCPST = dec(btt-tablexml.valor).
            when "vFCPSTRet" then w01_total.vFCPSTRet = dec(btt-tablexml.valor).
            when "vIPIDevol" then w01_total.vIPIDevol = dec(btt-tablexml.valor).
        end case.
    end.      
    
    find first x01_transp where x01_transp.chave = par-chave no-error.
    if not avail x01_transp
    then do:
        create x01_transp.
        assign
            x01_transp.chave = par-chave
            x01_transp.cnpj  = ?
            x01_transp.cpf = ?
            .
    end.
    
    for each btt-tablexml where 
             btt-tablexml.tabela matches "*transp*" no-lock:
        case btt-tablexml.campo:
            when "modFrete" then x01_transp.modFrete = int(btt-tablexml.valor).
            when "xnome" then x01_transp.xnome = btt-tablexml.valor.
            when "IE" then x01_transp.IE = btt-tablexml.valor.
            when "xEnder" then x01_transp.xEnder = btt-tablexml.valor.
            when "uf" then x01_transp.uf = btt-tablexml.valor.
            when "xmun" then x01_transp.xmun = btt-tablexml.valor.
            when "cnpj" then x01_transp.cnpj = btt-tablexml.valor.
            when "cpf" then x01_transp.cpf = btt-tablexml.valor.
            when "vServ" then x01_transp.vServ = dec(btt-tablexml.valor).
            when "vBCRet" then x01_transp.vBCRet = dec(btt-tablexml.valor).
            when "pICMSRet" then x01_transp.pICMSRet = dec(btt-tablexml.valor).
            when "vICMSRet" then x01_transp.vICMSRet = dec(btt-tablexml.valor).
            when "CFOP" then x01_transp.CFOP = int(btt-tablexml.valor).
            when "cMunFG" then x01_transp.cMunFG = int(btt-tablexml.valor).
            when "placa" then x01_transp.placa = btt-tablexml.valor.
            when "uf-placa" then x01_transp.uf-placa = btt-tablexml.valor.
            when "RNTC" then x01_transp.RNTC = btt-tablexml.valor.
            when "DtMDFe" then x01_transp.DtMDFe = date(btt-tablexml.valor).
        end case.
    end.                

    def var vndup as char.
    def var vdvenc as date.
    def var vnfat as char.
    def var vvliq as dec.
    def var vvorig as dec.
    def var vvdesc as dec.
    def var vvdup as dec.

    vndup = "".
    vdvenc = ?.
    vnfat = "".
    vvliq = 0.
    vvorig = 0.
    vvdesc = 0.
    vvdup = 0.
 
    for each btt-tablexml where 
             btt-tablexml.root = "infnfe" and
             btt-tablexml.tabela = "dup" no-lock:

        case btt-tablexml.campo:
            when "nDup" then vndup = btt-tablexml.valor.
            when "nFat" then vnFat = btt-tablexml.valor.
            when "VLiq" then vVLiq = dec(btt-tablexml.valor).
            when "VOrig" then vVOrig = dec(btt-tablexml.valor).
            when "VDesc" then vVDesc = dec(btt-tablexml.valor).
            when "dvenc" then          
                 vdvenc = date(int(substr(btt-tablexml.valor,6,2)),
                                       int(substr(btt-tablexml.valor,9,2)),
                                       int(substr(btt-tablexml.valor,1,4)))
                                        .
            when "VDup" then vVDup = dec(btt-tablexml.valor).
        end case.
        
        if vvdup > 0 and vdvenc <> ? and vndup <> ""
        then do:
            find first y01_cobr where
                       y01_cobr.chave = par-chave and
                       y01_cobr.ndup  = vndup and
                       y01_cobr.dvenc = vdvenc
                       no-error.
            if not avail y01_cobr
            then do:           
                create y01_cobr.
                assign
                    y01_cobr.chave = par-chave
                    y01_cobr.nDup = vndup
                    y01_cobr.dvenc = vdvenc
                    .
            end.
            assign        
                y01_cobr.nfat = vnfat
                y01_cobr.vliq = vvliq
                y01_cobr.vorig = vvorig
                y01_cobr.vdesc = vvdesc
                y01_cobr.vdup  = vvdup
                .
            assign
            vndup = "" vnFat = "" vVLiq = 0 vVOrig = 0 vVDesc = 0
            vdvenc = ? vVDup = 0.
 
        end.
    end.
    for each btt-tablexml where 
             btt-tablexml.root = "cobr" and
             btt-tablexml.tabela = "dup" no-lock:
        case btt-tablexml.campo:
            when "nDup" then vndup = btt-tablexml.valor.
            when "nFat" then vnFat = btt-tablexml.valor.
            when "VLiq" then vVLiq = dec(btt-tablexml.valor).
            when "VOrig" then vVOrig = dec(btt-tablexml.valor).
            when "VDesc" then vVDesc = dec(btt-tablexml.valor).
            when "dvenc" then          
                 vdvenc = date(int(substr(btt-tablexml.valor,6,2)),
                                       int(substr(btt-tablexml.valor,9,2)),
                                       int(substr(btt-tablexml.valor,1,4)))
                                        .
            when "VDup" then vVDup = dec(btt-tablexml.valor).
        end case.
        
        if vvdup > 0 and vdvenc <> ? and vndup <> ""
        then do:
            find first y01_cobr where
                       y01_cobr.chave = par-chave and
                       y01_cobr.ndup  = vndup and
                       y01_cobr.dvenc = vdvenc
                       no-error.
            if not avail y01_cobr
            then do:           
                create y01_cobr.
                assign
                    y01_cobr.chave = par-chave
                    y01_cobr.nDup = vndup
                    y01_cobr.dvenc = vdvenc
                    .
            end.
            assign        
                y01_cobr.nfat = vnfat
                y01_cobr.vliq = vvliq
                y01_cobr.vorig = vvorig
                y01_cobr.vdesc = vvdesc
                y01_cobr.vdup  = vvdup
                .
            assign
            vndup = "" vnFat = "" vVLiq = 0 vVOrig = 0 vVDesc = 0
            vdvenc = ? vVDup = 0.
 
        end.
    end.         
end.    

procedure impostos:
    def var vvalor as dec.
    
    if  ctt-tablexml.root = "imposto"
    then do: 
        if ctt-tablexml.tabela begins "ICMSSN"
        then do:
             
            find n01_icms where n01_icms.chave = par-chave and
                                n01_icms.nitem = i01_prod.nitem and
                      n01_icms.CST   = 90
                      /*int(substr(ctt-tablexml.tabela,7,3))*/
                      no-error.
            if not avail n01_icms
            then do:
                create n01_icms.
                assign
                    n01_icms.chave = par-chave
                    n01_icms.nitem = i01_prod.nitem
                    n01_icms.CST   = 90
                    /*int(substr(ctt-tablexml.tabela,7,3))*/
                    .
            end.          
            case ctt-tablexml.campo:
                when "orig" then n01_icms.orig = int(ctt-tablexml.valor).
                when "CST" then n01_icms.CST = int(ctt-tablexml.valor).
                when "vCredICMSSN" 
                then do:
                    if int(substr(ctt-tablexml.tabela,7,3)) = 101
                    then n01_icms.vICMS = dec(ctt-tablexml.valor).
                end.
            end case.

        end.

        else if ctt-tablexml.tabela begins "ICMS"
        then do:
            find n01_icms where n01_icms.chave = par-chave and
                                n01_icms.nitem = i01_prod.nitem and
                         n01_icms.CST   = int(substr(ctt-tablexml.tabela,5,2))
                      no-error.
            if not avail n01_icms
            then do:
                create n01_icms.
                assign
                    n01_icms.chave = par-chave
                    n01_icms.nitem = i01_prod.nitem
                    n01_icms.CST   = int(substr(ctt-tablexml.tabela,5,2))
                    .
            end.

            vvalor = dec(ctt-tablexml.valor) no-error.
            case ctt-tablexml.campo:
                when "orig" then n01_icms.orig = int(ctt-tablexml.valor).
                when "CST" then n01_icms.CST = int(ctt-tablexml.valor).
                when "modBC" then n01_icms.modBC = dec(ctt-tablexml.valor).
                when "vBC" then n01_icms.vBC = dec(ctt-tablexml.valor).
                when "pICMS" then n01_icms.pICMS = dec(ctt-tablexml.valor).
                when "vICMS" then n01_icms.vICMS = dec(ctt-tablexml.valor).
                when "modBCST" then n01_icms.modBCST = int(ctt-tablexml.valor).
                when "pMVAST" then n01_icms.pMVAST = dec(ctt-tablexml.valor).
                when "pRedBCST" then 
                        n01_icms.pRedBCST = dec(ctt-tablexml.valor).
                when "vBCST" then n01_icms.vBCST = dec(ctt-tablexml.valor).
                when "pICMSST" then n01_icms.pICMSST = dec(ctt-tablexml.valor).
                when "vicmsst" then n01_icms.vicmsst = dec(ctt-tablexml.valor).
                when "predbc" then n01_icms.predbc = dec(ctt-tablexml.valor).
                when "vicmsop" then n01_icms.vicmsop = dec(ctt-tablexml.valor).
                when "pdif" then n01_icms.pdif = dec(ctt-tablexml.valor).
                when "vicmsdif" then n01_icms.vicmsdif =
                 dec(ctt-tablexml.valor).

                /* grupo N23 */
  /* N23a */    when "vBCFCPST"    then n01_icms.vBCFCPST = vvalor.
  /* N23b */    when "pFCPST"      then n01_icms.pFCPST = vvalor.
  /* N23d */    when "vFCPST"      then n01_icms.vFCPST = vvalor.

                /* grupo N25.1 */
  /* N26 */     when "vBCSTRet"    then n01_icms.vBCSTRet    = vvalor.
  /* N26a */    when "pST"         then n01_icms.pST         = vvalor.
  /* N26b */    when "vICMSSubstituto" then n01_icms.vICMSSubstituto = vvalor.
  /* N27 */     when "vICMSSTRet"  then n01_icms.vICMSSTRet  = vvalor.

                /* grupo N27.1 */
  /* N27a */    when "vBCFCPSTRet" then n01_icms.vBCFCPSTRet = vvalor.
  /* N27b */    when "pFCPSTRet"   then n01_icms.pFCPSTRet   = vvalor.
  /* N27d */    when "vFCPSTRet"   then n01_icms.vFCPSTRet   = vvalor.
            
            end case.
        end.
        case ctt-tablexml.tabela:
            when "IPI"
            then do:
                find o01_ipi where o01_ipi.chave = par-chave and
                                   o01_ipi.nitem = i01_prod.nitem 
                                   no-error.
                if not avail o01_ipi
                then do:
                    create o01_ipi.
                    assign
                        o01_ipi.chave = par-chave
                        o01_ipi.nitem = i01_prod.nitem
                        .
                end.        
                case ctt-tablexml.campo:
                    when "clEnq" then o01_ipi.clEnq = ctt-tablexml.valor.
                    when "cnpjProd" then o01_ipi.cnpjProd = ctt-tablexml.valor.
                    when "cSelo" then o01_ipi.cSelo = ctt-tablexml.valor.
                    when "qSelo" then o01_ipi.qSelo = dec(ctt-tablexml.valor).
                    when "cEnq" then o01_ipi.cEnq = ctt-tablexml.valor.
                    when "CST" then o01_ipi.CST = int(ctt-tablexml.valor).
                    when "vIPI" then o01_ipi.vIPI = dec(ctt-tablexml.valor).
                    when "vBC" then o01_ipi.vBC = dec(ctt-tablexml.valor).
                    when "pIPI" then o01_ipi.pIPI = dec(ctt-tablexml.valor).
                    when "vunid" then o01_ipi.vunid = dec(ctt-tablexml.valor).
                    when "qUnid" then o01_ipi.qUnid = dec(ctt-tablexml.valor).
                end case.
            end.
            when "IPItrib"
            then do:
                find o01_ipi where o01_ipi.chave = par-chave and
                                   o01_ipi.nitem = i01_prod.nitem 
                                   no-error.
                if not avail o01_ipi
                then do:
                    create o01_ipi.
                    assign
                        o01_ipi.chave = par-chave
                        o01_ipi.nitem = i01_prod.nitem
                        .
                end.        
                case ctt-tablexml.campo:
                    when "clEnq" then o01_ipi.clEnq = ctt-tablexml.valor.
                    when "cnpjProd" then o01_ipi.cnpjProd = ctt-tablexml.valor.
                    when "cSelo" then o01_ipi.cSelo = ctt-tablexml.valor.
                    when "qSelo" then o01_ipi.qSelo = dec(ctt-tablexml.valor).
                    when "cEnq" then o01_ipi.cEnq = ctt-tablexml.valor.
                    when "CST" then o01_ipi.CST = int(ctt-tablexml.valor).
                    when "vIPI" then o01_ipi.vIPI = dec(ctt-tablexml.valor).
                    when "vBC" then o01_ipi.vBC = dec(ctt-tablexml.valor).
                    when "pIPI" then o01_ipi.pIPI = dec(ctt-tablexml.valor).
                    when "vunid" then o01_ipi.vunid = dec(ctt-tablexml.valor).
                    when "qUnid" then o01_ipi.qUnid = dec(ctt-tablexml.valor).
                end case.
            end.
            when "PISAliq"
            then do:
                find q01_pis where q01_pis.chave = par-chave and
                                   q01_pis.nitem = i01_prod.nitem 
                                   no-error.
                if not avail q01_pis
                then do:
                    create q01_pis.
                    assign
                        q01_pis.chave = par-chave
                        q01_pis.nitem = i01_prod.nitem
                        .
                end.        
                case ctt-tablexml.campo:
                    when "CST" then q01_pis.CST = int(ctt-tablexml.valor).
                    when "vBC" then q01_pis.vBC = dec(ctt-tablexml.valor).
                    when "pPIS" then q01_pis.pPIS = dec(ctt-tablexml.valor).
                    when "vPIS" then q01_pis.vPIS = dec(ctt-tablexml.valor).
                    when "qBCProd" then 
                            q01_pis.qBCProd = dec(ctt-tablexml.valor).
                    when "vAliqProd" then 
                            q01_pis.vAliqProd = dec(ctt-tablexml.valor). 
                end case.
            end.
            when "COFINSAliq"
            then do:
                find s01_cofins where s01_cofins.chave = par-chave and
                                      s01_cofins.nitem = i01_prod.nitem 
                                   no-error.
                if not avail s01_cofins
                then do:
                    create s01_cofins.
                    assign
                        s01_cofins.chave = par-chave
                        s01_cofins.nitem = i01_prod.nitem
                        .
                end. 
                case ctt-tablexml.campo:
                    when "CST" then s01_cofins.CST = int(ctt-tablexml.valor).
                    when "vBC" then s01_cofins.vBC = dec(ctt-tablexml.valor).
                    when "pCOFINS" then 
                            s01_cofins.pCOFINS = dec(ctt-tablexml.valor).
                    when "vCOFINS" then 
                            s01_cofins.vCOFINS = dec(ctt-tablexml.valor).
                    when "qBCProd" then 
                            s01_cofins.qBCProd = dec(ctt-tablexml.valor).    
                    when "vAliqProd" then 
                            s01_cofins.vAliqProd = dec(ctt-tablexml.valor).
                end case.
            end.
        end case.
    end.                                    
end procedure.


procedure p-retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.
    def var vb      as memptr.
    set-size(vb) = 200001.
        
    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").
    vretorno = replace(vretorno, "det nitem=~"","det><nitem>").
    vretorno = replace(vretorno, "~"><prod>","</nitem><prod>").
    vretorno = replace(vretorno, "<infNFe versao=","<infNFe><versao>").
    vretorno = replace(vretorno, "<infNFe Id=","<infNFe><Id>").
    vretorno = replace(vretorno, " Id=","</versao><Id>").
    vretorno = replace(vretorno, "><ide","</Id><ide").

    output to value("/admcom/relat/retorno-notarec1" + "." + string(mtime) +
                    ".txt").
    export vretorno.
    output close.
    
    put-string(vb, 1) = vretorno.

    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 

    if hroot:num-children > 1
    then run obtemroot(hroot:name, input "", input hroot).
    else run obtemcampo(hroot:name, input "", input hroot).

    set-size(vb) = 0.
    
end procedure.

procedure obtemroot.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        par-root = vh:name.
        vh:get-child(hc,loop).
        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        par-item = "" .
        if hc:num-children > 1
        then run obtemroot(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.tabela  = "". 
                tt-tablexml.campo   = "".
                tt-tablexml.valor   = trim(hc:node-value).
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
            end.
        end. 
    end.                       
end procedure.

procedure obtembanco.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    par-banco = p-tabela.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        par-item = "" .
        if hc:num-children > 1
        then run obtemtable(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco   = par-banco.
                tt-tablexml.tabela  = "". 
                tt-tablexml.campo   = "".
                tt-tablexml.valor   = trim(hc:node-value).
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
              end.
        end. 
    end.                       
end procedure.


procedure obtemtable.

    def input parameter p-root  as char.
    def input parameter p-tabela as char.
    def input parameter vh      as handle.
    def var p-campo as char.
    def var vitem as int.
    def var hc   as handle.
    def var loop as int.
    vitem = 0.
    par-root = p-root.
    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).

        /*
        if hc:name = "numitem"
        then vitem = int(hc:node-value).
        */
        if hc:num-children > 1
        then run obtemtable(vh:name, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(vh:name, hc:name, input hc:handle).
            else do:
                p-campo = vh:name.
                if p-campo = "nitem"
                then par-item = trim(hc:node-value).
                if p-tabela = "icmstot"
                then par-item = "".
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco   = par-banco.
                tt-tablexml.tabela  = p-tabela. 
                tt-tablexml.campo   = p-campo.
                tt-tablexml.valor   = trim(hc:node-value).
                if par-item <> "" 
                then  tt-tablexml.banco   = par-item .
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
              end.
        end. 
    end.                       
end procedure.

procedure obtemcampo.

    def input parameter p-root  as char.
    def input parameter p-campo as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.
    
    create x-noderef hc.
    /* A partir daqui monta o retorno */
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        /*
        message "333" hc:num-children hc:name hc:node-value . pause.
        */
        
        if hc:num-children > 1
        then run obtemtable(p-root, hc:name, input hc:handle).
        else do:
            if hc:name <> "#text"
            then run obtemcampo(p-root, hc:name, input hc:handle).
            else do:

                if p-campo = "nitem"
                then par-item = trim(hc:node-value).
                
                if p-root = "icmstot"
                then par-item = "".
                create tt-tablexml.
                tt-tablexml.root    = par-root.
                tt-tablexml.banco   = par-banco.
                tt-tablexml.tabela  = p-root.
                tt-tablexml.campo   = p-campo. 
                tt-tablexml.valor   = trim(hc:node-value).
                if par-item <> ""
                then  tt-tablexml.banco   = par-item .
                if tt-tablexml.root = "IPI"
                then tt-tablexml.root = "Imposto".
                if tt-tablexml.tabela = "Fat"
                then tt-tablexml.tabela = "Dup".
                if tt-tablexml.campo = "CSOSN"
                then assign
                        tt-tablexml.campo = "CST"
                        tt-tablexml.valor = "90"
                        .
             end.
        end. 
    end.                       

end procedure.

