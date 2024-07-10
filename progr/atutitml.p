
def input parameter vlog1 as char.


disable triggers for load of fin.titulo.
disable triggers for load of finmatriz.titulo.

{admdisparo.i}


 
def temp-table tit-rec
    field rec as recid
    field exportado as log.

def buffer btit-rec for tit-rec.

def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
 
def buffer btitulo for finmatriz.titulo.

def var i as int.

def var cont as int.
def var vlocado as log.


input from /usr/admcom/progr/servidor.txt.
repeat :
    create ttservidor.
    import ttservidor.
end.
input close.


output to value(vlog1) append.
    put  skip "atutitml.p - Mat titulo "  string(time,"hh:mm:ss") skip.
output close.

cont = 0.
    
    
do.

    cont = 0.
    for each tit-rec.
        delete tit-rec.
    end.
     
    for each ttservidor where ttservidor.servidor = setbcod no-lock,
        
        each btitulo where 
                 btitulo.exportado = no and 
                 btitulo.etbcod = ttservidor.etbcod
                 no-lock
             use-index exportado. 

            create btit-rec.
            assign
                btit-rec.exportado = 
                        if btitulo.titnat = yes
                        then  yes
                        else if btitulo.etbcobra = ttservidor.etbcod
                             then yes
                             else no.

            btit-rec.rec = recid(btitulo).

            cont = cont + 1. 
        
        
    
    end.
            
    output to value(vlog1) append.
    put  skip "atutitml.p - Mat titulo SERAO " cont " " 
            string(time,"hh:mm:ss") skip.
    output close.
    
    cont = 0.
    

    repeat transaction.

        find next tit-rec no-error.
        if not avail tit-rec
        then leave.
        
        
        cont = cont + 1.

        find finmatriz.titulo where 
                recid(finmatriz.titulo) = tit-rec.rec
            exclusive  no-error.
                  
 
        if avail finmatriz.titulo
        then do:
            if tit-rec.exportado
            then do:
                assign
                    finmatriz.titulo.exportado = yes.
                next.    
            end.
        end.
                 
        cont = cont + 1.
 
        if not avail finmatriz.titulo
        then do:
            
            if locked finmatriz.titulo
            then do:
                cont = cont - 1.
                output to value(vlog1) append.
                put  skip "atutitml.p - Im titulo Locado "  cont skip.
                output close.
            
                next.
            end.            
            leave.
        
        end.
   
        do: 
            find first fin.titulo where 
                       fin.titulo.empcod = finmatriz.titulo.empcod
                   and fin.titulo.titnat = finmatriz.titulo.titnat 
                   and fin.titulo.modcod = finmatriz.titulo.modcod 
                   and fin.titulo.etbcod = finmatriz.titulo.etbcod 
                   and fin.titulo.clifor = finmatriz.titulo.clifor 
                   and fin.titulo.titnum = finmatriz.titulo.titnum 
                   and fin.titulo.titpar = finmatriz.titulo.titpar
                   exclusive    no-error.
            if not avail fin.titulo
            then do:
                
                if locked fin.titulo
                then next.
                
                create fin.titulo.
            end.                

            if fin.titulo.titsit <> "PAG" 
            then do :
                {tt-titulo.i fin.titulo finmatriz.titulo}.
            end.    

            assign 
                fin.titulo.exportado       = yes.
                
            /*    
            if fin.titulo.titsit   = finmatriz.titulo.titsit and
               fin.titulo.titvlcob = finmatriz.titulo.titvlcob and 
               fin.titulo.titdtpag = finmatriz.titulo.titdtpag 
            then 
            */
                finmatriz.titulo.exportado = yes.
            
        end.    
    
        if cont mod 100 = 0 
        then do:
            output to value(vlog1) append.
            put  skip "Atutitml.p - Mat titulo  "  
                  string(time,"hh:mm:ss") " " cont " Ok" skip.
            output close.
        end.
    
    end.
    
    
    output to value(vlog1) append.
    put  skip "Atutitml.p - Mattitulo  "  
              string(time,"hh:mm:ss") " " cont " Encerrado" skip.
    output close.

end.



