def input parameter vopccod like opcom.opccod.
def input parameter vprocod like produ.procod.
def input parameter vmovtot like movim.movpc.
def input parameter ali_icm  as dec.
def input parameter val_icm  as dec.
def input parameter val_sub  as dec.
def output parameter val_bas as dec.
def output parameter val_ise as dec.
def output parameter val_out as dec.
def output parameter sittri  like clafis.sittri.
def output parameter valicm  as dec.

def var vopcgia as log.

/******************** CFOPS ENTRADA ********************/

vopcgia = yes.
valicm  = val_icm.
sittri  = ?.
val_bas = -999999999.99.
val_ise = -999999999.99.
val_out = -999999999.99.

if vopccod = "1101" or
   vopccod = "1102" or 
   /***17/10/2013 vopccod = "1202" or ***/
   vopccod = "1910" or 
   vopccod = "2101" or
   vopccod = "2102" or
   vopccod = "2124" or 
   vopccod = "2910" or
   vopccod = "2949" /*or
   vopccod = "1551" */
then do:
    if ali_icm = 0
    then val_bas = 0.
    else val_bas = (val_icm / ali_icm) * 100.

    if val_bas > vmovtot
    then val_bas = vmovtot.  
    val_ise = vmovtot - val_bas.
    /*
    val_out = 0.
    */
end.           

if vopccod = "1124" or
   vopccod = "1152" or 
   vopccod = "1253" or
   vopccod = "1552" or
   vopccod = "1902" or
   vopccod = "1905" or
   vopccod = "1906" or
   vopccod = "1908" or
   vopccod = "1913" or
   vopccod = "1915" or
   vopccod = "2902" or
   vopccod = "2913" or
   vopccod = "2915" or
   vopccod = "1556" or
   vopccod = "1253" or
   vopccod = "1303" or
   vopccod = "1551"
then assign val_bas = 0
            val_ise = 0
            val_out = vmovtot.
            
if vopccod = "1152" or
   vopccod = "2152" or
   vopccod = "5152" or
   vopccod = "6152" or
   vopccod = "1905" or
   vopccod = "1906" or
   vopccod = "1908" 
then assign valicm = 0.   
            
if vopccod = "1949" or
   vopccod = "1912" or
   vopccod = "1923" or
   vopccod = "2912" /*or
   vopccod = "2949" */
then if val_icm = 0
     then assign vopcgia = no
                 val_bas = 0
                 val_ise = 0
                 val_out = vmovtot.
     else do:
        if ali_icm = 0
        then val_bas = 0.
        else val_bas = (val_icm / ali_icm) * 100.

        if val_bas > vmovtot
        then val_bas = vmovtot.
        
        val_ise = vmovtot - val_bas.
        val_out = 0.
     end.
            
if vopccod = "1202" or /*** 17/10/2013 ***/
   vopccod = "1353" or
   vopccod = "1904" or
   vopccod = "2353"  
then do:
    if ali_icm = 0
    then val_bas = 0.
    else val_bas = (val_icm / ali_icm) * 100.

    if val_bas > vmovtot
    then val_bas = vmovtot.
    
    val_ise = 0. 
    val_out = vmovtot - val_bas.
end.
            
if vopccod = "6411" or
   vopccod = "5411"
then do:
    val_bas = 0.
    val_ise = 0.
    val_out = 0.
    
    if ali_icm = 0
    then val_bas = 0.
    else val_bas = (val_icm / ali_icm) * 100.
end.   

/**************** CFOPS SAIDAS *******************/

if vopccod = "5102" or
   vopccod = "5904" or
   vopccod = "6102"
then do:
    if ali_icm = 0
    then val_bas = 0.
    else val_bas = (val_icm / ali_icm) * 100.

    if val_bas > vmovtot
    then val_bas = vmovtot. 
    
    val_ise = 0. 
    val_out = vmovtot - val_bas.
end.

if vopccod = "5152" or
   vopccod = "5403" or
   vopccod = "5405" or
   vopccod = "5552" or
   vopccod = "5901" or
   vopccod = "5905" or
   vopccod = "5906" or
   vopccod = "5912" or
   vopccod = "5913" or
   vopccod = "5915" or
   vopccod = "5923" or
   vopccod = "5949" or
   vopccod = "6901" or
   vopccod = "6915" or
   vopccod = "6913" or
   vopccod = "6949"  
then assign val_bas = 0
            val_ise = 0
            val_out = vmovtot.

if vopccod = "5202" or
   vopccod = "5910" or
   vopccod = "6202"  
then do:
    if ali_icm = 0
    then val_bas = 0.
    else val_bas = (val_icm / ali_icm) * 100.
    
    if val_bas > vmovtot
    then val_bas = vmovtot. 
    
    val_ise = vmovtot - val_bas. 
    val_out = 0.
end.

/*
if val_ise > 0 and
   val_ise < /*=*/ 1 and
   vopccod <> "1292"
then assign val_ise = 0 
            val_bas = vmovtot.   
*/
                
if val_ise < 0 
then assign val_ise = 0.
                
if val_out >  0 and 
   val_out < /*=-*/ 1 and
   vopcgia
then assign val_out = 0 
            val_bas = vmovtot.   
                               
if val_out < 0 
then assign val_out = 0.
                               
if  val_bas > 0        and
    val_sub = 0        and
    vmovtot  > val_bas and
   (vmovtot - val_bas) > .50
then sittri = 20.

if vmovtot > val_bas and
   val_bas = 0      and
   val_sub = 0      and
   vopccod <> "1551"
then sittri = 51.
   
if val_sub > 0
then if int(substring(vopccod,1,1)) < 5 
     then sittri = 30.
     else sittri = 60.
