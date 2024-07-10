
def buffer bA01_infnfe for A01_infnfe.

def var nfe-emite like plani.emite.
 
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.
def shared temp-table tt-nfref like plani.
def shared temp-table tt-nfref1 like plani.
def shared temp-table tt-nfref2 like plani.

def buffer etb-emite for estab.
def buffer etb-desti for estab.
def buffer mun-emite for munic.
def buffer mun-desti for munic.

find first tt-plani no-error.
find tipmov where tipmov.movtdc = tt-plani.movtdc no-lock.

def output parameter v-ok as log.
def output parameter v-rec-nota as recid.

v-ok = no.

def var serie-nfe  as char.
def var versao-nfe as char.

if tt-plani.emite = 998 then nfe-emite = 993.
    else if tt-plani.emite = 930 then nfe-emite = 900.
        else nfe-emite = tt-plani.emite.

run le_tabini.p (nfe-emite, 0, "NFE - SERIE", OUTPUT serie-nfe).
run le_tabini.p (0, 0, "NFE - Versao", OUTPUT versao-nfe).

find first tt-plani.
    
def var modelo-documento as char init "55".
def var chave-nfe as char.
def var vemitecgc as char.
def var vdesticgc as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char.

def buffer e-forne for forne.
def var e-cnpj as char.

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
        find last A01_infnfe where   A01_infnfe.emite = nfe-emite and
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
                    A01_infnfe.emite = nfe-emite
                    A01_infnfe.serie = string(tt-plani.serie)
                    A01_infnfe.numero = tt-plani.numero
                    A01_infnfe.etbcod = tt-plani.etbcod
                    A01_infnfe.placod = tt-plani.placod
                    A01_infnfe.versao = dec(versao-nfe)
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Filial"
                    v-ok = yes
                    v-rec-nota = recid(A01_infnfe).

        find opcom where opcom.opccod = string(tt-plani.opccod) no-lock.
        
        create B01_IdeNFe.
        assign
                    B01_IdeNFe.chave = chave-nfe 
                    B01_IdeNFe.cuf    = int(ibge-uf-emite)
                    B01_IdeNFe.cnf   = dec(
                (int(modelo-documento) * 1000000) + tt-plani.numero  )
                    B01_IdeNFe.natop  = opcom.opcnom
                    B01_IdeNFe.indpag = 0
                    B01_IdeNFe.mod   = modelo-documento
                    B01_IdeNFe.serie  = int(serie-nfe)
                    B01_IdeNFe.nNF = tt-plani.numero
                    B01_IdeNFe.demi = tt-plani.pladat
                    B01_IdeNFe.hemi   = tt-plani.horincl
                    B01_IdeNFe.dsaient = ?
                    B01_IdeNFe.tpnf = 0
                    B01_IdeNFe.cMunFG = mun-emite.cidcod
                    B01_IdeNFe.tpimp =  "1"
                    B01_IdeNFe.tpemis = 1
                    B01_IdeNFe.cdv = 0
                    B01_IdeNFe.idamb = 2
                    B01_IdeNFe.finnfe = 1
                    B01_IdeNFe.procemi = 0
                    B01_IdeNFe.verproc = "1.4.1"
                    v-ok = yes.

        for each tt-nfref no-lock:
            find first bA01_infnfe  where
                bA01_infnfe.emite = tt-nfref.emite and
                bA01_infnfe.serie = tt-nfref.serie and
                bA01_infnfe.numero = tt-nfref.numero
                no-lock no-error.
            if avail bA01_infnfe
            then do:
            find first B12_NFref of A01_infnfe where
                    ( if avail bA01_infnfe
                        then B12_NFref.refnfe = bA01_infnfe.id
                        else B12_NFref.nnf = tt-nfref.numero)
                        no-lock no-error.

            if not avail B12_NFref
            then do:
                find first e-forne where 
                     e-forne.forcod = tt-nfref.emite no-lock no-error.
                if avail e-forne
                then do:
                    e-cnpj = e-forne.forcgc.     
                    e-cnpj = replace(e-cnpj,".","").
                    e-cnpj = replace(e-cnpj,"/","").
                    e-cnpj = replace(e-cnpj,"-","").
                end.
                create B12_NFref.
                assign
                    B12_NFref.chave = A01_infnfe.chave
                    B12_NFref.refnfe = bA01_infnfe.id
                    B12_NFref.cuf    = int(ibge-uf-emite)
                    B12_NFref.aamm   =
                        int(substr(string(tt-nfref.pladat,"99/99/9999"),9,2) +
                        substr(string(tt-nfref.pladat,"99/99/9999"),4,2))
                    B12_NFref.cnpj   = e-cnpj
                    B12_NFref.mod    = "01"
                    B12_NFref.serie  = 0
                    B12_NFref.nnf    = tt-nfref.numero
                    .
                create docrefer.
                assign
                    docrefer.etbcod = A01_infnfe.etbcod
                    docrefer.tiporefer = 13
                    docrefer.tipmov = "E"
                    docrefer.numori = tt-nfref.numero
                    docrefer.serieori = ""
                    docrefer.codedori = tt-nfref.desti
                    docrefer.dtemiori = tt-nfref.pladat
                    docrefer.serecf = e-forne.ufecod
                    /*docrefer.numecf = int(entry(3,tt-nfref.notped,"|"))
                    docrefer.dtemicupom = tt-nfref.pladat*/
                    docrefer.tipmovref = "S"
                    docrefer.tipoemi = "P"
                    docrefer.codrefer = string(tt-nfref.emite)
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer = string(B01_IdeNFe.serie)
                    docrefer.numerodr = A01_infnfe.numero
                    docrefer.datadr = today.
            end.
            end.
            else do:
            find first B12_NFref of A01_infnfe where
                    ( if length(tt-nfref.ufdes) = 44
                        then B12_NFref.refnfe = tt-nfref.ufdes
                        else B12_NFref.nnf = tt-nfref.numero)
                        no-lock no-error.
            if not avail B12_NFref
            then do:
                find first e-forne where 
                     e-forne.forcod = tt-nfref.emite no-lock no-error.
                if avail e-forne
                then do:
                    e-cnpj = e-forne.forcgc.     
                    e-cnpj = replace(e-cnpj,".","").
                    e-cnpj = replace(e-cnpj,"/","").
                    e-cnpj = replace(e-cnpj,"-","").
                end.

                create B12_NFref.
                assign
                    B12_NFref.chave = A01_infnfe.chave
                    B12_NFref.refnfe = tt-nfref.ufdes
                    B12_NFref.cuf    = int(ibge-uf-emite)
                    B12_NFref.aamm   =
                        int(substr(string(tt-nfref.pladat,"99/99/9999"),9,2) +
                        substr(string(tt-nfref.pladat,"99/99/9999"),4,2))
                    B12_NFref.cnpj   = e-cnpj
                    B12_NFref.mod    = "01"
                    B12_NFref.serie  = 0
                    B12_NFref.nnf    = tt-nfref.numero.

                create docrefer.
                assign
                    docrefer.etbcod    = A01_infnfe.etbcod
                    docrefer.tiporefer = 13
                    docrefer.tipmov    = "E"
                    docrefer.tipoemi   = "P"
                    docrefer.tipmovref = "S"
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer  = string(B01_IdeNFe.serie)
                    docrefer.numerodr  = A01_infnfe.numero

                    docrefer.codrefer = string(tt-nfref.emite)
                    docrefer.numori   = tt-nfref.numero
                    docrefer.serieori = tt-nfref.serie
                    docrefer.codedori = tt-nfref.desti
                    docrefer.dtemiori = tt-nfref.pladat
                    docrefer.serecf   = e-forne.ufecod
                    /*docrefer.numecf = int(entry(3,tt-nfref.notped,"|"))
                    docrefer.dtemicupom = tt-nfref.pladat*/
                    docrefer.datadr   = today.
            end.

            end.

        end.
        
        find C01_Emit of A01_infnfe no-lock no-error.
        if not avail C01_Emit
        then do:
            create C01_Emit.
            assign
                C01_Emit.chave = A01_infnfe.chave
                C01_Emit.xnome = etb-emite.etbnom
                C01_Emit.xfant = etb-emite.etbnom
                C01_Emit.ie    = vemiteie
                C01_Emit.cnpj  = vemitecgc
                C01_Emit.xlgr  = entry(1,etb-emite.endereco,",")
                C01_Emit.nro   = entry(2,etb-emite.endereco,",")
                C01_Emit.xbairro = bairro-emite 
                C01_Emit.cmun = mun-emite.cidcod
                C01_Emit.xmun = mun-emite.cidnom
                C01_Emit.uf   = mun-emite.ufecod
                C01_Emit.cep  = cep-emite
                C01_Emit.fone = dec(etb-emite.etbserie).
        end.           

        find E01_Dest of A01_infnfe no-lock no-error.
        if not avail E01_Dest
        then do:
            create E01_Dest.
            assign
                E01_Dest.chave = A01_infnfe.chave
                E01_Dest.xnome = etb-desti.etbnom
                E01_Dest.ie =    vdestiie
                E01_Dest.cnpj  = vdesticgc
                E01_Dest.xlgr  = entry(1,etb-emite.endereco,",")
                E01_Dest.nro   = entry(2,etb-emite.endereco,",")
                E01_Dest.xbairro = bairro-emite 
                E01_Dest.cmun = mun-desti.cidcod
                E01_Dest.xmun = mun-desti.cidnom
                E01_Dest.uf =   mun-desti.ufecod
                E01_Dest.cep = cep-desti
                E01_Dest.fone  = dec(etb-desti.etbserie).
            if avail cpforne
            then E01_Dest.email = cpforne.char-2. 
        end.   

        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                tt-movim.placod = tt-plani.placod and
                                tt-movim.movtdc = tt-plani.movtdc and
                                tt-movim.movdat = tt-plani.pladat
                          no-lock:
            find produ where produ.procod = tt-movim.procod no-lock.

            find I01_Prod of A01_infnfe
                          where I01_Prod.nitem = tt-movim.movseq
                          no-lock no-error.
            if not avail I01_Prod
            then do:
                create I01_Prod.
                assign
                    I01_Prod.chave = A01_infnfe.chave
                    I01_Prod.nitem = tt-movim.movseq
                    I01_Prod.cprod = string(tt-movim.procod)
                    I01_Prod.xprod = produ.pronom
                    I01_Prod.ncm   = if produ.codfis <> 0
                                     then string(produ.codfis) else "00"
                    I01_Prod.cfop  = tt-plani.opccod
                    I01_Prod.ucom  = produ.prounven
                    I01_Prod.qcom  = tt-movim.movqtm
                    I01_Prod.vuncom = tt-movim.movpc
                    I01_Prod.vprod = tt-movim.movpc * tt-movim.movqtm
                    I01_Prod.utrib = produ.prounven
                    I01_Prod.qtrib = tt-movim.movqtm
                    I01_Prod.vuntrib = tt-movim.movpc
                    I01_Prod.vfrete = 0
                    I01_Prod.vseg  = 0
                    I01_Prod.vdesc = 0.
            end.                            

            find N01_icms of I01_Prod no-lock no-error.
            if not avail N01_icms
            then do:
                    create N01_icms.
                    assign
                        N01_icms.chave = I01_Prod.chave
                        N01_icms.nitem = I01_Prod.nitem
                        N01_icms.orig = 0
                        N01_icms.cst = 90
                        N01_icms.modbc = 3
                        N01_icms.vBCST = tt-plani.bsubst
                        N01_icms.picmsst = 17
                        N01_icms.vICMSST = tt-plani.icmssubst
                        N01_icms.modbcst = 4.
                    
                    if int(tt-movim.movcsticms) > 99
                    then assign
                        N01_icms.orig = int(substr(tt-movim.movcsticms,1,1))
                        N01_icms.cst  = int(substr(tt-movim.movcsticms,2,2))
                        .
                    
                    
            end.                       

            find O01_ipi of I01_Prod no-lock no-error.
            if not avail O01_ipi
            then do:
                create O01_ipi.
                assign 
                    O01_ipi.chave = I01_Prod.chave
                    O01_ipi.nitem = I01_Prod.nitem
                    O01_ipi.cenq  = "999"
                    O01_ipi.cst = 53
                    O01_ipi.vipi = 0.
            end.                    

            find Q01_pis of I01_Prod no-lock no-error.
            if not avail Q01_pis
            then do:
                create Q01_pis.
                assign
                    Q01_pis.chave = I01_Prod.chave
                    Q01_pis.nitem = I01_Prod.nitem
                    Q01_pis.cst = 98.
            end.
 
            find S01_cofins of I01_Prod no-lock no-error.
            if not avail S01_cofins
            then do:                                             
                create S01_cofins.
                assign
                    S01_cofins.chave = I01_Prod.chave
                    S01_cofins.nitem = I01_Prod.nitem
                    S01_cofins.cst = 98.
            end.
        end.            

        /**** Totais da nfe ****/
        find W01_total of A01_infnfe no-lock no-error.
        if not avail W01_total
        then do:
            create W01_total.
            assign
                W01_total.chave = A01_infnfe.chave 
                /*
                W01_total.vbc = tt-plani.bicms
                W01_total.vicms = tt-plani.icms
                */
                W01_total.vbcst = tt-plani.bsubst
                W01_total.vst = tt-plani.icmssubst
                W01_total.vprod = tt-plani.protot
                /*W01_total.vfrete =
                W01_total.vseg  =
                W01_total.vdesc =
                W01_total.vii = 
                W01_total.vipi =
                */
                W01_total.vpis = 0
                W01_total.vcofins = 0
                /*W01_total.voutro = */
                W01_total.vnf = tt-plani.platot.
        end.                

        if tt-plani.notobs[1] <> ""
        then do:
            create Z01_InfAdic.
            assign 
                Z01_infadic.chave  = A01_infnfe.chave
                Z01_InfAdic.infCpl = trim(string(tt-plani.notobs[1])) + " "
                    + trim(string(tt-plani.notobs[2])) + " "
                    + trim(string(tt-plani.notobs[3])) + " ".
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
        create tt-nfref2.
        buffer-copy tt-plani to tt-nfref2.
        
        create placon.
        buffer-copy tt-plani to placon.

        for each tt-movim where tt-movim.procod > 0:
            create movcon.
            buffer-copy tt-movim to movcon.
        end.
    end.
end. 

