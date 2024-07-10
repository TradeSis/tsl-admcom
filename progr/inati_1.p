{admcab.i}
def var v-dtven like plani.pladat.
def var vetbcod like estab.etbcod.
def var vdata_1 like plani.pladat.
def var vdata_2 like plani.pladat.
def var vdtf as date label "Data Final" format "99/99/9999".
def var vfre as i label "Frequencia".
def var vtot as dec label "Valor Total".
def var vqtd as i label "Listados".
def var vtkm as dec label "Ticket Medio".
def var q as i.
def var varquivo as char.
def var dia-atr  as int format ">>9".
def var ii as int.


def var d as date.

def new shared temp-table tt-dados
    field clicod like clien.clicod
    field freq as int
    field vltot as dec
    field etique as log
        index iclicod clicod.

repeat:

    for each tt-dados:
        delete tt-dados.
    end.
    
    dia-atr = 15.
    
    update vetbcod colon 20
           vdata_1 colon 20  label "NÆo Compra Desde"
           vdata_2 colon 20  label "NÆo Paga   Desde"
           dia-atr colon 20 label "Ate "  " dias de atraso" 
                with frame f1 centered side-label.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:

        for each clien where 
                int(substring(string(clien.clicod),7,2)) = estab.etbcod no-lock.

            if clien.clicod < 10000000 or
               clien.clicod > 99999999
            then next.
            
            
            find last contrato where contrato.etbcod = estab.etbcod and
                                     contrato.clicod = clien.clicod
                                           no-lock no-error.
            if not avail contrato or
               contrato.dtinicial > vdata_1 
            then next.
 
            find last titulo where titulo.clifor    = clien.clicod and
                                   titulo.titsit    = "PAG"        and
                                   titulo.titdtpag  > vdata_2 no-lock no-error.
            if avail titulo
            then next.
                                   


            v-dtven = today.
            for each titulo use-index iclicod
                        where titulo.clifor = clien.clicod and
                              titulo.titnat = no              and
                              titulo.titsit = "LIB" no-lock.
                          
           
                if titulo.titdtven < v-dtven
                then v-dtven = titulo.titdtven.
        
            end. 
        
            if (today - v-dtven) > dia-atr
            then do:
                 next.
            end.
     
            
            
            
            find first tt-dados where tt-dados.clicod = clien.clicod no-error.
            if not avail tt-dados
            then do: 
                create tt-dados.
                assign tt-dados.clicod = clien.clicod.
            end.


        end.
    end.
     
    


    q = 0.

    
    varquivo = "..\relat\inati" + string(time).
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""inati_01""
            &Nom-Sis   = """CLIENTES INATIVOS"""
            &Tit-Rel   = """FILIAL - "" + string(vetbcod)" 
            &Width     = "80"
            &Form      = "frame f-cabcab"}

 
    for each tt-dados by tt-dados.clicod descending:
        
        find clien where clien.clicod = tt-dados.clicod no-lock no-error.

        q = q + 1.


        disp tt-dados.clicod(count) column-label "Codigo" 
             clien.clinom column-label "Nome" 
               with frame f5 down overlay row 5 width 130.


    end.
    output close.
    
    {mrod.i}
    
    
    
    /*
    message "Gerar arquivo de etiquetas" update sresp.
    if sresp
    then do:
    
        ii = 0.
        for each tt-dados:
 
            if tt-dados.etique 
            then ii = ii + 1. 

            display "Gerando clientes p/ mala direta...." ii no-label
                    with 1 down row 15 centered.
            pause 0.
                   
        end.
        
        run market_e.p(input vetbcod).
        
        
    end.
    */
    
end.

