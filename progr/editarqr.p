{admcab.i} 
def input parameter varqsai as char.
def var aux-anitai as int.
def var aux-anita1 as char.
def var aux-anita2 as char.
def var aux-anita3 as char.
def var aux-anita4 as char.
def var aux-anita5 as char.
if sretorno <> ""
then do:
    if sretorno <> "windows"
    then schave = sretorno.
    else schave = "".
    if opsys = "UNIX"
    then do: 
        run gera-fontes.
        
        aux-anita3 = "".
    
        do aux-anitai = 1 to num-entries(scabrel,"@"):
            if aux-anitai = 1
            then aux-anita1 = entry(1,scabrel,"@").
            else aux-anita3 = aux-anita3 + entry(aux-anitai,scabrel,"@") + "@".
        end.    

        aux-anita2 = if num-entries(aux-anita1,"/") > 1
                 then entry(num-entries(aux-anita1,"/"),aux-anita1,"/")
                 else if num-entries(aux-anita1,"~\") > 1
                      then entry(num-entries(aux-anita1,"~\"),aux-anita1,"~\")
                      else aux-anita1.
        /*unix silent sh value("./lp-criadir"),.
        */
        aux-anita4 = aux-anita2 + ".cab".
        aux-anita5 = aux-anita1 + ".cab".
        unix silent sh value("./imp-anita " +
                         aux-anita1 + " " + aux-anita2 + " " + 
                         aux-anita3 + " " + aux-anita4 + " " +
                         aux-anita5).
    end.
    else do:
        if schave <> ""
        then dos silent value("c:~\custom~\" + schave + " " + varqsai).
        else dos silent value("start " + varqsai).
    end.
end.
else if sretorno = ""
    then do:
        if opsys = "UNIX"
        then do:
            if schave = ""
            then do:
                output to ./imp .
                put unformatted
                    "mozilla $1 &" .
                output close.
                unix silent sh ./imp value(varqsai).    
            end.
            if schave = "ftp"
            then do:
                aux-anita1 = scabrel.
                aux-anita2 = if num-entries(aux-anita1,"/") > 1
                    then entry(num-entries(aux-anita1,"/"),aux-anita1,"/")
                    else if num-entries(aux-anita1,"~\") > 1
                      then entry(num-entries(aux-anita1,"~\"),aux-anita1,"~\")
                      else aux-anita1.
                do aux-anitai = 1 to num-entries(aux-anita1,"~\") - 1:
                    aux-anita3 = aux-anita3 + 
                            entry(aux-anitai,aux-anita1,"~\") + "~\".
                end.                 
                output to ./aniftp.txt .
                put unformatted
                    "user aud-ftp af030903 " skip
                    "binary    " skip
                    "prompt off  " skip
                    "lcd " aux-anita3 skip
                    "cd " varqsai skip
                    "get " aux-anita2 skip
                    "bye   " skip.
                output close.        
                output to ./aniftp.bat .
                put unformatted
                    "cd c:~\ " skip
                    "ftp -n -s:aniftp.txt database " skip
                    .
                output close.
                
                output to ./ftp-anita   .
                put unformatted     
                    "pcname=~"C:/aniftp.txt~""           skip 
                    "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
                    "echo -e ~"~\033~[3;1i~\c~""            skip      
                    "cat aniftp.txt"                             skip   
                    "echo -e ~"~\033~[4i~\c~""              skip
                    "pcname=~"C:/aniftp.bat~""           skip 
                    "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
                    "echo -e ~"~\033~[3;1i~\c~""            skip      
                    "cat aniftp.bat"                             skip   
                    "echo -e ~"~\033~[4i~\c~""              skip
                    "echo -e ~"~\033~[1yc:/aniftp.bat ~\033~\0134~"" skip 
                    .
                output close.
                unix silent sh value("./ftp-anita").
                sparam = varqsai + aux-anita2.
            end.
        end.
        else do:
            dos silent c:/custom/imp value(scabrel).
        end.
    end.

procedure gera-fontes:
        output to ./criadir.bat .
        put unformatted 
            "cd c:~\" skip
            "mkdir %1".
        output close.
        
        output to ./editstr.bat .
        put unformatted 
            "cd c:~\" skip
            "del criadir.bat" skip
            "start %1".
        output close.
        
        output to ./executa.bat .
        put unformatted 
            "@echo off" skip
            "if exist c:~\custom~\imp.exe c:~\custom~\imp.exe %1" skip
             /*c:~\temp~\anita.d~ ef" skip*/
            "if not exist c:~\custom~\imp.exe start %1" skip
            .
        output close.
        /**
        output to ./lp-criadir .
        put unformatted
            "pcname~=~"C:/criadir.bat~""           skip 
            "echo ~-e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
            "echo ~-e ~"~\033~[3;1i~\c~""            skip      
            "cat criadir.bat"                             skip   
            "echo -e ~"~\033~[4i~\c~""              skip
            "echo -e ~"~\033~[1yc:/criadir.bat ~"temp~" ~\033~\0134~"" skip
             .
        output close.
        **/
        output to ./lp-anita   .
        put unformatted     
            "pcname=~"C:/temp/executa.bat~""           skip 
            "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
            "echo -e ~"~\033~[3;1i~\c~""            skip      
            "cat executa.bat"                             skip   
            "echo -e ~"~\033~[4i~\c~""              skip
            "pcname=~"C:/temp/editstr.bat~""           skip 
            "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
            "echo -e ~"~\033~[3;1i~\c~""            skip      
            "cat editstr.bat"                             skip   
            "echo -e ~"~\033~[4i~\c~""              skip
            "echo -e ~"c:/temp/$2@~\c~" > temp.def" skip
            "echo -e ~"$3 ~\c~" >> temp.def" skip
            "pcname=~"C:/temp/anita.def~"" skip            
            "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~"" skip 
            "echo -e ~"~\033~[3;1i~\c~""     skip             
            "cat temp.def"             skip                    
            "echo -e ~"~\033~[4i~\c~""        skip            
            "pcname=~"C:/temp/$2~""           skip 
            "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
            "echo -e ~"~\033~[3;1i~\c~""            skip      
            "cat $1" skip 
            "echo -e ~"~\033~[4i~\c~""        skip
           /* "pcname=~"C:/temp/$4~""           skip 
            "echo -e ~"~\033~[13y$~{pcname~}~\033~\0134~\c~""  skip
            "echo -e ~"~\033~[3;1i~\c~""            skip      
            "cat $5"             skip*/
            "echo -e ~"~\033~[4i~\c~""              skip.
        if schave <> ""
        then put
            "echo -e ~"~\033~[1yc:/custom/" + schave + " c:/temp/~$2 ~\033~\0134~"" 
            format "x(75)" skip 
            .
        else put
        "echo -e ~"~\033~[1yc:/temp/executa.bat c:/temp/~$2 ~\033~\0134~ ~"
" skip .     
        /*
  "echo -e ~"~\033~[1yc:/temp/executa.bat c:/temp/temp.def ~\033~\0134~ ~"
            " skip .  */   
            
            /*
            "echo -e ~"~\033~[1yc:/temp/executa.bat c:/temp/~$2 ~\033~\0134~ ~"
" skip .      */
        output close.
        
end procedure.