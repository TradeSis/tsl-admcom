{admcab.i}

def var vlist-dep       as char.
def var vint-cont       as int.
def var vcha-dir-imp    as char.
def var v-linha         as char.
def var vdep-aux        as int.
def var varq2           as char.
def var varquivo        as char.
def var vdti            as date format "99/99/9999".
def var vdtf            as date format "99/99/9999".
def var v-nf            as int.
def var vetbcod         as int.

def temp-table tt-produ
    field etb-emite      like estab.etbcod
    field etb-desti      like estab.etbcod
    field procod         like produ.procod
    field itecod         like kit.itecod   /* Repete o produto e muda o filho */
    field pronom         like produ.pronom 
    field numero         like plani.numero
    field qtd-transf     like movim.movqtm
    field qtd-colet      like movim.movqtm 
    field qtd-diverg     like movim.movqtm format "->>>,>>9.99"
    index i1 etb-emite etb-desti numero procod.


def temp-table tt-kit
    field etb-emite      like estab.etbcod
    field etb-desti      like estab.etbcod
    field procod         like produ.procod
    field itecod         like kit.itecod    
    field pronom         like produ.pronom 
    field numero         like plani.numero.

update  vetbcod label "Filial" at 06
                    with frame f-dat centered color blue/cyan row 8
                            title " Filial " side-labels .

unix silent 
value("wget \http://desenv.lebes.com.br/confdescarga/exporta_conf.php?filial=" + string(vetbcod,"999")).


assign vlist-dep = "993,995,998".

do vint-cont = 1 to num-entries(vlist-dep):
       
    assign vcha-dir-imp = "/admcom/confer_android/"
                             /* + entry(vint-cont,vlist-dep) */
                             + "CONFEXP" + string(vetbcod,"999") + ".TXT".

    if search(vcha-dir-imp) = ?
    then next.
    
    assign varq2 = vcha-dir-imp + ".2"
           vdep-aux = int(entry(vint-cont,vlist-dep)) .

    unix silent
        value("/usr/dlc/bin/quoter -d % " + vcha-dir-imp + " > " + varq2).
                    
    input from value(varq2).
    
    repeat:
    
        import v-linha.
        
        find first tt-produ where tt-produ.etb-emite  = vdep-aux and
                   tt-produ.etb-desti  = int(substring(v-linha,1,3)) and
                   tt-produ.numero     = int(substring(v-linha,4,9))  and
                   tt-produ.procod     = int(substring(v-linha,13,8))
                   no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign tt-produ.etb-emite  = vdep-aux
               tt-produ.etb-desti  = int(substring(v-linha,1,3))
               tt-produ.procod     = int(substring(v-linha,13,8))
               tt-produ.pronom     = trim(substring(v-linha,21,40))
               tt-produ.numero     = int(substring(v-linha,4,9))
               .
        end.
        assign       
            tt-produ.qtd-transf =   tt-produ.qtd-transf +
                                    int(substring(v-linha,61,4))
            tt-produ.qtd-colet  =   tt-produ.qtd-colet +
                                    int(substring(v-linha,65,5))
               
               .
                    
        assign tt-produ.qtd-diverg
                     = tt-produ.qtd-colet - tt-produ.qtd-transf.         
        
        if substring(v-linha,70,8) <> ""
        then do:
        
            assign tt-produ.itecod = int(substring(v-linha,70,8)).
            
            find first tt-kit where tt-kit.etb-emite  = tt-produ.etb-emite and
                       tt-kit.etb-desti  = tt-produ.etb-desti and
                       tt-kit.numero     = tt-produ.numero and
                       tt-kit.procod     = tt-produ.procod
                       no-error.
            if not avail tt-kit
            then do:                    
                create tt-kit.
                assign
                    tt-kit.etb-emite  = tt-produ.etb-emite
                    tt-kit.etb-desti  = tt-produ.etb-desti
                    tt-kit.procod     = tt-produ.procod
                    tt-kit.itecod     = int(substring(v-linha,70,8))
                    tt-kit.pronom     = trim(substring(v-linha,78,28))
                    tt-kit.numero     = tt-produ.numero.
            end.
        end.
    
    end.
    
end.


if opsys = "UNIX"
then varquivo = "/admcom/relat/rconftra." + string(time).
else varquivo = "l:\relat\rconftra." + string(time).
    
{mdad.i
    &Saida     = "value(varquivo)"
    &Page-Size = "0"
    &Cond-Var  = "120"
    &Page-Line = "0"
    &Nom-Rel   = ""RCONFTRA""
    &Nom-Sis   = """SISTEMA DE TRANSFERENCIAS"""
    &Tit-Rel   = """CONFERENCIA DE TRANSFERENCIAS"""
    &Width     = "132"
    &Form      = "frame f-cabcab"}
    
    
for each tt-produ no-lock.

    release plani.
    find first plani where plani.etbcod = tt-produ.etb-emite
                       and plani.emite  = tt-produ.etb-emite
                       and plani.movtdc = 6
                       and plani.serie = "1"
                       and plani.numero = tt-produ.numero no-lock no-error.


    if vdti <> ?
        and vdtf <> ?
        and avail plani
        and (plani.pladat < vdti
               or plani.pladat > vdtf)
    then next.                    
    
    if v-nf > 0
        and v-nf <> tt-produ.numero 
    then next.    

    if vetbcod > 0
        and vetbcod <> tt-produ.etb-desti
    then next.                    

    display tt-produ.numero        column-label "NF"
            tt-produ.etb-emite     column-label "Emite"
            tt-produ.etb-desti     column-label "Desti"
            plani.pladat when avail plani column-label "Data" at 22
            tt-produ.procod     column-label "Prod."   format ">>>>>>>9"
            tt-produ.pronom        column-label "Descricao" format "x(26)"
            tt-produ.qtd-transf    column-label "Qtd Trans"
            tt-produ.qtd-colet     column-label "Qtd Colet" 
            tt-produ.qtd-diverg    column-label "Diverg."
                with frame f01 width 140 down.
            

    find first tt-kit where tt-kit.procod    = tt-produ.procod
                        and tt-kit.etb-emite = tt-produ.etb-emite
                        and tt-kit.etb-desti = tt-produ.etb-desti
                        and tt-kit.numero    = tt-produ.numero
                        and tt-kit.itecod    = tt-produ.itecod
                                      no-lock no-error.
                                        
    if avail tt-kit
    then do:
            
            display tt-kit.itecod format ">>>>>>>9" column-label "Cod Filho"
                    tt-kit.pronom format "x(26)"    column-label "Nome"
                                    with frame f01.

     end.

end.
                            
output close.                            

if opsys = "UNIX"
then do:
    message "Arquivo gerado: " varquivo. pause.
                                           
    run visurel.p (input varquivo, input "").
        
end.    
else do:
    {mrod.i}
end.    
                            
