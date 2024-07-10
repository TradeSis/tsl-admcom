{admcab.i}

def new shared temp-table ttser 
    field etbcod like plani.etbcod
    field cxacod like plani.cxacod
    field pladat like plani.pladat
    field ventot like plani.platot
    field situacao as char
    index serial etbcod
                 cxacod
                 pladat.
    

def var vdat as date.

def var i as i.

def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".

def temp-table warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".

repeat:
    for each ttser. delete ttser. end.
    
    form vetbcod estab.etbnom with frame f1.
    disp "ENTER para verificar Transmissao das Seriais"            
         @ estab.etbnom with frame f1.
         
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label 
            when avail estab
            with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    if vetbcod <> 0 and
       avail estab
    then undo. /* run ser.p(input vetbcod,
              input vdti,
              input vdtf).*/
    else do:
    
        for each estab where estab.etbcod < 900 and
                    {conv_difer.i estab.etbcod} no-lock.

            do vdat = vdti to vdtf:
            
                /*message estab.etbcod vdat. pause 0.*/

                for each plani where plani.movtdc = 5 /* or
                                     plani.movtdc = 12)*/
                                 and plani.etbcod = estab.etbcod
                                 and plani.pladat = vdat no-lock:
                    if plani.notped <> "C"
                    then next.              
                    find first ttser where ttser.etbcod = plani.etbcod and
                                           ttser.cxacod = plani.cxacod and
                                           ttser.pladat = plani.pladat
                                           no-error.
                    if not avail ttser
                    then do:
                                           
                        create ttser.
                        assign ttser.etbcod = plani.etbcod 
                               ttser.cxacod = plani.cxacod
                               ttser.pladat = plani.pladat.
                    end.           
                    assign ttser.ventot = ttser.ventot + plani.platot.
                                               
                end.             
            end.
            
        end.    
        
        for each ttser /*by ttser.etbcod
                       by ttser.cxacod
                       by ttser.pladat*/:
                       
            /*disp ttser.etbcod
                 ttser.cxacod
                 ttser.pladat 
                 ttser.ventot with centered.*/
            
            find first serial where serial.etbcod = ttser.etbcod and
                                    serial.cxacod = ttser.cxacod and
                                    serial.serdat = ttser.pladat 
                                    no-lock no-error.
            if not avail serial
            then assign ttser.situacao = "Serial FALTOU".
            else assign ttser.situacao = "Serial OK".

        end.
        
    end.
    
    run serial2a.p.
    
end.
