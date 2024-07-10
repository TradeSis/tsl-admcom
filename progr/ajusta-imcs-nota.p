def var v-al-icms as dec.

for each plani where plani.etbcod = 993 
                 and plani.dtinclu = 04/03/2012
                 and plani.numero = 19217 exclusive-lock.
                                                             
    display plani.icms
        /*  plani.alicms */
            plani.platot
            plani.protot
            plani.protot * 17 / 100
        /*  plani.frete
            plani.ipi                     
            plani.desacess
            plani.biss 
            plani.bicms         */
            plani.serie
        /*  plani.isenta*/ with frame f01 with 2 col.
                          /*
    update   plani.ICMS
             plani.AlICMS 
             plani.PLaTot
             plani.proTot
             plani.BICMS
             plani.Outras
             plani.IPI
             plani.Seguro
             plani.Frete
             plani.DesAcess
             plani.DescProd
             plani.Isenta   format "->>>,>>>,>>>,>>>,>>9.99"
             
             /*                                                    
             plani.movtdc                   format ">>9"
             plani.PlaCod                   format ">>>>>>>>>>>>9"
             plani.Numero                  
             plani.PlaDat                  
             plani.Serie                   
             plani.vencod                  
             plani.plades                  
             plani.crecod                  
             plani.VlServ                  
             plani.DescServ                
             plani.AcFServ                 
             plani.PedCod                  
             plani.BSubst                  
             plani.ICMSSubst               
             plani.BIPI                    
             plani.AlIPI                   
             plani.AcFProd                 
             plani.ModCod                  
             plani.AlISS                   
             plani.UFEmi                   
             plani.BISS                    
             plani.CusMed                  
             plani.UserCod                 
             plani.DtInclu                 
             plani.HorIncl                 
             plani.NotSit                  
             plani.NotFat                  
             plani.HiCCod                  
             plani.NotObs                  
             plani.RespFre                 
             plani.NotTran                 
             plani.ISS                     
             plani.NotPis                  
             plani.NotAss                  
             plani.NotCoFinS               
             plani.TMovDev                 
             plani.Desti                   
             plani.IndEmi                  
             plani.Emite                   
             plani.NotPed                  
             plani.OpCCod                    format ">>>>9"
             plani.UFDes                   
             plani.EtbCod                  
             plani.cxacod                  
             plani.datexp                  
             */

             
             with frame f01 no-validate with 3 col.
                            */
                                                             
    
    for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movdat = plani.pladat
                     and movim.movtdc = plani.movtdc
                                exclusive-lock,
                         
        first produ of movim no-lock.

         assign v-al-icms = movim.movalicm.
                                
         display 
         movim.procod
         produ.pronom format "x(15)"
         movim.movalicm
    /*   movim.movdev  */
         movim.movicms (total)
         (movim.movpc * movqtm * movim.movalicm / 100) (total) 
         (movim.movpc * movqtm) (total).
        
         /*   
         update movim.movicms.
         */
                               
     end.
            /*
     update plani.icms with frame f01 no-validate overlay.
              */
end.