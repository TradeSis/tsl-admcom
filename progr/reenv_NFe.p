def input parameter p-recid as recid.

def var p-valor as char.

def var icms_item like movim.movicms.
def var vobs like plani.notobs.
def var itvaloroutroicm like plani.platot.

def var ipi_base  like plani.platot.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var base_icms like plani.platot.
def var vdatexp like plani.datexp.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var varq    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def buffer bmovim for movim.
def var vetb as char. 

def var vemitecgc as char.
def var vdesticgc as char.
def var vdesticpf as char.
def var vemiteie as char.
def var vdestiie as char.
def var cep-emite as int.
def var cep-desti as int.
def var bairro-emite as char format "x(30)" .

def var vdestnom as char.
def var vdestrua as char.
def var vdestnum as char.
def var vdestbai as char.  
def var cdestfone as char.
def var cdestcep as char.
def var vdestfon as dec.
def var vdestmail as char.
def var vdestcep as int.
def var              vrec-nota          as recid.
def var sresp as log.

def buffer etb-emite for estab.
def buffer mun-emite for munic.
def buffer mun-desti for munic.

def new shared temp-table tt-plani    like plani.
def new shared temp-table tt-movim    like movim.
def new shared temp-table tt-nfref1 like plani.
def new shared temp-table tt-nfref2 like plani.

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.
find B01_IdeNFe of A01_infnfe no-lock.
/*
message A01_infnfe.etbcod
        A01_infnfe.emite
        A01_infnfe.serie
        A01_infnfe.numero
. pause.
*/
find first placon where placon.etbcod = A01_infnfe.etbcod and
                  placon.emite  = A01_infnfe.etbcod and
                  placon.serie  = A01_infnfe.serie and
                  placon.numero = A01_infnfe.numero
                  no-lock no-error.
if not avail placon
then find first placon where placon.etbcod = A01_infnfe.etbcod and
                  placon.placod  = A01_infnfe.placod and
                  placon.serie  = A01_infnfe.serie and
                  placon.numero = A01_infnfe.numero
                  no-lock no-error.
if not avail placon
then return.
/*
else do:
    create placon.
    assign
        placon.etbcod = A01_infnfe.etbcod
        placon.emite  = A01_infnfe.emite
        placon.serie  = A01_infnfe.serie
        placon.numero = A01_infnfe.numero
        .
        pause.
end.        
*/

if placon.opccod = 1603
then do.
    create tt-plani.
    buffer-copy placon to tt-plani.

    for each movcon where movcon.etbcod = placon.etbcod and
                          movcon.placod = placon.placod and
                          movcon.movtdc = placon.movtdc and
                          movcon.movdat = placon.pladat
                    no-lock:
        create tt-movim.
        buffer-copy movcon to tt-movim.
    end.

    run nfe_1603.p(output sresp,
                          output vrec-nota) no-error.
end.
    

/***                  
find etb-emite where etb-emite.etbcod = A01_infnfe.emite no-lock.
find mun-emite where mun-emite.cidnom = etb-emite.munic and
                mun-emite.ufecod = etb-emite.ufecod                 no-lock.

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

        def var ibge-uf-emite as char.
        
        find first tabaux where  tabaux.tabela = "codigo-ibge" and
                        tabaux.nome_campo = etb-emite.ufecod 
                        no-lock no-error.
        if avail tabaux
        then ibge-uf-emite = tabaux.valor_campo.

        vemitecgc = etb-emite.etbcgc.
        vemitecgc = replace(vemitecgc,".","").
        vemitecgc = replace(vemitecgc,"/","").
        vemitecgc = replace(vemitecgc,"-","").
        vemiteie  = etb-emite.etbinsc.
        vemiteie  = replace(vemiteie,"/",""). 

def var vtdesti as char extent 3 format "x(15)"
     init["FORNECEDOR","CLIENTE","FILIAL"].
if A01_infnfe.tdesti = ""
then do:
    disp vtdesti with frame f-dd no-label title "Informe o tipo de destino"
    row 10 overlay centered.
    choose field vtdesti with frame f-dd.
    A01_infnfe.tdesti = vtdesti[frame-index].
end.

if A01_infnfe.tdesti = "Filial"
then do:
    def buffer etb-desti for estab.
        find etb-desti where etb-desti.etbcod = placon.desti no-lock.
        find mun-desti where mun-desti.cidnom = etb-desti.munic and
                             mun-desti.ufecod = etb-desti.ufecod no-lock.

        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-desti.etbcod,"999") and
             tabaux.nome_campo = "BAIRRO" no-lock no-error.
        if avail tabaux
        then vdestbai = tabaux.valor_campo.
        else vdestbai = "".
        find tabaux where 
             tabaux.tabela = "ESTAB-" + string(etb-desti.etbcod,"999") and
             tabaux.nome_campo = "CEP" no-lock no-error.
        if avail tabaux
        then vdestcep = int(tabaux.valor_campo).
        else vdestcep = 0.

        vdesticgc = etb-desti.etbcgc.
        vdesticgc = replace(vdesticgc,".","").
        vdesticgc = replace(vdesticgc,"/","").
        vdesticgc = replace(vdesticgc,"-","").
        vdestiie  = etb-desti.etbinsc.
        vdestiie  = replace(vdestiie,"/","").

end.
else if A01_infnfe.tdesti = "Fornecedor"
then do:        
        find forne where forne.forcod = placon.desti no-lock.
        find mun-desti where mun-desti.cidnom = forne.formunic and
                             mun-desti.ufecod = forne.ufecod no-lock.
        find cpforne where cpforne.forcod = forne.forcod
                        no-lock no-error.
        vdesticgc = forne.forcgc.
        vdesticgc = replace(vdesticgc,".","").
        vdesticgc = replace(vdesticgc,"/","").
        vdesticgc = replace(vdesticgc,"-","").
        cdestfone = forne.forfone.
        cdestfone = replace(cdestfone,"-","").
        cdestfone = replace(cdestfone,".","").
        cdestcep  = forne.forcep.
        cdestcep = replace(cdestcep,"-","").
        cdestcep = replace(cdestcep,".","").
        vdestiie  = forne.forinest.
        vdestiie  = replace(vdestiie,"/","").
        vdestnom   = forne.fornom.
        vdestrua   = forne.forrua.
        vdestnum   = string(forne.fornum).
        vdestbai   = forne.forbairro.  
        vdestfon   = dec(cdestfone).
        vdestcep = int(cdestcep) .
        if avail cpforne
        then vdestmail   = cpforne.char-2.
                                        
end.
else if A01_infnfe.tdesti = "Cliente"
then do:        
        find clien where clien.clicod = placon.desti no-lock.
        find mun-desti where mun-desti.cidnom = clien.cidade[1] and
                             mun-desti.ufecod = clien.ufecod[1] no-lock.
        
        vdesticpf = clien.ciccgc.
        vdesticpf = replace(vdesticpf,".","").
        vdesticpf = replace(vdesticpf,"/","").
        vdesticpf = replace(vdesticpf,"-","").
        vdestiie  = "".
        vdestiie  = replace(vdestiie,"/","").
        vdestnom   = clien.clinom.
        vdestrua   = clien.endereco[1].
        vdestnum   = string(clien.numero[1]).
        vdestbai   = clien.bairro[1].  
        vdestfon   = dec(clien.fone).
        vdestcep   = int(clien.cep[1]).
        vdestmail  = "" .                                
end.


    find C01_Emit of A01_infnfe no-error.
    if avail C01_Emit
    then  assign
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

        find E01_Dest of A01_infnfe  no-error.
        if avail E01_Dest
        then assign
                E01_Dest.xnome = vdestnom
                E01_Dest.ie    = vdestiie
                E01_Dest.cnpj  = vdesticgc
                E01_Dest.cpf   = vdesticpf
                E01_Dest.xlgr  = vdestrua
                E01_Dest.nro   = vdestnum
                /*E01_Dest.xcpl  = entry(3,etb-desti.endereco,",")
                */
                E01_Dest.xbairro = vdestbai 
                E01_Dest.cmun  = mun-desti.cidcod
                E01_Dest.xmun  = mun-desti.cidnom
                E01_Dest.uf    = mun-desti.ufecod
                E01_Dest.cep   = vdestcep
                E01_Dest.fone  = vdestfon
                E01_Dest.email = vdestmail.     

    /* 3.10 */
    if trim(E01_Dest.cpf) <> ""
    then assign
            E01_Dest.ie = ""
            E01_Dest.indIEDest = 9. /* Nao Contrib */
    else if E01_Dest.ie = "" or E01_Dest.ie = ? or E01_Dest.ie begins "ISENT"
    then assign
            E01_Dest.ie = ""
            E01_Dest.indIEDest = 2. /* Isento */
    else E01_Dest.indIEDest = 1.            

        if vdestmail <> ""
        then do:
            find Z01_infadic of A01_infnfe where
                    Z01_infadic.xcampo = "EMAIL" no-error.
            if not avail Z01_infadic
            then create Z01_infadic.
            Z01_infadic.chave = A01_infnfe.chave.
            Z01_infadic.xcampo = "EMAIL".
            Z01_infadic.xtexto = vdestmail.
        end. 

        for each I01_Prod of A01_infnfe:
            find produ where produ.procod = int(I01_Prod.cprod)
                no-lock no-error.
            if  avail produ then 
            assign    
                    I01_Prod.xprod = produ.pronom
                    I01_Prod.ncm   = if produ.codfis <> 0
                                     then string(produ.codfis)  else ""
                    I01_Prod.ucom = produ.prounven
                    I01_Prod.utrib = produ.prounven
                    .
            else do:
                find prodnewfree where 
                        prodnewfree.procod = int(I01_Prod.cprod)
                no-lock no-error.
                if avail prodnewfree
                then 
                    assign    
                    I01_Prod.xprod = produ.pronom
                    /*I01_Prod.ncm   = if produ.codfis <> 0
                                     then string(produ.codfis)  else ""
                    I01_Prod.ucom = produ.prounven
                    I01_Prod.utrib = produ.prounven
                    */
                    .
 
            end.
        end. 
    **/



def var vok as log format "Sim/Nao" init no.
message "Confirma Envio ? " update vok.
if vok
then do:
    run manager_nfe.p (input "envio",
                       input recid(A01_infnfe),
                       output vok).
end.
