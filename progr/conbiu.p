{admcab.i}
def var vdata like plani.pladat.
def var vconta as int format "9999999999".
def temp-table tt-chq
    field rec  as recid
    field tot  like plani.platot
    field arq  as char
    field ord  as int.
def var varquivo as char.    
        
    
    
def var varqsai as char.
def var varqsai2 as char.
      
def var i-cont as int.

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".

def var vdtmov      as date format "99/99/9999".
def var vtotvalor   like fin.chq.valor.
def var par-agencia         like fin.chq.agencia.
def var par-conta           like fin.chq.conta.
def var par-seqdia          as   int.
def var par-codempresa      as char format "xxxx".
def var par-convenio        as char format "xx".
def var par-codarquivo      as char format "xxxxxx".
def var par-ageapres        as int  format "9999".
def var par-today           as date format "99/99/9999".
def var xx as int.
def var varq as char.
def var vv as int.
def temp-table tt-ord
    field arq as char
    field seq as int.
        
repeat:

    for each tt-chq:
        delete tt-chq.
    end.
    
    for each tt-ord:
        delete tt-ord.
    end.


    vv = 0.
    vdata = today.
    update vdata label "Data de Envio" with frame f1 side-label centered.
    
    varqsai   = "../banrisul/" + 
                string(day(vdata),"99") + 
                string(month(vdata),"99") + 
                string(year(vdata),"9999") + ".txt".
        
    if search(varqsai) = ?
    then do:
        message "Arquivo nao encontrato".
        pause.
        undo, retry.
    end.
            
    
    input from value(varqsai). 
    repeat:

        import varq.   
        find chq where recid(chq) = int(substring(varq,1,10))
                                    no-lock no-error.
        if avail chq 
        then do: 
            find first tt-chq where tt-chq.rec = recid(chq) no-error. 
            if not avail tt-chq 
            then create tt-chq. 
            assign tt-chq.rec = recid(chq)  
                   tt-chq.tot = dec(substring(varq,11,15))  
                   tt-chq.arq = substring(varq,38,12).
                   
            find first tt-ord where tt-ord.arq = tt-chq.arq no-error.
            if not avail tt-ord
            then do:
                vv = vv + 1.
                create tt-ord.
                assign tt-ord.arq = tt-chq.arq
                       tt-ord.seq = vv.
            end.
        end.
    end.         
    input close.

    
    varquivo = "../relat/biu." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "0"
        &Nom-Rel   = ""conbiu""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """LISTAGEM DE CHEQUES BANRISUL DIA: "" +
                         string(vdata,""99/99/9999"")"
       &Width     = "147"
       &Form      = "frame f-cabcab"}
    
    
    for each tt-ord by tt-ord.seq: 
        for each tt-chq where tt-chq.arq = tt-ord.arq,
            each chq where recid(chq) = tt-chq.rec
                            no-lock break by tt-chq.arq
                                          by chq.valor:
            
            display chq.banco 
                    chq.agencia format ">>>>9"
                    chq.conta   format "x(15)" 
                    chq.numero 
                    chq.valor(total by tt-chq.arq) 
                    tt-chq.tot column-label "Total Lote"
                    tt-chq.arq(count by tt-chq.arq) format "x(12)"
                        with frame f3 down width 130.
        end.
    end.
    output close.
    {mrod.i} 
end.  
