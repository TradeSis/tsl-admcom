
def shared var v-justif-est as char.

def shared temp-table tt-nfref
     field chave-nfe as char.
     
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.

def buffer etb-emite for estab.
def buffer etb-desti for estab.
def buffer mun-emite for munic.
def buffer mun-desti for munic.
find first tt-plani no-lock no-error.

def output parameter v-ok as log.
def output parameter v-rec-nota as recid.

v-ok = no.

def var serie-nfe  as char.
def var versao-nfe as char.
def var nfe-emite  like plani.emite.

if /*tt-plani.emite = 998 or 
   tt-plani.emite = 996 or*/ 
   tt-plani.emite = 930
then nfe-emite = 900.
else nfe-emite = tt-plani.emite.

run le_tabini.p (nfe-emite, 0, "NFE - SERIE", OUTPUT serie-nfe).
run le_tabini.p (0, 0, "NFE - Versao", OUTPUT versao-nfe).

find first tt-plani.
tt-plani.serie = serie-nfe.

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

natureza-operacao = "999-Estorno de NF-e nao cancelada no prazo legal".

def var chave-nfe as char.
def var vemitecgc as char.
def var vdesticgc as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char format "x(30)" .

do:
    DO:
        find etb-emite where etb-emite.etbcod = tt-plani.emite no-lock.
        find mun-emite where mun-emite.cidnom = etb-emite.munic and
                             mun-emite.ufecod = etb-emite.ufecod no-lock.
        find etb-desti where etb-desti.etbcod = tt-plani.desti no-lock.
        /*find cpforne where cpforne.forcod = etb-desti.forcod no-lock no-error.
        */
        find mun-desti where mun-desti.cidnom = etb-desti.munic and
                             mun-desti.ufecod = etb-desti.ufecod no-lock.

        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-emite.etbcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
      
        then cep-emite = int(tabaux.valor_campo).
        else cep-emite = 0.
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-emite.etbcod,"999") and
             tabaux.nome_campo = "BAIRRO" no-lock no-error.
        if avail tabaux
        then bairro-emite = tabaux.valor_campo.
        else bairro-emite = "".
        
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-desti.etbcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then cep-desti = int(tabaux.valor_campo).
        else cep-desti = 0.
        /*
        cep-desti = int(etb-desti.cep). 
        */
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
        
        if nfe-emite = 22
        then do:
            find last A01_infnfe where   A01_infnfe.emite = nfe-emite and
                            A01_infnfe.serie = "55" 
                            exclusive no-error.
        end.
        else do:
            find last A01_infnfe where   A01_infnfe.emite = nfe-emite and
                            A01_infnfe.serie = tt-plani.serie
                            exclusive no-error.
        end.
                                    
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
                         serie-nfe +
                         string(tt-plani.numero,"999999999").
 
        find A01_infnfe where   A01_infnfe.emite = nfe-emite and
                        A01_infnfe.serie = tt-plani.serie and
                        A01_infnfe.numero = tt-plani.numero
                        exclusive no-wait no-error.
                        
        if not avail A01_infnfe
        then do:
            if locked A01_infnfe
            then do:
                message "NFE esta sendo usada por outro processo."
                view-as alert-box.
                v-ok = no.
            end.
            else do:
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
                    v-ok = yes
                    v-rec-nota = recid(A01_infnfe).
            end.
        end.
        else assign v-ok = yes
                    v-rec-nota = recid(A01_infnfe).
        
        if v-ok = no
        then return.

        find opcom where opcom.opccod = string(tt-plani.opccod) no-lock.
        
        find B01_IdeNFe of A01_infnfe exclusive no-wait no-error.
        if not avail  B01_IdeNFe
        then do:
            if locked B01_IdeNFe
            then do:
                message color red/with
                    "NFE esta sendo usada por outro processo."
                view-as alert-box.
                v-ok = no.
            end.
            else do:
                create B01_IdeNFe.
                assign
                    B01_IdeNFe.chave   = chave-nfe 
                    B01_IdeNFe.cuf     = int(ibge-uf-emite)
                    B01_IdeNFe.cnf     = dec(
                (int(modelo-documento) * 1000000) + tt-plani.numero  )
                    B01_IdeNFe.natop   = natureza-operacao
                    B01_IdeNFe.indpag  = 0
                    B01_IdeNFe.mod     = modelo-documento
                    B01_IdeNFe.serie   = int(serie-nfe)
                    B01_IdeNFe.nNF     = tt-plani.numero
                    B01_IdeNFe.demi    = tt-plani.pladat
                    B01_IdeNFe.hemi    = tt-plani.horincl
                    B01_IdeNFe.dsaient = ?
                    B01_IdeNFe.tpnf    = 0
                    B01_IdeNFe.cMunFG  = mun-emite.cidcod
                    B01_IdeNFe.tpimp   =  "1"
                    B01_IdeNFe.tpemis  = 1
                    B01_IdeNFe.cdv     = 0
                    B01_IdeNFe.idamb   = 2
                    B01_IdeNFe.finnfe  = 3
                    B01_IdeNFe.procemi = 0
                    B01_IdeNFe.verproc = "1.4.1"
                    B01_IdeNFe.TDesti = v-justif-est 
                    v-ok = yes.
            end.
        end.
        else v-ok = yes.
        
        if v-ok = no
        then return.

        for each tt-nfref no-lock:
            find B12_NFref of A01_infnfe where
                    B12_NFref.refnfe = tt-nfref.chave-nfe
                    no-lock no-error.
            if not avail B12_NFref
            then do:
                create B12_NFref.
                assign 
                    B12_NFref.chave  = A01_infnfe.chave
                    B12_NFref.refnfe = tt-nfref.chave-nfe.
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
                /*C01_Emit.iest  = ""
                C01_Emit.im    = ""
                C01_Emit.cnae  = 0 */
                C01_Emit.cnpj  = vemitecgc
                /*C01_Emit.cpf = ""*/   
                C01_Emit.xlgr  = entry(1,etb-emite.endereco,",")
                C01_Emit.nro   = entry(2,etb-emite.endereco,",")
                /*C01_Emit.xcpl  = entry(3,etb-emite.endereco,",")
                */
                C01_Emit.xbairro = bairro-emite 
                C01_Emit.cmun = mun-emite.cidcod
                C01_Emit.xmun = mun-emite.cidnom
                C01_Emit.uf   = mun-emite.ufecod
                C01_Emit.cep  = cep-emite
                /*C01_Emit.cpais 
                C01_Emit.xpais   */
                C01_Emit.fone = dec(etb-emite.etbserie).
        end.           

        find E01_Dest of A01_infnfe no-lock no-error.
        if not avail E01_Dest
        then do:
            create E01_Dest.
            assign
                E01_Dest.chave = A01_infnfe.chave
                E01_Dest.xnome = etb-desti.etbnom
                E01_Dest.ie    = vdestiie
                E01_Dest.cnpj  = vdesticgc
                E01_Dest.xlgr  = entry(1,etb-desti.endereco,",")
                E01_Dest.nro   = entry(2,etb-desti.endereco,",")
                E01_Dest.xbairro = bairro-emite 
                E01_Dest.cmun = mun-desti.cidcod
                E01_Dest.xmun = mun-desti.cidnom
                E01_Dest.uf   = mun-desti.ufecod
                E01_Dest.cep  = cep-desti
                E01_Dest.fone = dec(etb-emite.etbserie).
        end.   

        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                tt-movim.placod = tt-plani.placod and
                                tt-movim.movtdc = tt-plani.movtdc and
                                tt-movim.movdat = tt-plani.pladat.
                             
            find produ where produ.procod = tt-movim.procod no-lock.
            
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
                    I01_Prod.cfop  = tt-plani.opccod
                    I01_Prod.ucom  = produ.prounven
                    I01_Prod.qcom  = tt-movim.movqtm
                    I01_Prod.vuncom = tt-movim.movpc
                    I01_Prod.vprod =  tt-movim.movpc * tt-movim.movqtm
                    I01_Prod.utrib = produ.prounven
                    I01_Prod.qtrib = tt-movim.movqtm
                    I01_Prod.vuntrib = tt-movim.movpc
                    I01_Prod.voutro = tt-movim.movipi
                    I01_Prod.vfrete = 0
                    I01_Prod.vseg  = 0
                    I01_Prod.vdesc = 0.
                
                /***
                if tt-movim.movipi > 0
                then do:
                    find first impostodevol where
                               impostodevol.chave = A01_infnfe.chave and
                               impostodevol.nitem = tt-movim.movseq
                               no-error.
                    if not avail impostodevol
                    then do:
                        create impostodevol.
                        assign
                            impostodevol.chave = A01_infnfe.chave
                            impostodevol.nitem = tt-movim.movseq
                            impostodevol.pdevol = 100
                            impostodevol.timposto = "IPI"
                            impostodevol.vimposto = tt-movim.movipi
                            impostodevol.emite = A01_infnfe.emite
                            impostodevol.serie = A01_infnfe.serie
                            impostodevol.numero = A01_infnfe.numero
                            .
                                              
                        val-ipi-dev = val-ipi-dev + tt-movim.movipi.
                        
                        tt-movim.movipi = 0.
                    end.
                end.
                ***/
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
                    N01_icms.modbc = 3
                    N01_icms.vbc   = tt-movim.movbicms
                    N01_icms.picms = tt-movim.movalicms
                    N01_icms.vicms = tt-movim.movicms
                    N01_icms.vbcst = tt-movim.movbsubst
                    N01_icms.vicmsst = tt-movim.movsubst.
/***
                    if tt-movim.movsubst > 0
                    then assign
                            N01_icms.vbcst   = tt-plani.bsubst
                            N01_icms.vicmsst = tt-plani.icmssubst.
                assign
                    tt-movim.movbicms = N01_icms.vbc
                    tt-movim.movicms  = N01_icms.vicms
                    tt-movim.movcsticms = string(N01_icms.cst, "99")
                    tt-movim.movsubst = tt-plani.icmssubst.
***/
            end.

            assign
                tt-movim.movcstpiscof = 98.

            find Q01_pis of I01_Prod no-lock no-error.
            if not avail Q01_pis
            then do:
                create Q01_pis.
                assign
                    Q01_pis.chave = I01_Prod.chave
                    Q01_pis.nitem = I01_Prod.nitem
                    Q01_pis.cst   = tt-movim.movcstpiscof.
            end.

            find S01_cofins of I01_Prod no-lock no-error.
            if not avail S01_cofins
            then do:
                create S01_cofins.
                assign
                    S01_cofins.chave = I01_Prod.chave
                    S01_cofins.nitem = I01_Prod.nitem
                    S01_cofins.cst   = tt-movim.movcstpiscof.
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
                W01_total.vbcst = tt-plani.bsubst
                W01_total.vst   = tt-plani.icmssubst
                W01_total.vprod = tt-plani.protot
                /*W01_total.vfrete =
                W01_total.vdesc =
                W01_total.vii = 
                W01_total.vipi = 
                */
                W01_total.voutro = tt-plani.ipi
                W01_total.vnf = tt-plani.platot
                W01_total.vipidevol = 0 /*tt-plani.ipi*/
                .
        end.                

        if v-justif-est <> ""
        then do:            
            find Z01_infadic of A01_infnfe no-error.
            if not avail Z01_infadic
            then do:
                create Z01_infadic.
                Z01_infadic.chave = A01_infnfe.chave.
            end.    
            Z01_infadic.infadfisco = v-justif-est .
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

v-ok = yes.