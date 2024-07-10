def output parameter v-ok as log.
def output parameter vrec-nota as recid.
 
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.
def new shared temp-table tt-nfref like plani.

def buffer etb-emite for estab.
def buffer etb-desti for forne.
def buffer mun-emite for munic.
def buffer mun-desti for munic.
find first tt-plani no-error.

v-ok = no.

def var serie-nfe as char.
run le_tabini.p (tt-plani.etbcod , 0, "NFE - SERIE", OUTPUT serie-nfe).

tt-plani.serie = serie-nfe.
    
def var modelo-documento as char init "55".
def var vobs      as char.
def var vcoo      as int.
def var chave-nfe as char.
def var vemitecgc as char.
def var vdesticgc as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char.

def var A01-rec as recid.

find first tt-plani no-error.

do transaction:
    DO:
        find etb-emite where etb-emite.etbcod = tt-plani.emite no-lock.
        find mun-emite where mun-emite.cidnom = etb-emite.munic and
                             mun-emite.ufecod = etb-emite.ufecod no-lock.
        find etb-desti where etb-desti.forcod = tt-plani.desti no-lock.
        find mun-desti where mun-desti.cidnom = etb-desti.formun and
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
        /*
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-desti.forcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then cep-desti = int(tabaux.valor_campo).
        else cep-desti = 0.
        */
        cep-desti = int(etb-desti.forcep).
         
        def var ibge-uf-emite as char.
        find first tabaux where  tabaux.tabela = "codigo-ibge" and
                        tabaux.nome_campo = etb-emite.ufecod 
                        no-lock no-error.
        if not avail tabaux
        then do:
            message "Codigo do IBGE nao cadastrado para UF " etb-emite.ufecod 
            view-as alert-box.
            v-ok = no.
            return.
        end.  
        ibge-uf-emite = tabaux.valor_campo.

        vemitecgc = etb-emite.etbcgc.
        vemitecgc = replace(vemitecgc,".","").
        vemitecgc = replace(vemitecgc,"/","").
        vemitecgc = replace(vemitecgc,"-","").
        vdesticgc = etb-desti.forcgc.
        vdesticgc = replace(vdesticgc,".","").
        vdesticgc = replace(vdesticgc,"/","").
        vdesticgc = replace(vdesticgc,"-","").
        vemiteie  = etb-emite.etbinsc.
        vemiteie  = replace(vemiteie,"/","").  
        vdestiie  = etb-desti.forinest.
        vdestiie  = replace(vdestiie,"/","").
        
        find last A01_infnfe where   A01_infnfe.emite = tt-plani.emite and
                     A01_infnfe.serie = tt-plani.serie 
                        exclusive-lock no-error.
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

        chave-nfe = "NFe" + ibge-uf-emite + 
                         substr(string(year(tt-plani.pladat),"9999"),3,2) +
                         string(month(tt-plani.pladat),"99") +
                         vemitecgc +
                         modelo-documento +
                         string(int(serie-nfe),"999") +
                         string(tt-plani.numero,"999999999").

        do on error undo:
            create A01_infnfe.
            assign  A01_infnfe.chave  = chave-nfe
                    A01_infnfe.emite  = tt-plani.emite
                    A01_infnfe.serie  = string(tt-plani.serie)
                    A01_infnfe.numero = tt-plani.numero
                    A01_infnfe.etbcod = tt-plani.etbcod
                    A01_infnfe.placod = tt-plani.placod
                    A01_infnfe.versao = 3.1
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Filial"
                    v-ok = yes
                    vrec-nota = (recid(A01_infnfe)).
            a01-rec = recid(A01_infnfe).
        end.
        
        find A01_infnfe where recid(A01_infnfe) = a01-rec no-lock no-error.
        
        find opcom where opcom.opccod = string(tt-plani.opccod) no-lock.

        create B01_IdeNFe.
        assign
            B01_IdeNFe.chave  = chave-nfe 
            B01_IdeNFe.cuf    = int(ibge-uf-emite)
            B01_IdeNFe.cnf    = dec(
                (int(modelo-documento) * 1000000) + tt-plani.numero)
            B01_IdeNFe.natop  = "IMPORTACAO"
            B01_IdeNFe.indpag = 0
            B01_IdeNFe.mod    = modelo-documento
            B01_IdeNFe.serie  = int(serie-nfe)
            B01_IdeNFe.nNF    = tt-plani.numero
            B01_IdeNFe.demi   = tt-plani.pladat
            B01_IdeNFe.hemi   = tt-plani.horincl
            B01_IdeNFe.dsaient = ?
            B01_IdeNFe.tpnf   = 0
            B01_IdeNFe.cMunFG = mun-emite.cidcod
            B01_IdeNFe.tpimp  = "1"
            B01_IdeNFe.tpemis = 1
            B01_IdeNFe.cdv    = 0
            B01_IdeNFe.idamb  = 2
            B01_IdeNFe.finnfe = 1 /* 3.10 */
            B01_IdeNFe.procemi = 0
            B01_IdeNFe.verproc = "1.4.1"
            v-ok = yes.

        /*** NF Referenciada  ***/      

        for each tt-nfref no-lock:
            if tt-nfref.serie = "V"
            then do.
                vcoo = int(entry(2,tt-nfref.notped,"|")) no-error.        
                if vcoo = 0 or vcoo = ?
                then next.
                vobs = vobs + "CF " + string(vcoo) + 
                       " Equip:" + entry(3,tt-nfref.notped,"|") +
                       " de " + string(tt-nfref.pladat) + " ".
            end.
            else do.
                vcoo = tt-nfref.numero.
                vobs = vobs + "NFCe " + string(vcoo) +
                       " Serie:" + tt-nfref.serie +
                       " de " + string(tt-nfref.pladat) + " ".
            end.
            find first B12_NFref of A01_infnfe where B12_NFref.nnf = vcoo
                    no-lock no-error.
            if not avail B12_NFref
            then do:
                create B12_NFref.
                assign 
                    B12_NFref.chave  = A01_infnfe.chave
                    B12_NFref.cuf    = int(ibge-uf-emite)
                    B12_NFref.aamm   = 
                         int(substr(string(tt-nfref.pladat,"99/99/9999"),9,2) +
                             substr(string(tt-nfref.pladat,"99/99/9999"),4,2))
                     B12_NFref.cnpj   = vemitecgc
                     B12_NFref.serie  = 0
                     B12_NFref.nnf    = vcoo.
                if tt-nfref.serie = "V"
                then assign
                        B12_NFref.mod    = "2D".
                else assign
                        B12_NFref.mod    = "65"
                        B12_NFref.refnfe = tt-nfref.notped.

                create docrefer.
                assign
                    docrefer.etbcod     = A01_infnfe.etbcod
                    docrefer.tiporefer  = 14 
                    docrefer.tipmov     = "S"
                    docrefer.serieori   = B12_NFref.mod /*"2D"*/
                    docrefer.codedori   = tt-nfref.desti
                    docrefer.dtemiori   = tt-nfref.pladat
                    docrefer.serecf     = tt-nfref.ufemi
                    docrefer.coo        = vcoo
                    docrefer.numecf     = if tt-nfref.serie = "V"
                                        then int(entry(3,tt-nfref.notped,"|"))
                                        else vcoo
                    docrefer.dtemicupom = tt-nfref.pladat
                    docrefer.tipmovref  = "S"
                    docrefer.tipoemi    = "P"
                    docrefer.codrefer   = string(tt-nfref.emite)
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer = string(B01_IdeNFe.serie)
                    docrefer.numerodr   = A01_infnfe.numero
                    docrefer.datadr     = today.
            end.
        end.

        /*******/
        
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
                /*C01_Emit.xcpl  = entry(3,etb-emite.endereco,",") */
                C01_Emit.xbairro = bairro-emite 
                C01_Emit.cmun = mun-emite.cidcod
                C01_Emit.xmun = mun-emite.cidnom
                C01_Emit.uf   = mun-emite.ufecod
                C01_Emit.cep  = cep-emite
                C01_Emit.fone = dec(etb-emite.etbserie).
        end.           

        def var vforfone as char.
        vforfone = etb-desti.forfone.
        vforfone = replace(vforfone," ","").
        vforfone = replace(vforfone,"(","").
        vforfone = replace(vforfone,")","").
        vforfone = replace(vforfone,"-","").

        find E01_Dest of A01_infnfe no-lock no-error.
        if not avail E01_Dest
        then do:
            find first cpforne where
                       cpforne.forcod = etb-desti.forcod
                       no-lock no-error.
            find first pais where pais.paisnom = etb-desti.forpais
                            no-lock no-error.
                    
            create E01_Dest.
            assign
                E01_Dest.chave = A01_infnfe.chave
                E01_Dest.xnome = etb-desti.fornom
                E01_Dest.indIEDest = 9
                E01_Dest.ie =    vdestiie
                /*E01_Dest.isuf 
                E01_Dest.email*/ 
                E01_Dest.cnpj  = vdesticgc
                /*E01_Dest.cpf   = */
                E01_Dest.xlgr  = etb-desti.forrua
                E01_Dest.nro   = string(etb-desti.fornum)
                /*E01_Dest.xcpl  = etb-desti.forcomp */
                E01_Dest.xbairro = etb-desti.forbairro 
                E01_Dest.cmun = 9999999
                      /*if avail cpforne then cpforne.int-1
                                else mun-desti.cidcod
                                */
                E01_Dest.xmun = "EXTERIOR"
                E01_Dest.uf   = "EX"
                E01_Dest.cep  = cep-desti
                E01_Dest.cpais = int(pais.pais-sigla) 
                E01_Dest.xpais = etb-desti.forpais
                E01_Dest.fone  = dec(vforfone).
            /*if avail cpforne
            then E01_Dest.email = cpforne.char-2. 
            */
            find first forneaux where
                       forneaux.forcod     = etb-desti.forcod and
                       forneaux.nome_campo = "IdEstangeiro"
                       no-lock no-error.
            if avail forneaux
            then E01_Dest.idEstrangeiro = forneaux.valor_campo.
        end.   
        def var vt as dec.
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                tt-movim.placod = tt-plani.placod and
                                tt-movim.movtdc = tt-plani.movtdc.
                             
            find produ where produ.procod = tt-movim.procod no-lock.
            find first tbimport where
                      tbimport.numeropi = tt-movim.numprocimp and
                      tbimport.procod   = tt-movim.procod and
                      tbimport.movseq   = tt-movim.movseq
                      no-lock no-error.
            find first tpimport where 
                        tpimport.numeropi = tbimport.numeropi and
                                tpimport.nrdi     = tbimport.nrdi
                                no-lock no-error.
            find I01_Prod of A01_infnfe where I01_Prod.nitem = tt-movim.movseq
                no-error.
            if not avail I01_Prod
            then do:
                create I01_Prod.
                assign
                    I01_Prod.chave = A01_infnfe.chave
                    I01_Prod.nitem = tt-movim.movseq
                    I01_Prod.cprod = string(tt-movim.procod)
                    I01_Prod.xprod = produ.pronom
                    I01_Prod.ncm   = string(produ.codfis)
                    I01_Prod.cfop  = if tt-movim.opfcod > 0
                                     then tt-movim.opfcod else tt-plani.opccod
                    I01_Prod.ucom = tbimport.unidade
                    I01_Prod.qcom = tt-movim.qcom
                    I01_Prod.vuncom = tt-movim.vuncom
                    I01_Prod.vprod = tt-movim.vuncom * tt-movim.qcom
                    I01_Prod.utrib = tbimport.unidade
                    I01_Prod.qtrib = tt-movim.qcom
                    I01_Prod.vuntrib = tt-movim.vuncom
                    I01_Prod.voutro = tt-movim.movacfin
                    I01_Prod.movpc = tt-movim.vuncom
                    .
                    vt = vt + I01_Prod.vprod.

            end.                            
            if mun-desti.ufecod = "EX"
            then do:
            find I18_DI of I01_Prod no-lock no-error.
            if not avail I18_DI
            then do:
                create I18_DI.
                assign
                    I18_DI.nDI         = tbimport.nrdi
                    I18_DI.xLocDesemb  = if avail tpimport
                                then tpimport.localdesemb else "" 
                    I18_DI.UFDesemb    = if avail tpimport
                                then tpimport.ufdesemb else ""
                    I18_DI.dDesemb     = tbimport.datadi
                    I18_DI.cExportador = string(etb-desti.forcod)
                    I18_DI.chave       = A01_infnfe.chave
                    I18_DI.ddi         = tbimport.datadi
                    I18_DI.nItem       = tbimport.movseq
                    I18_DI.tpViaTransp = "4"
                    I18_DI.tpIntermedio = "1"
                    .
            end.
            find I25_ADI of I01_Prod no-lock no-error.  
            if not avail I25_ADI
            then do:
                create I25_ADI.
                assign
                    I25_ADI.nAdicao      = int(tbimport.adicao)
                    I25_ADI.nSeqAdic     = tbimport.seqitemdi
                    I25_ADI.cFabricante  = string(etb-desti.forcod)
                    I25_ADI.VldescDI     = 0
                    I25_ADI.chave        = A01_infnfe.chave
                    I25_ADI.nDI          = tbimport.nrdi
                    I25_ADI.nItem        = tbimport.movseq
                    .
            end.                       
            end.
            find N01_icms of I01_Prod no-lock no-error.
            if not avail N01_icms
            then do:
                create N01_icms.
                assign
                    N01_icms.chave = I01_Prod.chave
                    N01_icms.nitem = I01_Prod.nitem
                    N01_icms.orig  = produ.codori
                    N01_icms.cst   = int(tt-movim.movcsticms)
                    N01_icms.modbc = 1
                    N01_icms.vbc   = tt-movim.movbicms
                    N01_icms.picms = tt-movim.movalicms
                    N01_icms.vicms = tt-movim.movicms.
            end.
            
            find P01_II of I01_Prod no-lock no-error.
            if not avail P01_II
            then do:
                create P01_II.
                assign
                    P01_II.chave = I01_Prod.chave
                    P01_II.nitem = I01_Prod.nitem
                    P01_II.vbc   = tt-movim.movbii
                    P01_II.vDespAdu = 0
                    P01_II.vII = tt-movim.movii
                    P01_II.vIOF = 0
                    .
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
                    .
                if tt-movim.movipi > 0
                then assign    
                    O01_ipi.cst = 00
                    O01_ipi.vipi = tt-movim.movipi 
                    O01_ipi.vbc  = tt-movim.movbipi
                    O01_ipi.pipi = tt-movim.movalipi
                    .
                else assign
                    O01_ipi.cst  = 99
                    O01_ipi.vipi = 0
                    O01_ipi.vbc  = 0
                    O01_ipi.pipi = 0
                    .
            end. 
            
            find Q01_pis of I01_Prod no-lock no-error.
            if not avail Q01_pis
            then do:
                create Q01_pis.
                assign
                    Q01_pis.chave = I01_Prod.chave
                    Q01_pis.nitem = I01_Prod.nitem
                    Q01_pis.cst   = tt-movim.movcstpiscof
                    Q01_pis.vbc   = tt-movim.movbpiscof
                    Q01_pis.ppis  = tt-movim.movalpis
                    Q01_pis.vpis  = tt-movim.movpis.
            end.
 
            find S01_cofins of I01_Prod no-lock no-error.
            if not avail S01_cofins
            then do:                                             
                create S01_cofins.
                assign
                    S01_cofins.chave   = I01_Prod.chave
                    S01_cofins.nitem   = I01_Prod.nitem
                    S01_cofins.cst     = tt-movim.movcstpiscof
                    S01_cofins.vbc     = tt-movim.movbpiscof
                    S01_cofins.pcofins = tt-movim.movalcofins
                    S01_cofins.vcofins = tt-movim.movcofins.
            end.
        end.

        /**** Totais da nfe ****/
        
        find W01_total of A01_infnfe no-lock no-error.
        if not avail W01_total
        then do:
            create W01_total.
            assign
                W01_total.chave = A01_infnfe.chave 
                W01_total.vbc   = tt-plani.bicms
                W01_total.vicms = tt-plani.icms
                W01_total.vprod = tt-plani.protot
                W01_total.vpis  = tt-plani.notpis
                W01_total.vcofins = tt-plani.notcofins
                W01_total.vnf   = tt-plani.platot
                W01_total.vii   = tt-plani.ii
                W01_total.voutro = tt-plani.desacess
                .
        end.
        vobs = tt-plani.notobs[1] +
               tt-plani.notobs[2] +
               tt-plani.notobs[3].
        if vobs <> ""
        then do.
            find last Z01_infadic of A01_infnfe no-error.
            if not avail Z01_infadic
            then do.
                create Z01_infadic.
                assign Z01_infadic.chave = A01_infnfe.chave.
            end.
            Z01_InfAdic.infCpl =  vobs.
        end.    
    end.
end.

find first A01_infnfe where recid(A01_infnfe) = a01-rec no-lock.
 
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
    then do transaction:
        create placon.
        buffer-copy tt-plani to placon no-error.

        find first tbimport where
                   tbimport.numeropi = tt-plani.numprocimp 
                   no-lock no-error.
        if avail tbimport
        then do on error undo:
            find first tpimport where 
                       tpimport.numeropi = tbimport.numeropi and
                       tpimport.nrdi     = tbimport.nrdi
                       exclusive no-error.
            if avail tpimport
            then assign
                    tpimport.numnfe = tt-plani.numero
                    tpimport.sernfe = tt-plani.serie
                    tpimport.eminfe = tt-plani.emite
                    tpimport.remnfe = tt-plani.desti.
        end.                        
        for each tt-movim where tt-movim.procod > 0:
            create movcon.
            buffer-copy tt-movim to movcon no-error.
        end.
    end.
end. 

for each tt-nfref.
    create ctdevven.
    assign
        ctdevven.movtdc  = 12
        ctdevven.etbcod  = A01_infnfe.etbcod
        ctdevven.placod  = A01_infnfe.placod
        ctdevven.emite   = A01_infnfe.etbcod
        ctdevven.serie   = A01_infnfe.serie
        ctdevven.numero  = A01_infnfe.numero
        ctdevven.pladat  = B01_IdeNFe.demi
        ctdevven.movtdc-ori = tt-nfref.movtdc
        ctdevven.etbcod-ori = tt-nfref.etbcod
        ctdevven.placod-ori = tt-nfref.placod
        ctdevven.emite-ori  = tt-nfref.emite
        ctdevven.serie-ori  = tt-nfref.serie
        ctdevven.numero-ori = tt-nfref.numero
        ctdevven.pladat-ori = tt-nfref.pladat.
    
    tt-nfref.notobs[1] = "MOVTDC=12" + 
                         "|ETBCOD=" + STRING(A01_infnfe.etbcod) +
                         "|PLACOD=" + STRING(A01_infnfe.placod) +
                         "|EMITE=" + STRING(A01_infnfe.etbcod) +
                         "|SERIE=" + A01_infnfe.serie +
                         "|NUMERO=" + STRING(A01_infnfe.numero) +
                         "|PLADAT=" + STRING(B01_IdeNFe.demi) +
                         "|". 
    for each tt-movim where tt-movim.procod > 0:
        run dev-movim.
    end.    
end.

procedure dev-movim:
    def var vok as log.
    def var vrecid as recid.
    def var vmovseq like devmovim.movseq.
    
    vok = no.

    for each devmovim where devmovim.etbcod = ctdevven.etbcod and
                            devmovim.placod = ctdevven.placod and
                            devmovim.procod = tt-movim.procod and
                            devmovim.movtdc = ctdevven.movtdc
                            no-lock:
        if devmovim.notori = ctdevven.numero-ori
        then do:
            vok = yes. 
            vrecid = recid(devmovim).
        end.    
    end.    
    if vok = no
    then do:
        find last devmovim where devmovim.etbcod = ctdevven.etbcod and
                                 devmovim.placod = ctdevven.placod and
                                 devmovim.movtdc = ctdevven.movtdc
                                  no-lock no-error.
        if avail devmovim
        then vmovseq = devmovim.movseq + 1.
        else vmovseq = 1.
        create devmovim.
        assign devmovim.etbcod = ctdevven.etbcod 
               devmovim.placod = ctdevven.placod
               devmovim.procod = tt-movim.procod
               devmovim.movseq = vmovseq
               devmovim.movtdc = tt-movim.movtdc
               devmovim.movdat = ctdevven.pladat
               devmovim.movqtm = tt-movim.movqtm
               devmovim.movpc  = tt-movim.movpc
               devmovim.emite  = ctdevven.etbcod-ori
               devmovim.notori = ctdevven.numero-ori
               devmovim.ocnum[7] = tt-nfref.emite
               devmovim.desti  = tt-nfref.emite.
    end.
    else do:
        find devmovim where recid(devmovim) = vrecid.
        devmovim.movqtm = devmovim.movqtm + movim.movqtm.
    end.
    find first devmovim where devmovim.etbcod = ctdevven.etbcod and
                              devmovim.placod = ctdevven.placod
                              no-lock no-error.
end procedure.

