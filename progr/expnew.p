{admcab.i}

def var vetbcod like estab.etbcod.
def var vforcod like forne.forcod.
def var vpedtdc like pedid.pedtdc.
def var vsemipi like plani.platot.  
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vpednum like pedid.pednum.
def var vseq    as int.

repeat:

    assign vdti = today
           vdtf = today
           vpednum = 0
           vetbcod = 996
           vpedtdc = 01
           vforcod = 5027
           vseq = 0.
           
    update vpednum label "Pedido "
           vdti    label "Periodo"
           vdtf    no-label 
                with frame f1 side-label width 80.

 
    output to l:\newfree\ordempedido.txt.
    if vpednum <> 0
    then do:
        find pedid where pedid.etbcod = vetbcod and
                         pedid.pedtdc = vpedtdc and
                         pedid.pednum = vpednum no-lock no-error.
        if not avail pedid
        then do:
            message "Pedido nao cadastrado".
            pause.
            undo, retry.
        end.
           
        for each liped of pedid no-lock:
                                
            vseq = vseq + 1.
            vsemipi = 0.
            vsemipi = (liped.lippreco - 
                      (liped.lippreco * (pedid.nfdes / 100))).
                     
            find produ where produ.procod = liped.procod no-lock no-error.
            if not avail produ
            then next.
            
            put "1  "                                  /* empresa         */
                "1  "                                  /* filial new free */
                string(pedid.pednum)    format "x(20)" /* numero pedido   */
                string(liped.procod)    format "x(20)" /* produto         */
                string(produ.prorefter) format "x(20)" /* referencia      */
                "          "                           /* cor             */
                "          "                           /* cor referencia  */
                "     "                                /* tamanho         */
                "                    "                 /* variacao        */
                dec(liped.lipqtd) format "999999999999999" /* quantidade  */
                pedid.peddat      format "99/99/9999"  /* data pedido     */
                pedid.peddti      format "99/99/9999"  /* prazo inicial   */
                pedid.peddtf      format "99/99/9999"  /* prazo final     */
                vsemipi           format "999999999999999" /* Vl. sem IPI */
                "000000"           
                "000000000000000" 
                produ.pronom      format "x(50)"       /* nome produto    */
                vseq              format "999999"      /* sequencial      */
                    skip.
        end.
        
    end.
    else do:
    
        for each pedid where pedid.etbcod = vetbcod  and
                             pedid.pedtdc = vpedtdc  and
                             pedid.clfcod = vforcod  and
                             pedid.peddat >= vdti    and
                             pedid.peddat <= vdtf no-lock:
            vseq = 0.
        
            for each liped of pedid no-lock:
                                
                vseq = vseq + 1.
                vsemipi = 0.
                vsemipi = (liped.lippreco - 
                          (liped.lippreco * (pedid.nfdes / 100))).
                     
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
            
                put "1  "                                  
                    "1  "                                  
                    string(pedid.pednum)    format "x(20)" 
                    string(liped.procod)    format "x(20)" 
                    string(produ.prorefter) format "x(20)" 
                    "          "                           
                    "          "                           
                    "     "                                
                    "                    "                 
                    dec(liped.lipqtd) format "999999999999999" 
                    pedid.peddat      format "99/99/9999" 
                    pedid.peddti      format "99/99/9999"  
                    pedid.peddtf      format "99/99/9999"  
                    vsemipi           format "999999999999999" 
                    "000000"           
                    "000000000000000" 
                    produ.pronom      format "x(50)"   
                    vseq              format "999999"  skip.
            end.
        
        end.
    
    end.
    output close.
    if vseq = 0
    then message "Nenhum registro encontrado".
    else message "Exportacao Concluida: l:\newfree\ordempedido.txt".
    pause.
end.
    
