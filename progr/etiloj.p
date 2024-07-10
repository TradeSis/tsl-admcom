{admcab.i}
def var toteti as int.
def var varquivo as char.
def var veti as int.
def var vl-cli-valor as decimal initial 0.

def new shared temp-table tt-cli 
    field clicod like clien.clicod
    field titnum like titulo.titnum
    field divida like titulo.titvlcob
    field etbcod like estab.etbcod
    field titdtven like titulo.titdtven.
    
def var ven-2050 as int.
def var ven-2035 as int.
def var ven-2030 as int.
def var ven-3060 as int.
def var ven-6090 as int.
    

def var t-lib like titulo.titvlcob.
def var t-inf like titulo.titvlcob.
def var vini as date format "99/99/9999" label "Data Inicial".
def var vi as int.
def var vfim as date format "99/99/9999" label  "Data Final".
def var diaini as int format ">>9" label "Dias Inicial".
def var diafim as int format ">>9" label "Dias Final".
def var vtotal      as char  extent 8 format "x(10)".
def var vcontrato like titulo.titnum.
def var vcli    like clien.clicod.
def var vclicod like clien.clicod  extent 2 format "999999999".
def var vclinom like clien.clinom format "x(25)"  extent 2.
def var vtitpar like titulo.titpar extent 2.
def var vtitnum like titulo.titnum format "x(8)" extent 2.
def var vnumero like clien.numero  extent 2 .
def var vendereco like clien.endereco format "x(32)" extent 2 .
def var vcep      like clien.cep extent 2 .
def var vcompl  like clien.compl extent 2.
def var vetbcod like titulo.etbcod extent 2 format ">>9".
def var vcidade like clien.cidade format "x(12)" extent 2.
def var vbairro like clien.bairro format "x(10)" extent 2.
def var vtitvlpag like titulo.titvlpag extent 2 .
def var vtitdtven like titulo.titdtven extent 2 format "99/99/9999".
def var vetique   as log format "Sim/Nao".

def var n-etiq  as int.
def var wetbcod like estab.etbcod.

def var wetbcod2 like estab.etbcod.

def buffer btitulo for titulo.

def var t as i.
def var i as int.
def var v as i.


do with width 80 title " Emissao de Etiquetas de Aviso " 
                frame f1 side-label row 4:

    for each tt-cli:
        delete tt-cli.
    end.

    assign ven-2050 = 0  
           ven-2035 = 0
           ven-2030 = 0
           ven-3060 = 0
           ven-6090 = 0
           toteti   = 0. 

    
    update wetbcod colon 20
           wetbcod2.

    if wetbcod <> 0
    then do:
        /*
        find estab where estab.etbcod = wetbcod.
        disp estab.etbnom no-label. */
    end.
    else disp " GERAL " @ estab.etbnom colon 20.
    update diaini colon 20
           diafim colon 45.
        vfim = today - diaini.
        vini = today - diafim.
    update vini colon 20
           vfim colon 45.
    update t-inf label "Valor Minimo" colon 20.
    vetique = no.
    update vetique label "Imprimir Etiqueta" colon 20.
    
    vcontrato = "".
    vcli = 0.
    vi = 1.

    for each estab where
            if wetbcod = 0
            then true
            else estab.etbcod >= wetbcod and
                 estab.etbcod <= wetbcod2:

        for each titulo use-index titdtven where
                        titulo.empcod = 19      and
                        titulo.titnat = no      and
                        titulo.modcod = "CRE"   and
                        titulo.titdtven >= vini and
                        titulo.titdtven <= vfim and
                        titulo.etbcod = estab.etbcod and
                        titulo.titsit <> "PAG" no-lock break by titulo.clifor:
            
            t-lib = t-lib + titulo.titvlcob.
            
            if last-of(titulo.clifor)
            then do:
                find first tt-cli where tt-cli.clicod = titulo.clifor no-error.
                if avail tt-cli
                then next.
                find first btitulo where btitulo.empcod = 19 and
                                         btitulo.titnat = no and
                                         btitulo.modcod = "CRE" and
                                         btitulo.titdtven < vini and
                                         btitulo.clifor = titulo.clifor and
                                         btitulo.titsit = "LIB"
                                          no-lock use-index iclicod no-error.
                if avail btitulo
                then next.
                
                if titulo.titdtven >= (today - 50) and
                   titulo.titdtven <= (today - 20)
                then ven-2050 = ven-2050 + 1.
                
                if titulo.titdtven >= (today - 35) and
                   titulo.titdtven <= (today - 20)
                then ven-2035 = ven-2035 + 1.
                
                if titulo.titdtven >= (today - 30) and
                   titulo.titdtven <= (today - 20)
                then ven-2030 = ven-2030 + 1.
                

                if titulo.titdtven >= (today - 60) and
                   titulo.titdtven <= (today - 30)
                then ven-3060 = ven-3060 + 1.
                

                if titulo.titdtven >= (today - 90) and
                   titulo.titdtven <= (today - 60)
                then ven-6090 = ven-6090 + 1.
                
                find clien where clien.clicod = titulo.clifor no-lock no-error.
                if not avail clien
                then next.

                do transaction:
                    create tt-cli.
                    assign tt-cli.clicod = titulo.clifor
                           tt-cli.titnum = titulo.titnum
                           tt-cli.titdtven = titulo.titdtven
                           tt-cli.divida = t-lib
                           tt-cli.etbcod = titulo.etbcod.
                end.
                vcli  = titulo.clifor.
                t-lib = 0.
            end.
        end.

    end.
    /*
    /* antonio - 05/08/2009 - Valor mínimo da divida */
    assign vl-cli-valor = 0.
    for each tt-cli break by tt-cli.clicod 
                          by tt-cli.titnum :
        assign vl-cli-valor = vl-cli-valor + tt-cli.divida.
        if last-of(tt-cli.titnum) 
        then do:
            if vl-cli-valor < t-inf then delete tt-cli.
            assign vl-cli-valor = 0.
        end.
    end.
   /**/
   */
    toteti = 0.
    for each tt-cli no-lock:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if not avail clien
        then next.
        toteti = toteti + 1.
        /*disp clien.clicod. */
    end.
    
    
    display ven-2050 label "20 e 50 dias  "
            ven-2035 label "20 e 35 dias  "
            ven-2030 label "20 e 30 dias  "
            ven-3060 label "30 e 60 dias  "
            ven-6090 label "60 e 90 dias  "
            toteti   label "Total Etiqueta"
                    with frame f-tela side-label
                                centered 1 column.
    

    
    
    if vetique
    then do:
        
        update veti label "No. Etiquetas"
                            with frame f-numero 
                                side-label overlay centered.
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/eti" + string(time).
        else varquivo = "..~\relat~\eti" + string(time).
        
        output to value(varquivo) page-size 0.
        
        for each tt-cli break by tt-cli.divida desc:
            
            find clien where clien.clicod = tt-cli.clicod no-lock.
            
            vi = vi + 1.

            assign vetbcod[vi]   = titulo.etbcod
                   vtitdtven[vi] = tt-cli.titdtven
                   vclicod[vi] = clien.clicod
                   vtitnum[vi] = tt-cli.titnum
                   vclinom[vi] = clien.clinom
                   vendereco[vi] = trim(clien.endereco[1] + "," +
                                        string(clien.numero[1])
                                            + " - " +
                                       (if clien.compl[1] = ?
                                        then ""
                                        else string(clien.compl[1])))
                   vcep[vi] = cep[1]
                   vcidade[vi] = cidade[1]
                   vbairro[vi] = bairro[1].

            if vi = 2 and veti > 0
            then do:
            
                put "C: " at 1  vclicod[1] "Ctr: " at 15 vtitnum[1]
                    "C: " at 37 vclicod[2] "Ctr: " at 50 vtitnum[2] skip

                    vclinom[1] at 1
                    vclinom[2] at 37 skip
                    vendereco[1] at 1
                    vendereco[2] at 37 skip

                    "Bair: " at 1 vbairro[1]  vtitdtven[1] at 20
                    "bair: " at 37 vbairro[2] vtitdtven[2] at 56 skip

                    "CEP: " at 1 vcep[1]  vcidade[1]   at 20
                    "CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).
                
                assign vetbcod[vi] = 0
                       vtitdtven[vi] = ?
                       vclicod[vi] = 0
                       vtitnum[vi] = ""
                       vclinom[vi] = ""
                       vendereco[vi] = ""
                       vcep[vi] = ""
                       vcidade[vi] = "".
                vi = 0.
                
                veti = veti - 2.
            
            end.
            
            if veti <= 0
            then do:
                delete tt-cli.
                vi = 0.
            end.
            
            

        end.
            
       
        put "Fil: " at 1  vetbcod[1] vtitdtven[1] at 20
            "Fil: " at 37 vetbcod[2] vtitdtven[2] at 56 skip 
            "Cta: " at 1  vclicod[1] "Ctr: " at 20 vtitnum[1] 
            "Cta: " at 37 vclicod[2] "Ctr: " at 56 vtitnum[2] skip 
            vclinom[1] at 1 
            vclinom[2] at 37 skip 
            "End: " at 1 vendereco[1] 
            "End: " at 37 vendereco[2] skip 
            "CEP: " at 1 vcep[1]  vcidade[1]   at 20 
            "CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).
    
        output  close.

        if opsys = "UNIX"
        then.
        else dos silent value("type " + varquivo + " > prn").  

    end.
    
    message "Emissao de Etiquetas p/ Cobranca encerrada.".
    
    message "deseja imprimir listagem" update sresp.
    if sresp 
    then do:
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/etiq." + string(time).
        else varquivo = "..\relat\etiq." + string(time).

        output to value(varquivo).

        put skip(3)
        "RELACAO DE CLIENTES NOTIFICADOS PARA EFEITO DE REGISTRO NO " AT 20
        "SPC (SERVICO DE PROTECAO AO CREDITO) EM CONFORMIDADE COM   " AT 20
        "O CODIGO DE DEFESA DO CONSUMIDOR." AT 20 SKIP(3).
        
        for each tt-cli no-lock:
            find clien where clien.clicod = tt-cli.clicod no-lock no-error.
            if not avail clien
            then next.
            display clien.clicod column-label "Codigo"
                    clien.clinom column-label "Nome"
                        with frame f-cli down width 80.
        end.
        PUT SKIP(3)
            "DATA DE ENVIO       ___/___/___" AT 40 SKIP(2)
            "         _________________     " AT 40 SKIP
            "              E B C T          " AT 40.
        
        output close.

        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i}
        end.
    end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/work9/clipar" + string(day(today),"99") +
                string(month(today),"99") + ".eti".
    else varquivo = "l:~\work9~\clipar" + string(day(today),"99") +
                string(month(today),"99") + ".eti".
                
    output to value(varquivo).
    
    for each tt-cli:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if not avail clien
        then next.
        export tt-cli.
    end.
   
    output close.
    
    message "deseja imprimir carta" update sresp.
    if sresp 
    then run carta2.p.
    
    message "deseja gerar arquivo cdl" update sresp.
    if sresp 
    then run cdl.p.
    
    message "Deseja gerar arquivo promocao" update sresp.
    if sresp 
    then run cdl01.p.
    


    
    
    message "deseja limpar arquivo" update sresp.
    if sresp
    then do:
    
        for each tt-cli:
            
            disp "Limpando Arquivos.....".
            disp tt-cli with 1 down. pause 0.
            delete tt-cli.
            
        end.
        
    end.

end.
