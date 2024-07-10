{admcab.i}

def var wcon        like contrato.contnum format ">>>>>>>>>9".
def var vclicod     like contrato.clicod  format ">>>>>>>>>9".
def var vnovo       like clien.clicod     format ">>>>>>>>>9".
def var vcontnum    like contrato.contnum format ">>>>>>>>>9".
repeat:
    assign vcontnum = 0.
    update vcontnum colon 15                  
            with frame f1 side-label centered title "Contrato".
                                              
    find contrato where contrato.contnum = vcontnum no-error.
    if not available contrato
    then do: 
        message "Contrato nao cadastrado".
        undo,retry.
    end.
    display contrato.clicod label "Cliente" colon 15 
            format ">>>>>>>>>9" with frame f1.
    find clien where clien.clicod = contrato.clicod no-lock no-error.
    display clien.clinom       no-label
            contrato.dtinicial colon 15 format "99/99/9999"
            contrato.etbcod    label "Filial" 
                colon 15 with frame f1.
    
    for each titulo where titulo.titnum = string(contrato.contnum) and
                          titulo.etbcod = contrato.etbcod and
                          titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.clifor = contrato.clicod and
                          titulo.modcod = "CRE" no-lock.
     
        display titulo.etbcod 
                titulo.titpar
                titulo.titsit
                titulo.titdtven 
                titulo.titdtpag 
                titulo.titvlpag
                titulo.titvlcob 
                    with frame f3 7 down 
                        title " Parcelas " centered.
    end.
    vnovo = 0.
    update vnovo label "Novo Cliente"
                    with frame f2 side-label width 80.
    find clien where clien.clicod = vnovo no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.
    message "Confirma Alteracao de contrato" update sresp.
    if sresp = no
    then undo, retry.
    
    for each contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum:
        find first plani where plani.etbcod = contrato.etbcod and
                               plani.placod = contnf.placod no-error.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat:
                do transaction:
                    movim.desti = vnovo.
                end. 
                
            end.
            do transaction:
                plani.desti = vnovo.
            end.
        end.
    end.                           
    
    for each titulo where titulo.titnum = string(contrato.contnum) and
                          titulo.etbcod = contrato.etbcod and
                          titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.clifor = contrato.clicod and
                          titulo.modcod = "CRE".
        do transaction:
            titulo.clifor = vnovo.
            titulo.exportado = no.
        end.
    end.
    do transaction:
        contrato.clicod = vnovo.
    end.
    
    repeat on endkey undo:
        run alt-filial.
        leave.
    end.    
     
    message "Alteracao de Contrato encerrada.".
end.

procedure alt-filial:
    def var vfilial as int.
    def var vip as char.
    def var vstatus as char.
    
    message "Informe a Filial para conectar" update vfilial.
    
    if vfilial > 0
    then do:
    vip = "filial" + string(vfilial,"999").
    
    message "Conectando...>>>>>   " vip.
  
    if connected ("suporte")
    then disconnect suporte.
    
    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja.
    connect com -H value(vip) -S sdrebcom -N tcp -ld comloja.
    if not connected ("finloja")   or
       not connected ("comloja") 
    then do:
        vstatus = "FALHA NA CONEXAO COM A FILIAL".
    end.
    else do:        
    run altifil.p ( fin.contrato.etbcod, fin.contrato.contnum, 
                    vnovo, output vstatus ). 
    /*
    output to altifil.log.
        put today "   "  vip format "x(15)" skip   
            vstatus format "x(60)" skip
            .
    output close.
    */             
    if connected ("finloja")
    then disconnect finloja.
    if connected ("comloja")
    then disconnect comloja.
    end.
    message color red/with
        vstatus view-as alert-box.
    end.
    connect suporte -N tcp -S sdrebsup -H linux.
    
end procedure.

