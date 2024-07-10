{cabec.i}

def input parameter par-rec-viagem as recid.

def var vhora as char label "Hora" format "x(5)".

def var vemitpro      as log format " /T" label "".
def var vserie       like plani.serie column-label "Ser".
def var vnumero      like plani.numero.
def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom format "x(12)".


    find first mdfviagem where recid(mdfviagem) = par-rec-viagem no-lock.

    find frete of mdfviagem no-lock.
    find forne of frete no-lock.
    find tpfrete of frete no-lock.
    find veiculo of mdfviagem no-lock.


varqsai = "../impress/mdferomaneio_" + string(time). 
   {sys/mdadmcab.i
     &Saida     = "value(varqsai)"
     &Page-Size = "64"
     &Cond-Var  = "120"
     &Page-Line = "66"
     &Nom-Rel   = ""rromaneio""
     &Nom-Sis   = """BS"""
     &Tit-Rel   = " ""ROMANEIO DE VIAGEM - TRANSP: "" + frete.frenom + 
            "" - DATA: "" +
        string(mdfviagem.dtviagem) + "" | PLACA: "" + string(mdfviagem.placa) +
        "" - ESTAB: "" + string(mdfviagem.etbcod) "
     &Width     = "120"
     &Form      = "frame f-cabcab"}


form
            with width 200
                with frame f2
                no-underline
                down.
      
disp
    mdfviagem.frecod colon 12 label "Transp"
    frete.frenom no-label 
    frete.fretpcod
    tpfrete.fretpemit label "TpE" 
    frete.rntrc  

    forne.forcgc colon 12 
    space(0) " Codigo: (" space(0) forne.forcod no-label space(0) ")"
    forne.forfone colon 60
 
    mdfviagem.etbcod colon 12 label "Filial"
    mdfviagem.placa  
    mdfviagem.dtviagem 
    
    vhora
    
   
    mdfviagem.viaobs  colon 12 label "Obs"

    with frame frame-cab overlay row 3 width 80 side-labels.


    for each mdfnfe of mdfviagem no-lock
        break by mdfnfe.mdfecod
              by mdfnfe.rotaseq.

        if first-of(mdfnfe.mdfecod)
        then do:
            find mdfe of mdfnfe no-lock no-error.
            disp
                "MDFe"
                mdfe.ufemi column-label "ORI"
                    when avail mdfe
                mdfe.ufdes column-label "DES"  
                    when avail mdfe
                mdfe.MdfeDtEmissao
                    when avail mdfe
                mdfe.MdfeSerie column-label "Ser"
                    when avail mdfe
                mdfe.MdfeNumero column-label "Numero"
                    when avail mdfe
                mdfe.mdfechave
                    when avail mdfe
                                        
             with frame f1 width 200.         
        end.

   
    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        



    find first a01_infnfe where
        a01_infnfe.chave = mdfnfe.infnfechave
        no-lock  no-error.

    vserie  = string(mdfnfe.serie).
    vnumero = mdfnfe.numero.

    vemitpro = avail a01_infnfe.
    
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie  = plani.serie.
            vnumero = plani.numero.
        end.
    end.    
    
            
        disp    
            space(5) "NFe "
            mdfnfe.rotaseq column-label "Rot"  
            vemitpro 
            mdfnfe.nfeid    format "xxxxxxxxxxxx..." column-label "Chave"
            vserie
            vnumero
            mdfnfe.tabemite no-label format  "x(3)"
            mdfnfe.emite    label "Emite" format ">>>>>>99"
            vufemi          no-label space(0) "/" space(0)
            vmunicemi       column-label "Local!Descarca"        
           
 
           
           /** "DESTI" **/
     
            mdfnfe.tabdesti format  "x(3)" no-label
            mdfnfe.desti     format ">>>>>>99"
                label "Emite"
            vufdes          no-label space(0) "/" spaCE(0)
            vmunicdes       COLUMN-LABEL "Local!Carga"

 /**          mdfnfe.pesobrutoKg 
        
            mdfnfe.valornota 
            **/
            
             /**
            skip
            space(13)
            
            "EMITE"
            mdfnfe.tabemite no-label format  "x(3)"
            mdfnfe.emite    no-label format ">>>>>>99"
            vufemi          no-label space(0) "/" space(0)
            vmunicemi       no-label        
                ***/
            with frame f2.
            down with frame f2.                
    end.    


    
{sys/mdadmrod.i                      
   &Saida     = "value(varqsai)"  
   &Form      = "frame f-rod3"}.  


