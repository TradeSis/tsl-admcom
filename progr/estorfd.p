{admcab.i}

def var varquivo as char.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.

varquivo = "/admcom/relat/estorfd" + string(time,"999999").

def temp-table tc-titulo like titulo.

def var vdata as date.
form tc-titulo.moecod no-label format "x(15)"
        with frame f-disp down.

def var vqtd-des as int.

def var vmoecod like titulo.moecod.

repeat:
    do on error undo, retry:
          update vdti label "Periodo estorno" 
                 vdtf label ""  with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
    end.
    
    do vdata = vdti to vdtf:
        disp "PROCESSANDO.... AGUARDE!   " vdata
            with frame f-dd 1 down no-box color message
            no-label row 10 centered.
        pause 0.    
            
        for each envfinan where
                 envfinan.datexp = vdata and
                 /*envfinan.envsit = "CAN" */
                 envfinan.envsit = "RET"
                 no-lock.
                 
            find first tc-titulo where 
                   tc-titulo.empcod = envfinan.empcod and
                   tc-titulo.titnat = envfinan.titnat and
                   tc-titulo.modcod = envfinan.modcod and
                   tc-titulo.etbcod = envfinan.etbcod and
                   tc-titulo.clifor = envfinan.clifor and
                   tc-titulo.titnum = envfinan.titnum 
                    no-error.
            if not avail tc-titulo
            then do:
                create tc-titulo.
                buffer-copy envfinan to tc-titulo.
            end.
        end.
    end.    
   
    {mdadmcab.i
        &Saida     = value(varquivo)
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""estorfd""
        &Nom-Sis   = """ """
        &Tit-Rel   = """CONTRATOS RETORNADOS"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    disp with frame f-1.
    
    for each tc-titulo no-lock, 
        first contrato where contrato.contnum = int(tc-titulo.titnum)
                        no-lock break by tc-titulo.moecod
                                      by contrato.contnum
                                      with frame f-disp.
        /*
        if first-of(tc-titulo.moecod)
        then do:
            if tc-titulo.moecod = "DEV"
            then disp "DEVOLUCAO" @ tc-titulo.moecod .
            ELSE IF tc-titulo.moecod = "NOV" 
                THEN DISP "NOVACAO" @ tc-titulo.moecod.
                ELSE IF tc-titulo.moecod = "" and
                        tc-titulo.titpar >= 30
                    THEN DISP "RENOVACAO" @ tc-titulo.moecod.        
                    ELSE DISP tc-titulo.moecod.
            
        END.        
        */
        vqtd-des = vqtd-des + 1.
        disp tc-titulo.etbcod column-label "Filial"
             tc-titulo.titnum  column-label "Contrato"
             contrato.dtinicial
             contrato.vltotal(total by tc-titulo.moecod)
             vqtd-des column-label "Quant." format ">>>>>>9"
             .

        down with frame f-disp.
    end.

    output close.
    run visurel.p(varquivo,"").
    leave.
end.

