
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.

def buffer etb-emite for estab.
def buffer etb-desti for estab.
def buffer mun-emite for munic.
def buffer mun-desti for munic.
find first tt-plani no-error.

find tipmov where tipmov.movtdc = tt-plani.movtdc no-lock.

def output parameter v-ok as log.
def output parameter v-rec-nota as recid.

v-ok = no.

def var serie-nfe as char.
def var p-valor as char.
run le_tabini.p (tt-plani.etbcod , 0,
            "NFE - SERIE", OUTPUT p-valor) .

serie-nfe = p-valor.

find first tt-plani.
find tipmov where tipmov.movtdc = tt-plani.movtdc no-lock no-error.
if not avail tipmov
then do:
    message color red/with
    "Tipo de documento " tt-plani.movtdc " nao cadastrado."
    view-as alert-box.
    v-ok = no.
    return.
end.    
    
def var modelo-documento as char init "55".

def var natureza-operacao as char.
find first tipmovaux where tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "natureza-operacao"
                           no-lock no-error.
if avail tipmovaux
then natureza-operacao = tipmovaux.valor_campo.

def var chave-nfe as char.
def var vemitecgc as char.
def var vdesticgc as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char.
def var vtofcod as char.
def var ind-entrega as log init no.
def var ent-endereco as char.
def var ent-numero as char.
def var ent-compl as char.
def var ent-bairro as char.
def var ent-cep as char.
def var ent-cidade as char.
def var ent-ufecod as char.
/*
find first planiaux where planiaux.etbcod      = tt-plani.etbcod
                      and planiaux.placod      = tt-plani.placod
                      and planiaux.emite       = tt-plani.emite
                      and planiaux.numero      = tt-plani.numero
                      and planiaux.nome_campo  = "ENTREGA"
                          no-lock no-error.
if avail planiaux
then do:
    assign
    ent-endereco = acha("endereco"     ,planiaux.valor_campo)
    ent-numero   = acha("numero"       ,planiaux.valor_campo)
    ent-compl    = acha("complemento"  ,planiaux.valor_campo)
    ent-bairro   = acha("bairro"  ,planiaux.valor_campo)
    ent-cep      = acha("cep"          ,planiaux.valor_campo)
    ent-cidade   = acha("cidade"  ,planiaux.valor_campo)
    ent-ufecod   = acha("uf"      ,planiaux.valor_campo)
    ind-entrega = yes
    .
end.
else*/ ind-entrega = no.

assign
    tt-plani.etbcod = 200
    tt-plani.emite = 200
    tt-plani.serie  = "55"
    tt-plani.movtdc = 12.

if ent-ufecod <> ""
then do:
    if ent-ufecod = "RS"
    then assign    
            tt-plani.hiccod = 1202
            tt-plani.opccod = 1202
            .
    else assign    
            tt-plani.hiccod = 2202
            tt-plani.opccod = 2202
            .
end.
else do:
    find clien where clien.clicod = tt-plani.desti no-lock no-error.
    if avail clien
    then do:
        if clien.ufecod[1] = "RS"
        then assign    
            tt-plani.hiccod = 1202
            tt-plani.opccod = 1202
            .
        else assign    
            tt-plani.hiccod = 2202
            tt-plani.opccod = 2202
            .
    end.
    else do:
        assign    
            tt-plani.hiccod = 1202
            tt-plani.opccod = 1202
            .
    end.
end.
    
for each tt-movim:
    tt-movim.movtdc = 12 .
    tt-movim.etbcod = 200.
end.

def var val-pis as dec.
def var val-cof as dec.

do:
    DO:
        find etb-emite where etb-emite.etbcod = tt-plani.emite no-lock.
        find mun-emite where mun-emite.cidnom = etb-emite.munic and
                             mun-emite.ufecod = etb-emite.ufecod no-lock.
        find etb-desti where etb-desti.etbcod = tt-plani.desti no-lock.
        find mun-desti where mun-desti.cidnom = etb-desti.munic and
                             mun-desti.ufecod = etb-desti.ufecod no-lock.

        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-emite.etbcod,"999") and
             tabaux.nome_campo = "BAIRRO" no-lock no-error.
        if avail tabaux
        then bairro-emite = tabaux.valor_campo.
        else bairro-emite = "".

        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-emite.etbcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then cep-emite = int(tabaux.valor_campo).
        else cep-emite = 0.
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-desti.etbcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then cep-desti = int(tabaux.valor_campo).
        else cep-desti = 0.
        
        def var ibge-uf-emite as char.
        find first tabaux where  tabaux.tabela = "codigo-ibge" and
                        tabaux.nome_campo = etb-emite.ufecod 
                        no-lock no-error.
        if not avail tabaux
        then do:
            bell.
            message color red/with
            "Codigo do IBGE nao cadastrado para UF " etb-emite.ufecod 
            view-as alert-box.
            v-ok = no.
            return.
        end.  
        ibge-uf-emite = tabaux.valor_campo.
        
        vemitecgc = etb-emite.etbcgc.
        vemitecgc = replace(vemitecgc,".","").
        vemitecgc = replace(vemitecgc,"/","").
        vemitecgc = replace(vemitecgc,"-","").
        vdesticgc = etb-desti.etbcgc.
        vdesticgc = replace(vdesticgc,".","").
        vdesticgc = replace(vdesticgc,"/","").
        vdesticgc = replace(vdesticgc,"-","").
        vemiteie  = etb-emite.etbinsc.
        vemiteie  = replace(vemiteie,"/","").  
        vdestiie  = etb-desti.etbinsc.
        vdestiie  = replace(vdestiie,"/","").
        find last A01_infnfe where   A01_infnfe.emite = tt-plani.emite and
                        A01_infnfe.serie = tt-plani.serie 
                        exclusive no-error.
        if not avail A01_infnfe
        then assign
                tt-plani.placod = 550000001
                tt-plani.numero = 1.
        else assign
                tt-plani.placod = A01_infnfe.placod + 1
                tt-plani.numero = A01_infnfe.numero + 1.

        for each tt-movim:
            tt-movim.placod = tt-plani.placod.
        end.

        chave-nfe = "NFe" + ibge-uf-emite + string(year(tt-plani.pladat)) +
                         string(month(tt-plani.pladat)) +
                         vemitecgc +
                         modelo-documento +
                         serie-nfe +
                         string(tt-plani.numero,"999999999").
 
                        
        create A01_infnfe.
        assign
                    A01_infnfe.chave = chave-nfe
                    A01_infnfe.emite = tt-plani.emite
                    A01_infnfe.serie = string(tt-plani.serie)
                    A01_infnfe.numero = tt-plani.numero
                    A01_infnfe.etbcod = tt-plani.etbcod
                    A01_infnfe.placod = tt-plani.placod
                    A01_infnfe.versao = 1.10
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Cliente"
                    v-ok = yes
                    v-rec-nota = recid(A01_infnfe).
        
        find opcom where opcom.opccod = string(tt-plani.opccod) no-lock.
        
        create B01_IdeNFe.
        assign
                    B01_IdeNFe.chave  = chave-nfe 
                    B01_IdeNFe.cuf    = int(ibge-uf-emite)
                    B01_IdeNFe.cnf    = dec(
                (int(modelo-documento) * 1000000) + tt-plani.numero  )
                    B01_IdeNFe.natop  = opcom.opcnom
                    B01_IdeNFe.indpag = 0
                    B01_IdeNFe.mod    = modelo-documento
                    B01_IdeNFe.serie  = int(serie-nfe)
                    B01_IdeNFe.nNF    = tt-plani.numero
                    B01_IdeNFe.demi   = tt-plani.pladat
                    B01_IdeNFe.hemi   = tt-plani.horincl
                    B01_IdeNFe.hemi   = tt-plani.horincl
                    B01_IdeNFe.dsaient = ?
                    B01_IdeNFe.tpnf   = 0
                    B01_IdeNFe.cMunFG = mun-emite.cidcod
                    B01_IdeNFe.tpimp  = "1"
                    B01_IdeNFe.tpemis = 1
                    B01_IdeNFe.cdv    = 0
                    B01_IdeNFe.idamb  = 2
                    B01_IdeNFe.finnfe = 1
                    B01_IdeNFe.procemi = 0
                    B01_IdeNFe.verproc = "1.4.1"
                    v-ok = yes.

        /*** NF Referenciada        
        for each tt-nfref no-lock:
            find B12_NFref of A01_infnfe where
                    B12_NFref.refnfe = tt-nfref.chave-nfe
                    no-lock no-error.
            if nota avail B12_NFref
            then do:
                create B12_NFref.
                assign 
                    B12_NFref.refnfe = tt-nfref.chave-nfe
                    B12_NFref.cuf    = 
                    B12_NFref.aamm   =
                    B12_NFref.cnpj   =
                    B12_NFref.mod    =
                    B12_NFref.serie  =
                    B12_NFref.nnf    =
                    .
            end.
        end.
        ***/
        
        find C01_Emit of A01_infnfe no-lock no-error.
        if not avail C01_Emit
        then do:
            create C01_Emit.
            assign
                C01_Emit.chave = A01_infnfe.chave
                C01_Emit.xnome = etb-emite.etbnom
                C01_Emit.xfant = etb-emite.etbnom
                C01_Emit.ie    = vemiteie
                /*C01_Emit.iest  = ""
                C01_Emit.im    = ""
                C01_Emit.cnae  = 0 */
                C01_Emit.cnpj  = vemitecgc
                /*C01_Emit.cpf = ""*/   
                C01_Emit.xlgr  = entry(1,etb-emite.endereco,",")
                C01_Emit.nro   = entry(2,etb-emite.endereco,",")
                /*C01_Emit.xcpl  = entry(3,etb-emite.endereco,",") */
                C01_Emit.xbairro = bairro-emite 
                C01_Emit.cmun = mun-emite.cidcod
                C01_Emit.xmun = mun-emite.cidnom
                C01_Emit.uf   = mun-emite.ufecod
                C01_Emit.cep  = cep-emite
                /*C01_Emit.cpais 
                C01_Emit.xpais   */
                C01_Emit.fone = dec(etb-emite.etbserie) 
                .
        end.           

        find E01_Dest of A01_infnfe no-lock no-error.
        if not avail E01_Dest
        then do:
            create E01_Dest.
            assign
                E01_Dest.chave = A01_infnfe.chave
                E01_Dest.xnome = etb-desti.etbnom
                E01_Dest.ie =    vdestiie
                /*E01_Dest.isuf 
                E01_Dest.email*/ 
                E01_Dest.cnpj  = vdesticgc
                /*E01_Dest.cpf   = */
                E01_Dest.xlgr  = entry(1,etb-emite.endereco,",")
                E01_Dest.nro   = entry(2,etb-emite.endereco,",")
                /*E01_Dest.xcpl  = entry(3,etb-desti.endereco,",") */
                E01_Dest.xbairro = bairro-emite 
                E01_Dest.cmun = mun-desti.cidcod
                E01_Dest.xmun = mun-desti.cidnom
                E01_Dest.uf =   mun-desti.ufecod
                E01_Dest.cep = cep-desti
                /*E01_Dest.cpais 
                E01_Dest.xpais */
                E01_Dest.fone  = dec(etb-desti.etbserie)
                .
            if avail cpforne
            then E01_Dest.email = cpforne.char-2. 
        end.   
        /***
        find F01_Retirada of A01_infnfe no-lock NO-ERROR.
        if not-avail F01_Retirada
        then do:
            create F01_Retirada.
            assign
                F01_Retirada.chave = A01_infnfe.chave
                F01_Retirada.cnpj =
                F01_Retirada.xlgr =
                F01_Retirada.nro  =
                F01_Retirada.xcpl =
                F01_Retirada.xbairro =
                F01_Retirada.cmun =
                F01_Retirada.xmun =
                F01_Retirada.uf =
                .
                
        find G01_Entrega of A01_infnfe no-lock no-error.
        if not avail G01_Entrega
        then do:
            create G01_Entrega.
            assign
                G01_Entrega.chave = A01_infnfe.chave
                G01_Entrega.cnpj  =
                G01_Entrega.xlgr  =
                G01_Entrega.nro   =
                G01_Entrega.xcpl  =
                G01_Entrega.xbairro =
                G01_Entrega.cmun =
                G01_Entrega.xmun =
                G01_Entrega.uf   =
                .
        end.
        ***/
                
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                         tt-movim.placod = tt-plani.placod and
                                         tt-movim.movtdc = tt-plani.movtdc and
                                         tt-movim.movdat = tt-plani.pladat
                                         no-lock:
                             
            find produ where produ.procod = tt-movim.procod no-lock.
            
            find I01_Prod of A01_infnfe where
                I01_Prod.nitem = tt-movim.movseq
                no-error.
            if not avail I01_Prod
            then do:
                create I01_Prod.
                assign
                    I01_Prod.chave = A01_infnfe.chave
                    I01_Prod.nitem = tt-movim.movseq
                    /*I01_Prod.infadprod*/ 
                    I01_Prod.cprod = string(tt-movim.procod)
                    /*I01_Prod.cean*/ 
                    I01_Prod.xprod = produ.pronom
                    I01_Prod.ncm   = if produ.codfis <> 0
                                     then string(produ.codfis)  else ""
                    /*I01_Prod.extipi 
                    I01_Prod.genero*/ 
                    I01_Prod.cfop = tt-plani.opccod
                    I01_Prod.ucom = produ.prounven
                    I01_Prod.qcom = tt-movim.movqtm
                    I01_Prod.vuncom = tt-movim.movpc
                    I01_Prod.vprod =  tt-movim.movpc * tt-movim.movqtm
                    /*I01_Prod.ceantrib */
                    I01_Prod.utrib = produ.prounven
                    I01_Prod.qtrib = tt-movim.movqtm
                    I01_Prod.vuntrib = tt-movim.movpc
                    I01_Prod.vfrete = 0
                    I01_Prod.vseg =   0
                    I01_Prod.vdesc =  0
                    .
            end.                            
            
            find N01_icms of I01_Prod no-lock no-error.
            if not avail N01_icms
            then do:
                    create N01_icms.
                    assign
                        N01_icms.chave = I01_Prod.chave
                        N01_icms.nitem = I01_Prod.nitem
                        N01_icms.orig  = produ.codori
                        .
                    if tt-movim.movalicms = 0
                    then assign    
                        N01_icms.cst = 60
                        N01_icms.modbc = 1
                        N01_icms.vbc = 0
                        N01_icms.picms = 0
                        N01_icms.vicms = 0
                        .
                    else assign
                        N01_icms.cst = 0
                        N01_icms.modbc = 1
                        N01_icms.vbc = tt-movim.movpc * tt-movim.movqtm
                        N01_icms.picms = tt-movim.movalicms
                        N01_icms.vicms = N01_icms.vbc * 
                                    (tt-movim.movalicms / 100).
            end.                       

            find O01_ipi of I01_Prod no-lock no-error.
            if not avail O01_ipi
            then do:
                create O01_ipi.
                assign 
                    O01_ipi.chave = I01_Prod.chave
                    O01_ipi.nitem = I01_Prod.nitem
                   /* O01_ipi.clenq = 
                    O01_ipi.cnpjprod =
                    O01_ipi.cselo =
                    O01_ipi.qselo = */
                    O01_ipi.cenq  = "999"
                    O01_ipi.cst = 53
                    O01_ipi.vipi = 0
                    /*O01_ipi.vbc =
                    O01_ipi.pipi =
                    O01_ipi.vunid =
                    O01_ipi.qunid = */
                    .
            end.                    

            find first clafis where
                 clafis.codfis = produ.codfis no-lock no-error.
            
            if avail clafis and
                clafis.cofinssai > 0 or
                clafis.pissai > 0
            then do: 
                find Q01_pis of I01_Prod no-lock no-error.
                if not avail Q01_pis
                then do:
                    create Q01_pis.
                    assign
                        Q01_pis.chave = I01_Prod.chave
                        Q01_pis.nitem = I01_Prod.nitem
                        Q01_pis.cst = 98
                        Q01_pis.vbc = I01_Prod.vprod
                        Q01_pis.ppis = if clafis.pissai > 0
                            then clafis.pissai else 1.65
                        Q01_pis.vpis = I01_Prod.vprod * (Q01_pis.ppis / 100).
                        val-pis = val-pis + Q01_pis.vpis.
                end.
 
                find S01_cofins of I01_Prod no-lock no-error.
                if not avail S01_cofins
                then do:                                             
                    create S01_cofins.
                    assign
                        S01_cofins.chave = I01_Prod.chave
                        S01_cofins.nitem = I01_Prod.nitem
                        S01_cofins.cst = 98
                        S01_cofins.vbc = I01_Prod.vprod
                        S01_cofins.pcofins = if clafis.cofinssai > 0
                                then clafis.cofinssa else 7.60
                        S01_cofins.vcofins = I01_Prod.vprod * 
                                        (S01_cofins.pcofins / 100).
                    val-cof = val-cof + S01_cofins.vcofins .
                end.
            end.
            else do: 
                find Q01_pis of I01_Prod no-lock no-error.
                if not avail Q01_pis
                then do:
                    create Q01_pis.
                    assign
                        Q01_pis.chave = I01_Prod.chave
                        Q01_pis.nitem = I01_Prod.nitem
                        Q01_pis.cst = 06.
                    if avail clafis and
                             clafis.log1 /* Monofasico */
                    then Q01_pis.cst = 04.
                end.
 
                find S01_cofins of I01_Prod no-lock no-error.
                if not avail S01_cofins
                then do:                                             
                    create S01_cofins.
                    assign
                        S01_cofins.chave = I01_Prod.chave
                        S01_cofins.nitem = I01_Prod.nitem
                        S01_cofins.cst = 06
                        .
                    if avail clafis and
                        clafis.log1 /* Monofasico */
                    then S01_cofins.cst = 04.
                end.
            end.

        end.            
        /**** Totais da nfe ****/
            
        find W01_total of A01_infnfe no-lock no-error.
        if not avail W01_total
        then do:
            create W01_total.
            assign
                W01_total.chave = A01_infnfe.chave 
                W01_total.vbc = tt-plani.bicms
                W01_total.vicms = tt-plani.icms
                /*W01_total.vbcst =
                W01_total.vst =*/
                W01_total.vprod = tt-plani.protot
                /*W01_total.vfrete =
                W01_total.vseg  =
                W01_total.vdesc =
                W01_total.vii = 
                W01_total.vipi =
                */
                W01_total.vpis = val-pis
                W01_total.vcofins = val-cof
                /*W01_total.voutro = */
                W01_total.vnf = tt-plani.platot
                .
        end.                
        /*** implementar
        find W17_issqntot of A01_nfe no-lock no-error.                
        if not avail W17_issqntot
        then do:
            put "W17|" W17_issqntot.vserv "|" W17_issqntot.vbc "|" 
                W17_issqntot.viss "|" W17_issqntot.vpis "|"
                W17_issqntot.vcofins "|" skip.
        end.
        find W23_rettribtot of A01_nfe no-lock no-error.
        if avail W23_rettribtot
        then 
            put "W23|" W23_rettribtot.vretpis "|" W23_rettribtot.vretcofins "|"
                W23_rettribtot.vretcsll "|" W23_rettribtot.vbcirrf "|"
                W23_rettribtot.virrf "|" W23_rettribtot.vbcretprev "|"
                W23_rettribtot.vretprev "|" skip.
        ***/
        
        /***
        find X01_transp of A01_infnfe no-lock no-error.
        if not avail X01_transp
        then do:
            create X01_transp.
            assign
                X01_transp.chave = A01_infnfe.chave
                X01_transp.modfrete = 1
                .
            /**    
            put "X|" X01_transp.modfrete "|" skip
         "X03|" X01_transp.xnome "|" X01_transp.ie "|" X01_transp.xender "|"
                X01_transp.uf "|" X01_transp.xmun "|" skip
         "X04|" X01_transp.cnpj "|" skip
         "X05|" X01_transp.cpf "|" skip.

        if X01_transp.vserv > 0
        then put "X11|" X01_transp.vserv "|" X01_transp.vbcret "|"
                    X01_transp.picmsret "|" X01_transp.vicmsret "|"
                    X01_transp.cfop "|" X01_transp.cmunfg "|" skip.
        if X01_transp.placa <> ""
        then put "X18|" X01_transp.placa "|" X01_transp.uf "|"
                    X01_transp.rntc "|" skip.
            **/
        end.
        ***/
        /*** Implementar 
        for each X22_reboque of X01_transp no-lock:
            put "X22|" X22_reboque.placa "|" X22_reboque.uf "|"
                   X22_reboque.rntc "|" skip.
        end.
        for each X26_vol of X01_transp no-lock:
            put "X26|" X26_vol.qvol "|" X26_vol.esp "|" X26_vol.marca "|"
                       X26_vol.nvol "|" X26_vol.pesol "|" X26_vol.pesob skip
        end.
        for each X33_lacres of X01_transp no-lock:
            put "X33|" X33_vol.nlacre "|" skip.
        end.
        end.                
        for each Y01_cobr of A01_nfe brek by nfat no-lock:
        if first-off(nfat)
        then put "Y02|" Y01_cobr.nfat "|" Y01_cobr.vorig "|" Y01_cobr.vdesc "|"
                    Y01_cobr.vliq "|" skip.
        put "Y07|" Y01_cobr.ndup "|" Y01_cobr.dvenc "|" Y01_cobr.vdup "|" skip.
        end.
        
        for each Z01_infadic of A01_nfe no-lock:
        if Z01_infadic.obscont <> ""
        then put "Z||" Z01_infadic.obscont "|" skip
        put "Z04|" Z01_infadic.xcampo "|" Z01_infadic.xtexto "|" skip.
        end.
        Implementar ******/

        if avail cpforne and cpforne.char-2 <> ""
        then do:
            find Z01_infadic of A01_infnfe where
                    Z01_infadic.xcampo = "EMAIL" no-error.
            if not avail Z01_infadic
            then create Z01_infadic.
            Z01_infadic.chave = A01_infnfe.chave.
            Z01_infadic.xcampo = "EMAIL".
            Z01_infadic.xtexto = cpforne.char-2.
        end. 
    end.
end.    

find first tt-plani where
           tt-plani.placod = A01_infnfe.placod and
           tt-plani.etbcod = A01_infnfe.etbcod
           no-lock no-error.
if avail tt-plani
then do:
    find first placon where placon.etbcod = tt-plani.etbcod and
                      placon.placod = tt-plani.placod
                      no-lock no-error.
    if not avail placon
    then do :
        create placon.
        buffer-copy tt-plani to placon.

        for each tt-movim where tt-movim.procod > 0:
            create movcon.
            buffer-copy tt-movim to movcon.
        end.
    end.
end. 

