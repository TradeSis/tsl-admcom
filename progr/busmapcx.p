{admcab.i}

def var vetbcod as integer no-undo.
def var vcxacod as integer no-undo.
def var vdatmov as date no-undo.
def var vnrored as integer.
def var vcont   as integer.

def buffer bmapctb for mapctb.

def var vgtotal-ini-mat  as decimal format "->>>,>>>,>>9.99".
def var vgtotal-ini-fil  as decimal format "->>>,>>>,>>9.99".

form

" ********* MATRIZ *********           ********* FILIAL *********    " skip 
mapctb.Etbcod       mapcxa.Etbcod    
mapctb.cxacod       mapcxa.cxacod    
mapctb.datmov       mapcxa.datmov    
mapctb.datatu       mapcxa.datatu     
mapctb.datred       mapcxa.datred    
mapctb.nrofab       mapcxa.nrofab     
mapctb.nroseq       mapcxa.nroseq    
mapctb.nrocan       mapcxa.nrocan    
mapctb.nrored       mapcxa.nrored    
vgtotal-ini-mat     vgtotal-ini-fil  
mapctb.gtotal       mapcxa.gtotal    
mapctb.valliq       mapcxa.valliq    
mapctb.valbru       mapcxa.valbru    
mapctb.vlsan        mapcxa.vlsan     
mapctb.vlsub        mapcxa.vlsub     
mapctb.vlsup        mapcxa.vlsup     
mapctb.vlise        mapcxa.vlise
with frame f-mostra-1 with 2 col.
     
form     
" ********* MATRIZ *********           ********* FILIAL *********    " skip(1)
mapctb.vlacr        mapcxa.vlacr     
mapctb.vldes        mapcxa.vldes     
mapctb.vlcan        mapcxa.vlcan     
mapctb.cooini       mapcxa.cooini    
mapctb.coofin       mapcxa.coofin    
mapctb.t01          mapcxa.t01       
mapctb.t02          mapcxa.t02       
mapctb.t03          mapcxa.t03       
mapctb.t04          mapcxa.t04       
mapctb.t05          mapcxa.t05       
mapctb.t06          mapcxa.t06       
mapctb.t07          mapcxa.t07       
mapctb.t08          mapcxa.t08       
mapctb.t09          mapcxa.t09       
with frame f-mostra-2 with 2 col.


form
" ********* MATRIZ *********           ********* FILIAL *********    " skip(1)
mapctb.t10          mapcxa.t10       
mapctb.t11          mapcxa.t11       
mapctb.t12          mapcxa.t12       
mapctb.t13          mapcxa.t13       
mapctb.t14          mapcxa.t14       
mapctb.t15          mapcxa.t15       
mapctb.t16          mapcxa.t16       
mapctb.dt1          mapcxa.dt1       
mapctb.dt2          mapcxa.dt2       
mapctb.dt3          mapcxa.dt3       
mapctb.ch1          mapcxa.ch1       
mapctb.ch2          mapcxa.ch2       
mapctb.ch3          mapcxa.ch3       
mapctb.de1          mapcxa.de1       
mapctb.de2          mapcxa.de2       
mapctb.de3          mapcxa.de3       
 with frame f-mostra-3 with 2 col.
    
bl_princ:
repeat:    
    
update vetbcod  label "Filial"
       vdatmov  label "Data"  format "99/99/9999"
       vcxacod  label "Equip.(Caixa)"
       
       vnrored  label "Num.Reducao" format ">>>>>>9"
                help "Este campo não é obrigatório!"
       
                with frame f01 side-labels 1 col.

find first mapctb where mapctb.Etbcod = vetbcod
                    and mapctb.cxacod = vcxacod
                    and mapctb.datmov = vdatmov
                    and mapctb.nrored = (if vnrored = 0
                                        then mapctb.nrored
                                        else vnrored)
                                        exclusive-lock no-error.
                    
find first mapcxa where mapcxa.Etbcod = vetbcod
                    and mapcxa.cxacod = vcxacod
                    and mapcxa.datmov = vdatmov
                    and mapcxa.nrored = (if avail mapctb
                                         then mapctb.nrored
                                         else if vnrored > 0
                                         then vnrored
                                         else mapcxa.nrored)
                                         no-lock.
                    

if avail mapctb and avail mapcxa
    or (not avail mapctb and avail mapcxa)
then 

do on error undo, retry:

    

    assign vcont = 1.
    
    bl_mostra:
    repeat:

        assign vgtotal-ini-mat = 0
               vgtotal-ini-fil = 0.
                                        

        if vcont = 1
        then do:

            if avail mapctb
            then do:

            if mapctb.ch1 = ""
            then find last bmapctb use-index ind-2
                     where bmapctb.etbcod = mapctb.etbcod and
                           bmapctb.cxacod = mapctb.cxacod and
                           bmapctb.ch2 <> "E"            and
                           bmapctb.datmov < mapctb.datmov
                                 no-lock no-error.
 
            else find last bmapctb use-index ind-1
                     where bmapctb.ch1    = mapctb.ch1 and
                           bmapctb.ch2 <> "E"          and
                           bmapctb.datmov < mapctb.datmov
                                 no-lock no-error.


            if avail bmapctb
            then assign vgtotal-ini-mat = bmapctb.gtotal.
            else assign vgtotal-ini-mat = mapctb.gtotal -
                                     mapctb.t01 -
                                     mapctb.t02 -
                                     mapctb.t03 -
                                     mapctb.vlsub -
                                     mapctb.vlcan +
                                     mapctb.vlacr.
            end.
                                     
                   vgtotal-ini-fil = mapcxa.gtotal -
                                     mapcxa.t01 -
                                     mapcxa.t02 -
                                     mapcxa.t03 -
                                     mapcxa.vlsub -
                                     mapcxa.vlcan +
                                     mapcxa.vlacr.

            if avail mapctb
            then
            
            display     
                mapctb.Etbcod               
                mapctb.cxacod      
        mapctb.datmov      
        mapctb.datatu      
        mapctb.datred      
        mapctb.nrofab      
        mapctb.nroseq      
        mapctb.nrocan      
        mapctb.nrored
        vgtotal-ini-mat  label "Gr Total Ant"    
        mapctb.gtotal      
        mapctb.valliq      
        mapctb.valbru      
        mapctb.vlsan       
        mapctb.vlsub       
        mapctb.vlsup       
        mapctb.vlise       
              with frame f-mostra-1.
              
              
       display 
        mapcxa.Etbcod    
            mapcxa.cxacod    
            mapcxa.datmov    
            mapcxa.datatu    
            mapcxa.datred    
            mapcxa.nrofab    
            mapcxa.nroseq    
            mapcxa.nrocan    
            mapcxa.nrored    
            vgtotal-ini-fil  label "Gr Total Ant"
            mapcxa.gtotal    
            mapcxa.valliq    
            mapcxa.valbru    
            mapcxa.vlsan     
            mapcxa.vlsub     
            mapcxa.vlsup     
            mapcxa.vlise
                        with frame f-mostra-1.
      
      end.
      else if vcont = 2 then do:             

        if avail mapctb
        then
        display
        mapctb.vlacr       
        mapctb.vldes       
        mapctb.vlcan       
        mapctb.cooini      
        mapctb.coofin      
        mapctb.t01         
        mapctb.t02         
        mapctb.t03         
        mapctb.t04         
        mapctb.t05         
        mapctb.t06         
        mapctb.t07         
        mapctb.t08         
        mapctb.t09        
              with frame f-mostra-2
       .
       
       
       display

            mapcxa.vlacr     
            mapcxa.vldes     
            mapcxa.vlcan     
            mapcxa.cooini    
            mapcxa.coofin    
            mapcxa.t01       
            mapcxa.t02       
            mapcxa.t03       
            mapcxa.t04       
            mapcxa.t05       
            mapcxa.t06       
            mapcxa.t07       
            mapcxa.t08       
            mapcxa.t09       
                with frame f-mostra-2.
            
        end.  
        else if vcont = 3 then do:

        if avail mapctb
        then

         display
        mapctb.t10         
        mapctb.t11         
        mapctb.t12         
        mapctb.t13         
        mapctb.t14         
        mapctb.t15         
        mapctb.t16         
        mapctb.dt1         
        mapctb.dt2         
        mapctb.dt3         
        mapctb.ch1         
        mapctb.ch2         
        mapctb.ch3         
        mapctb.de1         
        mapctb.de2         
        mapctb.de3         
            with frame f-mostra-3.
            
        
                display
            mapcxa.t10       
            mapcxa.t11       
            mapcxa.t12       
            mapcxa.t13       
            mapcxa.t14       
            mapcxa.t15       
            mapcxa.t16       
            mapcxa.dt1       
            mapcxa.dt2       
            mapcxa.dt3       
            mapcxa.ch1       
            mapcxa.ch2       
            mapcxa.ch3       
            mapcxa.de1       
            mapcxa.de2       
                mapcxa.de3       
                with frame f-mostra-3.
                
       sresp =  no.
       message "(V)isualizar novamente ou (S)air e continuar?"
                    update sresp format "Visualizar/Sair".  
        
        if sresp
        then do:
            assign vcont = 1.
            next bl_mostra.
        end.    
        else leave bl_mostra.
        
        end.
        
        assign vcont = vcont + 1.

    end. /* repeat */      
          
    sresp = no.
    message "Confirma importação da Filial?" update sresp.
    
    if not sresp
    then next bl_princ.
    else do on error undo, retry:
    
        if not avail mapctb
        then
        create mapctb.

        buffer-copy mapcxa to mapctb.

        message "Redução " + string(vnrored) + " importada corretamente."
            view-as alert-box.

    end.
end.

end. /* repeat bl_princ */

/*
display mapctb.
 
display mapcxa.                    
*/


