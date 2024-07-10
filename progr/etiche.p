{admcab.i}

def new shared temp-table tt-cli 
    field clicod like clien.clicod
    field titnum like titulo.titnum
    field divida like titulo.titvlcob
    field etbcod like estab.etbcod
    field titdtven like titulo.titdtven.
 
def var vpag as l.
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
def var vdt like plani.pladat.
def buffer bcheque for cheque.
def var valmax  like plani.platot.

def var n-etiq  as int.
def var wetbcod like estab.etbcod.

def var wetbcod2 like estab.etbcod.

def var t as i.
def var i as int.
def var v as i.

def temp-table tt-che
    field etbcod like cheque.cheetb
    field clicod like cheque.clicod
    field numero like cheque.chenum
    field dtven  like cheque.cheven.


do with width 80 title " Emissao de Etiquetas de Aviso " frame f1 side-label
                row 4:

    for each tt-che:
        delete tt-che.
    end.
    update wetbcod colon 20
           wetbcod2.

    update diaini colon 20
           diafim colon 45.
    vfim = today - diaini.
    vini = today - diafim.
    update vini colon 20
           vfim colon 45.
    update valmax label "Valor Maximo" colon 20.
                
    vcli = 0.
    vi = 0.
    
    vdt = today + 100.
    for each cheque where cheque.chesit = "LIB"     and
                          cheque.cheetb >= wetbcod  and
                          cheque.cheetb <= wetbcod2 and
                          cheque.cheven >= vini     and
                          cheque.cheven <= vfim     and
                          cheque.cheval >= valmax      
                          no-lock break by cheque.clicod:

        
        display cheque.cheetb
                cheque.clicod
                cheque.cheven with 1 down. pause 0.
        
        if last-of(cheque.clicod)
        then do:
            find first tt-che where tt-che.clicod = cheque.clicod no-error.
            if not avail tt-che
            then do:
                create tt-che.
                assign tt-che.etbcod  = cheque.cheetb
                       tt-che.clicod  = cheque.clicod
                       tt-che.numero  = cheque.chenum
                       tt-che.dtven   = cheque.cheven.
                
                create tt-cli.
                assign tt-cli.clicod = cheque.clicod
                       tt-cli.etbcod = cheque.cheetb.

            
            end.
        end.    
    end.

    message "deseja imprimir etiqueta" update sresp.
    if sresp 
    then do:

        output to printer page-size 0.
        for each tt-che break by tt-che.etbcod 
                              by tt-che.clicod:
            find clien where clien.clicod = tt-che.clicod no-lock.
        
            vi = vi + 1.
            if last-of(tt-che.etbcod) and vi = 1
            then vi = vi + 1.
        
            assign vetbcod[vi]   = tt-che.etbcod
                   vtitdtven[vi] = tt-che.dtven
                   vclicod[vi]   = clien.clicod
                   vtitnum[vi]   = string(tt-che.numero)
                   vclinom[vi]   = clien.clinom
                   vendereco[vi] = trim(endereco[1] + "," +
                                        string(clien.numero[1])
                                        + " - " +
                                   (if clien.compl[1] = ?
                                    then ""
                                    else string(clien.compl[1])))
                   vcep[vi] = cep[1]
                   vcidade[vi] = cidade[1]
                   vbairro[vi] = bairro[1].

            if vi = 2
            then do: 
                put "C: " at 1  vclicod[1] "Cheq: " at 15 vtitnum[1]
                    "C: " at 37 vclicod[2] "Cheq: " at 50 vtitnum[2] skip

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
                       vcidade[vi] = ""
                       vi = 0.
            end.
        end.
        output  close.
    end.
    message "deseja gerar arquivo cdl" update sresp.
    if sresp 
    then run cdl.p.
    

 


end.
