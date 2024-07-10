def temp-table tt-plani like com.plani.
def temp-table tt-movim like com.movim.

def input parameter vetbcod like estab.etbcod.
def input parameter vnumero like com.plani.numero.
def input parameter vserie like com.plani.serie.

repeat:

find first nfeloja.placon where placon.etbcod = vetbcod and
                        placon.numero = vnumero and
                        placon.serie = vserie
                   no-lock no-error.
if not avail placon then leave.
create tt-plani.
buffer-copy placon to tt-plani.

for each nfeloja.movcon where movcon.etbcod = placon.etbcod and
    movcon.placod = placon.placod and
    movcon.movtdc = placon.movtdc.

disp movcon.procod movcon.movpc * movcon.movqtm movcon.movalicms
    movcon.movicms.
    update movcon.movalicms.
    movcon.movicms = (movcon.movpc * movcon.movqtm) * (movcon.movalicms / 100).

create tt-movim.
buffer-copy movcon to tt-movim.
end.

find first tt-plani.

find first nfeloja.a01_infnfe where
           a01_infnfe.etbcod = tt-plani.etbcod and
           a01_infnfe.numero = tt-plani.numero
            no-error.

disp a01_infnfe.chave label "Chave NFe" with frame f2 1 down side-label overlay.
find nfeloja.B01_IdeNFe of A01_infnfe.
update B01_IdeNFe.tpnf
       B01_IdeNFe.natOp
       B01_IdeNFe.idDest.

def var vt-frete as dec.
vt-frete = 0.       
        
def var ali-item as dec.
def var vbc-item as dec.
def var icm-item as dec.
def var fre-item as dec.
def var vbc-total as dec.
def var icm-total as dec.
def var val-pis as dec.
def var val-cof as dec.

         assign
            vbc-total = 0
            icm-total = 0
            val-pis = 0
            val-cof = 0.
def var vdesc as char format "x(60)" extent 6 label "INfAdProd".
 
def var log-ref as log format "Sim/Nao".
message "Deseja informar referenciada?" update log-ref.
if log-ref
then do:
    find first nfeloja.B12_NFref where 
           B12_NFref.chave =  A01_infnfe.chave 
            no-error.
        if not avail B12_NFref
        then do :
                create B12_NFref.
                assign 
                    B12_NFref.chave = A01_infnfe.chave
                    .
        end.            
                update  
                    B12_NFref.refnfe
                    B12_NFref.cuf    
                    B12_NFref.aamm 
                    B12_NFref.cnpj 
                    B12_NFref.mod 
                    B12_NFref.serie
                    B12_NFref.nnf 
                    .
                
                create nfeloja.docrefer.
                assign
                    docrefer.etbcod = A01_infnfe.etbcod
                    docrefer.tiporefer = 14 
                    docrefer.tipmov = "S"
                    docrefer.serieori = B12_NFref.mod
                    docrefer.codedori = tt-plani.desti
                    docrefer.dtemiori = tt-plani.pladat
                    docrefer.serecf = tt-plani.ufemi
                    /*docrefer.numecf = int(entry(3,tt-plani.notped,"|"))*/
                    docrefer.dtemicupom = tt-plani.pladat
                    docrefer.tipmovref = "S"
                    docrefer.tipoemi = "P"
                    docrefer.codrefer = string(tt-plani.desti)
                    docrefer.modelorefer = string(B01_IdeNFe.mod)
                    docrefer.serierefer = string(B01_IdeNFe.serie)
                    docrefer.numerodr = A01_infnfe.numero
                    docrefer.datadr = today
                    .

end.
for each nfeloja.I01_Prod of A01_infnfe :

    find first tt-movim where
               tt-movim.etbcod = placon.etbcod and
               tt-movim.placod = placon.placod and
               tt-movim.movtdc = placon.movtdc and
               tt-movim.procod = int(cprod)
               no-error.
    if not avail tt-movim then next.
               
    update xprod format "x(60)"  label "Desc.Prod.".
   
    vdesc[1] = substr(string(infadprod),1,60).
    vdesc[1] = substr(string(infadprod),62,60).
    vdesc[1] = substr(string(infadprod),122,60).
    vdesc[1] = substr(string(infadprod),182,60).
    vdesc[1] = substr(string(infadprod),242,60).
    vdesc[1] = substr(string(infadprod),302,60).

    update vdesc[1]
    vdesc[2]
    vdesc[3]
    vdesc[4]
    vdesc[5] 
    vdesc[6]
    with side-label.
    
    update I01_Prod 
    except xprod infAdProd
    with frame fI01 1 column title " PRODUTO " overlay.
    
    assign
        tt-movim.opfcod = I01_Prod.cfop
        tt-movim.movpc  = I01_Prod.vprod / I01_Prod.qcom
        tt-movim.movqtm = I01_Prod.qcom
        tt-movim.movdev = I01_Prod.vfrete / I01_Prod.qcom
        tt-movim.movdes = I01_Prod.vdesc / I01_Prod.qcom
        tt-movim.movseq = nitem.
        
    find nfeloja.N01_icms of I01_Prod  no-error.
    update N01_icms with frame fN01 1 column title " ICMS " overlay.
    
    assign
        tt-movim.movcsticm = string(N01_icms.cst)
        tt-movim.movbicms  = N01_icms.vbc
        tt-movim.movalicms = N01_icms.picms
        tt-movim.movicms   = N01_icms.vicms
        tt-movim.movsubst  = N01_icms.vicmsst
        .
    /*
    find O01_ipi of I01_Prod  no-error.
    O01_ipi.cst = 00.
    
    update O01_ipi with frame O01 1 column title " IPI " overlay.
    */
    find nfeloja.Q01_pis of I01_Prod no-error.
    update Q01_pis with frame fQ01 1 column title " PIS " overlay.
    
    assign
        tt-movim.movpis   = Q01_pis.vpis
        tt-movim.movalpis = Q01_pis.ppis
        tt-movim.movbpiscof = Q01_pis.vbc
        tt-movim.movcstpiscof = Q01_pis.cst.

    find nfeloja.S01_cofins of I01_Prod no-error.
    update S01_cofins with frame fS01 1 column title " COFINS " overlay.

    assign
        tt-movim.movcofins = S01_cofins.vcofins
        tt-movim.movalcofins = S01_cofins.pcofins
        .

    infadprod = vdesc[1] + " " + vdesc[2] + " " + vdesc[3] + " " + vdesc[4] +
     " " + vdesc[5] + " " + vdesc[6] . 
end.    
                                    
find nfeloja.W01_total of A01_infnfe no-error.
if avail W01_total
then do:
    update W01_total
                with frame f-tot 1 column
                title " Totalizadores " overlay.
            
    assign
        tt-plani.platot = W01_total.vnf
        tt-plani.protot = W01_total.vprod
        tt-plani.bicms  = W01_total.vbc
        tt-plani.icms   = W01_total.vicms
        tt-plani.bsubst = W01_total.vbcst
        tt-plani.icmssubst   = W01_total.vst
        tt-plani.frete = W01_total.vfrete
        tt-plani.seguro = W01_total.vseg
        tt-plani.descprod = W01_total.vdesc
        tt-plani.ipi = W01_total.vipi
        tt-plani.notpis = W01_total.vpis
        tt-plani.notcofins = W01_total.vcofins.

for each B12_NFref of A01_infnfe  : /*where
                    ( if avail bA01_infnfe
                      then B12_NFref.refnfe = bA01_infnfe.id 
                      else B12_NFref.nnf = int(entry(2,tt-nfref.notped,"|")))
                    no-lock no-error.*/
    if B12_NFref.nnf = 0
    then delete B12_NFref.
    update B12_NFref. 
end.
                       
for each docrefer where docrefer.etbcod = A01_infnfe.etbcod and
                          docrefer.numerodr = A01_infnfe.numero and
                          docrefer.tiporefer = 14 and
                          docrefer.serieori = "2D" and
                          docrefer.numecf = 0:
        delete docrefer.
end.                          

find nfeloja.E01_Dest of A01_infnfe  no-error.
    update E01_Dest
        with frame f-dest 1 column title " Destinatario " overlay.
end.

for each nfeloja.I01_Prod of A01_infnfe:
    update I01_Prod.xprod I01_Prod.ucom I01_Prod.utrib.
end.    
/*
run reenv_NFe_tst.p(recid(A01_infnfe)).
*/
leave.
end.

find first nfeloja.placon where placon.etbcod = tt-plani.etbcod and
                        placon.placod = tt-plani.placod 
                        .
buffer-copy tt-plani to placon.

for each tt-movim where tt-movim.procod > 0:
    find first nfeloja.movcon where
               movcon.etbcod = tt-movim.etbcod and
               movcon.placod = tt-movim.placod and
               movcon.procod = tt-movim.procod
               .
    buffer-copy tt-movim to movcon.
end.