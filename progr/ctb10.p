{admcab.i}
    

def var totsai like plani.platot.
def var totent like plani.platot.
def var vopfcod as char.
def temp-table tt-fis
    field opfcod  as char
    field tot-pla like plani.platot
    field tot-bic like plani.platot
    field tot-icm like plani.platot
    field tot-ipi like plani.platot
    field tot-out like plani.platot.
             
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var varquivo as char.

    
def var vprocod like produ.procod.
def var vfil      like estab.etbcod.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def buffer bestab for estab.

def temp-table tt-ecf
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field codecf as int format "99999"
        index ind-1 etbcod
                    cxacod.



def var v-ecf as int.
def var vcgc as char format "x(14)".
def var ii as int.
def var valor-contabil like plani.platot.
    

def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.




def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
    

def var val07 as dec.

 


def var vise like plani.platot.

def var outras-icms as dec format "->>>,>>9.99".
def var /* input parameter */ vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var /* input parameter */ vdti    as date format "99/99/9999".
def var /* input parameter */ vdtf    as date format "99/99/9999".
def stream sarq.
def var vemp like estab.etbcod.
def var valor-icms as dec.
def var alicota-icms as dec.

repeat:
    
    for each tt-fis:
        delete tt-fis.
    end.

    input from ..\progr\tt-ecf.txt.
    repeat:
        create tt-ecf.
        import tt-ecf.
    end.
    input close.

    for each tt-ecf where tt-ecf.etbcod = 0.
        delete tt-ecf.
    end.

    
    for each tt-07. 
        delete tt-07. 
    end.
    
    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     
    
        
    
    assign tot-valor = 0 
           tot-base  = 0 
           tot-icms  = 0.


    
    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

    
    for each tt-icms where tt-icms.dtini <= vdti and
                           tt-icms.dtfin >= vdtf:   

        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdti        and
                             movim.movdat <= vdtf        and
                             movim.procod = tt-icms.procod no-lock.
                             
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
        
            if not avail plani
            then next.
                
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
    
        end.
    
    end.        
 

    
    find estab where estab.etbcod = vetbcod no-lock.
    
  
    do vdt = vdti to vdtf:

        for each tipmov where tipmov.movtdc = 4 or
                              tipmov.movtdc = 12 no-lock:
                          
            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec = vdt no-lock:

                if fiscal.emite = 5027 
                then next. 
                outras-icms = 0.
                
                if tipmov.movtdc = 4 
                then do:
                    find forne where forne.forcod = fiscal.emite 
                            no-lock no-error.
                    if not avail forne
                    then next.
                end.         
                     
                   
                vopfcod = string(fiscal.opfcod).
                find first tt-fis where tt-fis.opfcod = vopfcod no-error.
                if not avail tt-fis
                then do:
                    create tt-fis.
                    assign tt-fis.opfcod = vopfcod.
                end.
            
                assign tt-fis.tot-pla = tt-fis.tot-pla + fiscal.platot. 
                       tt-fis.tot-bic = tt-fis.tot-bic + fiscal.bicms. 
                       tt-fis.tot-icm = tt-fis.tot-icm + fiscal.icms. 
                       tt-fis.tot-ipi = tt-fis.tot-ipi + fiscal.ipi. 
                       tt-fis.tot-out = tt-fis.tot-out + fiscal.out.
                        
            
           
 
            end. 
        end. 
    end.
                    
    
 
    do vdt = vdti to vdtf:
        for each tipmov where tipmov.movtdc = 6  or 
                              tipmov.movtdc = 13 or
                              tipmov.movtdc = 14 or
                              tipmov.movtdc = 16 no-lock,
            each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each plani where plani.etbcod = estab.etbcod and
                             plani.pladat = vdt and
                             plani.movtdc = tipmov.movtdc no-lock:
         
            outras-icms  = 0.
            valor-icms   = 0.
        
        
            find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat 
                                            no-lock no-error.
            if avail movim
            then valor-icms = (plani.bicms * (movim.movalicms / 100)).
                               
        
            if plani.ipi > 0
            then do:
                if (plani.platot - plani.bicms) > plani.ipi
                then outras-icms = plani.platot - plani.bicms - plani.ipi.
            end.
            else if plani.bicms < plani.platot
                 then outras-icms = plani.platot - plani.bicms.
        

            if plani.movtdc = 16 
            then do:
                if forne.ufecod = "RS"
                then vopfcod = "5915".
                else vopfcod = "6949".
            end.

            if plani.movtdc = 14  
            then do:
                if forne.ufecod = "RS"
                then vopfcod = "5901".
                else vopfcod = "6901".
            end.
 
            if plani.movtdc = 13  
            then do:
                if forne.ufecod = "RS"
                then vopfcod = "5202".
                else vopfcod = "6202".
            end.
            if plani.movtdc = 6
            then vopfcod = "5152".
            
            
               
            find first tt-fis where tt-fis.opfcod = vopfcod no-error.
            if not avail tt-fis
            then do: 
                create tt-fis.
                assign tt-fis.opfcod = vopfcod.
            end.
            
            assign tt-fis.tot-pla = tt-fis.tot-pla + plani.platot. 
                   tt-fis.tot-bic = tt-fis.tot-bic + plani.bicms. 
                   tt-fis.tot-icm = tt-fis.tot-icm + valor-icms. 
                   tt-fis.tot-ipi = tt-fis.tot-ipi + plani.ipi. 
                   tt-fis.tot-out = tt-fis.tot-out + outras-icms.
                 
            
            
            assign outras-icms = 0   
                   valor-icms  = 0.   

        end.
    end.


    do vdt = vdti to vdtf:

        for each serial where serial.etbcod = vetbcod and
                              serial.serdat = vdt          and
                              serial.icm17 > 0 no-lock:

        
            find first tt-07 where tt-07.etbcod = serial.etbcod and
                                   tt-07.cxacod = serial.cxacod and
                                   tt-07.data   = serial.serdat no-error.
            if avail tt-07
            then val07 = tt-07.valor.
            else val07 = 0.
    
            outras-icms = serial.icm17 - 
                          ((serial.icm17 - val07) + (val07 * 0.41177)).
            if outras-icms < 0
            then outras-icms = 0.
                  
        
            assign tot-valor = tot-valor +  (serial.icm17 + serial.sersub)  
                   tot-base  = tot-base  + ((serial.icm17 - val07) + 
                                            (val07 * 0.41177))  
                   tot-icms  = tot-icms +  ( ((serial.icm17 - val07) * 0.17) 
                                               + (val07 * 0.07) ) .

               
            find first tt-fis where tt-fis.opfcod = "5102" no-error.
            if not avail tt-fis
            then do: 
                create tt-fis.
                assign tt-fis.opfcod = "5102".
            end.
            
            assign tt-fis.tot-pla = tt-fis.tot-pla + 
                                    ((serial.icm17 - val07) + 
                                     (val07 * 0.41177))

                   tt-fis.tot-bic = tt-fis.tot-bic + 
                                    ((serial.icm17 - val07) + 
                                     (val07 * 0.41177))

                   tt-fis.tot-icm = tt-fis.tot-icm +    
                                     (((serial.icm17 - val07) * 0.17) 
                                        + (val07 * 0.07) ) 
                                    
                   tt-fis.tot-out = tt-fis.tot-out + outras-icms.
        end.         
    end.

    do vdt = vdti to vdtf:


    

        for each serial where serial.etbcod = vetbcod and
                              serial.serdat = vdt     and
                              serial.icm12 > 0 no-lock:

       
    
          
            find first tt-fis where tt-fis.opfcod = "5102" no-error.
            if not avail tt-fis 
            then do: 
                create tt-fis.
                assign tt-fis.opfcod = "5102".
            end.
            
            assign tt-fis.tot-pla = tt-fis.tot-pla + serial.icm12 
                   tt-fis.tot-bic = tt-fis.tot-bic + (serial.icm12 * 0.705889) 
                   tt-fis.tot-icm = tt-fis.tot-icm + 
                                    ((serial.icm12 * 0.705889) * 0.17).    
             
        end.
    
    end.
 
    do vdt = vdti - 30 to vdtf + 30:
    
        for each plani where plani.movtdc = 6       and
                             plani.desti  = vetbcod and
                             plani.pladat = vdt no-lock:
        
                        
            if plani.datexp >= vdti and
               plani.datexp <= vdtf
            then.
            else next.

            outras-icms = 0.

            if plani.ipi > 0
            then do:
                if (plani.platot - plani.bicms) > plani.ipi
                then outras-icms = plani.platot - plani.bicms - plani.ipi.
            end.
            else outras-icms = plani.platot - plani.bicms.
               
            find first tt-fis where tt-fis.opfcod = "1152" no-error.
            if not avail tt-fis
            then do: 
                create tt-fis.
                assign tt-fis.opfcod = "1152".
            end.
            
            assign tt-fis.tot-pla = tt-fis.tot-pla + plani.platot. 
                   tt-fis.tot-ipi = tt-fis.tot-ipi + plani.ipi. 
                   tt-fis.tot-out = tt-fis.tot-out + outras-icms.
        end.
    end.          
    
    
    varquivo = "l:\relat\ctb" + string(vetbcod,"999") + ".rel". 
    
    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "64" 
            &Cond-Var  = "130"  
            &Page-Line = "66"  
            &Nom-Rel   = ""ctb10""  
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
        &Tit-Rel   = """MOVIMENTOS PARA IMPORTACAO"" + 
                     ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                     "" "" + string(vdti,""99/99/9999"") + "" ate "" +
                             string(vdtf,""99/99/9999"")"
        &Width     = "130" 
        &Form      = "frame f-cabcab3"}
        
    totsai = 0.
    totent = 0.
        
    for each tt-fis by tt-fis.opfcod: 
        
        display tt-fis.opfcod column-label "Oper.Fiscal"
                tt-fis.tot-pla(total) column-label "Total"  
                                  format ">>>,>>>,>>9.99"
                tt-fis.tot-bic(total) column-label "Base ICMS"
                                  format ">>>,>>>,>>9.99"
                tt-fis.tot-icm(total) column-label "ICMS" 
                                  format ">>>,>>>,>>9.99"
                tt-fis.tot-ipi(total) column-label "IPI"
                                  format ">>>,>>>,>>9.99"
                tt-fis.tot-out(total) column-label "Outras"
                                  format ">>>,>>>,>>9.99"
                    with frame flista1 width 200 down.
                    
        if substring(tt-fis.opfcod,1,1) = "1" or
           substring(tt-fis.opfcod,1,1) = "2" 
        then totent = totent + tt-fis.tot-pla.
        else totsai = totsai + tt-fis.tot-pla.
         
    end.                  
    display totent label "Total Entradas" format "zzz,zzz,zz9.99" at 10
            totsai label "Total Saidas  " format "zzz,zzz,zz9.99" at 10
                    with frame f-tot side-label.
    output close.
    {mrod.i}
end.





