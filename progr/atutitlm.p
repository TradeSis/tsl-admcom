/********************/


def input parameter vlog1 as char.

disable triggers for load of fin.titulo.
disable triggers for load of finmatriz.titulo.

{admdisparo.i}


def new shared temp-table tt-titulo like fin.titulo.
 
def temp-table tit-rec
    field rec as recid.
def buffer btit-rec for tit-rec.

def var vdragao as log.
    
def buffer btitulo for fin.titulo.

def var i as int.

def var cont as int.
def var vlocado as log.

output to value(vlog1) append.
    put  skip "Atufin.p - Im titulo "  string(time,"hh:mm:ss") skip.
output close.

cont = 0.
    
    
do.

    cont = 0.
    for each tit-rec.
        delete tit-rec.
    end.
    
    for each btitulo where
            btitulo.exportado = no
        no-lock.

        cont = cont + 1.
        create btit-rec.
        assign
            btit-rec.rec = recid(btitulo).

    end.
    
    output to value(vlog1) append.
    put  skip "Atufin.p - Im titulo SERAO " cont " " string(time,"hh:mm:ss")     skip.
    output close.

    
    cont = 0.
    
repeat transaction: /* Loja para Matriz */

    find next tit-rec no-error.
    
    if not avail tit-rec
    then leave.
    
    find fin.titulo where
            recid(fin.titulo) = tit-rec.rec
        exclusive no-wait no-error.

    cont = cont + 1.
        
    if not avail titulo
    then do:
        if locked titulo
        then do:
    
            output to value(vlog1) append.
            put  skip "Atufin.p - Im titulo Locado "  cont skip.
            output close.
            
            next.
        end.            
        next.
    end.
        
    do: 
    
        if cont mod 100 = 0 or
           cont <= 2
        then do:
            output to value(vlog1) append.
            put  skip "Atufin.p - Im titulo  "  
                        string(time,"hh:mm:ss") " " cont skip.
            output close.
        end.
    
        vlocado = no.
        vdragao = no.
        
        find finmatriz.titulo where 
             finmatriz.titulo.empcod  = fin.titulo.empcod and
             finmatriz.titulo.titnat  = fin.titulo.titnat and
             finmatriz.titulo.modcod  = fin.titulo.modcod and
             finmatriz.titulo.etbcod  = fin.titulo.etbcod and
             finmatriz.titulo.clifor  = fin.titulo.clifor and
             finmatriz.titulo.titnum  = fin.titulo.titnum and
             finmatriz.titulo.titpar  = fin.titulo.titpar  
            exclusive no-wait no-error.
        if not avail finmatriz.titulo
        then do:
            if locked finmatriz.titulo
            then vlocado = yes.
            else vlocado = no.
        end.
        
        if vlocado 
        then do:
            output to value(vlog1) append.
            put  skip "Atufin.p - Im titulo Locado na Matriz "  cont skip.
            output close.
            next.
        end.        
        
        if not avail finmatriz.titulo 
        then do:
            
            if fin.titulo.clifor <> 1    and
               fin.titulo.titsit = "PAG" and
               fin.titulo.titpar <> 0
            then do:
                find finmatriz.titexporta where  
                            finmatriz.titexporta.empcod  = fin.titulo.empcod and
                            finmatriz.titexporta.titnat  = fin.titulo.titnat and
                            finmatriz.titexporta.modcod  = fin.titulo.modcod and
                            finmatriz.titexporta.etbcod  = fin.titulo.etbcod and
                            finmatriz.titexporta.clifor  = fin.titulo.clifor and
                            finmatriz.titexporta.titnum  = fin.titulo.titnum and
                            finmatriz.titexporta.titpar  = fin.titulo.titpar and
                            finmatriz.titexporta.datexp  = fin.titulo.datexp
                           exclusive no-error. 
                if not avail finmatriz.titexporta
                then do:
                   create finmatriz.titexporta.
                   {tt-titexporta.i finmatriz.titexporta fin.titulo}. 
                end.
            end.
            find first flag where flag.clicod = fin.titulo.clifor 
                        no-lock no-error.
            if avail flag and flag.flag1 = yes
            then do:
                if setbcod <> 32
                then do :
                    output to value(vlog1) append.
                    put  skip "Atufin.p - Im titulo Dragao "  
                          flag.flag1
                          fin.titulo.titnum "/"
                          fin.titulo.titpar " Cli "
                          fin.titulo.clifor " " 
                        string(time,"hh:mm:ss") cont skip.
                    output close.
                    for each tt-titulo.
                        delete tt-titulo.
                    end.
                    
                    raw-transfer fin.titulo to tt-titulo.
                    
                    run cardrag.p(recid(tt-titulo)).
                    vdragao = yes.

                    hide message no-pause.
                end.    
            end.
            else do:
                create finmatriz.titulo.
                {tt-titulo.i finmatriz.titulo fin.titulo}.
            end.
        end.
        else do:
            if finmatriz.titulo.titsit <> "PAG"
            then {tt-titulo.i finmatriz.titulo fin.titulo}.
        end.
        if avail finmatriz.titulo
        then do :
            if fin.titulo.titdtpag <> ? and
                finmatriz.titulo.titdtpag <> ?
            then do:
                if fin.titulo.titdtpag <> finmatriz.titulo.titdtpag or
                   fin.titulo.titvlpag <> finmatriz.titulo.titvlpag or
                   fin.titulo.etbcobra <> finmatriz.titulo.etbcobra
                then do:
                    create finmatriz.titexporta.
                    {tt-titexporta.i finmatriz.titexporta fin.titulo}.
                end.
            end.
        end.    
        if avail finmatriz.titulo
        then do : 
            if finmatriz.titulo.etbcod = setbcod
            then finmatriz.titulo.exportado = yes.
            else finmatriz.titulo.exportado = no.
        end.
        
        do:
            if avail finmatriz.titulo or
               vdragao or
               avail finmatriz.titexporta
            then fin.titulo.exportado = yes.

        end.    
            
    end.

    if cont mod 100 = 0 
    then do:
        output to value(vlog1) append.
        put  skip "Atufin.p - Im titulo  "  
              string(time,"hh:mm:ss") " " cont " Ok" skip.
        output close.
    end.
    
end.


output to value(vlog1) append.
put  skip "Atufin.p - Im titulo  "  
          string(time,"hh:mm:ss") " " cont " Encerrado" skip.
output close.

end.



