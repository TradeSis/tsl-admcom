
def input parameter p-recid-neuclien as recid.
def input parameter p-tipoconsulta   as char.
def input parameter p-etbcod         as int.   
def input parameter p-cpf            as char.
def output parameter par-clicod like clien.clicod.
def output parameter vstatus     as char.

vstatus = "S".

    find neuclien where recid(neuclien) = p-recid-neuclien 
        no-lock
        no-error.
    if not avail neuclien
    then do:
        vstatus = "E".
        return.
    end.         
    par-clicod = neuclien.clicod. 
    if par-clicod <> ? 
    then do: 
        par-clicod = neuclien.clicod. 
        find clien where clien.clicod = par-clicod 
            no-lock no-error. 
        if not avail clien 
        then par-clicod = ?.      
    end.     
    if par-clicod = ?             
    then do:                   
        run /admcom/progr/p-geraclicod.p (output par-clicod). 
        do on error undo. 
            create clien. 
            assign 
                clien.clicod = par-clicod 
                clien.ciccgc = p-cpf
                clien.clinom = caps(neuclien.nome_pessoa) 
                clien.tippes = neuclien.tippes
                clien.dtnasc = neuclien.dtnasc 
                clien.etbcad = p-etbcod 
                clien.mae    = nome_mae.

           create cpclien. 
           assign  
            cpclien.clicod     = par-clicod 
            cpclien.var-char11 = ""
            cpclien.datexp     = today.
            
            vstatus = "S".    
            
            find current neuclien exclusive no-wait no-error.
            if avail neuclien
            then do:
                neuclien.clicod = par-clicod.
            end.
            
        end.  
    end.


