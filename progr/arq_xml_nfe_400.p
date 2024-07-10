/*
#1 04/19 - Projeto ICMS Efetivo
*/
{gerxmlnfe.i}

pause 0.

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


FUNCTION fusohr returns character.
    return SUBSTRING(  STRING(DATETIME-TZ(DATE(STRING(DAY(today),"99") + "/" +
        STRING(MONTH(today),"99") + "/" + STRING(YEAR(today),"9999")), MTIME,
        TIMEZONE)),  24,6).
END FUNCTION.

  
{geraxml.i}

function topto returns character
    (input par-virgula as char).
    return replace(par-virgula,",",".").
end function.


function converte returns character
    (input par-valor as dec).

    return trim(replace(string(par-valor,"zzzzzzzzzzz9.99"), ",", ".")).

end function.


function Troca-Letra returns character
    (input par-texto as char).

    def var mletrade   as int  extent 6 init [199, 195, 138, 142, 166, 186].
    def var mletrapara as char extent 6 init ["C", "A", "C", "A", "A", "O"].
    def var vtexto as char.
    def var vletra as char.
    def var vct    as int.
    def var vi     as int.

    par-texto = caps(trim(replace(par-texto, "~\"," "))).
    do vi = 1 to length(par-texto).
        vletra = substring(par-texto, vi, 1).
        if asc(vletra) > 127
        then
            do vct = 1 to 6.
                if asc(vletra) = mletrade[vct]
                then vletra = mletrapara[vct].
            end.

        if      vletra = "<" then vtexto = vtexto + "&lt;".
        else if vletra = ">" then vtexto = vtexto + "&gt;".
        else if vletra = "&" then vtexto = vtexto + "&amp;".
        else if asc(vletra) = 34 then vtexto = vtexto + "&quot;". /* " */
        else if asc(vletra) = 39 then vtexto = vtexto + "&#39;".  /* ' */
        else
            if length(vletra) = 1 and
               asc(vletra) >  31 and
               asc(vletra) < 127
            then vtexto = vtexto + vletra.
    end.
    return vtexto.

end function.


def input  parameter p-recid   as recid.
def input  parameter p-idamb   as integer format "9".
def output parameter p-arquivo as char.

def var vcont-pro-aux as integer.
def var vtippes as log.
def var vcepaux   as char.
def var vfoneaux  as char.
def var vtesta    as dec.
def var vobservacao as char format "x(1000)".
def var vobservdec as char.
def var vdt       as char format "x(10)".
def var vnumero   as char.
def var vretorno  as char.
def var p-valor   as char.

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.

/* 3.10 */
find first e01_dest of a01_infnfe no-lock.
find first I01_Prod of A01_infnfe no-lock.

do on error undo.
    find B01_IdeNFe of A01_infnfe .
    B01_IdeNFe.idamb = p-idamb.
     
    if (I01_Prod.cfop > 2000 and I01_Prod.cfop < 2999) or
       (I01_Prod.cfop > 6000 and I01_Prod.cfop < 6999)
    then do:
        if e01_dest.indiedest <> 9
        then B01_IdeNFe.idDest = 2.
        else B01_IdeNFe.idDest = 1. 
    end.    
    else if (I01_Prod.cfop > 3000 and I01_Prod.cfop < 3999) or
            (I01_Prod.cfop > 7000 and I01_Prod.cfop < 7999)
    then B01_IdeNFe.idDest = 3.
end.

/***/
if I01_Prod.cfop <> 5927
then
    if program-name(2) <> "pre_nfe_5202.p" and
       (I01_Prod.cfop <> 1202 and I01_Prod.cfop <> 1411) /* P2k - Data Hub */
    then run nfex01transp_400.p (recid(a01_infnfe),1).
    else run nfex01transp_400.p (recid(a01_infnfe),9).

p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor).
p-arquivo = p-valor + A01_infnfe.chave + ".xml".

def var ind-chave as log.
def var chave-nfe like A01_infnfe.chave.

p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0, "NFE - GERAR CHAVE DE ACESSO",
                 OUTPUT p-valor).
if p-valor = "SIM"
then ind-chave = yes.
else ind-chave = no.

/**** ****/

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.
find B01_IdeNFe of A01_infnfe no-lock.
find estab where estab.etbcod = A01_infnfe.etbcod no-lock.

if ind-chave
then chave-nfe = "infNFe versao=~"4.00~" Id=~"" + A01_infnfe.chave + "~"".
else chave-nfe = "infNFe versao=~"4.00~" Id=~"" +  "~"".


output to value(p-arquivo).

geraxml("XML","","","").
geraxml("T1","","enviNFe xmlns=~"http://www.portalfiscal.inf.br/nfe~" xmlns:ds=~"http://www.w3.org/2000/09/xmldsig#~" xmlns:xsi=~"http://www.w3.org/2001/XMLSchema-instance~" versao=~"2.0~"","").
geraxml("T1","","NFe xmlns:xsi=~"http://www.w3.org/2001/XMLSchema-instance~" 
 xmlns=~"http://www.portalfiscal.inf.br/nfe~"","").
geraxml("T2","",chave-nfe,"").

/***
    B - Identificação da Nota Fiscal eletrônica
***/

geraxml("T3","","ide","").
geraxml("T4","T4","cUF",string(B01_IdeNFe.cuf)).
geraxml("T4","T4","cNF",string(B01_IdeNFe.cnf)).
geraxml("T4","T4","natOp",B01_IdeNFe.natOp).
/*geraxml("T4","T4","indPag",string(B01_IdeNFe.indpag)).*/
geraxml("T4","T4","mod",B01_IdeNFe.mod).
geraxml("T4","T4","serie",string(B01_IdeNFe.serie)).
geraxml("T4","T4","nNF",string(A01_infnfe.numero)).

vdt = string(year(B01_IdeNFe.demi),"9999") + "-" +
      string(month(B01_IdeNFe.demi),"99") + "-" +
      string(day(B01_IdeNFe.demi),"99") +
      "T" + string(B01_IdeNFe.hemi, "hh:mm:ss") + fusohr().
geraxml("T4","T4","dhEmi",vdt).

geraxml("T4","T4","tpNF",string(B01_IdeNFe.tpnf)).
geraxml("T4","T4","idDest", string(B01_IdeNFe.idDest)). /* 3.1 */
geraxml("T4","T4","cMunFG",string(B01_IdeNFe.cmunfg)).
geraxml("T4","T4","tpImp",B01_IdeNFe.tpimp).
geraxml("T4","T4","tpEmis",string(B01_IdeNFe.tpEmis)).
geraxml("T4","T4","cDV",string(B01_IdeNFe.cdv)).

/* ambiente: "2" = homologação / "1" = Producao */
geraxml("T4","T4","tpAmb",string(B01_IdeNFe.idamb)).

geraxml("T4","T4","finNFe", string(B01_IdeNFe.finnfe)).
geraxml("T4","T4","procEmi",string(B01_IdeNFe.procemi)).
geraxml("T4","T4","indFinal",string(B01_IdeNFe.indFinal)). /* 3.1 */
geraxml("T4","T4","indPres", string(B01_IdeNFe.indPres)).  /* 3.1 */
geraxml("T4","T4","verProc",B01_IdeNFe.verproc).

run exp-refer. /* 3.10 */

geraxml("","T3","ide","").

/***
    C - Identificação do Emitente da Nota Fiscal eletrônica
***/

find C01_Emit of A01_infnfe .
C01_Emit.xnome = replace(C01_Emit.xnome,"&","E").
C01_Emit.xfant = replace(C01_Emit.xfant,"&","E").

geraxml("T3","","emit","").

if C01_Emit.cnpj <> ""
then geraxml("T4","T4","CNPJ", C01_Emit.cnpj).
else geraxml("T4","T4","CPF",  C01_Emit.cpf).

geraxml("T4","T4","xNome",C01_Emit.xnome).
if C01_Emit.xfant <> ""
then geraxml("T4","T4","xFant",C01_Emit.xfant).

geraxml("T4","","enderEmit","").
geraxml("T5","T5","xLgr",C01_Emit.xlgr).
geraxml("T5","T5","nro",C01_Emit.nro).

if C01_Emit.xcpl <> ""
then geraxml("T5","T5","xCpl",C01_Emit.xcpl).

if C01_Emit.xbairro <> ""
then geraxml("T5","T5","xBairro",C01_Emit.xbairro).

geraxml("T5","T5","cMun",string(C01_Emit.cmun)).
geraxml("T5","T5","xMun",C01_Emit.xmun).
geraxml("T5","T5","UF",C01_Emit.uf).

assign vcepaux = string(C01_Emit.cep,"99999999"). 
geraxml("T5","T5","CEP",vcepaux).                 

geraxml("T5","T5","cPais",string(C01_Emit.cpais)).
geraxml("T5","T5","xPais",C01_Emit.xpais).

if string(C01_Emit.fone) <> "" and string(C01_Emit.fone) <> "0" 
then do:
     vfoneaux = string(/*string(C01_Emit.dddfone) +*/ string(C01_Emit.fone)). 
     vfoneaux = substring(vfoneaux,1,14).
     geraxml("T5","T5","fone",vfoneaux).
end.

geraxml("","T4","enderEmit","").

geraxml("T4","T4","IE",C01_Emit.ie).

if C01_Emit.iest <> ""
then geraxml("T4","T4","IEST",C01_Emit.iest).

/* TO DO CRT */
geraxml("T4","T4","CRT","3").

geraxml("","T3","emit","").

/***
    E - Identificação do Destinatário da Nota Fiscal eletrônica
***/
find E01_Dest of A01_infnfe .
E01_Dest.xnome = replace(E01_Dest.xnome,"&","E").           

geraxml("T3","","dest","").

if E01_Dest.cnpj <> "" 
then do:
    if length(E01_Dest.cnpj) > 11
    then geraxml("T4","T4","CNPJ",E01_Dest.cnpj).
    else geraxml("T4","T4","CPF",E01_Dest.cnpj).
end.
else if E01_Dest.idEstrangeiro <> ""
then geraxml("T4","T4","idEstrangeiro",E01_Dest.idEstrangeiro).

vtippes = E01_Dest.cpf <> "".

if E01_Dest.cpf <> ""
then geraxml("T4","T4","CPF",E01_Dest.cpf).

run trata_caract_esp.p(input E01_Dest.xnome, output E01_Dest.xnome).

geraxml("T4","T4","xNome",E01_Dest.xnome).
geraxml("T4","","enderDest","").

run trata_caract_esp.p(input E01_Dest.xLgr, output E01_Dest.xLgr).
geraxml("T5","T5","xLgr",E01_Dest.xLgr).
geraxml("T5","T5","nro",E01_Dest.nro).

if E01_Dest.xcpl <> "" and
   E01_Dest.xcpl <> ?
then geraxml("T5","T5","xCpl",E01_Dest.xcpl).

run trata_caract_esp.p(input E01_Dest.xbairro, output E01_Dest.xbairro).
if E01_Dest.xbairro = ""
then E01_Dest.xbairro = "CENTRO".
if E01_Dest.xbairro <> ""
then geraxml("T5","T5","xBairro",E01_Dest.xbairro).

geraxml("T5","T5","cMun",string(E01_Dest.cmun)).

run trata_caract_esp.p(input E01_Dest.xmun, output E01_Dest.xmun).

geraxml("T5","T5","xMun",E01_Dest.xmun).
geraxml("T5","T5","UF",E01_Dest.uf).

assign vcepaux = string(E01_Dest.cep,"99999999"). 

if E01_Dest.uf <> "EX"
then geraxml("T5","T5","CEP",vcepaux).                
if E01_Dest.cpais <> 0
then geraxml("T5","T5","cPais",string(E01_Dest.cpais)).
if E01_Dest.xpais <> ""
then geraxml("T5","T5","xPais",E01_Dest.xpais).

if string(E01_Dest.fone) <> ""  and string(E01_Dest.fone) <> "0"
    and string(E01_Dest.fone) <> "?" and string(E01_Dest.fone) <> ?
then do:
    vfoneaux = substring(string(E01_Dest.fone),1,14).    
    geraxml("T5","T5","fone",vfoneaux).
end.

geraxml("","T4","enderDest","").

if vtippes or E01_Dest.uf = "EX" 
then assign
        E01_Dest.ie = ""
        E01_Dest.indIEDest = 9. /* Nao Contrib */
else if E01_Dest.ie = "" or E01_Dest.ie = ? or E01_Dest.ie begins "ISENT"
then assign
        E01_Dest.ie = ""
        E01_Dest.indIEDest = 2. /* Isento */
    
geraxml("T4","T4","indIEDest", string(E01_Dest.indIEDest)).

if E01_Dest.ie <> ""
then geraxml("T4","T4","IE",E01_Dest.ie).

if E01_Dest.email <> ""
then geraxml("T4","T4","email",E01_Dest.email).

geraxml("","T3","dest","").

/***
    H - Detalhamento de Produtos e Serviços da NF-e
***/

assign vcont-pro-aux = 1.

for each I01_Prod of A01_infnfe by I01_Prod.nItem /*I01_Prod.xprod[1]*/:

    find produ where produ.procod = int(I01_Prod.cprod) no-lock no-error.
    if avail produ and
       I01_Prod.ncm <> string(produ.codfis)
    then I01_Prod.ncm   = string(produ.codfis).
            
    find N01_icms of I01_Prod no-lock no-error.

    if I01_Prod.ncm = "" or int(I01_Prod.ncm) = 0
    then I01_Prod.ncm = "00".
    else if I01_Prod.ncm = "99999999"
    then I01_Prod.ncm = "00000000".
    else I01_Prod.ncm = string( int(I01_Prod.ncm), "99999999").

    if avail N01_icms and
       (N01_icms.cst = 10 or
        N01_icms.cst = 30 or
        N01_icms.cst = 60 or
        N01_icms.cst = 70 or
        N01_icms.cst = 90)
    then do.
        find clafis where clafis.codfis = int(I01_Prod.ncm)
                    no-lock no-error.
        if avail clafis and clafis.char1 <> ""
        then I01_Prod.cest = clafis.char1 /* CEST */.
    end.
    
    geraxml("T3","","det nItem=""" + string(vcont-pro-aux) + """","").
    
    assign vcont-pro-aux = vcont-pro-aux + 1.
     
    geraxml("T4","","prod","").
    geraxml("T5","T5","cProd",I01_Prod.cprod).

    
    geraxml("T5","T5","cEAN","SEM GTIN").
    
    /*
    if produ.proindice begins "SEM GTIN" or length(produ.proindice) < 12
    then geraxml("T5","T5","cEAN","SEM GTIN").
    else geraxml("T5","T5","cEAN",produ.proindice).
    */
    
    run trata_caract_esp.p(input I01_Prod.xprod[1], output I01_Prod.xprod[1]).
    
    geraxml("T5","T5","xProd",I01_Prod.xprod[1]).    
    geraxml("T5","T5","NCM",  I01_Prod.ncm).
    /* if I01_Prod.cest <> ""
    then */  geraxml("T5","T5","CEST",  I01_Prod.Cest).
    geraxml("T5","T5","CFOP",string(I01_Prod.cfop)).
    
    if I01_Prod.ucom = ""
    then I01_Prod.ucom = "UN".
    
    geraxml("T5","T5","uCom",I01_Prod.ucom).    
    geraxml("T5","T5","qCom",topto(string(I01_Prod.qcom,">>>>>>>9.9999"))).
    if I01_Prod.movpc = 0
    then geraxml("T5","T5","vUnCom",
                        topto(string(I01_Prod.vUnCom,">>>>>>>9.9999"))).    
    else geraxml("T5","T5","vUnCom",
                        topto(string(I01_Prod.movpc,">>>>>>>9.999999999"))).
    geraxml("T5","T5","vProd",
                        topto(string(I01_Prod.vprod,">>>>>>>>>9.99"))). 
    
    geraxml("T5","T5","cEANTrib","SEM GTIN").
    
    /*
    if produ.proindice begins "SEM GTIN" or length(produ.proindice) < 12
    then geraxml("T5","T5","cEANTrib","SEM GTIN").
    else geraxml("T5","T5","cEANTrib",produ.proindice).
    */
         
    geraxml("T5","T5","uTrib",I01_Prod.uTrib).
    geraxml("T5","T5","qTrib",
                        topto(string(I01_Prod.qtrib,">>>>>>>9.9999"))).
    if I01_Prod.movpc = 0
    then geraxml("T5","T5","vUnTrib",
                        topto(string(I01_Prod.vuntrib,">>>>>>>9.9999"))).
    else geraxml("T5","T5","vUnTrib",
                        topto(string(I01_Prod.movpc,">>>>>>>9.999999999"))). 

    if I01_Prod.vfrete > 0 
    then geraxml("T5","T5","vFrete",
                        topto(string(I01_Prod.vfrete,">>>>>>>>>9.99"))).
    if I01_Prod.vseg > 0 
    then geraxml("T5","T5","vSeg",
                        topto(string(I01_Prod.vseg,">>>>>>>>>9.99"))).
    if I01_Prod.vdesc > 0 
    then geraxml("T5","T5","vDesc",
                        topto(string(I01_Prod.vdesc,">>>>>>>>>9.99"))).

    if I01_Prod.voutro > 0 
    then geraxml("T5","T5","vOutro",
                        topto(string(I01_Prod.voutro,">>>>>>>>>9.99"))).

    geraxml("T5","T5","indTot","1").
    geraxml("T5","T5","nItemPed","1").
    geraxml("T5","T5","cBenef","SEM CBENEF").    
    
    if I01_Prod.nFCI <> ""
    then geraxml("T5","T5","nFCI",I01_Prod.nFCI).
    else do:
        find first produaux where
                   produaux.procod = produ.procod and
                   produaux.nome_campo = "nFCI"
                   no-lock no-error.
        if avail produaux
        then geraxml("T5","T5","nFCI",produaux.valor_campo).           
    end.
    if E01_Dest.uf = "EX"
    then do:
        find I18_DI of I01_prod no-lock no-error.
        if avail I18_DI
        then do:
            geraxml("T5","","DI","").
            geraxml("T6","T6","nDI",string(I18_DI.nDI)).
   
            vdt =   string(year(I18_DI.dDI),"9999") + "-" +
                    string(month(I18_DI.dDI),"99") + "-" +
                    string(day(I18_DI.dDI),"99").
            geraxml("T6","T6","dDI",vdt).

            geraxml("T6","T6","xLocDesemb",string(I18_DI.xlocdesemb)).
            geraxml("T6","T6","UFDesemb",string(I18_DI.ufdesemb)).
            
            vdt =   string(year(I18_DI.dDesemb),"9999") + "-" +
                    string(month(I18_DI.dDesemb),"99") + "-" +
                    string(day(I18_DI.dDesemb),"99").
            geraxml("T6","T6","dDesemb",vdt).

            geraxml("T6","T6","tpViaTransp",I18_DI.tpViaTransp).
            geraxml("T6","T6","tpIntermedio",I18_DI.tpIntermedio).
            geraxml("T6","T6","cExportador",string(I18_DI.cExportador)).

            for each I25_adi of I18_DI no-lock:
                geraxml("T6","","adi","").
                geraxml("T7","T7","nAdicao",string(I25_adi.nadi)).
                geraxml("T7","T7","nSeqAdic",string(I25_adi.nseqadi)).
                geraxml("T7","T7","cFabricante",string(I25_adi.cFabricante)).
                /*
                geraxml("T7","T7","vDescDI",
                            string(I25_adi.vldescdi,">>>>9.99")).
                */
                geraxml("","T6","adi","").
            end.    
            geraxml("","T5","DI","").
        end.
    end.
    
    geraxml("","T4","prod","").
    
    geraxml("T4","","imposto","").
    geraxml("T5","","ICMS","").
    if avail N01_icms
    then do:         
        if N01_icms.cst = 0
        then do:
            geraxml("T6","","ICMS00","").
            geraxml("T7","T7","orig", string(N01_icms.orig)).
            geraxml("T7","T7","CST",  string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","vBC",  converte(N01_icms.vbc)).
            geraxml("T7","T7","pICMS",converte(N01_icms.picms)).
            geraxml("T7","T7","vICMS",converte(N01_icms.vicms)).
            geraxml("","T6","ICMS00","").
        end.

        if N01_icms.cst = 10
        then do:
            geraxml("T6","","ICMS10","").
            geraxml("T7","T7","orig", string(N01_icms.orig)).
            geraxml("T7","T7","CST",  string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","vBC",  converte(N01_icms.vbc)).
            geraxml("T7","T7","pICMS",converte(N01_icms.picms)).
            geraxml("T7","T7","vICMS",converte(N01_icms.vicms)).

            if N01_icms.vBCFCP > 0 /*#1 */
            then do.
                geraxml("T7","T7","vBCFCP",converte(N01_icms.vBCFCP)).
                geraxml("T7","T7","pFCP",  converte(N01_icms.pFCP)).
                geraxml("T7","T7","vFCP",  converte(N01_icms.vFCP)).
            end.

            geraxml("T7","T7","modBCST",string(N01_icms.modBCST)).
            if N01_icms.modBCST = 4
            then geraxml("T7","T7","pMVAST",converte(N01_icms.pMVAST)).
            geraxml("T7","T7","vBCST",  converte(N01_icms.vBCST)).
            geraxml("T7","T7","pICMSST",converte(N01_icms.pICMSST)).
            geraxml("T7","T7","vICMSST",converte(N01_icms.vICMSST)).

            if N01_icms.vBCFCPST > 0 /* #1 */
            then do.
                geraxml("T7","T7","vBCFCPST",converte(N01_icms.vBCFCPST)).
                geraxml("T7","T7","pFCPST",  converte(N01_icms.pFCPST)).
                geraxml("T7","T7","vFCPST",  converte(N01_icms.vFCPST)).
            end.
            geraxml("","T6","ICMS10","").
        end.

        if N01_icms.cst = 20
        then do:
            geraxml("T6","","ICMS20","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","pRedBC",topto(string(N01_icms.predbc,"zz9.99"))).
            geraxml("T7","T7","vBC",
                            topto(string(N01_icms.vbc,"zzzzzzzzzzzz9.99"))).
            geraxml("T7","T7","pICMS",
                            topto(string(N01_icms.picms,"zz9.99"))).
            geraxml("T7","T7","vICMS",
                            topto(string(N01_icms.vicms,"zzzzzzzzzzz9.99"))).
            geraxml("","T6","ICMS20","").
        end.
 
        if N01_icms.cst = 30
        then do:
            geraxml("T6","","ICMS30","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","pMVAST",topto(string(N01_icms.pmvast,"zz9.99"))).
            geraxml("T7","T7","pRedBCST",
                            topto(string(N01_icms.predbcst,"zz9.99"))).
            geraxml("T7","T7","vBCST",
                            topto(string(N01_icms.vbcst,"zzzzzzzzzzzz9.99"))).
            geraxml("T7","T7","pICMSST",                         
                            topto(string(N01_icms.picmsst,"zz9.99"))).
            geraxml("T7","T7","vICMS",
                            topto(string(N01_icms.vicms,"zzzzzzzzzzzz9.99"))).
        end.

        if N01_icms.cst = 40 or N01_icms.cst = 41
        then do:
            geraxml("T6","","ICMS40","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("","T6","ICMS40","").
        end.

        if N01_icms.cst = 51
        then do:
            geraxml("T6","","ICMS51","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).

            if N01_icms.predbc > 0
            then geraxml("T7","T7","pRedBC",string(N01_icms.predbc)).

            if N01_icms.vbc >= 0
            then geraxml("T7","T7","vBC",
                        topto(string(N01_icms.vbc,"zzzzzzzzz9.99"))).

            if N01_icms.picms >= 0
            then geraxml("T7","T7","pICMS",
                        topto(string(N01_icms.picms,"zzzzzzzzz9.99"))).
            
            /* if N01_icms.predbc >= 0
            then geraxml("T7","T7","pRedBC",
                        topto(string(N01_icms.predbc,"zzzzzzzzz9.99"))).
            */
            
            if N01_icms.pdif > 0
            then do:
                if N01_icms.vicmsop >= 0
                then geraxml("T7","T7","vICMSOp",
                        topto(string(N01_icms.vicmsop,"zzzzzzzzz9.99"))).
                        
                if N01_icms.pdif >= 0
                then geraxml("T7","T7","pDif",
                        topto(string(N01_icms.pdif,"zzzzzzzzz9.9999"))).
            
                if N01_icms.vicmsdif >= 0
                then geraxml("T7","T7","vICMSDif",
                        topto(string(N01_icms.vicmsdif,"zzzzzzzzz9.99"))).

                if N01_icms.vicms >= 0
                then geraxml("T7","T7","vICMS",
                        topto(string(N01_icms.vicms,"zzzzzzzzz9.99"))).
            end.
        
            geraxml("","T6","ICMS51","").
        end.

        if N01_icms.cst = 60
        then do.
            geraxml("T6","","ICMS60","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).

            if N01_icms.vBCSTRet > 0 /*#1 N25 */
            then do.
                geraxml("T7","T7","vBCSTRet",  converte(N01_icms.vBCSTRet)).
                geraxml("T7","T7","pST",  converte(N01_icms.pST)).
                /*if N01_icms.vICMSSubstituto > 0
                then*/ geraxml("T7","T7","vICMSSubstituto",
                                          converte(N01_icms.vICMSSubstituto)).
                geraxml("T7","T7","vICMSSTRet",converte(N01_icms.vICMSSTRet)).
            end.

            if N01_icms.vBCFCPSTRet > 0 /*#1 N27 */
            then do.
                geraxml("T7","T7","vBCFCPSTRet",
                                               converte(N01_icms.vBCFCPSTRet)).
                geraxml("T7","T7","pFCPSTRet", converte(N01_icms.pFCPSTRet)).
                geraxml("T7","T7","vFCPSTRet", converte(N01_icms.vFCPSTRet)).
            end.

            if N01_icms.vBCEfet > 0 /*#1 N33 */
            then do.
                geraxml("T7","T7","pRedBCEfet",converte(N01_icms.pRedBCEfet)).
                geraxml("T7","T7","vBCEfet",   converte(N01_icms.vBCEfet)).
                geraxml("T7","T7","pICMSEfet", converte(N01_icms.pICMSEfet)).
                geraxml("T7","T7","vICMSEfet", converte(N01_icms.vICMSEfet)).
            end.

            geraxml("","T6","ICMS60","").
        end.

        if N01_icms.cst = 90
        then do:
            geraxml("T6","","ICMS90","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            if N01_icms.modbc > 0
            then do:
                geraxml("T7","T7","modBC",string(N01_icms.modbc)).
                geraxml("T7","T7","vBC",  converte(N01_icms.vbc)).
                if N01_icms.predbc > 0
                then geraxml("T7","T7","pRedBC",converte(N01_icms.predbc)).
                geraxml("T7","T7","pICMS", converte(N01_icms.picms)).
                geraxml("T7","T7","vICMS", converte(N01_icms.vicms)).
                geraxml("T7","T7","modBCST",string(N01_icms.modbcst,"9")).

                if N01_icms.pmvast > 0
                then geraxml("T7","T7","pMVAST",converte(N01_icms.pmvast)).
                if N01_icms.predBCST > 0
                then geraxml("T7","T7","pRedBCST",converte(N01_icms.predBCST)).
                geraxml("T7","T7","vBCST",   converte(N01_icms.vBCST)).
                geraxml("T7","T7","pICMSST", converte(N01_icms.pICMSST)).
                geraxml("T7","T7","vICMSST", converte(N01_icms.vICMSST)).
            end.
            geraxml("","T6","ICMS90","").
        end.
    end.                       
    geraxml("","T5","ICMS",""). 

    find P01_ii of I01_Prod no-lock no-error.
    if avail P01_ii and P01_ii.vII > 0
    then do:
        geraxml("T5","","II","").
        geraxml("T6","T6","vBC",
                    topto(string(P01_II.vbc,"zzzzzzzzz9.99"))).
        geraxml("T6","T6","vDespAdu",
                    topto(string(P01_II.vdespadu,"zzzzzzzzz9.99"))).
        geraxml("T6","T6","vII",
                    topto(string(P01_II.vii,"zzzzzzzzz9.99"))).
        geraxml("T6","T6","vIOF",
                    topto(string(P01_II.viof,"zzzzzzzzz9.99"))).
        geraxml("","T5","II","").
    end.

    find O01_ipi of I01_Prod no-lock no-error.
    if avail O01_ipi and (O01_ipi.vIPI > 0 or E01_Dest.uf = "EX") 
    then do:
        geraxml("T5","","IPI","").
        
        if O01_ipi.clEnq <> ""
        then geraxml("T6","T6","clEnq","").
        
        if O01_ipi.CNPJprod <> ""
        then geraxml("T6","T6","CNPJprod","").
        
        if O01_ipi.cSelo <> ""
        then geraxml("T6","T6","cSelo","").
        
        if O01_ipi.cEnq <> ""
        then geraxml("T6","T6","cEnq",string(O01_ipi.cEnq)).
        
        geraxml("T6","","IPITrib","").
        geraxml("T7","T7","CST",string(int(O01_ipi.cst),"99")).
        geraxml("T7","T7","vBC",topto(string(O01_ipi.vbc,"zzzzzzzzz9.99"))).
        
/*** calculo do IPI por valor da unidade
        if O01_ipi.qUnid <> 0
        then geraxml("T7","T7","qUnid",string(O01_ipi.qUnid)).
        
        geraxml("T7","T7","vUnid",topto(string(O01_ipi.vUnid,"zzzzzzzzz9.99"))).
***/
        geraxml("T7","T7","pIPI",topto(string(O01_ipi.pIPI,"zz9.99"))).
        geraxml("T7","T7","vIPI",topto(string(O01_ipi.vIPI,"zzzzzzzzz9.99"))).
        geraxml("","T6","IPITrib","").
        geraxml("","T5","IPI","").
     end.
    
     find Q01_pis of I01_Prod no-lock no-error.
     if avail Q01_pis
     then do:
        geraxml("T5","","PIS","").
        if Q01_pis.cst = 1 or Q01_pis.cst = 2 
        then do.
             geraxml("T6","","PISAliq","").
             geraxml("T7","T7","CST",string(int(Q01_pis.cst),"99")).
             geraxml("T7","T7","vBC",
                     topto(string(Q01_pis.vBC,"zzzzzzzzz9.99"))).
             geraxml("T7","T7","pPIS",
                     topto(string(Q01_pis.pPis,"zzzzzzzzz9.99"))).
             geraxml("T7","T7","vPIS",
                     topto(string(Q01_pis.vPis,"zzzzzzzzz9.99"))).
             geraxml("","T6","PISAliq",""). 
        end.
        else if Q01_pis.cst >= 4 and Q01_pis.cst <= 9
        then do:
             geraxml("T6","","PISNT","").
             geraxml("T7","T7","CST",string(int(Q01_pis.cst),"99")).
             geraxml("","T6","PISNT",""). 
        end. 
        else if Q01_pis.cst >= 49 and Q01_pis.cst <= 99
        then do:
            geraxml("T6","","PISOutr","").
            geraxml("T7","T7","CST",string(int(Q01_pis.cst),"99")).
            geraxml("T7","T7","vBC",
                                  topto(string(Q01_pis.vBC,"zzzzzzzzz9.99"))).
            geraxml("T7","T7","pPIS",
                                  topto(string(Q01_pis.pPis,"zzzzzzzzz9.99"))).
            geraxml("T7","T7","vPIS",
                                  topto(string(Q01_pis.vPis,"zzzzzzzzz9.99"))).
            geraxml("","T6","PISOutr","").
        end.
        geraxml("","T5","PIS","").
     end. 
     
     find S01_cofins of I01_Prod no-lock no-error.
     if avail S01_cofins
     then do:
        geraxml("T5","","COFINS","").

        if S01_cofins.cst = 1 or S01_cofins.cst = 2 
        then do.
             geraxml("T6","","COFINSAliq","").
             geraxml("T7","T7","CST",string(int(S01_cofins.cst),"99")).
             geraxml("T7","T7","vBC",
                     topto(string(S01_cofins.vBC,"zzzzzzzzz9.99"))).
             geraxml("T7","T7","pCOFINS",
                     topto(string(S01_cofins.pcofins,"zzzzzzzzz9.99"))).
             geraxml("T7","T7","vCOFINS",
                     topto(string(S01_cofins.vcofins,"zzzzzzzzz9.99"))).
             geraxml("","T6","COFINSAliq",""). 
        end.
        else if S01_cofins.cst >= 4 and S01_cofins.cst <= 9
        then do:
             geraxml("T6","","COFINSNT","").
             geraxml("T7","T7","CST",string(int(S01_cofins.cst),"99")).
             geraxml("","T6","COFINSNT",""). 
        end. 
        else if S01_cofins.cst >= 49 and S01_cofins.cst <= 99
        then do:
            geraxml("T6","","COFINSOutr","").
            geraxml("T7","T7","CST",string(int(S01_cofins.cst),"99")).
            geraxml("T7","T7","vBC",
                        topto(string(S01_cofins.vBC,"zzzzzzzzz9.99"))).
            geraxml("T7","T7","pCOFINS",
                        topto(string(S01_cofins.pcofins,"zzzzzzzzz9.99"))).
            geraxml("T7","T7","vCOFINS",
                        topto(string(S01_cofins.vcofins,"zzzzzzzzz9.99"))).
            geraxml("","T6","COFINSOutr","").
        end.
        geraxml("","T5","COFINS","").
    end. 
    geraxml("","T4","imposto","").

    /**** Imposto devolvido ******/    
    for each impostodevol of I01_prod no-lock:
    geraxml("T4","","impostoDevol","").
    geraxml("T5","T5","pDevol",
                    topto(string(impostodevol.pdevol,"zzzzzzzzz9.99"))).
    geraxml("T5","",string(impostodevol.tImposto),""). 
    geraxml("T6","T6","vIPIDevol",
                    topto(string(impostodevol.vimposto,"zzzzzzzzz9.99"))).
    geraxml("","T5",string(impostodevol.tImposto),"").                 
    geraxml("","T4","impostoDevol","").
    end.
    /*************/
    /********
    for each icmsufdest of I01_prod no-lock:
    geraxml("T4","","ICMSUFDest","").
    geraxml("T5","T5","vBCUFDest",
                  topto(string(icmsufdest.vBCUFDest,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","pFCPUFDest",      
                  topto(string(icmsufdest.pFCPUFDest,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","pICMSUFDest",
                  topto(string(icmsufdest.pICMSUFDest,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","pICMInter",
                  topto(string(icmsufdest.pICMSInter,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","pICMInterPart",
                  topto(string(icmsufdest.pICMSInterPart,"zzzzzzzzz9.99"))).    
    geraxml("T5","T5","vFCPUFDest",
                  topto(string(icmsufdest.vFCPUFDest,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vICMSUFDest",
                  topto(string(icmsufdest.vICMSUFDest,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vICMSUFRemet",
                  topto(string(icmsufdest.vICMSUFRemet,"zzzzzzzzz9.99"))).
                      
    geraxml("","T4","ICMSUFDest","").
    end.
    ************/
    
    if I01_Prod.infadprod <> ""
    then geraxml("T4","T4","infAdProd",I01_Prod.infadprod).

    geraxml("","T5","det","").

end.

/**** Totais da nfe ****/
geraxml("T3","","total","").

find W01_total of A01_infnfe no-lock no-error.
if avail W01_total
then do:
    geraxml("T4","","ICMSTot","").
    geraxml("T5","T5","vBC",topto(string(W01_total.vbc,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vICMS",topto(string(W01_total.vicms,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vICMSDeson", "0.00"). /* 3.10 */
    geraxml("T5","T5","vFCP",topto(string(W01_total.vfcp,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vBCST",topto(string(W01_total.vbcst,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vST",topto(string(W01_total.vst,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vFCPST",topto(string(W01_total.vfcpst,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vFCPSTRet",
                    topto(string(W01_total.vfcpstret,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vProd",topto(string(W01_total.vprod,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vFrete",topto(string(W01_total.vfrete,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vSeg",topto(string(W01_total.vseg,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vDesc",topto(string(W01_total.vdesc,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vII",topto(string(W01_total.vii,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vIPI",topto(string(W01_total.vipi,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vIPIDevol",
                    topto(string(W01_total.vipidevol,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vPIS",topto(string(W01_total.vpis,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vCOFINS",
                    topto(string(W01_total.vcofins,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vOutro",topto(string(W01_total.voutro,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vNF",topto(string(W01_total.vnf,"zzzzzzzzz9.99"))).
    geraxml("","T4","ICMSTot","").    
end.
geraxml("","T3","total","").

/* Transportadora / Volumes */
geraxml("T3","","transp","").
find X01_transp of A01_infnfe no-lock no-error.
if avail X01_transp
then do:
    geraxml("T4","T4","modFrete",string(X01_Transp.modFrete,"9")).

    if X01_Transp.xNome <> ""
    then do:
        geraxml("T4","","transporta","").
        if X01_Transp.CNPJ <> ""
        then geraxml("T5","T5","CNPJ",X01_Transp.CNPJ).
        geraxml("T5","T5","xNome",string(X01_Transp.xNome,"x(60)")).
        geraxml("T5","T5","xEnder",X01_Transp.xEnder).
        geraxml("T5","T5","xMun",X01_Transp.xMun).
        geraxml("T5","T5","UF",X01_Transp.UF).
        geraxml("","T4","transporta","").
    end.    

    if X01_Transp.placa <> ""
    then do:
        geraxml("T4","","veicTransp","").
        geraxml("T5","T5","placa",string(X01_Transp.placa)).
        geraxml("T5","T5","UF",string(X01_Transp.UF)).
        geraxml("T5","T5","RNTC",string(X01_Transp.rntc)).
        geraxml("","T4","veicTransp","").
    end.                      

    find first X26_vol where
               X26_vol.chave = A01_infnfe.chave and
               X26_vol.cnpj  = X01_transp.cnpj and
               X26_vol.cpf   = X01_transp.cpf
               no-lock no-error.
    if avail X26_vol and
        X26_vol.qvol > 0
    then do:
        /**
        *vqtd = X26_vol.qvol.
        *vespecie = X26_vol.esp.
        *vmarca   = x26_vol.marca.
        **/
            
        geraxml("T4","","vol","").

        if x26_vol.qvol > 0
        then geraxml("T5","T5","qVol", string(x26_vol.qvol)).
            
        if x26_vol.esp <> ? and x26_vol.esp <> ""
        then geraxml("T5","T5","esp", x26_vol.esp).

        if x26_vol.marca <> ? and x26_vol.marca <> ""
        then geraxml("T5","T5","marca", x26_vol.marca).

        if vnumero <> ? and vnumero <> ""
        then geraxml("T5","T5","nVol", vnumero).

        /**vpliqui = X26_vol.pesol.**/
        /**vpbruto = X26_vol.pesob.**/
        if X26_VOL.PESOL > 0
        then geraxml("T5","T5","pesoL",
                topto(string(X26_VOL.PESOL,"zzzz9.999"))).

        if X26_VOL.PESOB > 0
        then geraxml("T5","T5","pesoB",
                topto(string(X26_VOL.PESOB,"zzzz9.999"))).

        geraxml("","T4","vol","").            
    end.
end.
else geraxml("T4","T4","modFrete","0").

geraxml("","T3","transp","").

geraxml("T3","","pag","").
geraxml("T4","","detPag","").
geraxml("T5","T5","indPag","0").
find first y01_pag where y01_pag.chave = A01_infnfe.chave no-lock no-error.
if not avail y01_pag
then do:
    geraxml("T5","T5","tPag","90").
    geraxml("T5","T5","vPag","0.00").
end.
else for each y01_pag where y01_pag.chave = A01_infnfe.chave no-lock:
    geraxml("T5","T5","tPag",
                topto(string(y01_pag.tpag,"99"))).
    geraxml("T5","T5","vPag",
                topto(string(y01_pag.vpag,"zzzzzzzzz9.99"))).
end.       
geraxml("","T4","detPag","").
geraxml("","T3","pag","").       



/* Observacoes */

find Z01_InfAdic of A01_infnfe no-lock no-error.
if avail Z01_InfAdic 
then do:
    geraxml("T3","","infAdic","").

    if Z01_InfAdic.infadfisco <> ""
    then geraxml("T4","T4","infAdFisco",trim(Z01_InfAdic.infadfisco)).
    else do:
        find B12_NFref of A01_infnfe no-lock no-error.
        assign vobservacao = "".
        if avail B12_NFref 
        then do:
            if string(B12_NFref.Nnf) <> "" and 
            not Z01_InfAdic.infCpl matches ("*" + string(B12_NFref.Nnf) + "*")
            then vobservacao = vobservacao + "    Doc.Origem : " +
                               string(B12_NFref.Nnf) + " ".
        end.
        vobservacao = vobservacao + " " + Z01_InfAdic.infCpl.
        vobservacao = vobservacao + " " + vobservdec.
        
        if vobservacao <> ""
        then geraxml("T4","T4","infCpl",troca-letra(vobservacao)).
    end.

    geraxml("","T3","infAdic","").
end.

/******
geraxml("T3","","pag","").
find first y01_pag where y01_pag.chave = A01_infnfe.chave no-lock no-error.
if not avail y01_pag
then do:
    /*geraxml("T4","","detPag","").*/
    geraxml("T4","T4","tPag","90").
    geraxml("T4","T4","vPag","0.00").
    /*geraxml("","T4","detPag","").*/
end.
else for each y01_pag where y01_pag.chave = A01_infnfe.chave no-lock:
    /*geraxml("T4","","detPag",""). */
    geraxml("T4","T4","tPag",
                topto(string(y01_pag.tpag,"99"))).
    geraxml("T4","T4","vPag",
                topto(string(y01_pag.vpag,"zzzzzzzzz9.99"))).
    /*geraxml("","T4","detPag","").*/
end.       
geraxml("","T3","pag","").       
*******/


geraxml("","T2","infNFe","").
geraxml("","T1","NFe","").
geraxml("","T1","enviNFe","").

output close.

run /admcom/progr/altera-sit-nfe.p (input p-recid).

do on error undo.

    find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                             tab_log.nome_campo = "NFe-Solicitacao" and
                             tab_log.valor_campo = A01_InfNFe.chave
                       no-error.
    if not avail tab_log
    then do:
        create tab_log.
        assign
            tab_log.etbcod = A01_InfNFe.etbcod
            tab_log.nome_campo = "NFe-Solicitacao"
            tab_log.valor_campo = A01_InfNFe.chave.
    end.
    assign
        tab_log.dtinclu = today
        tab_log.hrinclu = time.

    find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                             tab_log.nome_campo = "NFe-UltimoEvento" and
                             tab_log.valor_campo = A01_InfNFe.chave
                        no-error.
    if not avail tab_log
    then do:
        create tab_log.
        assign
            tab_log.etbcod = A01_InfNFe.etbcod
            tab_log.nome_campo = "NFe-UltimoEvento"
            tab_log.valor_campo = A01_InfNFe.chave.
    end.
    assign
        tab_log.dtinclu = today
        tab_log.hrinclu = time.
end.


procedure exp-refer.

find first B12_NFref where B12_NFref.chave = A01_infnfe.chave no-lock no-error.
if avail B12_NFref  
then do:
    if B12_NFref.nNF = 0 and
       B12_NFref.refnfe = ""
    then next.
               
    geraxml("T4","","NFref","").
    
    if B12_NFref.mod = "2D"
    then do:
        geraxml("T5","","refECF","").
        geraxml("T5","T5","mod","2D").
        geraxml("T5","T5","nECF","001").
        geraxml("T5","T5","nCOO",string(B12_NFref.nNF,"999999")).
        geraxml("","T5","refECF","").
    end.
    else do:
        
        if B12_NFref.refnfe <> ""
        then do:
            geraxml("T5","T5","refNFe",trim(B12_NFref.refnfe)).
        end.
        else do:                                    
            geraxml("T5","","refNF","").
            geraxml("T5","T5","cUF",string(B12_NFref.cUF)).
            geraxml("T5","T5","AAMM",string(B12_NFref.AAMM,"9999")).
    
            if length(B12_NFref.CNPJ) > 11
            then geraxml("T5","T5","CNPJ",string(B12_NFref.CNPJ)).
            else geraxml("T5","T5","CPF",string(B12_NFref.CNPJ)).
    
            geraxml("T5","T5","mod",string(B12_NFref.mod)).
            geraxml("T5","T5","serie",string(B12_NFref.serie)).
            geraxml("T5","T5","nNF",string(B12_NFref.Nnf)).
            geraxml("","T5","refNF","").
        end.
    end.

    geraxml("","T4","NFref","").
end.

end procedure.

