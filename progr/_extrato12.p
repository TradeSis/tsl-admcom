def var vdtsap as date initial  07/01/2020.

{admcab.i}   

{extrato12-def.i new}

def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vsalant   like estoq.estatual.

repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    clear frame f-val all.
    if setbcod < 500 
    then vetbcod = setbcod.
    else update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp vetbcod estab.etbnom when avail estab no-label with frame f-pro.
    
    update vprocod at 1
               with frame f-pro centered width 80 color blue/cyan 
                            row 3 side-label
                            title " Data Maxima " + string(vdtsap - 1,"99/99/9999").

    find produ where produ.procod = vprocod no-lock.
    
    disp produ.pronom no-label with frame f-pro.

    run ver-data.

message color normal
"As consultas de movimentacoes de estoque devem ser realizadas no SAP".
message "Apenas consultas de movimentações anteriores a " vdtsap " sao permitidas".
    
    if vdata2 >= vdtsap
        then vdata2 = vdtsap - 1.
        
    update vdata1 label "Periodo" 
           vdata2 validate(vdata2 < vdtsap,"Periodo nao permitido") no-label with frame f-pro.

    if day(vdata1) <> 1
    then vdata1 = date(month(vdata1),01,year(vdata1)).
    
    if vdata1 < 01/01/11 and vetbcod < 990
    then vdata1 = 01/01/11.
    disp vdata1 with frame f-pro.
    vdt = vdata1.
    
    /**
    if setbcod < 200
    then do:
        MESSAGE "Atencao : Este produto pode ter Movimentado o estoque"            ~              "nos ultimos 30 minutos!"                                       
            "Favor aguardar atualizacao p/executar a consulta."                 
            view-as alert-box.                                                  
                                                                                   MESSAGE 
    "Atencao :   Este produto pode ter Movimentacoes de Devolução de Venda," sk~ip 
    "que irao aparecer apos o encerramento dos Caixas e emissao de N.Fiscais" s~kip     "Tais Operacoes devem ser consideradas no Saldo Final do Produto!"    
           view-as alert-box.                                                  
    

    end. **/
    
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
    hide message no-pause.
    message "Processando Estab" vetbcod.
    for each tt-movest.
            delete tt-movest.
    end.        
    if vetbcod = 0
    then run movest11_semsaldo.p.
    else 
        if vetbcod = 981 
        then run movest11-e.p. 
        else run movest11.p.

    hide message no-pause.

    if vetbcod = 0
    then do:
        run extrato12semsaldo.p.
    end.    
    else do:
        run _extrato12_movimento.p.
    end.    

    
    
    
end.

procedure ver-data:
 
    def buffer bmovim for movim.
    def var vdata-8 as date.
    def var vdata-7 as date.
    
    find last bmovim where bmovim.procod = vprocod and
                          bmovim.emite  = 900 and
                          bmovim.movtdc = 8
                           no-lock no-error.
    if not avail bmovim
    then
    find last bmovim where bmovim.procod = vprocod and
                          bmovim.emite  = 993 and
                          bmovim.movtdc = 8
                           no-lock no-error.
    if avail bmovim 
    then vdata-8 = date(month(bmovim.datexp),01,year(bmovim.datexp)).

    find last bmovim where bmovim.procod = vprocod and
                          bmovim.desti  = 900 and
                          bmovim.movtdc = 7
                           no-lock no-error.
    if not avail bmovim
    then
    find last bmovim where bmovim.procod = vprocod and
                          bmovim.desti  = 993 and
                          bmovim.movtdc = 7
                           no-lock no-error.
    if avail bmovim 
    then vdata-7 = date(month(bmovim.datexp),01,year(bmovim.datexp)).
        
    if vdata-8 = ? and
       vdata-7 = ?
    then vdata1 = produ.prodtcad.    
    else if vdata-8 = ? and
            vdata-7 <> ?
        then vdata1 = vdata-7.
        else if vdata-8 <> ? and
                vdata-7 = ?
            then vdata1 = vdata-8.    
            else if vdata-8 > vdata-7
                then vdata1 = vdata-8.
                else vdata1 = vdata-7.
    vdata2 = today.
                         
end procedure.
