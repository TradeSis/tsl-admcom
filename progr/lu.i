def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def workfile wf-arq
    field arq as char format "x(50)".
def workfile warquivo
    field warq as char format "x(50)".

for each warquivo:
    delete warquivo.
end.

    dos silent dir value("..\import\*.cup") /s/b > ..\import\arq.
    input from ..\import\arq.
    repeat:
	create warquivo.
	import warq.
	dos silent quoter
	    value(warq) > value(substring(warq,1,(length(warq) - 1)) + "c").
    end.
    input close.

    for each warquivo:
	delete warquivo.
    end.

    dos silent dir value("..\import\*.cuc") /s/b > ..\import\arq.

    input from ..\import\arq.
    repeat:
	create warquivo.
	import warq.
    end.

    for each warquivo where warquivo.warq <> "" :
	vcont = 0.
	input from value(warq).
	repeat:
	    import vlinha.
	    vcont = vcont + 1.
	    if vcont = 1 and vlinha = ""
	    then do:
		create wf-arq.
		assign wf-arq.arq = warq.
	    end.
	end.
	input close.
    end.
    for each wf-arq:
	dos silent
	    value("del " +  substring(wf-arq.arq,1,(length(wf-arq.arq) - 1)) +
	    "p").
	dos silent value("del " + wf-arq.arq).
    end.
