output to /admcom/work8/clien.d.
for each clien where datexp > 01/01/2002:
    if substring(string(clicod),7,2) = "55" then
        export clien.
    end.
output close.