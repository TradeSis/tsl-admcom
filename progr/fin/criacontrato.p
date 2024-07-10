def input param vclifor as int.
def input param vetbcod as int.
def input param vmodcod as char.
def output param vrec as recid.

vrec = ?.

def var vmes as int.
def var vano as int.
def var vday as int.
def var vtitdtven as date.
def var vi as int.
            def var vcontnum like contrato.contnum format ">>>>>>>>>9".
            
            update vcontnum colon 13 
                with frame
                f-contrato1 width 80 title " Contrato " side-label row 3.

            
            find contrato where contrato.contnum  = int(vcontnum) exclusive no-error.
            if avail contrato
            then do:
                message "Contrato ja criado".
                pause.
                undo, return.
            end.
            create contrato. 
            contrato.contnum       = vcontnum. 
            contrato.clicod        = vclifor.  
            contrato.etbcod        = vetbcod.
            contrato.modcod        = vmodcod.
        find clien of contrato no-lock.
        
        disp
                    contrato.etbcod colon 45

            contrato.clicod colon 13 label "Cliente"
            
            clien.clinom no-label when avail clien format "x(20)"
            contrato.modcod colon 65 label "Modal"
            with frame f-contrato1.
            
            update 
                contrato.dtinicial format "99/99/9999" colon 13
                contrato.nro_parcelas label "Qtd Parcelas"
                 with no-validate with frame f-contrato1.
        if contrato.nro_parcelas = 0
        then do:
            message "Informe qtd de parcelas.".
            pause.
            undo.
        end.                 

    update
        contrato.vltotal colon 12 label "Vlr Total"
        contrato.vlentra colon 12 label "Vlr Entrada"
        with frame f-contrato2
        no-validate.
        
    disp    
        contrato.vltotal - contrato.vlentra
                 label "Vlr liquido" format "->>>>>,>>9.99" 
                 with frame f-contrato2.
    update             
        contrato.vlf_principal label "Principal" colon 12
        contrato.vlf_acrescimo label "Acrescimo" colon 12
                 
        contrato.vlseguro colon 12 
        contrato.vliof colon 8
        contrato.cet 
        contrato.txjuros colon 12
                contrato.vltaxa label  "TFC"                 

        with side-label width 30 frame f-contrato2 row 09 title " Valores ".
                 


                if contrato.vlentra > 0
                then do:  
                    create titulo.  
                    titulo.datexp = today. 
                    titulo.contnum  = contrato.contnum. 
                    
                    assign            
                    titulo.empcod     = 19
                    titulo.titnat     = no
                    titulo.modcod     = contrato.modcod 
                    titulo.etbcod     = contrato.etbcod 
                    titulo.clifor     = contrato.clicod 
                    titulo.titnum     = string(titulo.contnum).
                    titulo.titpar     = 0.
                    titulo.titdtemi   = contrato.dtinicial.
                    titulo.titdtven   = contrato.dtinicial.
                    titulo.titsit     = "PAG".
                    assign
                        titulo.modcod     = contrato.modcod
                        titulo.titvlcob   = contrato.vlentra
                        titulo.tpcontrato = contrato.tpcontrato.
                end.

                vday = day(dtinicial).
                vmes = month(dtinicial).
                vano = year(dtinicial).
                    
                    vmes = vmes + 1. 
                    if vmes > 12  
                    then assign vano = vano + 1 
                                vmes = 1.

                do vi = 1 to contrato.nro_parcelas:                 
    
                    vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF VDAY > 28 
                              THEN 28 
                              ELSE VDAY 
                         ELSE if VDAY > 30 
                              then 30 
                              else vday, 
                         vano).
                
                    create titulo.   
                    if vrec = ?
                    then  vrec = recid(titulo).
                    
                    titulo.datexp = today. 
                    titulo.contnum  = contrato.contnum. 
                    assign            
                    titulo.empcod     = 19
                    titulo.titnat     = no
                    titulo.modcod     = contrato.modcod 
                    titulo.etbcod     = contrato.etbcod 
                    titulo.clifor     = contrato.clicod 
                    titulo.titnum     = string(titulo.contnum).
                    titulo.titpar     = vi.
                    titulo.titdtemi   = contrato.dtinicial.
                    titulo.titdtven   = vtitdtven.
                    titulo.titsit     = "LIB".
                    assign
                        titulo.modcod     = contrato.modcod
                        titulo.titvlcob   = (contrato.vltotal - contrato.vlentra) / contrato.nro_parcelas.
                        titulo.tpcontrato = contrato.tpcontrato.
                    assign
                        titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcelas.
                        titulo.vlf_principal  = contrato.vlf_principal / contrato.nro_parcelas.

                    titulo.cobcod = 1. 
                    
                    vmes = vmes + 1. 
                    if vmes > 12  
                    then assign vano = vano + 1 
                                vmes = 1.

                end.
                     
                for each titulo where titulo.contnum = contrato.contnum.
                    titulo.titdesc        = contrato.vlseguro / contrato.nro_parcela. /* apenas compatibilidade, porque nao usa mais este campo */
                    titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcelas.
                end.                

                
            leave.