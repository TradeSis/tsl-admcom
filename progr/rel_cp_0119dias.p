/* helio 18072022 - ID 123982 - Diferença relatório empréstimo */
{admcab.i}

def var vdti        as date.
def var vdtf        as date.

def var vdt  as date.

def var vetbi as integer.
def var vetbf as integer.

def var v-tipoemp like plani.notobs[1].

def var varquivo as char.

def var vlimite-disponivel as char.
def var vtotal-venda       as decimal.
def var vval-venda         as decimal.
def var vtotal-contrato like contrato.vltotal.
def var vtotal-seguro like contrato.vlseguro format ">>>,>>9.99".

def temp-table tt-vcp
    field etbcod like plani.etbcod format ">>9" column-label "Fil"
    field pladat like plani.pladat format "99/99/9999" label "Dt.Venda"
    field hora   as char label "Hora"
    field dtinicial like contrato.dtinicial format "99/99/9999" 
                        label "Dt.Contrato"
    field contnum like contrato.contnum format ">>>>>>>>>>9" label "Contrato"
    field desti like plani.desti  format ">>>>>>>>>>9" column-label "Conta"
    field clinom like clien.clinom format "x(30)" label "Cliente" 
    field val-venda as dec format "->>,>>>,>>9.99" label "Val. Contratado"
    field vltotal like contrato.vltotal   column-label "Val. Contrato"
    field vlseguro like contrato.vlseguro format ">>>,>>9.99"
    field tipoemp like plani.notobs[1] column-label "Tipo"
    field findesc like profin.findesc column-label "Produto"
    index i1 etbcod pladat.

def buffer bestab for estab.

assign vetbi = 1
        vetbf = 999
        vdti = today 
        vdtf = today.

update vetbi format ">>9" label "Filial............" colon 25 
with frame f-filtros side-labels.

find estab where estab.etbcod = vetbi no-lock.
display estab.etbnom format "x(15)" no-label with frame f-filtros width 78.
    
display " a " with frame f-filtros.
update  vetbf format ">>9" no-label with frame f-filtros .

find bestab where bestab.etbcod = vetbf no-lock.
display bestab.etbnom format "x(15)" no-label with frame f-filtros.

update vdti label "Periodo de........" format "99/99/9999" colon 25 
 with frame f-filtros side-labels.

display " a " with frame f-filtros.

update  vdtf no-label format "99/99/9999"  with frame f-filtros.

def var vprod as char format "!!x".
/*vprod = "CP0".
find first profin where profin.modcod = vprod no-lock.
disp vprod profin.findesc no-label with frame f-filtros.
*/
update vprod at 7 label "Produto..........." with frame f-filtros.
if vprod <> ""
then do:
find first profin where profin.modcod = vprod no-lock.
disp profin.findesc no-label with frame f-filtros.
end.

form  with frame f-rel.

assign vtotal-venda = 0.
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel_cp_0119." + string(time).
    else varquivo = "..\relat\rel_cp_0119." + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "170"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_cp_0119""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
      &Tit-Rel   = """RELATORIO CREDITO PESSOAL - ""
                   + ""FILIAL "" + string(vetbi, "">>9"") 
                   + "" A "" + string(vetbf, "">>9"")
                   + "" - PERIODO DE ""
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "170"
        &Form      = "frame f-cabcab"}

for each estab where estab.etbcod >= vetbi
                 and estab.etbcod <= vetbf
                      no-lock.
                   
    do vdt = vdti to vdtf:
                    
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdt
                             no-lock,
            first contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod and
                              contnf.notaser = plani.serie
                              no-lock,      
            first contrato where contrato.contnum = contnf.contnum 
                             no-lock:
                             
            if vprod <> "" and contrato.modcod <> vprod
            then next.
                                
            if contrato.banco <> 13
            then next.
            
      
            if acha("Deposito",plani.notobs[1]) <> ""
            then v-tipoemp = plani.notobs[1].
            
            assign vval-venda = 0.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat
                                        no-lock,
                                        
                first profin where profin.procod = movim.procod no-lock.
                                        
                assign vval-venda = movim.movpc * movim.movqtm.
            end.                            
                      
            find clien where clien.clicod = plani.desti no-lock no-error.
            find profin where profin.modcod = contrato.modcod no-lock no-error.
            create tt-vcp.
            assign
                tt-vcp.etbcod = plani.etbcod
                tt-vcp.pladat = plani.pladat
                tt-vcp.hora   = string(plani.horincl,"HH:MM:SS")
                tt-vcp.dtinicial = contrato.dtinicial
                tt-vcp.contnum = contrato.contnum
                tt-vcp.desti = plani.desti
                tt-vcp.clinom = if avail clien then clien.clinom else ""
                tt-vcp.val-venda = vval-venda 
                tt-vcp.vltotal = contrato.vltotal
                tt-vcp.vlseguro = contrato.vlseguro
                tt-vcp.tipoemp = plani.notobs[1]
                tt-vcp.findesc = if avail profin then profin.findesc else "".
        end.
    end.
end.

for each tt-vcp use-index i1 where tt-vcp.etbcod > 0 no-lock:
            display
                   tt-vcp.etbcod format ">>9" column-label "Fil"
                   tt-vcp.pladat format "99/99/9999" label "Dt.Venda"
                   tt-vcp.dtinicial format "99/99/9999" label "Dt.Contrato"
                   tt-vcp.contnum format ">>>>>>>>>>9" label "Contrato"
                   tt-vcp.desti  format ">>>>>>>>>>9" column-label "Conta"
                   tt-vcp.clinom format "x(30)" label "Cliente"
                   tt-vcp.val-venda
                        format "->>,>>>,>>9.99" label "Val. Contratado"
                   tt-vcp.vltotal   column-label "Val. Contrato"
                   tt-vcp.tipoemp column-label "Tipo"

                  with frame f-rel width 200 down.
            down with frame f-rel.

            assign 
                vtotal-venda = vtotal-venda + tt-vcp.val-venda
                vtotal-contrato = vtotal-contrato + tt-vcp.vltotal.
                
end.
down(1) with frame f-rel.
disp vtotal-venda @ tt-vcp.val-venda
     vtotal-contrato @ tt-vcp.vltotal
     "TOTAL" @ tt-vcp.tipoemp
     with frame f-rel.

output close.

if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}.
end.
