{admcab.i} 
          
{retorna-pacnv.i new}          
          
def var valor-origem as dec.
def var valor-outros as dec.
def var vseguro as dec.
def var v-acrescimo as dec format ">>>,>>>,>>9.99".

def var vnumero as int format ">>>>>>>>9".
def var vetbcod like estab.etbcod.
def var vdatini as date.
def var vdatfin as date.
def var vdata as date.

def temp-table tt-contrato
    field etbcod like contrato.etbcod
    field clicod like contrato.clicod
    field contnum like contrato.contnum
    field crecod  like contrato.crecod
    field modcod  like contrato.modcod
    field vltotal like contrato.vltotal
    field vlentra like contrato.vlentra
    field numero  like plani.numero
    field val_origem as dec
    field val_out    as dec
    field val_acrescimo as dec
    field val_seguro like plani.seguro
    field banco like contrato.banco
    field chave as char format "x(44)"
    .
    
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
update vetbi at 2 label "Filial" 
       vetbf label "Ate" with frame f1 side-label width 80.
/*
update vetbcod at 2 label "Filial" with frame f1 side-label width 80.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
*/

update vdatini at 1 format "99/99/9999" label "Periodo de"
        with frame f1.
vdatfin = vdatini.
update vdatfin label "Ate"  format "99/99/9999"
       with frame f1.

for each tt-contrato: delete tt-contrato. end.
do vetbcod = vetbi to vetbf:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then next.
    disp vetbcod label "Filial" with 1 down.
    pause 0.
    do vdata = vdatini to vdatfin:
        disp vdata label "Data" with 1 down.
        pause 0.
    for each contrato where 
                        contrato.etbcod = estab.etbcod and
                        contrato.dtinicial = vdata 
                        no-lock:
        vnumero = 0.
        vseguro = 0.  
        valor-origem = 0.
        valor-outros = 0. 
        
        find first contnf where 
               contnf.etbcod  = contrato.etbcod and
               contnf.contnum = contrato.contnum
               no-lock no-error.
        if avail contnf 
        then do:
            find plani where plani.etbcod = contnf.etbcod and
                         plani.movtdc = 5 and
                         plani.placod = contnf.placod and
                         plani.serie  = contnf.notaser
                         no-lock no-error.
            if avail plani and plani.crecod = 2
            then do:
                valor-origem = 0.

                run retorna-pacnv-valores-contrato.p(input recid(plani), 
                                              input ?, 
                                              input ?).
                /***
                run calcula-valor-origem-contrato.p
                    (input recid(plani), ?, 
                        output valor-origem,
                        output valor-outros).
                vseguro = plani.seguro.
                ***/
                vnumero = plani.numero.
                
                valor-origem = pacnv-principal.
                
                if valor-origem > 0 and (contrato.vltotal - valor-origem) > 0
                then do:
                    create tt-contrato.
                    assign
                        tt-contrato.etbcod = contrato.etbcod
                        tt-contrato.clicod = contrato.clicod
                        tt-contrato.contnum = contrato.contnum 
                        tt-contrato.crecod  = plani.pedcod 
                        tt-contrato.vltotal = contrato.vltotal
                        tt-contrato.vlentra = contrato.vlentra
                        tt-contrato.numero  = vnumero
                        tt-contrato.val_origem = valor-origem /*- vseguro*/
                        tt-contrato.val_out    = valor-outros 
                        tt-contrato.val_acrescimo = pacnv-acrescimo
                            /*contrato.vltotal - valor-origem*/
                        tt-contrato.val_seguro = pacnv-seguro /*vseguro*/
                        tt-contrato.banco = contrato.banco
                        tt-contrato.chave = plani.ufdes
                        tt-contrato.modcod = contrato.modcod
                        .
                    if tt-contrato.vlentra = 0 and
                        pacnv-entrada > 0
                    then tt-contrato.vlentra = pacnv-entrada.    
                end.
            end.
        end.
        else do:
            valor-origem = 0.
 
            run retorna-pacnv-valores-contrato.p (input ?, 
                                              input recid(contrato), 
                                              input ?).
            valor-origem = pacnv-principal.

            /*
            run calcula-valor-origem-contrato.p
                    (?,input recid(contrato),
                     output valor-origem,
                     output valor-outros).
            */
            
            vseguro = contrato.vlseguro.
            
            if valor-origem > 0 and (contrato.vltotal - valor-origem) > 0
            then do:
                create tt-contrato.
                assign
                    tt-contrato.etbcod = contrato.etbcod
                    tt-contrato.clicod = contrato.clicod
                    tt-contrato.contnum = contrato.contnum 
                    tt-contrato.crecod  = contrato.crecod
                    tt-contrato.vltotal = contrato.vltotal
                    tt-contrato.vlentra = contrato.vlentra
                    tt-contrato.numero  = 0
                    tt-contrato.val_origem = valor-origem
                    tt-contrato.val_out    = valor-outros 
                    tt-contrato.val_acrescimo = pacnv-acrescimo
                        /*contrato.vltotal - valor-origem*/
                    tt-contrato.val_seguro = vseguro
                    tt-contrato.banco = contrato.banco
                    tt-contrato.modcod = contrato.modcod
                        .
                if tt-contrato.vlentra = 0 and
                    pacnv-entrada > 0
                then tt-contrato.vlentra = pacnv-entrada.    
            end.
        end.
    end.
    end.    
end.
message "Aguarde garando arquivos..." .
pause 0.

def var valchar as char format "x(15)".
def var varq as char.
def var varquivo as char.
varquivo = "/admcom/relat/relcontcar_v0181_" + string(time) + ".rel".
varq = "/admcom/relat/relcontcar_v0181_" + string(time) + ".csv".

{mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "190"
                &Page-Line = "66"
                &Nom-Rel   = ""relcpg""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ RELATORIO DE ACRESCIMOS """
                &Width     = "216"
                &Form      = "frame f-cabcab"}

disp with frame f1.
for each tt-contrato:
    v-acrescimo = v-acrescimo + 
        (tt-contrato.vltotal - tt-contrato.val_origem).
    find first finan where finan.fincod = tt-contrato.crecod no-lock no-error.
    find first titulo where
               titulo.clifor = tt-contrato.clicod and
               titulo.titnum = string(tt-contrato.contnum) and
               titulo.titpar > 0
               no-lock no-error.
    find first modal where modal.modcod = tt-contrato.modcod no-lock no-error.

            disp tt-contrato.etbcod column-label "Fil"
                 tt-contrato.contnum format ">>>>>>>>>9" 
                 modal.modnom when avail modal
                 tt-contrato.crecod 
                 finan.finnom when avail finan column-label "Plano"
                 finan.finnpc column-label "NPar"
                 titulo.titvlcob when avail titulo column-label "Parcela"
                        format "->>>,>>9.99"
                 tt-contrato.vltotal(total) column-label "VlContrato"
                        format ">>>,>>>,>>9.99"
                 tt-contrato.vlentra(total) column-label "Entrada"
                        format ">>>,>>>,>>9.99"
                 tt-contrato.numero format ">>>>>>>>9"  column-label "Venda"
                 tt-contrato.val_origem(total)     column-label "VlVenda"
                        format ">>>,>>>,>>9.99"
                 tt-contrato.val_acrescimo(total) column-label "Acrescimo"
                        format "->>,>>>,>>9.99"
                 tt-contrato.val_seguro(total) column-label "Seguro"
                        format ">>,>>>,>>9.99"
                 tt-contrato.banco column-label "Cobr"
                 tt-contrato.chave column-label "Chave"
                 with frame f-disp width 230 down.

end.
    
output close.

output to value(varq).
put "Filial;Contrato;Modalidade;Plano Credito;;Numero parcela;Valor parcela;Valor Contrato~ ;Entrada;Numero venda;Valor venda;Acrescimo;Seguro;Cobrança;Chave"
 skip.   
for each tt-contrato:
    v-acrescimo = v-acrescimo + 
        (tt-contrato.vltotal - tt-contrato.val_origem).
    find first finan where finan.fincod = tt-contrato.crecod no-lock no-error.
    find first titulo where
               titulo.clifor = tt-contrato.clicod and
               titulo.titnum = string(tt-contrato.contnum) and
               titulo.titpar > 0
               no-lock no-error.
    find first modal where modal.modcod = tt-contrato.modcod no-lock no-error.

    put unformatted
        tt-contrato.etbcod 
        ";"
        tt-contrato.contnum 
        ";" .
        
    if avail modal
    then do:
        put modal.modnom
        ";".
    end.    
    put tt-contrato.crecod 
        ";".
    if avail finan
    then do:
        put finan.finnom 
            ";"
            finan.finnpc 
            ";"
            .
    end.
    if avail titulo
    then do:        
        valchar = string(titulo.titvlcob).
        valchar = replace(valchar,",","").
        valchar = replace(valchar,".",",").
        put valchar
        ";"
        .
    end.
        
    valchar = string(tt-contrato.vltotal).
    valchar = replace(valchar,",","").
    valchar = replace(valchar,".",",").
    put valchar ";".
    
    valchar = string(tt-contrato.vlentra).
    valchar = replace(valchar,",","").
    valchar = replace(valchar,".",",").
    put valchar ";".
    
    put tt-contrato.numero format ">>>>>>>>9"
        ";".
    
    valchar = string(tt-contrato.val_origem).
    valchar = replace(valchar,",","").
    valchar = replace(valchar,".",",").
    put valchar ";".

    valchar = string(tt-contrato.val_acrescimo).
    valchar = replace(valchar,",","").
    valchar = replace(valchar,".",",").
    put valchar ";".

    valchar = string(tt-contrato.val_seguro).
    valchar = replace(valchar,",","").
    valchar = replace(valchar,".",",").
    put valchar ";".

    
    /*put replace(string(tt-contrato.vltotal,">>>>>>>>9.99"),".",",")
        ";"
        replace(string(tt-contrato.vlentra,">>>>>>>>9.99"),".",",")
        ";"
        tt-contrato.numero format ">>>>>>>>9"
        ";"
        replace(string(tt-contrato.val_origem,">>>>>>>>9.99"),".",",")
        ";"
        replace(string(tt-contrato.val_acrescimo,">>>>>>>>9.99"),".",",")
        ";"
        replace(string(tt-contrato.val_seguro,">>>>>>>>9.99"),".",",")
        ";"*/
        
    put tt-contrato.banco 
        ";"
        tt-contrato.chave 
        skip.
        
end.
output close.

message color red/with
    "Arquivo CSV gerado" skip
    varq
    view-as alert-box
    .
    
run visurel.p(varquivo,"").

