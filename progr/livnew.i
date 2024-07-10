def var vliv as char.

if opsys = "UNIX"
then do:
    output to /admcom/import/data1.txt.
        os-command silent ls -lt ../connect/gerarel/livro.txt.
    output close.

    os-command silent 
        /usr/dlc/bin/quoter ../impot/data1.txt > ../import/data.txt.



    os-command silent rm -f ../import/data1.txt.

    if search("../import/data.txt") <> ? 
    then do:
    
        input from ../import/data.txt.
        repeat:
            import vliv.
        end.
        input close.
    
    end.
end.
else do:
    output to value("l:\import/data1.txt").
        os-command silent ls -lt value("l:\connect\gerarel\livro.txt").
    output close.

    os-command silent 
    c:\dlc\bin\quoter value("l:~\import~\data1.~txt") > value("l:~\import~\data.~txt").



    os-command silent rm -f value("l:\import\data1.txt").

    if search("l:\import\data.txt") <> ? 
    then do:
    
        input from value("l:\import\data.txt").
        repeat:
            import vliv.
        end.
        input close.
    
    end.
end.    
