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


function numero returns character
    (input par-num as char).

    def var par-ret as char.
    def var j as int.
    def var t as int.
    def var vletra as char.

    if par-num = ?
    then par-num = "".
    t = length(par-num).
    do j = 1 to t:
        vletra = substr(par-num,j,1).
        if vletra = "0" or
           vletra = "1" or
           vletra = "2" or
           vletra = "3" or
           vletra = "4" or
           vletra = "5" or
           vletra = "6" or
           vletra = "7" or
           vletra = "8" or
           vletra = "9"
        then assign par-ret = par-ret + vletra.
    end.
    return par-ret.

end function.


def var vt-frete as dec.
 
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.

def buffer etb-emite for estab.
def buffer cli-desti for clien.
def buffer mun-emite for munic.
def buffer mun-desti for munic.
find first tt-plani no-lock no-error.
find tipmov where tipmov.movtdc = tt-plani.movtdc no-lock.

def input parameter par-rec as recid.
def output parameter v-ok as log.
def output parameter vrec-nota as recid.

v-ok = no.

def var serie-nfe as char.
def var vnumero like plani.numero.
def var vplacod like plani.placod.

run le_tabini.p (tt-plani.etbcod, 0, "NFE - SERIE", OUTPUT serie-nfe).

find first tt-plani.

tt-plani.serie = serie-nfe.
    
def var modelo-documento as char init "55".
def var chave-nfe as char.
def var vemitecgc as char.
def var vdesticgc as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char format "x(30)" .
def var ind-entrega as log init no.
def var ent-endereco as char.
def var ent-numero as char.
def var ent-compl as char.
def var ent-bairro as char.
def var ent-cep as char.
def var ent-cidade as char.
def var ent-ufecod as char.
def var vtotserv   as dec.

find first planiaux where planiaux.etbcod      = tt-plani.etbcod
                      and planiaux.placod      = tt-plani.placod
                      and planiaux.emite       = tt-plani.emite
                      and planiaux.numero      = tt-plani.numero
                      and planiaux.nome_campo  = "ENTREGA"
                          no-lock no-error.
if avail planiaux
then assign
        ent-endereco = acha("endereco"     ,planiaux.valor_campo)
        ent-numero   = acha("numero"       ,planiaux.valor_campo)
        ent-compl    = acha("complemento"  ,planiaux.valor_campo)
        ent-bairro   = acha("bairro"  ,planiaux.valor_campo)
        ent-cep      = acha("cep"          ,planiaux.valor_campo)
        ent-cidade   = acha("cidade"  ,planiaux.valor_campo)
        ent-ufecod   = acha("uf"      ,planiaux.valor_campo)
        ind-entrega = yes.
else ind-entrega = no.

def var ind-transp as log init no.
def var tra-nome as char init "".
def var tra-volume as int init 0.
def var tra-especie as char init "".
def var tra-tipo as int init 1.
def var tra-placa as char init "".
def var tra-uf as char init "".
def var tra-forinest as char.
def var tra-endereco as char.
def var tra-municipio as char.
def var tra-forcgc as char.
def var tra-cpf as char.

find first planiaux where planiaux.etbcod     = tt-plani.etbcod
                      and planiaux.placod     = tt-plani.placod
                      and planiaux.emite      = tt-plani.emite
                      and planiaux.numero     = tt-plani.numero
                      and planiaux.nome_campo = "FRECOD"
                          no-lock no-error.
if avail planiaux 
then do.
    find com.frete where com.frete.frecod = int(planiaux.valor_campo)
                         no-lock no-error.

    if avail com.frete  and com.frete.frecod <> 0
    then assign
            ind-transp = yes
            tra-nome = com.frete.frenom.
    else assign
            ind-transp = no
            tra-nome = "".        
    if avail com.frete
    then do:
        find forne where forne.forcod = frete.forcod no-lock no-error.
        if avail forne
        then assign
                 tra-forinest = forne.forinest
                 tra-endereco = forne.forrua  + " " + string(forne.fornum)
                 tra-municipio = forne.formunic
                 tra-uf = forne.ufecod
                 tra-forcgc    = forne.forcgc
                 tra-cpf       = "".
    end.            
end.
else assign
        ind-transp = no
        tra-nome = "".

find first planiaux where planiaux.etbcod     = tt-plani.etbcod
                      and planiaux.placod     = tt-plani.placod
                      and planiaux.emite      = tt-plani.emite
                      and planiaux.numero     = tt-plani.numero
                      and planiaux.nome_campo = "VOLUMES"
                          no-lock no-error.
if avail planiaux 
then tra-volume = int(planiaux.valor_campo).
else tra-volume = 0.

def temp-table tt-indpag
    field nfat as char
    field vorig as dec
    field vliq  as dec
    field ndup  as char
    field dvenc as date
    field vdup  as dec.

def buffer cplani for plani.

if tt-plani.pedcod <> 0   
then do:
    for each tt-indpag: delete tt-indpag. end.
    
    find first cplani where 
               cplani.etbcod = tt-plani.etbcod and
               cplani.emite  = tt-plani.emite and
               cplani.serie  = "V" and
               cplani.numero = tt-plani.numero
               no-lock no-error.
    if avail cplani
    then do:
        for each contnf where contnf.etbcod = cplani.etbcod and
                              contnf.placod = cplani.placod 
                              no-lock.
            find contrato where contrato.contnum = contnf.contnum 
                    no-lock no-error.
            if not avail contrato then next.

            for each titulo where titulo.clifor = contrato.clicod and
                                  titulo.titnum = string(contrato.contnum) and
                        titulo.titpar > 0
                        no-lock by titpar.
                create tt-indpag.
                assign
                    tt-indpag.nfat  = string(contrato.contnum)
                    tt-indpag.vorig = contrato.vltotal
                    tt-indpag.vliq  = contrato.vltotal
                    tt-indpag.ndup  = titulo.titnum + "-" +
                                      string(titulo.titpar)
                    tt-indpag.dvenc = titulo.titdtven
                    tt-indpag.vdup = titulo.titvlcob.
            end.    
        end.
    end.
end.

find first tt-indpag no-lock no-error.
if not avail tt-indpag
then tt-plani.pedcod = 0. /* Nao enviar crediario */
             
do:
   DO:
       find etb-emite where etb-emite.etbcod = tt-plani.emite no-lock.
       find mun-emite where mun-emite.cidnom = etb-emite.munic and
                            mun-emite.ufecod = etb-emite.ufecod no-lock.

       find cli-desti where cli-desti.clicod = tt-plani.desti no-lock.
       find cpclien where cpclien.clicod = cli-desti.clicod no-lock no-error.
       if ind-entrega
       then find mun-desti where mun-desti.cidnom = ent-cidade and
                             mun-desti.ufecod = ent-ufecod no-lock.
       else find mun-desti where mun-desti.cidnom = cli-desti.cidade[1] and
                             mun-desti.ufecod = cli-desti.ufecod[1] no-lock.

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

        cep-desti = int(numero(cli-desti.cep[1])).
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
        
        vemitecgc = Numero(etb-emite.etbcgc).
        vdesticgc = Numero(cli-desti.ciccgc).
        vemiteie  = Numero(etb-emite.etbinsc).
        vdestiie  = Numero(cli-desti.ciinsc).
              
        run bas/grplanum.p (tt-plani.etbcod, tt-plani.serie,
                            output vplacod, output vnumero).

        assign
            tt-plani.placod = vplacod
            tt-plani.numero = vnumero.
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
 
        find A01_infnfe where   A01_infnfe.emite = tt-plani.emite and
                        A01_infnfe.serie = tt-plani.serie and
                        A01_infnfe.numero = tt-plani.numero
                        exclusive no-wait no-error.                        
        if not avail A01_infnfe
        then do:
            if locked A01_infnfe
            then do:
                message color red/with
                "NFE esta sendo usada por outro processo."
                view-as alert-box.
                v-ok = no.
            end.
            else do:
                create A01_infnfe.
                assign
                    A01_infnfe.chave = chave-nfe
                    A01_infnfe.emite = tt-plani.emite
                    A01_infnfe.serie = string(tt-plani.serie)
                    A01_infnfe.numero = tt-plani.numero
                    A01_infnfe.etbcod = tt-plani.etbcod
                    A01_infnfe.placod = tt-plani.placod
                    A01_infnfe.versao = 3.10
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Cliente"
                    v-ok = yes
                    vrec-nota = recid(A01_infnfe).
            end.
        end.
        else assign v-ok      = yes
                    vrec-nota = recid(A01_infnfe).
        
        if v-ok = no
        then return.
        
        release A01_infnfe.
        
        find first A01_infnfe where recid(A01_infnfe) = vrec-nota
                            no-lock no-error.

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
                    B01_IdeNFe.chave = chave-nfe 
                    B01_IdeNFe.cuf   = int(ibge-uf-emite) 
                    B01_IdeNFe.cnf   = dec(
                        (int(modelo-documento) * 1000000) + tt-plani.numero)
                    B01_IdeNFe.natop  = opcom.opcnom
                    B01_IdeNFe.indpag = if tt-plani.pedcod = 0
                                        then 0 else 1
                    B01_IdeNFe.mod   = modelo-documento
                    B01_IdeNFe.serie = int(serie-nfe)
                    B01_IdeNFe.nNF   = tt-plani.numero
                    B01_IdeNFe.demi  = tt-plani.pladat
                    B01_IdeNFe.hemi  = tt-plani.horincl
                    B01_IdeNFe.dsaient = ?
                    B01_IdeNFe.tpnf  = 1
                    B01_IdeNFe.cMunFG = mun-emite.cidcod
                    B01_IdeNFe.tpimp  = "1"
                    B01_IdeNFe.tpemis = 1
                    B01_IdeNFe.cdv    = 0
                    B01_IdeNFe.idamb  = 2
                    B01_IdeNFe.finnfe = 1
                    B01_IdeNFe.procemi = 0
                    B01_IdeNFe.verproc = "1.4.1"
                    B01_IdeNFe.indFinal = 1
                    v-ok = yes
                    vrec-nota = (recid(A01_infnfe)).
            end.
        end.
        else assign v-ok = yes
                    vrec-nota = (recid(A01_infnfe)).
                    
        if v-ok = no
        then return.
        if num-entries(tt-plani.notped,"|") >= 2
        then do:
            find first B12_NFref where B12_NFref.chave =  A01_infnfe.chave 
                    no-lock no-error.
            if not avail B12_NFref
            then do:
                create B12_NFref.
                assign 
                    B12_NFref.chave = A01_infnfe.chave
                    B12_NFref.refnfe = ""
                    B12_NFref.cuf    = int(ibge-uf-emite)
                    B12_NFref.aamm   = 
                        int(substr(string(tt-plani.pladat,"99/99/9999"),9,2) +
                        substr(string(tt-plani.pladat,"99/99/9999"),4,2))
                    B12_NFref.cnpj   = vemitecgc
                    B12_NFref.mod    = "2D"
                    B12_NFref.serie  = 0
                    B12_NFref.nnf    = int(entry(2,tt-plani.notped,"|")).

                create docrefer.
                assign
                    docrefer.etbcod   = A01_infnfe.etbcod
                    docrefer.tiporefer = 14 
                    docrefer.tipmov   = "S"
                    docrefer.serieori = "2D"
                    docrefer.codedori = tt-plani.desti
                    docrefer.dtemiori = tt-plani.pladat
                    docrefer.serecf   = tt-plani.ufemi
                    docrefer.numecf   = int(entry(3,tt-plani.notped,"|"))
                    docrefer.dtemicupom = tt-plani.pladat
                    docrefer.tipmovref = "S"
                    docrefer.tipoemi = "P"
                    docrefer.codrefer = string(tt-plani.desti)
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer = string(B01_IdeNFe.serie)
                    docrefer.numerodr = A01_infnfe.numero
                    docrefer.datadr = today.
            end.
        end.
        else do:
            find first B12_NFref where B12_NFref.chave =  A01_infnfe.chave
                                no-lock no-error.
            if not avail B12_NFref
            then do:
                create B12_NFref.
                assign
                    B12_NFref.chave  = A01_infnfe.chave
                    B12_NFref.refnfe = tt-plani.ufemi.
                create docrefer.
                assign
                    docrefer.etbcod    = A01_infnfe.etbcod
                    docrefer.tiporefer = 14
                    docrefer.tipmov    = "S"
                    docrefer.serieori  = "65"
                    docrefer.codedori  = tt-plani.desti
                    docrefer.dtemiori  = tt-plani.pladat
                    docrefer.serecf    = tt-plani.ufemi
                    docrefer.numecf    = tt-plani.numero
                    docrefer.dtemicupom  = tt-plani.pladat
                    docrefer.tipmovref = "S"
                    docrefer.tipoemi   = "P"
                    docrefer.codrefer  = string(tt-plani.desti)
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer  = string(B01_IdeNFe.serie)
                    docrefer.numerodr  = A01_infnfe.numero
                    docrefer.datadr    = today.
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
            replace(C01_Emit.xnome,"&","E").
            replace(C01_Emit.xfant,"&","E").
        end.           

        find E01_Dest of A01_infnfe no-lock no-error.
        if not avail E01_Dest
        then do:
            create E01_Dest.
            assign
                E01_Dest.chave = A01_infnfe.chave
                E01_Dest.xnome = cli-desti.clinom
                E01_Dest.ie    = vdestiie
                E01_Dest.xlgr  = if ind-entrega
                                 then ent-endereco else cli-desti.endereco[1]
                E01_Dest.nro   = if ind-entrega
                                 then ent-numero
                                 else string(cli-desti.numero[1])
                E01_Dest.xcpl  = if ind-entrega
                                 then ent-compl else cli-desti.compl[1]
                E01_Dest.xbairro = if ind-entrega
                                 then ent-bairro else cli-desti.bairro[1] 
                E01_Dest.cmun = mun-desti.cidcod
                E01_Dest.xmun = mun-desti.cidnom
                E01_Dest.uf   = mun-desti.ufecod
                E01_Dest.cep  = if ind-entrega
                                then int(ent-cep) else cep-desti
                E01_Dest.fone = dec(cli-desti.fone).
            if cli-desti.tippes
            then assign E01_Dest.cpf = vdesticgc
                        E01_Dest.indiedest = 9.
            else assign E01_Dest.cnpj = vdesticgc.
        end.   
                     
        vt-frete = 0.       
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                         tt-movim.placod = tt-plani.placod and
                                         tt-movim.movtdc = tt-plani.movtdc and
                                         tt-movim.movdat = tt-plani.pladat.
                             
            find produ where produ.procod = tt-movim.procod no-lock.
            if produ.proipiper = 98 /* Servicos */
            then do.
                vtotserv = vtotserv + tt-movim.movpc.
                next.
            end.
            
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
                    I01_Prod.vprod = tt-movim.movpc * tt-movim.movqtm
                    I01_Prod.utrib = produ.prounven
                    I01_Prod.qtrib = tt-movim.movqtm
                    I01_Prod.vuntrib = tt-movim.movpc
                    I01_Prod.vfrete = 0
                    I01_Prod.vseg  = 0
                    I01_Prod.vdesc = 0.
                
                if tt-plani.frete > 0
                then assign
                    vt-frete = vt-frete + (tt-plani.frete *
                        (I01_Prod.vprod / tt-plani.protot))
                    I01_Prod.vfrete = tt-plani.frete *
                        (I01_Prod.vprod / tt-plani.protot).
            end.                            

            find N01_icms of I01_Prod no-lock no-error.
            if not avail N01_icms
            then do:
                create N01_icms.
                assign
                        N01_icms.chave = I01_Prod.chave
                        N01_icms.nitem = I01_Prod.nitem
                        N01_icms.orig  = produ.codori
                        N01_icms.cst   = int(tt-movim.movcsticms).
            end.                       

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
                    
        if tt-plani.frete > 0 and
           tt-plani.frete <> vt-frete
        then do.
            find first I01_Prod of A01_infnfe no-error.
            if tt-plani.frete > vt-frete
            then I01_Prod.vfrete = I01_Prod.vfrete +
                           (tt-plani.frete - vt-frete).
            else if tt-plani.frete < vt-frete
            then I01_Prod.vfrete = I01_Prod.vfrete +
                            (tt-plani.frete - vt-frete).             
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
                W01_total.vprod = tt-plani.protot - vtotserv
                W01_total.vfrete = tt-plani.frete
                W01_total.vpis  = 0
                W01_total.vcofins = 0
                W01_total.vnf   = tt-plani.platot - vtotserv.
        end.

        if ind-transp
        then do:
            find first X01_transp where
                X01_transp.chave = A01_infnfe.chave no-error.
            if not avail X01_transp
            then  create X01_transp.

            assign
                X01_transp.chave = A01_infnfe.chave
                X01_transp.modfrete = tra-tipo
                X01_transp.xnome = tra-nome
                X01_transp.uf = tra-uf
                X01_transp.placa = caps(tra-placa)
                X01_transp.ie = tra-forinest
                X01_transp.xender = tra-endereco
                X01_transp.xmun = tra-municipio
                X01_transp.cnpj = tra-forcgc
                X01_transp.cpf = tra-cpf.

            X01_transp.xnome = replace(X01_transp.xnome,"&","E").
    
            find first X26_vol where
               X26_vol.chave = A01_infnfe.chave and
               X26_vol.cnpj  = X01_transp.cnpj and
               X26_vol.cpf   = X01_transp.cpf and
               X26_vol.esp   = "" and
               X26_vol.marca = "" and
               X26_vol.nvol = 0 
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
                    X26_vol.qvol = 0
                    X26_vol.esp  = "".
            end.
        end.


        find first tt-indpag where tt-indpag.nfat <> "" no-error.
        if avail tt-indpag and
           tt-plani.pedcod > 0
        then do:
            for each tt-indpag where tt-indpag.nfat <> "" no-lock:
                create Y01_cobr.
                assign
                    Y01_cobr.chave = A01_infnfe.chave
                    Y01_cobr.nfat  = tt-indpag.nfat
                    Y01_cobr.vorig = tt-indpag.vorig
                    Y01_cobr.vdesc = 0
                    Y01_cobr.vliq  = tt-indpag.vliq
                    Y01_cobr.ndup  = tt-indpag.ndup
                    Y01_cobr.dvenc = tt-indpag.dvenc
                    Y01_cobr.vdup  = tt-indpag.vdup.
            end.
        end.
        find Z01_InfAdic of A01_infnfe no-lock no-error.
        if not avail Z01_InfAdic
        then do:
            create Z01_InfAdic.
            Z01_InfAdic.chave = A01_infnfe.chave.
            Z01_InfAdic.infCpl = tt-plani.notobs[3].
        end.    
    end.
end.    

find first tt-plani where
           tt-plani.placod = A01_infnfe.placod and
           tt-plani.etbcod = A01_infnfe.etbcod
           no-lock no-error.
if avail tt-plani
then do on error undo:
    find first placon where placon.etbcod = tt-plani.etbcod and
                      placon.placod = tt-plani.placod
                      no-lock no-error.
    if not avail placon
    then do :
        create placon.
        buffer-copy tt-plani to placon.
        placon.crecod = 2.

        if tt-plani.movtdc = 48
        then assign
                placon.ufemi = ""
                placon.ufdes = "".

        for each tt-movim where tt-movim.procod > 0:
            create movcon.
            buffer-copy tt-movim to movcon.
        end.
    end.
end. 

find plani where recid(plani) = par-rec  no-lock.
do on error undo.
    find first planiaux where planiaux.movtdc      = plani.movtdc
                          and planiaux.etbcod      = plani.etbcod
                          and planiaux.emite       = plani.emite
                          and planiaux.placod      = plani.placod
                          and planiaux.emite       = plani.emite
                          and planiaux.serie       = plani.serie
                          and planiaux.numero      = plani.numero
                          and planiaux.nome_campo  = "NOTA-ACOBERTADA"
                           no-error.
    if not avail planiaux
    then do:
        create planiaux.
        assign
            planiaux.movtdc      = plani.movtdc 
            planiaux.etbcod      = plani.etbcod 
            planiaux.placod      = plani.placod 
            planiaux.emite       = plani.emite 
            planiaux.numero      = plani.numero 
            planiaux.serie       = plani.serie 
            planiaux.nome_campo  = "NOTA-ACOBERTADA".
        planiaux.valor_campo = planiaux.valor_campo + 
            "|EMITE=" + string(A01_infnfe.emite) + 
            "|SERIE=" + string(A01_infnfe.serie) +
            "|NUMERO=" + string(A01_infnfe.numero) .
    end.
    else
        planiaux.valor_campo = planiaux.valor_campo + 
            "|EMITE=" + string(A01_infnfe.emite) + 
            "|SERIE=" + string(A01_infnfe.serie) +
            "|NUMERO=" + string(A01_infnfe.numero) .
end.

