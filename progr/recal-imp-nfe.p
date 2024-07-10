def temp-table tt-plani like plani.
def temp-table tt-movim like movim.

def var vetbcod like estab.etbcod.
def var vnumero like plani.numero.

update vetbcod label "Filial"
with frame f1 1 down side-label.

repeat:

update vnumero label "NFe Numero" with frame f1.

for each placon where placon.etbcod = vetbcod and
numero = vnumero
 no-lock.
/*
disp platot protot frete bicms icms.
*/
create tt-plani.
buffer-copy placon to tt-plani.

for each movcon where movcon.etbcod = placon.etbcod and
movcon.placod = placon.placod and
movcon.movtdc = placon.movtdc .
/*
disp procod format ">>>>>>>>9" movpc movqtm movpc * movqtm(total) movalicms movicms.
*/

disp movcon.procod movcon.movpc * movcon.movqtm movcon.movalicms
    movcon.movicms.
    update movcon.movalicms.
    movcon.movicms = (movcon.movpc * movcon.movqtm) * (movcon.movalicms / 100).

create tt-movim.
buffer-copy movcon to tt-movim.
end.
end.

find first tt-plani.

find first a01_infnfe where
           a01_infnfe.etbcod = tt-plani.etbcod and
           a01_infnfe.numero = tt-plani.numero
            no-error.

disp a01_infnfe.chave label "Chave NFe" with frame f2 1 down side-label.             
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
            val-cof = 0
            .
         /*   
         for each tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                         tt-movim.placod = tt-plani.placod and
                                         tt-movim.movtdc = tt-plani.movtdc and
                                         tt-movim.movdat = tt-plani.pladat
                                         .
            /*
            find produ where produ.procod = tt-movim.procod no-lock.
 
            {cal_imposto_nfe.i}
            */
            find I01_Prod of A01_infnfe where
                I01_Prod.nitem = tt-movim.movseq
                no-error.
            if avail I01_Prod
            then do:
                /*I01_Prod.vfrete = fre-item.
                disp I01_Prod.vprod I01_Prod.vfrete.
                */

                disp xprod I01_Prod.vprod(total) I01_Prod.qcom I01_Prod.qtrib.
                
            end.
            
            /*
            find N01_icms of I01_Prod  no-error.
            if avail N01_icms
            then do:
                /*assign
                    N01_icms.vbc = vbc-item
                    N01_icms.picms = ali-item
                    N01_icms.vicms = icm-item
                    .
                  */

                disp N01_icms.cst 
                      N01_icms.vbc  
                      N01_icms.picms
                      N01_icms.vicms .
                /*
                if N01_icms.cst = 0
                then
                N01_icms.vicms = N01_icms.vbc * (N01_icms.picms / 100).
                */
                update N01_icms.cst 
                      N01_icms.vbc  
                      N01_icms.picms
                      N01_icms.vicms .

            end.
                       */
            /*
            find first clafis where
                 clafis.codfis = produ.codfis no-lock no-error.
            
            if avail clafis and
                clafis.cofinssai > 0 or
                clafis.pissai > 0
            then*/ 
            /*
            /*if I01_Prod.cfop = 1202
            then*/ do: 
                find Q01_pis of I01_Prod  no-error.
                if not avail Q01_pis
                then  create Q01_pis.
                    assign
                        Q01_pis.chave = I01_Prod.chave
                        Q01_pis.nitem = I01_Prod.nitem
                        Q01_pis.cst = 01
                        Q01_pis.vbc = I01_Prod.vprod
                        Q01_pis.ppis = 1.65
                        Q01_pis.vpis = I01_Prod.vprod * (Q01_pis.ppis / 100)
                        .
                val-pis = val-pis + Q01_pis.vpis.
                
                find S01_cofins of I01_Prod  no-error.
                if not avail S01_cofins
                then   create S01_cofins.
                    assign
                        S01_cofins.chave = I01_Prod.chave
                        S01_cofins.nitem = I01_Prod.nitem
                        S01_cofins.cst = 01
                        S01_cofins.vbc = I01_Prod.vprod
                        S01_cofins.pcofins = 7.60
                        S01_cofins.vcofins = I01_Prod.vprod * 
                                        (S01_cofins.pcofins / 100)
                        .
                val-cof = val-cof + S01_cofins.vcofins.
            end.
            */
        end.
        */


for each I01_Prod of A01_infnfe :
    update I01_Prod 
    except infAdProd
    with frame fI01 1 column title " PRODUTO ".
    find N01_icms of I01_Prod  no-error.
    update N01_icms with frame fN01 1 column title " ICMS ".
    find Q01_pis of I01_Prod no-error.
    update Q01_pis with frame fQ01 1 column title " PIS ".
    find S01_cofins of I01_Prod no-error.
    update S01_cofins with frame fS01 1 column title " COFINS ".
end.    
                                    
        find W01_total of A01_infnfe no-error.
        if avail W01_total
        then do:
            
            /*assign
                W01_total.vbc = vbc-total
                W01_total.vicms = icm-total
                .
                */
            /*
            W01_total.vpis = val-pis.
            W01_total.vcofins = val-cof.
            */    
            /*
            disp W01_total.vbc 
                  W01_total.vicms
                  W01_total.vpis
                  W01_total.vcofins
                  .
            */

            update W01_total
                with frame f-tot 1 column
                title " Totalizadores ".
            


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

find E01_Dest of A01_infnfe  no-error.
    update  E01_Dest
    with frame f-dest 1 column title " Destinatario ".
                
end.

for each I01_Prod of A01_infnfe:
    update I01_Prod.xprod I01_Prod.ucom I01_Prod.utrib.
end.    

leave.
end.
