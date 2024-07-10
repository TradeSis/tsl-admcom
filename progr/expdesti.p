{admcab.i}
def var vempcod like lfcad.empcod.

repeat:

    update vempcod with frame f1 side-label width 80.
    
    message "Deseja gerar arquivo" update sresp.
    
    if sresp = no
    then undo, retry.
    
    output to m:\livros\sccli.exp.
    for each lfcad where empcod = vempcod no-lock.
    
        put lfcad.Codigo      format "99999"
            lfcad.Nome    
            lfcad.Ender   
            lfcad.Municipio  
            lfcad.Cep        
            lfcad.Uf         
            lfcad.Cgc        
            lfcad.Insc       
            lfcad.Ativ-Econ   format "9999999"  
            lfcad.Contrib     format "9"
            lfcad.Cod-Cont   
            lfcad.Flag-Cont 
            "                          " skip.
     end.
     output close.
end.     
     
     
            
