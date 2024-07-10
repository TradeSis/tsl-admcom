/*  cria triexporta.p    */
def input parameter par-tabela  as char.
def input parameter par-evento  as char.
def input parameter par-rec     as recid.


do on error undo.
    find first triexporta where
        triexporta.tabela   = par-tabela and
        triexporta.datatrig = today and
        triexporta.tabela-recid = par-rec 
    exclusive no-wait no-error.
    if not avail triexporta
    then do:
        create triexporta.
        ASSIGN triexporta.TABELA       = par-tabela 
               triexporta.DATATRIG     = today 
               triexporta.Tabela-Recid = par-rec.
    end.
    assign                
        triexporta.EVENTO       = par-evento 
        triexporta.HORATRIG     = time 
        triexporta.DATAEXP      = ? 
        triexporta.HORAEXP      = ? .
end.    
