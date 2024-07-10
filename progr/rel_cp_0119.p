/* helio 25052022 - pacote melhorias cobranca */
{admcab.i}

def var vdti        as date.
def var vdtf        as date.

def var vdt  as date.

def var vetbi as integer.
def var vetbf as integer.

def var v-empdeposito as log format "Deposito/Dinheiro".

def var varquivo as char.

def var vlimite-disponivel as char.
def var vtotal-venda       as decimal.
def var vval-venda         as decimal.
def var vtotal-contrato like contrato.vltotal.
def var vtotal-seguro like contrato.vlseguro format ">>>,>>9.99".
def var vtotal-iof like contrato.vliof       format ">>>,>>9.99".
def var vtotal-cet like contrato.cet         format ">>>,>>9.99".
def var vtotal-taxa like contrato.vltaxa     format ">>>,>>9.99" .

def temp-table tt-vcp no-undo
    field etbcod like plani.etbcod format ">>9" column-label "Fil"
    field placod like plani.placod
    field pladat like plani.pladat format "99/99/9999" label "Dt.Venda"
    field hora   as char label "Hora"
    field crecod like contrato.crecod label "Plano" format ">>>9"
    field dtinicial like contrato.dtinicial format "99/99/9999" 
                        label "Dt.Contrato"
    field contnum like contrato.contnum format ">>>>>>>>>>9" label "Contrato"
    field desti like plani.desti  format ">>>>>>>>>>9" column-label "Conta"
    field ciccgc like clien.ciccgc label "CPF" format "x(15)"
    field clinom like clien.clinom format "x(30)" label "Cliente" 
    field val-venda as dec format "->>,>>>,>>9.99" label "Val. Contratado"
    field vltotal like contrato.vltotal   column-label "Val. Contrato"
    field vlseguro like contrato.vlseguro format ">>>,>>9.99"
    field vliof like contrato.vliof    format ">>>,>>9.99"
    field cet like contrato.cet      format ">>>,>>9.99"
    field vltaxa like contrato.vltaxa   format ">>>,>>9.99"
    field empdeposito like v-empdeposito column-label "Tipo"
    field findesc like profin.findesc column-label "Produto"
    field nparcela as int
    field vparcela as dec
    field funcod    like plani.vencod
    field funape        like func.funape
    field funfunc       like func.funfunc
    index i1 is unique primary etbcod pladat placod.

def buffer bestab for estab.

assign vetbi = 1
        vetbf = 999
        vdti = today 
        vdtf = today.

update vetbi format ">>9" label "Filial............" colon 25 
with frame f-filtros side-labels
title "RELATORIO DE CREDITO PESSOAL" width 80.

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

/* helio 25052022 - pacote melhorias cobranca */
def var vfiltravendedor as log format "Sim/Nao".
def var vetbven like func.etbcod.
def var vfuncod like func.funcod.
def var vfunfunc    like func.funfunc.
do  with frame f-filtros.

    vfiltravendedor = no.
    update vfiltravendedor label "Filtra Vendedor?.." colon 25.
    
    if vfiltravendedor
    then do:
        update vetbven label "Filial" . update vfuncod label "Codigo" .    
        find func where func.etbcod = vetbven and func.funcod = vfuncod no-lock no-error.
        if not avail func
        then do:
            message "Vendedor" vfuncod "nao encontrado na filial" vetbven.
            undo.
        end.
    end.        
    update vfunfunc label "Cargo Vendedor..." colon 25.
    vfunfunc = caps(vfunfunc).
        disp vfunfunc.
        
end.    
/**/ 

form  with frame f-rel.

assign vtotal-venda = 0.
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel_cp_0119_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") + ".txt".
    else varquivo = "..\relat\rel_cp_0119_" + string(time) + ".txt".

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "200"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_cp_0119""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
      &Tit-Rel   = """RELATORIO CREDITO PESSOAL - ""
                   + ""FILIAL "" + string(vetbi, "">>9"") 
                   + "" A "" + string(vetbf, "">>9"")
                   + "" - PERIODO DE ""
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "220"
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
                              contnf.placod = plani.placod /*and
                              contnf.notaser = plani.serie  */
                              no-lock,      
            first contrato where contrato.contnum = contnf.contnum 
                             no-lock:
                             
            if vprod <> "" and contrato.modcod <> vprod
            then next.
                                
            /**if contrato.banco <> 13
            then next.**/
            
            find profin where profin.modcod = contrato.modcod no-lock no-error.
            if not avail profin
            then next.

    
            find first contcp where contcp.contnum = contrato.contnum no-lock no-error.
            if contrato.dtinicial >= 07/01/2020 /* barramento */
            then if avail contcp
                 then v-empdeposito = yes.
                 else v-empdeposito = no.
            else  if acha("Deposito",plani.notobs[1]) <> ""
                  then v-empdeposito = yes.
                  else v-empdeposito = no.
            
            assign vval-venda = 0.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                       /*      and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat */
                                        no-lock,
                                        
                first profin where profin.procod = movim.procod
                                   no-lock.
                                        
                assign vval-venda = movim.movpc * movim.movqtm.
                                        
            end.                            
                      
            find first clien where clien.clicod = plani.desti 
                                    no-lock no-error.

            
            find finan where finan.fincod = plani.pedcod no-lock no-error.
            if not avail finan
            then do:
                message "Plano de financiamento " plani.pedcod
                " nao cadastrado". pause.
                next.
            end.
            find profin where profin.modcod = contrato.modcod no-lock no-error.
            if not avail profin
            then next.

            find func where func.etbcod = plani.etbcod and func.funcod = plani.vencod no-lock no-error.
            if vfiltravendedor
            then do:
                if not avail func
                then next.
                if func.etbcod = vetbven and func.funcod = func.funcod
                then.
                else next.
            end.
            if vfunfunc <> ""
            then do:
                if not avail func
                then next.

                if func.funfunc <> vfunfunc
                then next.
            end.
            create tt-vcp.
            assign
                tt-vcp.etbcod = plani.etbcod
                tt-vcp.pladat = plani.pladat
                tt-vcp.hora   = string(plani.horincl,"HH:MM:SS")
                tt-vcp.crecod = finan.fincod
                tt-vcp.dtinicial = contrato.dtinicial
                tt-vcp.contnum = contrato.contnum
                tt-vcp.desti = plani.desti
                tt-vcp.ciccgc = clien.ciccgc
                tt-vcp.clinom = clien.clinom
                tt-vcp.val-venda = vval-venda - contrato.vltaxa
                tt-vcp.vltotal = contrato.vltotal
                tt-vcp.vlseguro = if contrato.vlseguro = ? then 0 else contrato.vlseguro
                tt-vcp.vliof = contrato.vliof
                tt-vcp.cet = contrato.cet
                tt-vcp.vltaxa = contrato.vltaxa
                tt-vcp.empdeposito = v-empdeposito
                tt-vcp.findesc = if avail profin then profin.findesc else "-"
                tt-vcp.nparcela = finan.finnpc
                tt-vcp.vparcela = contrato.vltotal / finan.finnpc
                /* helio 25052022 - pacote melhorias cobranca */
                tt-vcp.placod   = plani.placod 
                tt-vcp.funcod   = plani.vencod     
                tt-vcp.funape   = if avail func then func.funape  else "NAO ENCONTRADO" 
                tt-vcp.funfunc  = if avail func then func.funfunc else "DESCONHECIDO".
                .

        end.
    end.
end.
for each tt-vcp use-index i1 where tt-vcp.etbcod > 0 no-lock:
                           
            display
                   tt-vcp.etbcod format ">>9" column-label "Fil"
                   tt-vcp.pladat format "99/99/99" label "Dt.Venda"
                   /*tt-vcp.hora label "Hora"*/
                   tt-vcp.crecod label "Plano" format ">>>9"
                   tt-vcp.dtinicial format "99/99/99" label "Dt.Contrato"
                   tt-vcp.contnum format ">>>>>>>>>>9" label "Contrato"
                   tt-vcp.desti  format ">>>>>>>>>>9" column-label "Conta"
                   tt-vcp.ciccgc
                   tt-vcp.clinom format "x(25)" label "Cliente" when avail clien
                   tt-vcp.val-venda
                        format "->>,>>>,>>9.99" label "Val. Contratado"
                   tt-vcp.vltotal   column-label "Val. Contrato"
                   tt-vcp.vlseguro format ">>>,>>9.99"
                   tt-vcp.vliof    format ">>>,>>9.99"
                   tt-vcp.cet      format ">>>,>>9.99"
                   tt-vcp.vltaxa   format ">>>,>>9.99"
                   tt-vcp.empdeposito column-label "Tipo"
                   tt-vcp.findesc column-label "Produto"
                   tt-vcp.nparcela column-label "Parc" format ">>9"
                   tt-vcp.vparcela column-label "Val.Parc"
                   tt-vcp.funcod format ">>>>>>>9" column-label "Codigo"
                   tt-vcp.funape    column-label "Vendedor"
                   tt-vcp.funfunc column-label "Cargo"
                  with frame f-rel width 330 down.
            down with frame f-rel.

            assign 
                vtotal-venda = vtotal-venda + tt-vcp.val-venda
                vtotal-contrato = vtotal-contrato + tt-vcp.vltotal
                vtotal-seguro = vtotal-seguro + tt-vcp.vlseguro
                vtotal-iof = vtotal-iof + tt-vcp.vliof
                vtotal-cet = vtotal-cet + tt-vcp.cet
                vtotal-taxa = vtotal-taxa + tt-vcp.vltaxa
                .
end.
down(1) with frame f-rel.
disp vtotal-venda @ tt-vcp.val-venda
     vtotal-contrato @ tt-vcp.vltotal
     vtotal-seguro @ tt-vcp.vlseguro
     vtotal-iof @ tt-vcp.vliof
     vtotal-cet @ tt-vcp.cet
     vtotal-taxa @ tt-vcp.vltaxa
     "TOTAL" @ tt-vcp.empdeposito
     with frame f-rel.

output close.


if opsys = "UNIX"
then do:
    run visurel.p (input varquivo,
                   input "").
end.
else do:
    {mrod.i}.
end.
                                                           


