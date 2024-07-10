{admcab.i}

def SHARED temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(25)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    .

def var /*input parameter*/ p-etbcod like estab.etbcod.
def var /*input parameter*/ p-dti as date.
def var /*input parameter*/ p-dtf as date.
def var /*input parameter*/ p-cxacod as int.

def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vstatus as char format "x(40)".
def var varq_log as char format "x(40)".
def var varq_loj as char.
def var vdata as date .
vdata = today.
def var vtabela as char extent 15.
def var vprograma as char extent 15.
def var vtabela1 as char.
def var vindex as int.

def var vetbcod like estab.etbcod.

def var vip1 like vip.
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.

def var vnrored as integer.
def var vcont   as integer.

def var vpausa  as integer.

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

for each estab no-lock:
    P-ETBCOD = ESTAB.ETBCOD.
    find first tt-caixa where
               tt-caixa.etbcod = estab.etbcod and
               tt-caixa.equip > 0 and
               tt-caixa.difer = yes
               no-error.
    if avail tt-caixa
    then do:
               
        vip = "filial" + string(p-etbcod,"999").

        if connected ("admloja")
                    then disconnect admloja.    
                  
        pause 0.
        message "Conectando..." vip.
  
        connect adm -H value(vip) -S sadm -N tcp -ld admloja
                no-error.
    
        if not connected ("admloja")
        then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                next.    
        end.
            
        vetbcod = int(substr(string(vip),7,3)).
        
        for each tt-caixa where tt-caixa.etbcod = estab.etbcod and
                                tt-caixa.difer  = yes:
            
            run busca-rdz-filial.p 
                    (tt-caixa.etbcod, tt-caixa.datmov, 
                     tt-caixa.cxacod, output vstatus ). 
            
        
        end.
            
        if connected ("admloja")
        then disconnect admloja.

        for each tt-caixa where tt-caixa.etbcod = estab.etbcod and
                                tt-caixa.difer  = yes:
            run mapcxa-mapctb.
        end.
    end.
end.    


procedure mapcxa-mapctb:
    for each mapcxa where mapcxa.Etbcod = tt-caixa.etbcod
                  and mapcxa.datmov = tt-caixa.datmov  
                  and mapcxa.cxacod = tt-caixa.cxacod no-lock
                                    break by mapcxa.Etbcod
                                          by mapcxa.cxacod
                                          by mapcxa.datmov:
    
    find first mapctb where mapctb.Etbcod = mapcxa.etbcod
                        and mapctb.cxacod = mapcxa.cxacod
                        and mapctb.datmov = mapcxa.datmov
                                exclusive-lock no-error.

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
              
                    pause vpausa.
              
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
      
                    pause vpausa.

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
                      with frame f-mostra-2.
       
                    pause vpausa.
       
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
                        
                    pause vpausa.    
            
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
            
        
                    pause vpausa.

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
                
                    pause vpausa.
                if vpausa > 0
                then do:

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
                else leave bl_mostra.

            end.
        
            assign vcont = vcont + 1.
        
        end. 
        if not avail mapctb
        then create mapctb.
        buffer-copy mapcxa to mapctb.

    end. /* do on error undo, retry: */
end. /* for each estab */

end procedure.
