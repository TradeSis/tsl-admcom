{admcab.i new}


def var vtitulo    as char.
def var vetbcod    as int.
def var vimporta-lista   as log format "Sim/Nao".
def var varq-lista as  char.
def var vlinha     as char.

form vetbcod format ">>9"          label "Fil"              at 07
     vtitulo format "x(15)"        label "Contrato"         at 02
        with frame f01 side-labels.

assign vimporta-lista = no.

message "Deseja importar uma lista com titulos para quitação?" update vimporta-lista.

if vimporta-lista
then do:

    assign varq-lista = "/admcom/work/".

    update varq-lista format "x(60)" label "Lista"
                with frame f-lista side-label .

    if search(varq-lista) = ?
    then do:
                                   
        message "Arquivo Não encontrado!"
                 view-as alert-box.
        undo, retry.
        
    end.
end.
else do:
    
    update vetbcod
            vtitulo
                with frame f01.
                
end.                

   
if vimporta-lista
then do:
    
    input from value(varq-lista).
       
    repeat:
           
       import vlinha.
       
       if entry(1,vlinha,";") = "FL" then next.
       
       display vlinha format "x(60)".
                 
       if num-entries(vlinha,";") >= 2
       then do:
           /*            
           find first tt-imp
                where tt-imp.etbcod = int(entry(1,vlinha,";"))
                  and tt-imp.numero = int(entry(2,vlinha,";"))
                                       no-lock no-error.
                                                  
           if not avail tt-imp
           then do:
                
               create tt-imp.
               assign tt-imp.etbcod = int(entry(1,vlinha,";"))
                      tt-imp.numero = int(entry(2,vlinha,";")).
                         
           end.
           */
                   
       end.
                           
    end.

end.
         
        
        
        
for each d.titulo where d.titulo.etbcod = vetbcod
                    and d.titulo.titnum = vtitulo
                    and d.titulo.titnat = no  
                            exclusive-lock by titpar.

    find first clien where clien.clicod = d.titulo.clifor
                            no-lock no-error.                    
                    
    find first fin.titulo where fin.titulo.empcod = d.titulo.empcod
                            and fin.titulo.titnat = d.titulo.titnat
                            and fin.titulo.modcod = d.titulo.modcod
                            and fin.titulo.etbcod = d.titulo.etbcod
                            and fin.titulo.CliFor = d.titulo.clifor
                            and fin.titulo.titnum = d.titulo.titnum
                            and fin.titulo.titpar = d.titulo.titpar
                                        no-lock no-error.

    display d.titulo.etbcod   column-label "Fil" format ">>9"
            d.titulo.titnum
            d.titulo.titdtemi
            d.titulo.titdtven
            d.titulo.titdtpag
            d.titulo.titpar format ">>9"
            d.titulo.clifor
            clien.clinom format "x(11)" when avail clien
            "*" when avail fin.titulo
                   and d.titulo.titdtpag = ?
                   and fin.titulo.titdtpag <> ?.
            
    if d.titulo.titdtpag = ?
        and avail fin.titulo
        and fin.titulo.titdtpag <> ?
    then do:
        
        sresp = no.
        
        message "Deseja quitar a parcela " d.titulo.titpar
                "no banco LP "      update sresp.
        
        if sresp
        then do:
            assign d.titulo.titdtpag = fin.titulo.titdtpag
                   d.titulo.datexp = fin.titulo.datexp
                   d.titulo.titvlpag = fin.titulo.titvlpag
                   d.titulo.titsit = fin.titulo.titsit.
            pause.
            display d.titulo.titdtpag.
            pause.
        end.   
    end.    
                    
end.


