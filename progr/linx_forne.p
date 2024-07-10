def input parameter par-arq as char.


 pause 0 before-hide.
def temp-table tt_forne
    field NOME_CLIFOR   as char
    field RAZAO_SOCIAL  as char
    field CGC_CPF       as char
    field ENDERECO      as char
    field CIDADE        as char
    field UF            as char.
def var v as int.
input from value(par-arq).
repeat.
    create tt_forne.
    import delimiter ";" tt_forne.
    v = v + 1. 
    if v = 1 then  next.
    
    find first forne where forne.forcgc = CGC_CPF no-lock no-error.
    
    tt_forne.RAZAO_SOCIAL = trim(tt_forne.RAZAO_SOCIAL).
    
    .
    if not avail forne
    then do.
        def var vforcod as int.
        def buffer bforne for forne.
        find last bforne exclusive-lock no-error. 
        if available bforne 
        then assign vforcod = bforne.forcod + 1. 
        else assign vforcod = 1.  
        /*
        find forne where forne.fornom = caps(tt_forne.NOME_CLIFOR)
                                    no-error.
            */
        find forne where forne.fornom = caps(tt_forne.RAZAO_SOCIAL) no-error.
        if not avail forne
        then do.
            create forne.
            assign forne.forcod   = vforcod.
        end.
        assign forne.forfan   = caps(tt_forne.NOME_CLIFOR)   
               forne.fornom   = caps(tt_forne.RAZAO_SOCIAL)
               forne.forcgc   = caps(tt_forne.CGC_CPF)       
               forne.forrua   = caps(tt_forne.ENDERECO)      
               forne.formunic = caps(tt_forne.CIDADE)         
               forne.livcod = ?
               forne.ufecod   = caps(tt_forne.UF)           .
    end.
    else do.
        find first forne where forne.forcgc = CGC_CPF
                    exclusive no-wait 
                    no-error.
            if not locked forne
            then do.
                assign forne.forfan   = caps(tt_forne.NOME_CLIFOR)
                       forne.fornom   = caps(tt_forne.RAZAO_SOCIAL)
                       forne.forcgc   = caps(tt_forne.CGC_CPF)
                       forne.forrua   = caps(tt_forne.ENDERECO)
                       forne.formunic = caps(tt_forne.CIDADE)
                       forne.ufecod   = caps(tt_forne.UF).
            end.
    end.
    if not avail forne then next.
    find first depara_clifor where 
                depara_clifor.nome_clifor = tt_forne.NOME_CLIFOR
                no-error.
    if not avail depara_clifor
    then create depara_clifor.
    ASSIGN depara_clifor.nome_clifor = tt_forne.NOME_CLIFOR
           depara_clifor.codigo      = forne.forcod.
    if depara_clifor.codigo = ?
    then pause 2.
end.    
