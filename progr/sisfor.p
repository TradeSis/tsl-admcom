{admcab.i}
def var vdata like plani.pladat.
def var vdt   like plani.pladat.
def var ii as int.
def var vv as int.
def var cgc-admcom like forne.forcgc.
def var v-rua   like forne.forrua.
def var v-mun   like forne.formunic.
def var v-ufe   like forne.ufecod.
def var v-cep   like forne.forcep.
def var v-bai   like forne.forbairro.
def var varq as char.

repeat:

    update vdt label "Fornecedores cadastrados a partir de"
                with frame f1 side-label width 80.

    if opsys = "UNIX"
    then varq = "../sispro/fornecedores/forne" + 
                string(day(vdt),"99") + string(month(vdt),"99") +
                string(year(vdt),"9999") + ".txt".
    else varq = "..~\sispro~\fornecedores~\forne" + 
                string(day(vdt),"99") + string(month(vdt),"99") +
                string(year(vdt),"9999") + ".txt".
            
output to value(varq).

put unformatted "H"  
    "01"  format "x(16)" 
    string(day(today),"99") format "99" 
    string(month(today),"99") format "99" 
    string(year(today),"9999") format "9999" 
    substring(string(time,"HH:MM:SS"),1,2)  format "99"  
    substring(string(time,"HH:MM:SS"),4,2)  format "99"   
    substring(string(time,"HH:MM:SS"),7,2)  format "9999"  
    " " format "x(237)" skip.
     
for each forne no-lock by forne.forcod desc.

    if forne.fordtcad < vdt
    then next. 
    
    assign v-rua = forne.forrua
           v-mun = forne.formunic
           v-ufe = forne.ufecod
           v-cep = forne.forcep
           v-bai = forne.forbairro.

    if v-rua = "" or
       v-mun = "" or
       v-ufe = "" or
       v-cep = "" or
       v-bai = ""
    then assign v-rua = ""
                v-mun = ""
                v-ufe = ""
                v-cep = ""
                v-bai = "".
        
    cgc-admcom = forne.forcgc.
    vv = 0.  
    do vv = 1 to 18:    
        if substring(cgc-admcom,vv,1) = "-" or 
           substring(cgc-admcom,vv,1) = "." or                     
           substring(cgc-admcom,vv,1) = "r" or 
           substring(cgc-admcom,vv,1) = "r"  
        then substring(cgc-admcom,vv,1) = "".
    
    end.
    if forne.fordtcad = ?
    then vdata = 01/01/2000.
    else vdata = forne.fordtcad.
   
    put unformatted 
        "P"  
        "01"  format "x(16)"
        string(day(today),"99") format "99" 
        string(month(today),"99") format "99" 
        string(year(today),"9999") format "9999" 
        substring(string(time,"HH:MM:SS"),1,2)  format "99" 
        substring(string(time,"HH:MM:SS"),4,2)  format "99"  
        substring(string(time,"HH:MM:SS"),7,2)  format "99" 
        string(forne.forcod) format "x(20)"
        forne.fornom         format "x(40)"  
        v-rua                format "x(30)"       
        v-bai                format "x(30)" 
        v-mun                format "x(30)" 
        v-ufe                format "x(02)"   
        v-cep                format "x(08)"   
        "J"                  format "x(01)"
        cgc-admcom           format "x(14)" 
        forne.forinest       format "x(20)"
        forne.forfone        format "x(14)"
        forne.forfax         format "x(14)"
        string(day(vdata),"99") format "99" 
        string(month(vdata),"99") format "99" 
        string(year(vdata),"9999") format "9999" 
        "31122099" format "x(08)" skip 
        "E" 
        "01"  format "x(16)"
        string(day(today),"99") format "99" 
        string(month(today),"99") format "99" 
        string(year(today),"9999") format "9999" 
        substring(string(time,"HH:MM:SS"),1,2)  format "99" 
        substring(string(time,"HH:MM:SS"),4,2)  format "99"  
        substring(string(time,"HH:MM:SS"),7,2)  format "99" 
        string(forne.forcod) format "x(20)"
        "             FOR"
        " " format "x(203)" 
        skip.
        
end.    

put unformatted 
    "T" 
    "01"  format "x(16)" 
    string(day(today),"99") format "99"  
    string(month(today),"99") format "99"  
    string(year(today),"9999") format "9999"  
    substring(string(time,"HH:MM:SS"),1,2)  format "99"  
    substring(string(time,"HH:MM:SS"),4,2)  format "99"   
    substring(string(time,"HH:MM:SS"),7,2)  format "99"  
    " " format "x(255)" 
    skip.

output close.

message color red/with
    "Arquivo gerado " varq
    view-as alert-box  .
    
    leave.
end.


                   