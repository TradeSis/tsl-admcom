{gerxmlnfe.i}

pause 0.

def var arq_envio as char.
def var vmetodo as char.
def var vcont as integer.

def var vcont-pro-aux as integer.

def var vchave-aux  as char.

def var mail-dest as char.
def var mail-tran as char.
def var opc-dest as char.
def var opc-tran as dec.

def var vpause  as integer.

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
  
{geraxml.i}                             

function topto returns character
    (input par-virgula as char).
     return replace(par-virgula,",",".").
end function.

function tovig returns character
    (input par-ponto as char).
     return replace(par-ponto,".",",").
end function.

def input  parameter p-recid as recid.
/*def input  parameter p-oper  as char.
def output parameter p-volta as logical initial no.
*/
def var vcepaux    as char.
def var vfoneaux as char.
def var vtesta     as dec.
def var vobservacao as char format "x(1000)".
def var vobservdec as char.

def var vdt as char format "x(10)".
def var vespecie  as char.
def var vmarca    as char.
def var vnumero   as char.
def var vpbruto   as dec.
def var vpliqui   as dec.

def var vretorno as char.

/**** ****/

run /admcom/progr/grava_log_nfe.p (input p-recid) no-error.

find A01_infnfe where recid(A01_infnfe) = p-recid exclusive-lock.

def var varquivo as char.

def var v-idamb as int format "9".
v-idamb = 2.
def var p-valor as char.
p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
if p-valor = "PRODUCAO"
THEN v-idamb = 1.

find B01_IdeNFe of A01_infnfe .
B01_IdeNFe.idamb = v-idamb.

def var vnome as char format "x(30)".
def var vqtd  as dec.
def var vesp  as char.
def var vfre  as int format "9" initial 1.
def var vuf   as char format "x(02)" initial "RS".
def var vplaca              as char label "Placa".
def var vforcgc like forne.forcgc.
def var vforinest  like forne.forinest.
def var vendereco  as char format "x(50)".
def var vmunicipio as char format "x(30)".
def var vcpf as char format "x(11)".
/***/
vnome = "DREBES & CIA LTDA".
vfre = 1.

if program-name(2) <> "pre_nfe_5202.p"
then do on error undo, retry:

    find first X01_transp where
           X01_transp.chave = A01_infnfe.chave no-lock no-error.
    if avail X01_transp
    then do: 
        assign
            vfre = X01_transp.modfrete 
            vnome = X01_transp.xnome
            vuf =  X01_transp.uf 
            vplaca =  X01_transp.placa 
            vforinest = X01_transp.ie 
            vendereco = X01_transp.xender 
            vmunicipio = X01_transp.xmun
            vforcgc = X01_transp.cnpj
            vcpf = X01_transp.cpf 
        .
        
        find first X26_vol where
                X26_vol.chave = A01_infnfe.chave and
                X26_vol.cnpj  = X01_transp.cnpj and
                X26_vol.cpf   = X01_transp.cpf /*and
                X26_vol.nvol = 0                 */
                no-error.
        if avail X26_vol
        then assign vqtd = X26_vol.qvol
                    vesp = X26_vol.esp
                    .
    end.                
    else do:
        /****
        message "3333". pause.
        find first X26_vol where
            X26_vol.chave = A01_infnfe.chave no-lock no-error.
        if avail X26_vol
        then assign vqtd = X26_vol.qvol
                    vesp = X26_vol.esp
                .
        message A01_infnfe.chave vqtd. pause.
        ****/
    end.

    if vforcgc = "00000000000000"
    then vforcgc = "".
    
    do on endkey undo:
    
    update  vnome label "Razao Social" colon 16
        vforcgc label "CNPJ"        colon 16
        vforinest label "IE"       colon 16
        vendereco label "Endereco" colon 16
        vuf   label "UF"             colon 16
        vplaca    label "Placa"      colon 16
        vmunicipio label "Municipio" colon 16
        vqtd  label "Volumes"        colon 16
        vesp  label "Especie"        colon 16
        vfre  label "Frete por Conta" colon 16
        " ( 0-Emitente 1-Destinatario )"
        with frame f-placa centered side-label color blue/cyan
        row 7 overlay title " Transportadora ".
    end.
    if vforcgc = "00000000000000"
    then vforcgc = "".

    /***
    find first X01_transp where
           X01_transp.chave = A01_infnfe.chave no-error.
    if not avail X01_transp
    then do:
        create X01_transp.

        assign
        X01_transp.chave = A01_infnfe.chave
        X01_transp.modfrete = vfre
        X01_transp.xnome = vnome
        X01_transp.uf = vuf
        X01_transp.placa = caps(vplaca)
        X01_transp.ie = vforinest
        X01_transp.xender = vendereco
        X01_transp.xmun = vmunicipio
        X01_transp.cnpj = vforcgc
        X01_transp.cpf = vcpf
        .

        X01_transp.xnome = replace(X01_transp.xnome,"&","E").
    
        find first X26_vol where X26_vol.chave = A01_infnfe.chave no-error.
        if not avail X26_vol                
        then do:
            create X26_vol.
        end.    
    
        assign
            X26_vol.chave = A01_infnfe.chave
            X26_vol.cnpj  = X01_transp.cnpj
            X26_vol.cpf   = X01_transp.cpf
            X26_vol.marca = ""
            X26_vol.nvol = 0
            X26_vol.qvol = vqtd
            X26_vol.esp  = vesp
            .
                            
                            
    end.    
    else do:
        assign
        X01_transp.chave = A01_infnfe.chave
        X01_transp.modfrete = vfre
        X01_transp.xnome = vnome
        X01_transp.uf = vuf
        X01_transp.placa = caps(vplaca)
        X01_transp.ie = vforinest
        X01_transp.xender = vendereco
        X01_transp.xmun = vmunicipio
        X01_transp.cnpj = vforcgc
        X01_transp.cpf = vcpf
        .

        X01_transp.xnome = replace(X01_transp.xnome,"&","E").
    
 
        find first X26_vol where
               X26_vol.chave = A01_infnfe.chave and
               X26_vol.cnpj  = X01_transp.cnpj and
               X26_vol.cpf   = X01_transp.cpf and
        /**    X26_vol.esp   = vesp and
               X26_vol.marca = "" and   ***/
               X26_vol.nvol = 0 
               no-error.
        if not avail X26_vol                
        then do:
            create X26_vol.
        end.    
    
        assign
            X26_vol.chave = A01_infnfe.chave
            X26_vol.cnpj  = X01_transp.cnpj
            X26_vol.cpf   = X01_transp.cpf
            X26_vol.marca = ""
            X26_vol.nvol = 0
            X26_vol.qvol = vqtd
            X26_vol.esp  = vesp
            .
    end.
    ***/

    find first X01_transp where
           X01_transp.chave = A01_infnfe.chave no-error.
    if not avail X01_transp
    then create X01_transp.

    assign
        X01_transp.chave = A01_infnfe.chave
        X01_transp.modfrete = vfre
        X01_transp.xnome = vnome
        X01_transp.uf = vuf
        X01_transp.placa = caps(vplaca)
        X01_transp.ie = vforinest
        X01_transp.xender = vendereco
        X01_transp.xmun = vmunicipio
        X01_transp.cnpj = vforcgc
        X01_transp.cpf = vcpf
        .
        
    X01_transp.xnome = replace(X01_transp.xnome,"&","E").
    
    find first X26_vol where
               X26_vol.chave = A01_infnfe.chave and
               X26_vol.cnpj  = X01_transp.cnpj and
               X26_vol.cpf   = X01_transp.cpf and
        /**    X26_vol.esp   = vesp and
               X26_vol.marca = "" and   ***/
               X26_vol.nvol = 0 
               no-error.
    /*if not avail X26_vol
    then find first X26_vol where
                    X26_vol.chave = A01_infnfe.chave no-error.
    */
    if not avail X26_vol                
    then do:
        create X26_vol.
    end.    
    
    assign
        X26_vol.chave = A01_infnfe.chave
        X26_vol.cnpj  = X01_transp.cnpj
        X26_vol.cpf   = X01_transp.cpf
        X26_vol.marca = ""
        X26_vol.nvol = 0
        X26_vol.qvol = vqtd
        X26_vol.esp  = vesp
        .
            
end.
else do:
    
    find first X01_transp where
           X01_transp.chave = A01_infnfe.chave no-error.
    if not avail X01_transp
    then do:
        create X01_transp.

        assign
        X01_transp.chave = A01_infnfe.chave
        X01_transp.modfrete = vfre
        X01_transp.xnome = vnome
        X01_transp.uf = vuf
        X01_transp.placa = caps(vplaca)
        X01_transp.ie = vforinest
        X01_transp.xender = vendereco
        X01_transp.xmun = vmunicipio
        X01_transp.cnpj = vforcgc
        X01_transp.cpf = vcpf
        .

        X01_transp.xnome = replace(X01_transp.xnome,"&","E").
        /***
        find first X26_vol where
                   X26_vol.chave = A01_infnfe.chave 
       /***    and X26_vol.cnpj  = X01_transp.cnpj 
               and X26_vol.cpf   = X01_transp.cpf
               and X26_vol.esp   = vesp  
               and X26_vol.marca = ""
               and X26_vol.nvol = 0          ***/
               no-error.
        if not avail X26_vol
        then do:
            create X26_vol.
            assign
                X26_vol.chave = A01_infnfe.chave
                X26_vol.cnpj  = X01_transp.cnpj
                X26_vol.cpf   = X01_transp.cpf
                X26_vol.marca = ""
                X26_vol.nvol = 0
          /*    X26_vol.qvol = vqtd
                X26_vol.esp  = vesp  */
            .
        end.
        *****/
        
    end.
end.

hide frame f-placa no-pause.
clear frame f-placa all.

disp skip(1)
    "AGUARDE A AUTORIZAÇÃO DA NOTA FISCAL ELETRONICA!" skip(1)
        "SE ACONTECER QUALQUER PROBLEMA OU APARECER MENSAGEM DE ERRO" skip
            "E NÃO APARECER A TELA FINAL COM O NUMERO DA NFe AUTORIZADA" skip
                "ENTRE EM CONTATO COM O SETOR FISCAL/CONTABIL." skip(1)
                     with frame f-mens 1 down centered row 7 color message
                          overlay title "  A T E N Ç Ã O  " .
                          pause 0.
                          
                          message "ENVIANDO SOLICITAÇÃO DE AUTORIZAÇÃO .... AGUARDE!" .
PAUSE 1 no-message.

p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

varquivo = p-valor + A01_infnfe.chave + ".xml".

def var ind-chave as log.
p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - GERAR CHAVE DE ACESSO", OUTPUT p-valor) .
if p-valor = "SIM"
then ind-chave = yes.
else ind-chave = no.

def var chave-nfe like A01_infnfe.chave.

/**** ****/

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.
find B01_IdeNFe of A01_infnfe no-lock.
find estab where estab.etbcod = A01_infnfe.etbcod no-lock.

if ind-chave
then chave-nfe = "infNFe versao=~"2.00~" Id=~"" + A01_infnfe.chave + "~"".
else chave-nfe = "infNFe versao=~"2.00~" Id=~"" +  "~"".

output to value(varquivo).

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
geraxml("T4","T4","indPag",string(B01_IdeNFe.indpag)).
geraxml("T4","T4","mod",B01_IdeNFe.mod).
geraxml("T4","T4","serie",string(B01_IdeNFe.serie)).
geraxml("T4","T4","nNF",string(A01_infnfe.numero)).

vdt = string(year(B01_IdeNFe.demi),"9999") + "-" +
      string(month(B01_IdeNFe.demi),"99") + "-" +
      string(day(B01_IdeNFe.demi),"99").
geraxml("T4","T4","dEmi",vdt).

if B01_IdeNFe.dsaient <> ?
then do:
    vdt = string(string(year(B01_IdeNFe.dsaient),"9999") + "-" +
          string(month(B01_IdeNFe.dsaient),"99") + "-" +
          string(day(B01_IdeNFe.dsaient),"99")).
    geraxml("T4","T4","dSaiEnt",vdt).
end.

geraxml("T4","T4","tpNF",string(B01_IdeNFe.tpnf)).
geraxml("T4","T4","cMunFG",string(B01_IdeNFe.cmunfg)).

find  first B12_NFref where
            B12_NFref.chave =  A01_infnfe.chave no-lock no-error.
if avail  B12_NFref  
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

geraxml("T4","T4","tpImp",B01_IdeNFe.tpimp).
geraxml("T4","T4","tpEmis",string(B01_IdeNFe.tpEmis)).
geraxml("T4","T4","cDV",string(B01_IdeNFe.cdv)).

/* ambiente: "2" = homologação / "1" = Producao */
geraxml("T4","T4","tpAmb",string(B01_IdeNFe.idamb)).

geraxml("T4","T4","finNFe", string(B01_IdeNFe.finnfe)).
geraxml("T4","T4","procEmi",string(B01_IdeNFe.procemi)).
geraxml("T4","T4","verProc",B01_IdeNFe.verproc).

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
if E01_Dest.uf = "EX" 
then geraxml("T4","T4","CNPJ","").

if E01_Dest.cpf <> ""
then geraxml("T4","T4","CPF",E01_Dest.cpf).

run trata_caract_esp.p(input E01_Dest.xnome, output E01_Dest.xnome).

geraxml("T4","T4","xNome",E01_Dest.xnome).
geraxml("T4","","enderDest","").

run trata_caract_esp.p(input E01_Dest.xLgr, output E01_Dest.xLgr).

geraxml("T5","T5","xLgr",E01_Dest.xLgr).
geraxml("T5","T5","nro",E01_Dest.nro).

if E01_Dest.xcpl <> ""
then geraxml("T5","T5","xCpl",E01_Dest.xcpl).

run trata_caract_esp.p(input E01_Dest.xbairro, output E01_Dest.xbairro).

if E01_Dest.xbairro = "" then E01_Dest.xbairro = "CENTRO".
if E01_Dest.xbairro <> ""
then geraxml("T5","T5","xBairro",E01_Dest.xbairro).

geraxml("T5","T5","cMun",string(E01_Dest.cmun)).

run trata_caract_esp.p(input E01_Dest.xmun, output E01_Dest.xmun).

geraxml("T5","T5","xMun",E01_Dest.xmun).
geraxml("T5","T5","UF",E01_Dest.uf).

assign vcepaux = string(E01_Dest.cep,"99999999"). 

if E01_Dest.uf <> "EX"
then geraxml("T5","T5","CEP",vcepaux).                 

if E01_Dest.xpais <> ""
then geraxml("T5","T5","xPais",E01_Dest.xpais).

if string(E01_Dest.fone) <> ""  and string(E01_Dest.fone) <> "0"
    and string(E01_Dest.fone) <> "?" and string(E01_Dest.fone) <> ?
then do:
    vfoneaux = substring(string(E01_Dest.fone),1,14).    
    geraxml("T5","T5","fone",vfoneaux).
end.

geraxml("","T4","enderDest","").

vtesta = dec(E01_Dest.ie) no-error.

if E01_Dest.cnpj <> "" and E01_Dest.ie <> "" 
then do:
    if vtesta = 0 and E01_Dest.uf <> "EX"
    then geraxml("T4","T4","IE","ISENTO").
    else geraxml("T4","T4","IE",E01_Dest.ie).
end.

if E01_Dest.email <> ""
then geraxml("T4","T4","email",E01_Dest.email).

geraxml("","T3","dest","").

/*** ANTONIO NOVO 30.12.2010 IMPORTACAO ***/

/** Claudir tirou
find plani where plani.etbcod = int(A01_infnfe.etbcod) and
                 plani.placod = int(A01_infnfe.placod) 
                no-lock no-error.

/**** Observaçoes de OPcom com Embasamento Legal - 24/01/2011 ****/
assign  vobservdec = "".
if avail plani 
then find opcom where opcom.opccod = string(plani.opccod) no-lock no-error.
if avail opcom
then do:
        vobservdec = opcom.opcmen[1] + opcom.opcmen[2] + opcom.opcmen[3].
        vobservdec = " -> " + left-trim(vobservdec).
end.
/******/
***/

/* claudir tirou
if E01_Dest.uf = "EX" 
then do:
        if not avail plani then leave.
        find planidad of plani where planidad.campo = "DeclaracaoImportacao" 
                   no-lock no-error.
        if avail planidad 
        then  do:
            assign vcompadi = 999999.
            vndi    =  acha("Numero", planidad.descricao).
            vddi    =  date(acha("DtReg", planidad.descricao)).
            vxloc   =  acha("Local", planidad.descricao).  
            vddesmb =  date(acha("DtDes", planidad.descricao)).  
            vufedes =  acha("UF", planidad.descricao).  
            vcexpor =  string(plani.desti).
        end.
end. 
/***/
***/

/***
    H - Detalhamento de Produtos e Serviços da NF-e
***/


/***
Re-ordena o campo I01_Prod.nitem para que aparecam em ordem alfabetica no XML
***/
/*

assign vcont-pro-aux = 1.

for each I01_Prod of A01_infnfe by I01_Prod.xprod[1] :

    assign I01_Prod.nitem = vcont-pro-aux.
    
    assign vcont-pro-aux = vcont-pro-aux + 1.

end.
*/

assign vcont-pro-aux = 1.

for each I01_Prod of A01_infnfe by I01_Prod.xprod[1] :

    if I01_Prod.ncm = "" then I01_Prod.ncm = "00".
    
    /**** 
    **** Dulce solicitou ordenação alfabetica nos produtos ****
    geraxml("T3","","det nItem=""" + string(I01_Prod.nitem) + """","").
    ****/
    geraxml("T3","","det nItem=""" + string(vcont-pro-aux) + """","").
    
    assign vcont-pro-aux = vcont-pro-aux + 1.
    
    geraxml("T4","","prod","").
    geraxml("T5","T5","cProd",string(I01_Prod.cprod)).
    geraxml("T5","T5","cEAN","").

    run trata_caract_esp.p(input I01_Prod.xprod[1], output I01_Prod.xprod[1]).
    
    geraxml("T5","T5","xProd",I01_Prod.xprod[1]).    
    geraxml("T5","T5","NCM",string(I01_Prod.ncm)).    
    geraxml("T5","T5","CFOP",string(I01_Prod.cfop)).
    
    if I01_Prod.ucom = ""
    then I01_Prod.ucom = "UN".
    
    geraxml("T5","T5","uCom",I01_Prod.ucom).
    
    geraxml("T5","T5","qCom",topto(string(I01_Prod.qcom,">>>>>>>9.9999"))).
    geraxml("T5","T5","vUnCom",
                        topto(string(I01_Prod.vUnCom,">>>>>>>9.9999"))).    
    geraxml("T5","T5","vProd",
                        topto(string(I01_Prod.vprod,">>>>>>>>>9.99"))). 
    geraxml("T5","T5","cEANTrib","").
    
    geraxml("T5","T5","uTrib",I01_Prod.ucom).
    
    geraxml("T5","T5","qTrib",
                        topto(string(I01_Prod.qtrib,">>>>>>>9.9999"))).
    geraxml("T5","T5","vUnTrib",
                        topto(string(I01_Prod.vuntrib,">>>>>>>9.9999"))).
    
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
    
    geraxml("T5","T5","indTot", "1").

    

    /*** Claudir tirou
    /*** ANTONIO NOVO IMPORTACAO - 30/12/2010 ***/
    if E01_Dest.uf = "EX"
    then do:
            find first movim of plani where movim.movseq = I01_Prod.nitem
                             no-lock no-error.
            if not avail movim then leave.
            find first produ of movim no-lock no-error.
            vfabcod = produ.fabcod .

            find first planidad of plani no-lock no-error.    

            find first movimdad where movimdad.etbcod = planidad.etbcod and
                                      movimdad.placod = planidad.placod and
                                      movimdad.movseq = I01_Prod.nItem and
                                      movimdad.campo  = "Adicao" 
                                     no-lock no-error.
            if avail movimdad 
            then do:
                if vcompadi = 999999 /* DI - Doc.Importacao neivel de nota */
                then do: 
                
                    find last bI01_Prod of A01_infnfe no-lock no-error.
                    geraxml("T5","","DI","").
                    geraxml("T6","T6","nDI",vndi).
   
                    vdt =   string(year(vddi),"9999") + "-" +
                            string(month(vddi),"99") + "-" +
                            string(day(vddi),"99").
            
                    geraxml("T6","T6","dDI",vdt).
                    geraxml("T6","T6","xLocDesemb",vxloc).
                    geraxml("T6","T6","UFDesemb",vufedes).
            
                    vdt =   string(year(vddesmb),"9999") + "-" +
                            string(month(vddesmb),"99") + "-" +
                            string(day(vddesmb),"99").
            
                    geraxml("T6","T6","dDesemb",vdt).
                    geraxml("T6","T6","cExportador",vcexpor).
                end.
            end.
            if avail planidad and avail movimdad
            then do:
                vnadi     = int(acha("Numero", planidad.descricao)).  
                vnseqadi  = int(acha("Sequencial", planidad.descricao)).  
                if vcompadi <> vnadi
                then do: 
                    vstrchar  = string(vnadi).
                    geraxml("T6","","adi","").
                    geraxml("T7","T7","nAdicao",vstrchar).
                    vstrchar = string(vnseqadi).
                    geraxml("T7","T7","SeqAdic",vstrchar).
                    vstrchar = string(vfabcod).
                    geraxml("T7","T7","cFabricante",vstrchar).
                    geraxml("","T7","nAdicao","").
                    geraxml("","T6","adi","").
                    vcompadi  = vnadi.
                end.
                if recid(bI01_Prod) = recid (I01_Prod)  
                then geraxml("","T5","DI","").
            end.
    end.
    /*****/
    ***/
    
    geraxml("","T4","prod","").
    
    geraxml("T4","","imposto","").
    find N01_icms of I01_Prod no-lock no-error.
    geraxml("T5","","ICMS","").
    if avail N01_icms
    then do:    
        if N01_icms.cst = 0
        then do:
            geraxml("T6","","ICMS00","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","vBC",
                             topto(string(N01_icms.vbc,"zzzzzzzzzzzz9.99"))).
            geraxml("T7","T7","pICMS",
                            topto(string(N01_icms.picms,"zz9.99"))).
            geraxml("T7","T7","vICMS",
                            topto(string(N01_icms.vicms,"zzzzzzzzzzzz9.99"))).
           
            geraxml("","T6","ICMS00","").
        
        end.

        if N01_icms.cst = 10
        then do:
            geraxml("T6","","ICMS10","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            geraxml("T7","T7","vBC",
                            topto(string(N01_icms.vbc,"zzzzzzzzzzzz9.99"))).
            geraxml("T7","T7","pICMS",
                            topto(string(N01_icms.picms,"zz9.99"))).
            geraxml("T7","T7","vICMS",
                            topto(string(N01_icms.vicms,"zzzzzzzzzzzz9.99"))).
            geraxml("T7","T7","modBCST",string(N01_icms.modBCST)).

            /****
            if versatu <> 1.10
            then do:
                geraxml("T7","T7","pMVAST",
                        topto(string(N01_icms.pmvast,"zz9.99"))).
                geraxml("T7","T7","pRedBCST",
                        topto(string(N01_icms.predbcst,"zz9.99"))).
            end.            
            ***/

            if N01_icms.vBCST  > 0
            then geraxml("T7","T7","vBCST",
                         topto(string(N01_icms.vBCST,"zzzzzzzzz9.99"))).
            if N01_icms.pICMSST > 0
            then geraxml("T7","T7","pICMSST",
                         topto(string(N01_icms.pICMSST,"zzz9.99"))).
            if N01_icms.vICMSST > 0
            then geraxml("T7","T7","vICMSST",
                         topto(string(N01_icms.vICMSST,"zzzzzzzzz9.99"))).
 
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

        if N01_icms.cst = 51
        then do:
            geraxml("T6","","ICMS51","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).

            if N01_icms.predb > 0
            then geraxml("T7","T7","pRedBC",string(N01_icms.predb)).

            if N01_icms.vbc >= 0
            then geraxml("T7","T7","vBC",
                        topto(string(N01_icms.vbc,"zzzzzzzzz9.99"))).

            if N01_icms.picms >= 0
            then geraxml("T7","T7","pICMS",
                        topto(string(N01_icms.picms,"zzzzzzzzz9.99"))).

            if N01_icms.vicms >= 0
            then geraxml("T7","T7","vICMS",
                        topto(string(N01_icms.vicms,"zzzzzzzzz9.99"))).
            geraxml("","T6","ICMS51","").
        end.

        if N01_icms.cst = 60
        then do.
            geraxml("T6","","ICMS60","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","vBCSTRet", "0.00").  /* N01_icms.vbcst   */
            geraxml("T7","T7","vICMSSTRet","0.00"). /* N01_icms.vicmsst */
            geraxml("","T6","ICMS60","").
        end.

        if N01_icms.cst = 90
        then do:
            geraxml("T6","","ICMS90","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("T7","T7","modBC",string(N01_icms.modbc)).
            
            geraxml("T7","T7","vBC",
                            topto(string(N01_icms.vbc,"zzzzzzzzz9.99"))).
            if N01_icms.predb > 0
            then geraxml("T7","T7","pRedBC",string(N01_icms.predb,"zzz9.99")).
            
            geraxml("T7","T7","pICMS",
                            topto(string(N01_icms.picms,"zzzzzzzzz9.99"))).
            geraxml("T7","T7","vICMS",
                            topto(string(N01_icms.vicms,"zzzzzzzzz9.99"))).
            
            if N01_icms.modbcst > 0
            then geraxml("T7","T7","modBCST", string(N01_icms.modbcst,"9")).
            if N01_icms.pmvast <> 0
            then geraxml("T7","T7","pMVAST",
                            topto(string(N01_icms.pmvast,"zzzzzzzzz9.99"))).
            if N01_icms.predBCST > 0
            then geraxml("T7","T7","pRedBCST",
                            topto(string(N01_icms.predBCST,"zzz9.99"))).
            if N01_icms.vBCST  > 0
            then geraxml("T7","T7","vBCST",
                            topto(string(N01_icms.vBCST,"zzzzzzzzz9.99"))).
            if N01_icms.pICMSST > 0
            then geraxml("T7","T7","pICMSST",
                            topto(string(N01_icms.pICMSST,"zzz9.99"))).
            if N01_icms.vICMSST > 0
            then geraxml("T7","T7","vICMSST",
                            topto(string(N01_icms.vICMSST,"zzzzzzzzz9.99"))).
            geraxml("","T6","ICMS90","").
        end.

        if N01_icms.cst = 40
        then do:
            geraxml("T6","","ICMS40","").
            geraxml("T7","T7","orig",string(N01_icms.orig)).
            geraxml("T7","T7","CST",string(int(N01_icms.cst),"99")).
            geraxml("","T6","ICMS40","").
        end.
    end.                       
    geraxml("","T5","ICMS",""). 

    find O01_ipi of I01_Prod no-lock no-error.
    if avail O01_ipi and O01_ipi.vIPI > 0
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
    
     geraxml("T5","","II","").
     geraxml("T6","","vBC","2054.00").
     geraxml("T6","","vII","328.64"). 
     geraxml("","T5","II","").

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
        else if Q01_pis.cst >= 4 and Q01_pis.cst < 9
        then do:
             geraxml("T6","","PISNT","").
             geraxml("T7","T7","CST",string(int(Q01_pis.cst),"99")).
             geraxml("","T6","PISNT",""). 
        end. 
        else if Q01_pis.cst = 98 or Q01_pis.cst = 49
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
        else if S01_cofins.cst >= 4 and S01_cofins.cst < 9
        then do:
             geraxml("T6","","COFINSNT","").
             geraxml("T7","T7","CST",string(int(S01_cofins.cst),"99")).
             geraxml("","T6","COFINSNT",""). 
        end. 
        else if S01_cofins.cst = 98  or S01_cofins.cst = 49
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
    geraxml("T5","T5","vBCST",topto(string(W01_total.vbcst,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vST",topto(string(W01_total.vst,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vProd",topto(string(W01_total.vprod,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vFrete",topto(string(W01_total.vfrete,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vSeg",topto(string(W01_total.vseg,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vDesc",topto(string(W01_total.vdesc,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vII",topto(string(W01_total.vii,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vIPI",topto(string(W01_total.vipi,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vPIS",topto(string(W01_total.vpis,"zzzzzzzzz9.99"))).
    geraxml("T5","T5","vCOFINS",topto(string(W01_total.vcofins,"zzzzzzzzz9.99"))).
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
    /**** and
               X26_vol.esp   = vesp and   
               X26_vol.marca = "" and
               X26_vol.nvol = 0           *****/
               no-lock no-error.
    if avail X26_vol and
        X26_vol.qvol > 0
    then do:
    
        vqtd = X26_vol.qvol.
        vespecie = X26_vol.esp.
            
        geraxml("T4","","vol","").

        if vqtd > 0
        then geraxml("T5","T5","qVol", string(vqtd)).
            
        if vespecie <> ? and vespecie <> ""
        then geraxml("T5","T5","esp", vespecie).

        if vmarca <> ? and vmarca <> ""
        then geraxml("T5","T5","marca", vmarca).

        if vnumero <> ? and vnumero <> ""
        then geraxml("T5","T5","nVol", vnumero).

        if vpliqui > 0
        then geraxml("T5","T5","pesoL",topto(string(vpliqui,"zzzz9.999"))).

        if vpbruto > 0
        then geraxml("T5","T5","pesoB",topto(string(vpbruto,"zzzz9.999"))).

        geraxml("","T4","vol","").            
    end.
end.
else geraxml("T4","T4","modFrete","0").

geraxml("","T3","transp","").

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
        assign vobservacao = vobservacao + " " + Z01_InfAdic.infCpl.
               vobservacao = vobservacao + " " + vobservdec.
        
        if vobservacao <> ""
        then geraxml("T4","T4","infCpl",trim(vobservacao)).
        end.

        geraxml("","T3","infAdic","").

end.

geraxml("","T2","infNFe","").
geraxml("","T1","NFe","").
geraxml("","T1","enviNFe","").

output close.

do on error undo:
    find A01_infnfe where recid(A01_infnfe) = p-recid exclusive.
    A01_InfNFe.solicitacao = "Autorizacao". 
    A01_InfNFe.Aguardando = "Envio".                   
end.

find current a01_infnfe no-lock.

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
        tab_log.valor_campo = A01_InfNFe.chave
        .
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
        tab_log.valor_campo = A01_InfNFe.chave
        .
end.

assign
    tab_log.dtinclu = today
    tab_log.hrinclu = time.

/*
run chama-ws.p(input A01_InfNFe.emite,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "AutorizarNfe",
               input varquivo, 
               output vretorno).
*/

mail-dest = E01_Dest.email.

/*mail-dest = "leote-ti@lebes.com.br".
*/

if mail-dest <> ""
then opc-dest = "3".
else opc-dest = "".

run chama-wsnfe.p(input A01_InfNFe.etbcod,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "AutorizarNfe",
               input varquivo,
               input mail-dest,
               input opc-dest,
               input mail-tran,
               input opc-tran,
               output vretorno).
                                                            
run p-trata-retorno.

procedure p-trata-retorno:

    def var vnum-erro as integer.

    assign p-valor = "".
    run /admcom/progr/le_xml.p(input vretorno,
                               input "status_notamax",
                               output p-valor).

    assign vnum-erro = integer(p-valor).


    /*********** Se programa pre_nfe_5202 que esta na Cron chamou ********
     *********** entao nao faz consultas ao SEFAZ.      ******************/
    if vnum-erro = 0
        and program-name(2) matches("*pre_nfe_5202*")
    then do:
    
        assign A01_infnfe.solicitacao = "Autorizacao".
        
        return.

    end.
    
    case (vnum-erro):

    when 1
    then do:
    
        assign p-valor = "".
        run /admcom/progr/le_xml.p(input vretorno,
                                   input "mensagem_erro",
                                   output p-valor).
    
        assign B01_IdeNFe.temite = p-valor.
        
        assign A01_infnfe.aguardando = "Intervenção-Erro parser"
               /*A01_infnfe.solicitacao = "Correcao"*/ .

    end.
    when 0
    then do on endkey undo:
    
        message "Aguardando Autorização SEFAZ".
        pause 20 no-message.
        
        assign vcont = 0.
        
        repeat on endkey undo:
        
            if vcont > 10
            then do:

            message "Nota Enviada ao NotaMax, verifique a situação no Cockpit".
                pause .
                leave.
            end.

            p-valor = "".
            run /admcom/progr/le_tabini.p (A01_infnfe.emite, 0,
                             "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
                             arq_envio = p-valor.

            /*
            find B01_IdeNFe of A01_infnfe no-lock.
            */
            
            find C01_Emit of A01_infnfe no-lock.
            
            
            
            assign vmetodo = "ConsultarNfe".

            assign varquivo = arq_envio + vmetodo + "_"
                                  + string(A01_infnfe.numero) + "_"
                                  + string(time).

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "cnpj_emitente",
                       C01_Emit.cnpj,
                       no). 
                       
            geraXmlNfe(no,
                       "numero_nota",
                       string(A01_infnfe.numero),
                       no).
                       
            geraXmlNfe(no,
                       "serie_nota",
                       string(B01_IdeNFe.serie),
                       yes).
                       
            output close.
    
            /* Apos esperar, realiza uma consulta ao NotaMax */ 
            run chama-ws.p(input A01_infnfe.emite,
                           input A01_InfNFe.numero,
                           input "NotaMax",
                           input vmetodo,
                           input varquivo,
                           output vretorno).
                           
            assign p-valor = "".
            run /admcom/progr/le_xml.p(input vretorno,
                                       input "chave_nfe",
                                       output p-valor).

            assign vchave-aux = p-valor.
            
            run p-grava-chave-nfe-sefaz(input rowid(A01_infnfe),
                                        input p-valor).
            
            assign p-valor = "".
            run /admcom/progr/le_xml.p(input vretorno,
                                       input "status_nfe_notamax",
                                       output p-valor).
            
                                               
            case p-valor:
    
                when "2" then do:
                    
                    message "NF com erro no arquivo.".
                    pause.

                    if avail A01_infnfe
                    then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = ""
                    /*A01_infnfe.solicitacao = "Correcao" */
                    A01_infnfe.aguardando = "Intervenção-Erro parser".

                    assign p-valor = "".
                    run /admcom/progr/le_xml.p(input vretorno,
                                               input "erro_validacao",
                                               output p-valor).

                    assign B01_IdeNFe.temite = p-valor.
        
                    assign A01_infnfe.aguardando = "Intervenção-Erro parser".

                    leave.

                end.
    
    
                when "6" then do:
                
                    message "Aguardando retorno do SEFAZ (" vcont ")".
                    pause 2 no-message.

                    if avail A01_infnfe
                    then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = ""
                    A01_infnfe.solicitacao = "Autorizacao"
                    A01_infnfe.aguardando = "Aguardando SEFAZ".

                    assign B01_IdeNFe.temite = "Aguardando autorização SEFAZ".

                    next.

                end.

                    
                when "7" then do:

                    message "NF Autorizada, aguarde a impressão do DANFE".
                    pause 0 no-message.                    
                                        
                    if avail A01_infnfe
                    then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = "Autorizada"
                    A01_infnfe.solicitacao = ""
                    A01_infnfe.aguardando = "".
                    
                    if v-idamb = 1
                    then
                    run /admcom/progr/alt_mov_nfe.p(input "Cria",
                                                    input rowid(A01_infnfe)).
                    
                    if program-name(2) <> "pre_nfe_5202.p"
                    then run p-imprime-danfe.
    
                    leave.

                end.
    
                when "8" then do:
        
                    message "NF Rejeitada pelo SEFAZ.".
                    pause.
                    
                    if avail A01_infnfe
                    then assign
                        A01_infnfe.sitnfe = integer(p-valor)  
                        A01_infnfe.situacao = ""
                        /*A01_infnfe.solicitacao = "Correcao"*/
                        A01_infnfe.aguardando = "Intervenção-Rejeição SEFAZ".
    
                    assign p-valor = "".
                    run /admcom/progr/le_xml.p(input vretorno,
                                               input "erro_validacao",
                                              output p-valor).
              
                    assign B01_IdeNFe.temite = p-valor.

                    leave.

                end.
    
                when "9" then do:
        
                    message "NF Denegada pelo SEFAZ.".
                    pause.
                    
                    if avail A01_infnfe
                    then assign
                        A01_infnfe.sitnfe = integer(p-valor)  
                        A01_infnfe.situacao = "Denegada"
                        A01_infnfe.solicitacao = ""
                        A01_infnfe.aguardando = "".
    
                    assign p-valor = "".
                    run /admcom/progr/le_xml.p(input vretorno,
                                               input "erro_validacao",
                                              output p-valor).
              
                    assign B01_IdeNFe.temite = p-valor.

                    leave.

                end.

            end case.
    
            assign vcont = vcont + 1.
            
            pause 5 no-message.
             
        end.     
    
    end.
                                           
    end case.                                           
                                           

end procedure.

                               

procedure p-imprime-danfe:
            
            assign vmetodo = "ConsultarPdfNfe".

            assign varquivo = arq_envio + vmetodo + "_"
                                  + string(A01_infnfe.numero) + "_"
                                  + string(time).

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "chave_nfe",
                       vchave-aux,
                       yes). 
                       
            output close.
    
            /* Apos esperar, realiza uma consulta ao NotaMax */ 
            run chama-ws.p(input A01_infnfe.emite,
                           input A01_InfNFe.numero,
                           input "NotaMax",
                           input vmetodo,
                           input varquivo,
                           output vretorno).
            
            run visurel.p(vretorno,"").

end procedure.
                               


procedure p-grava-chave-nfe-sefaz:

    def input parameter par-rowid as rowid.
    def input parameter par-chave as char.
    
    def buffer bA01_infnfe for A01_infnfe.

    find bA01_infnfe where rowid(bA01_infnfe) = par-rowid
                                 exclusive-lock no-error.
                                 
    if avail bA01_infnfe
    then assign bA01_infnfe.id = par-chave.

end procedure.


