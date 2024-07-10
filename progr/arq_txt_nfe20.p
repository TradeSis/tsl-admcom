/*{admcab.i} */
def input parameter p-recid as recid.
def var varquivo as char.

def var v-idamb as int format "9".
v-idamb = 2.
def var p-valor as char.
p-valor = "".
run le_tabini.p (0, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
if p-valor = "PRODUCAO"
THEN v-idamb = 1.
find A01_infnfe where recid(A01_infnfe) = p-recid .
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
        row 7 overlay title " Transprotadora ".

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

    find first X26_vol where
               X26_vol.chave = A01_infnfe.chave no-error.
    if not avail X26_vol
    then create X26_vol.
    assign
        X26_vol.chave = A01_infnfe.chave
        X26_vol.qvol = vqtd
        X26_vol.esp  = vesp
        .
end.
/***/
end.
else do:
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

    find first X26_vol where
               X26_vol.chave = A01_infnfe.chave no-error.
    if not avail X26_vol
    then create X26_vol.
    assign
        X26_vol.chave = A01_infnfe.chave
        X26_vol.qvol = vqtd
        X26_vol.esp  = vesp
        .
end.         
p-valor = "".
run le_tabini.p (0, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

varquivo = p-valor + A01_infnfe.chave + ".txt".

output to value(varquivo).
put "NOTAFISCAL|1" skip.
put "A|" + string(A01_infnfe.versao,"9.99") + "|" 
        trim(substr(STRING(A01_infnfe.chave),1,3)) "|" skip.
put "B|" B01_IdeNFe.cuf    "|" B01_IdeNFe.cnf "|" 
         B01_IdeNFe.natop format "x(60)" "|"
         B01_IdeNFe.indpag "|" string(B01_IdeNFe.mod) "|" 
         string(B01_IdeNFe.serie) "|"
         string(B01_IdeNFe.nNF)    "|" 
         year(B01_IdeNFe.demi) format "9999" "-"
         month(B01_IdeNFe.demi) format "99" "-"
         day(B01_IdeNFe.demi) format "99"
          "|" B01_IdeNFe.dsaient "|"
          "|" B01_IdeNFe.hsaient "|"
         B01_IdeNFe.tpnf   "|" B01_IdeNFe.cMunFG "|" B01_IdeNFe.tpimp "|"
         B01_IdeNFe.tpemis "|" B01_IdeNFe.cdv    "|" B01_IdeNFe.idamb "|"
         B01_IdeNFe.finnfe "|" B01_IdeNFe.procemi "|"
         trim(B01_IdeNFe.verproc) "|" 
         B01_IdeNFe.dthoracont "|" B01_IdeNFe.xjus "|"
         skip.

for each B12_NFref where B12_NFref.chave = A01_infnfe.chave no-lock:
    if B12_NFref.refnfe <> ""
    then put "B13|" B12_NFref.refnfe "|" skip.
    else if B12_NFref.nnf <> 0
    then put "B14|" B12_NFref.cuf "|" B12_NFref.aamm "|" B12_NFref.cnpj "|"
        B12_NFref.mod "|" B12_NFref.serie "|"  B12_NFref.nnf "|"
        skip.
end.

find C01_Emit of A01_infnfe no-lock.        

put "C|" C01_Emit.xnome "|" C01_Emit.xfant "|" C01_Emit.ie "|"
         C01_Emit.iest "|" C01_Emit.im "|" C01_Emit.cnae "|"
         C01_Emit.crt "|"
         skip.
if C01_Emit.cnpj <> ""
then put "C02|" C01_Emit.cnpj "|" skip.
else put "C02a|" C01_Emit.cpf "|" skip.
            
put "C05|" C01_Emit.xlgr "|" C01_Emit.nro "|" C01_Emit.xcpl "|"
           C01_Emit.xbairro "|" C01_Emit.cmun "|" C01_Emit.xmun "|"
           C01_Emit.uf "|" C01_Emit.cep "|" C01_Emit.cpais "|"
           C01_Emit.xpais "|" C01_Emit.fone "|" skip.
           
find E01_Dest of A01_infnfe no-lock.           

put "E|" E01_Dest.xnome "|" E01_Dest.ie "|" 
         E01_Dest.isuf "|" E01_Dest.email "|" 
         skip.
if E01_Dest.cnpj <> ""
then put "E02|" E01_Dest.cnpj "|" skip.
else put "E03|" E01_Dest.cpf "|" skip.

put "E05|" E01_Dest.xlgr "|" E01_Dest.nro "|" E01_Dest.xcpl "|"
           E01_Dest.xbairro "|" E01_Dest.cmun "|" E01_Dest.xmun "|" 
           E01_Dest.uf "|"
           E01_Dest.cep "|" E01_Dest.cpais "|" E01_Dest.xpais "|"
           E01_Dest.fone "|" E01_Dest.ISUF "|" E01_Dest.email "|"
           skip.
           
find F01_Retirada of A01_infnfe no-lock no-error.
if avail F01_Retirada then
put "F|" F01_Retirada.cnpj "|" F01_Retirada.xlgr "|" F01_Retirada.nro "|"
         F01_Retirada.xcpl "|" F01_Retirada.xbairro "|" F01_Retirada.cmun "|"
         F01_Retirada.xmun "|" F01_Retirada.uf "|" skip.
           
find G01_Entrega of A01_infnfe no-lock no-error.
if avail G01_Entrega then
put "G|" G01_Entrega.cnpj "|" G01_Entrega.xlgr "|" G01_Entrega.nro "|"
         G01_Entrega.xcpl "|" G01_Entrega.xbairro "|" G01_Entrega.cmun "|"
         G01_Entrega.xmun "|" G01_Entrega.uf "|" skip.
           
for each I01_Prod of A01_infnfe no-lock:
    put "H|" I01_Prod.nitem "|" I01_Prod.infadprod "|" skip
        "I|" I01_Prod.cprod "|" /*I01_Prod.cean*/ "|" I01_Prod.xprod "|"
             I01_Prod.ncm "|" 
             I01_Prod.extipi "|" I01_Prod.genero "|"
             I01_Prod.cfop "|" I01_Prod.ucom "|" 
             I01_Prod.qcom   format ">>>>>>>>>9.9999" "|" 
             I01_Prod.vuncom format ">>>>>>>>>>>>>>>9.9999" "|" 
             I01_Prod.vprod  format ">>>>>>>>>9.99" "|" 
             I01_Prod.ceantrib "|"
             I01_Prod.utrib "|" 
             I01_Prod.qtrib   format ">>>>>>>>>9.9999" "|" 
             I01_Prod.vuntrib format ">>>>>>>>>>>>>>>9.9999" "|".
        if I01_Prod.vfrete > 0 
        then put I01_Prod.vfrete format ">>>>>>>>>9.99".
        put "|".
        if I01_Prod.vseg > 0 
        then put I01_Prod.vseg format ">>>>>>>>>9.99".
        put "|".
        if I01_Prod.vdesc > 0 
        then put I01_Prod.vdesc format ">>>>>>>>>9.99".
        put "|" .
        if I01_Prod.voutro > 0
        then put I01_Prod.voutro format ">>>>>>>>>9.99".
        put "|"
        I01_Prod.indprod "|" I01_Prod.xped "|" I01_Prod.nitemped "|"
        skip.

    for each I18_DI of I01_Prod no-lock.
        put "I18|" I18_DI.ndi "|" I18_DI.ddi "|" I18_DI.xlocdesemb "|"
                   I18_DI.ufdesemb "|" I18_DI.ddesemb "|" 
                I18_DI.cexportador "|" skip.
                 
        for each I25_ADI of I18_DI no-lock:
            put "I25|" I25_ADI.nadicao "|" I25_ADI.nseqadic "|"
                       I25_ADI.cfabricante "|" I25_ADI.vldescdi "|"
                       skip.
        end.
    end.
    put "M|" skip.
    put "N|" skip.
    find N01_icms of I01_Prod no-lock no-error.
    if avail N01_icms
    then do:
        if N01_icms.cst = 0
        then put "N02|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" skip.
        else if N01_icms.cst = 10
        then put "N03|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" N01_icms.modbcst "|" 
                        N01_icms.pmvast "|" N01_icms.predbcst "|"
                        N01_icms.vbcst "|" N01_icms.picmsst "|" skip.
        else if N01_icms.cst = 20
        then put "N04|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.predbc "|" 
                        N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" skip.
        else if N01_icms.cst = 30
        then put "N05|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbcst "|" N01_icms.pmvast "|"
                        N01_icms.predbcst "|" N01_icms.vbcst "|" 
                        N01_icms.picmsst "|" skip.
        else if N01_icms.cst = 40 or
                N01_icms.cst = 41 or 
                N01_icms.cst = 50   
        then put "N06|" N01_icms.orig "|" N01_icms.cst "|"  
                        N01_icms.vicms "|" N01_icms.motdesicms "|"
                        skip.              
        else if N01_icms.cst = 51
        then put "N07|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.predbc "|" 
                        N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" skip.
        else if N01_icms.cst = 60
        then put "N08|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.vbcst "|" N01_icms.vicmsst "|" skip.
        else if N01_icms.cst = 70
        then put "N09|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.predbc "|" 
                        N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" N01_icms.modbcst "|"
                        N01_icms.pmvast "|" N01_icms.predbcst "|"
                        N01_icms.vbcst "|" N01_icms.picmsst "|"
                        N01_icms.vicmsst "|" skip.
        else if N01_icms.cst = 90
        then put "N10|" N01_icms.orig "|" N01_icms.cst "|"
                        N01_icms.modbc "|" N01_icms.predbc "|" 
                        N01_icms.vbc "|" N01_icms.picms "|"
                        N01_icms.vicms "|" N01_icms.modbcst "|"
                        N01_icms.pmvast "|" N01_icms.predbcst "|"
                        N01_icms.vbcst "|" N01_icms.picmsst "|"
                        N01_icms.vicmsst "|" skip.

    end.                       
    find O01_ipi of I01_Prod no-lock no-error.
    if avail O01_ipi
    then do:
        put "O|".
        if O01_ipi.clenq <> "" then put O01_ipi.clenq.
        put "|".
        if O01_ipi.cnpjprod <> "" then put O01_ipi.cnpjprod.
        put "|".
        if O01_ipi.cselo <> "" then put O01_ipi.cselo.
        put "|".
        if O01_ipi.qselo > 0 then put O01_ipi.qselo.
        put "|".
        put O01_ipi.cenq "|" skip.
                 
        if  O01_ipi.cst = 00 or
               O01_ipi.cst = 49 or
               O01_ipi.cst = 50 or
               O01_ipi.cst = 53 or
               O01_ipi.cst = 99
        then do:
                put "O08|" O01_ipi.cst "|" /*O01_ipi.vipi "|"*/ skip.
                /*
                put "O10|" O01_ipi.vbc "|" O01_ipi.pipi "|"skip.
                put "O11|" O01_ipi.vunid "|" O01_ipi.qunid "|" skip.
                */
        end.
    end. 
    
    put "Q|"  skip.
    find Q01_pis of I01_Prod no-lock no-error.
    if avail Q01_pis
    then do:
        if Q01_pis.cst = 01 or
           Q01_pis.cst = 02
        then put "Q02|" Q01_pis.cst "|" Q01_pis.vbc "|" Q01_pis.ppis "|"
                        Q01_pis.vpis "|" skip.
        else if Q01_pis.cst = 03
        then put "Q03|" Q01_pis.cst "|" Q01_pis.qbcprod "|" 
                        Q01_pis.valiqprod "|" Q01_pis.vpis "|" skip.
        else if Q01_pis.cst = 04 or
                Q01_pis.cst = 06 or         
                Q01_pis.cst = 07 or
                Q01_pis.cst = 08 or
                Q01_pis.cst = 09
        then put "Q04|" Q01_pis.cst "|" skip.
        else if Q01_pis.cst = 99
        then put "Q05|" Q01_pis.cst "|" Q01_pis.vbc "|" Q01_pis.ppis "|"
                        Q01_pis.qbcprod "|" Q01_pis.valiqprod "|" 
                        Q01_pis.vpis "|" skip.
                        
    end.
    find R01_pisst of I01_Prod no-lock no-error.
    if avail R01_pisst
    then do:
        put "R|" R01_pisst.vpis "|" skip
            "R02|" R01_pisst.vbc "|" skip
            "R04|" R01_pisst.qbcprod "|" R01_pisst.valiqprod "|" skip.
    end.
    put "S|" skip.
    find S01_cofins of I01_Prod no-lock no-error.
    if avail S01_cofins
    then do:
        if S01_cofins.cst = 01 or
           S01_cofins.cst = 02
        then put "S02|" S01_cofins.cst "|" S01_cofins.vbc "|" 
                        S01_cofins.pcofins "|" S01_cofins.vcofins "|" skip.
        else if S01_cofins.cst = 03
        then put "S03|" S01_cofins.cst "|" S01_cofins.qbcprod "|" 
                        S01_cofins.valiqprod "|" S01_cofins.vcofins "|" skip.
        else if S01_cofins.cst = 04 or
                S01_cofins.cst = 06 or
                S01_cofins.cst = 07 or
                S01_cofins.cst = 08 or
                S01_cofins.cst = 09 
        then put "S04|" S01_cofins.cst "|" skip.
        else if S01_cofins.cst = 99
        then do:
            put "S05|" S01_cofins.cst "|" S01_cofins.vcofins "|" skip
                "S07|" S01_cofins.vbc "|" S01_cofins.pcofins "|" skip
                "S09|" S01_cofins.qbcprod "|" S01_cofins.valiqprod "|" skip.
        end.        
    end.
    find T01_cofinsst of I01_Prod no-lock no-error.
    if avail T01_cofinsst
    then do:
        put "T02|" T01_cofinsst.vbc "|" skip
            "T04|" T01_cofinsst.qbcprod "|" T01_cofinsst.valiqprod "|" skip.
    end.
    find U01_issqn of I01_Prod no-lock no-error.
    if avail U01_issqn
    then do:
        put "U|" U01_issqn.vbc "|" U01_issqn.valiq "|" U01_issqn.vlissqn "|"
                 U01_issqn.cmunfg "|" U01_issqn.clistserv "|" skip.
    end.
            
end.

/**** Totais da nfe ****/
put "W|" skip.            
find W01_total of A01_infnfe no-lock no-error.
if avail W01_total
then put "W02|" W01_total.vbc format ">>>>>>>>>>>9.99" "|" 
                W01_total.vicms format ">>>>>>>>>>>9.99" "|" 
                W01_total.vbcst format ">>>>>>>>>>>9.99" "|"
                W01_total.vst format ">>>>>>>>>>>9.99" "|" 
                W01_total.vprod format ">>>>>>>>>>>9.99" "|" 
                W01_total.vfrete format ">>>>>>>>>>>9.99" "|"
                W01_total.vseg format ">>>>>>>>>>>9.99" "|" 
                W01_total.vdesc format ">>>>>>>>>>>9.99" "|" 
                W01_total.vii format ">>>>>>>>>>>9.99" "|"
                W01_total.vipi format ">>>>>>>>>>>9.99" "|" 
                W01_total.vpis format ">>>>>>>>>>>9.99" "|" 
                W01_total.vcofins format ">>>>>>>>>>>9.99" "|"
                W01_total.voutro format ">>>>>>>>>>>9.99" "|" 
                W01_total.vnf format ">>>>>>>>>>>9.99" "|" skip.
find W17_issqntot of A01_infnfe no-lock no-error.                
if avail W17_issqntot
then put "W17|" W17_issqntot.vserv format ">>>>>>>>>>>9.99" "|" 
                W17_issqntot.vbc format ">>>>>>>>>>>9.99" "|" 
                W17_issqntot.viss format ">>>>>>>>>>>9.99" "|" 
                W17_issqntot.vpis format ">>>>>>>>>>>9.99" "|"
                W17_issqntot.vcofins format ">>>>>>>>>>>9.99" "|" skip.
find W23_rettribtot of A01_infnfe no-lock no-error.
if avail W23_rettribtot
then put "W23|" W23_rettribtot.vretpis format ">>>>>>>>>>>9.99" "|" 
                W23_rettribtot.vretcofins format ">>>>>>>>>>>9.99" "|"
                W23_rettribtot.vretcsll format ">>>>>>>>>>>9.99" "|"
                W23_rettribtot.vbcirrf format ">>>>>>>>>>>9.99" "|"
                W23_rettribtot.virrf format ">>>>>>>>>>>9.99" "|"
                W23_rettribtot.vbcretprev format ">>>>>>>>>>>9.99" "|"
                W23_rettribtot.vretprev format ">>>>>>>>>>>9.99" "|" skip.

/*
put "X|1|" skip.
*/

find first X01_transp where
                   X01_transp.chave = A01_infnfe.chave no-lock no-error.
if avail X01_transp
then do:

    put "X|" X01_transp.modfrete "|" skip.

    if X01_transp.modfrete <> 1 and
       X01_transp.modfrete <> 9
    then do:
        put "X03|" X01_transp.xnome "|" X01_transp.ie "|" X01_transp.xender "|"
               X01_transp.uf "|" X01_transp.xmun "|" skip.
        put "X04|" X01_transp.cnpj "|" skip.
        /*
         "X05|" X01_transp.cpf "|" skip.
        */
        /*
        if X01_transp.vserv > 0
        then put "X11|" X01_transp.vserv "|" X01_transp.vbcret "|"
                    X01_transp.picmsret "|" X01_transp.vicmsret "|"
                    X01_transp.cfop "|" X01_transp.cmunfg "|" skip.
        */
        
        if X01_transp.placa <> ""
        then put "X18|" X01_transp.placa "|" X01_transp.uf "|"
               X01_transp.rntc "|" skip.
        
        /**
        for each X22_reboque where 
             X22_reboque.chave = X01_transp.chave and
             X22_reboque.cnpj  = X01_transp.cnpj  and
             X22_reboque.cpf   = X01_transp.cpf 
              no-lock:
            put "X22|" X22_reboque.placa "|" X22_reboque.uf "|"
                   X22_reboque.rntc "|" skip.
        end.
        **/
        
        for each X26_vol of X01_transp no-lock:
            put "X26|" X26_vol.qvol "|" X26_vol.esp "|" X26_vol.marca "|" .
            if X26_vol.nvol > 0 then put X26_vol.nvol.
            put "|".
            if  X26_vol.pesol > 0 then put X26_vol.pesol.
            put "|".
            if X26_vol.pesob > 0 then put X26_vol.pesob.
            put "|" skip.
        end.

        /**
        for each X33_lacres of X01_transp no-lock:
            put "X33|" X33_lacres.nlacre "|" skip.
        end.
        **/
    end.
end. 
               
for each Y01_cobr of A01_infnfe no-lock break by nfat:
    if first-of(nfat)
    then put "Y02|" Y01_cobr.nfat "|" Y01_cobr.vorig "|" Y01_cobr.vdesc "|"
                    Y01_cobr.vliq "|" skip.
    put "Y07|" Y01_cobr.ndup "|" Y01_cobr.dvenc "|" Y01_cobr.vdup "|" skip.
end.
for each Z01_infadic of A01_infnfe no-lock:
    if Z01_infadic.obscont <> "" or Z01_infadic.xcampo <> ""
    then.
    put "Z|" Z01_infadic.infadfisco "|" trim(Z01_infadic.obscont) "|" skip.
    put "Z04|" Z01_infadic.xcampo "|" 
            Z01_infadic.xtexto format "x(50)" "|" skip.
end.
output close.
                    
A01_InfNFe.solicitacao = "Autorizacao". 
A01_InfNFe.Aguardando = "Envio".                   

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

  
return.  
