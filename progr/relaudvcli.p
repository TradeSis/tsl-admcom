{admcab.i new}
{setbrw.i}                                                                      

def temp-table tt-plam
    field etbcod like plani.etbcod 
    field pladat like plani.pladat
    field numero like plani.numero
    field platot like plani.platot
    field protot like plani.protot
    field procod like movim.procod
    field pronom like produ.pronom
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field movtot as dec
    index i1 etbcod numero
            .

def var vclicod like clien.clicod.

update vclicod with frame f1.

find clien where clien.clicod = vclicod no-lock.

for each plani where plani.movtdc = 5 and
                     plani.desti = vclicod
                     no-lock.
                     disp plani.modcod.
                     pause.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc
                         no-lock.

        find produ where produ.procod = movim.procod
                no-lock no-error.
        if not avail produ then next.
                
        create tt-plam.
        assign
            tt-plam.etbcod = plani.etbcod 
            tt-plam.pladat = plani.pladat
            tt-plam.numero = plani.numero
            tt-plam.platot = plani.platot
            tt-plam.protot = plani.protot
            tt-plam.procod = movim.procod
            tt-plam.pronom = produ.pronom
            tt-plam.movpc  = movim.movpc
            tt-plam.movqtm = movim.movqtm
            tt-plam.movtot = movim.movpc * movim.movqtm
            .
    end.
end.                       
  
{movest10-def.i new}


for each tt-plam :

  /****
repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    clear frame f-val all.
    if setbcod < 200 
    then vetbcod = setbcod.
    else update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp vetbcod estab.etbnom no-label with frame f-pro.
    /*
    update vdata1 label "Periodo" colon 55
           vdata2 no-label with frame f-pro.

    if vdata1 < 01/01/11 and vetbcod < 990
    then vdata1 = 01/01/11.
    disp vdata1 with frame f-pro.
    */
    
    update vprocod at 1
               with frame f-pro centered width 80 color blue/cyan 
                            row 3 side-label.

    find produ where produ.procod = vprocod no-lock.
    
    disp produ.pronom no-label with frame f-pro.

    run ver-data.
    
    update vdata1 label "Periodo" 
           vdata2 no-label with frame f-pro.

    if day(vdata1) <> 1
    then vdata1 = date(month(vdata1),01,year(vdata1)).
    
    if vdata1 < 01/01/11 and vetbcod < 990
    then vdata1 = 01/01/11.
    disp vdata1 with frame f-pro.
    vdt = vdata1.
    
    if setbcod < 200
    then do:
        MESSAGE "Atencao : Este produto pode ter Movimentado o estoque"        ~    ~              "nos ultimos 30 minutos!"                                               "Favor aguardar atualizacao p/executar a consulta."                 
            view-as alert-box.                                                  
                                                                               ~    MESSAGE 
    "Atencao :   Este produto pode ter Movimentacoes de Devolução de Venda," sk~~ip 
    "que irao aparecer apos o encerramento dos Caixas e emissao de N.Fiscais" s~~kip     "Tais Operacoes devem ser consideradas no Saldo Final do Produto!"    
           view-as alert-box.                                                  
    

    end. 
    for each movdat where movdat.procod = produ.procod no-lock.
    
        find movim where movim.procod = movdat.procod and
                         movim.etbcod = movdat.etbcod and
                         movim.placod = movdat.placod no-lock no-error.
        if not avail movim or movim.movtdc > 9000
        then next.

        if movim.movdat < 01/01/11 and vetbcod < 990
        then next.
        
        if movim.etbcod = vetbcod or
           movim.desti  = vetbcod 
        then do:
            if vdt > movim.movdat
            then vdt = movim.movdat.
        end.
        
    end.    

    for each tt-saldo: delete tt-saldo. end.
    for each tt-movest: delete tt-movest. end.
    sal-atu = 0.
    sal-ant = 0.
    
    vdisp = no.
    
    if vetbcod = 981
    then run movest10-e.p.
    else run movest10.p.

    run _extrato11_movimento.p.
    
end.
       ***/
end.

form tt-plam.etbcod label "Fil"
     tt-plam.numero label "Numero"
     tt-plam.pladat label "Data"
     tt-plam.protot label "Total!Produtos"
     tt-plam.procod label "Produto"
     tt-plam.pronom label "Descricao"
     tt-plam.movqtm label "Quant"
     tt-plam.movpc  label "Val.Unit."
     tt-plam.movtot label "Val.Total"
     with frame f-disp down width 150.


    def var varquivo as char.
    
    varquivo = "/admcom/relat/relaudvcli" + string(vclicod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "130"  
                &Cond-Var  = "80" 
                &Page-Line = "130" 
                &Nom-Rel   = ""relaudvcli"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """MOVIMENTO VENDA - "" +
                            string(vclicod) + "" "" + clien.clinom " 
                &Width     = "130"
                &Form      = "frame f-cabcab"}

for each tt-plam use-index i1 break by tt-plam.etbcod by tt-plam.numero.
    disp tt-plam.etbcod
         tt-plam.numero
         tt-plam.pladat
         tt-plam.protot
         tt-plam.procod
         tt-plam.pronom
         tt-plam.movqtm
         tt-plam.movpc
         tt-plam.movtot(sub-total by tt-plam.numero)
         with frame f-disp
         .
     down with frame f-disp.
end.


output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.

