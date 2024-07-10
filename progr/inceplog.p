def input parameter p-cep as char.
def output parameter p-ufecod like unfed.ufecod.
def output parameter p-locnum like munic.loc_num.
def output parameter p-bainum like bairro.codbai.
def output parameter p-lognum like ceplog.log_num.

def var  array as char format "x(40)" extent 10.
def var array-cod as char format "x(10)" extent 10.
def var cod as char extent 10.
def var cod2 as char extent 10.

def buffer bceplog for ceplog.
def temp-table tt-bairro like bairro.

def var campo as char extent 10.
def var aux-campo as char.
def var aux as char format "x(40)".
def var aux-cod as char format "x(10)".
def var i as i.
def var j as i.
def var vrow1 as int.
def var vrow2 as int.
def var vdown as int.
def var p-retorno as char.
form p-ufenom as char format "x(50)" label "Estado   "
     p-locnom as char format "x(50)" label "Municipio"
     p-bainom as char format "x(50)" label "Bairro   "
     p-lognom as char format "x(50)" label "Endereco "
     with frame f1 1 down side-label 
     row 4 width 80 overlay.
form with frame f2.
if p-cep <> ""
then find first ceplog where
                ceplog.log_cep = p-cep no-lock no-error.
if not avail ceplog
then do:                
    p-ufecod = "RS".
    {zoocep.in unfed unfed.ufecod ufenom
        12 p-ufenom true 69 unfed.ufecod 2 60 "unfed.ufecod >= p-ufecod" }
    if keyfunction(lastkey) = "END-ERROR"
    then return.
    p-ufecod = p-retorno.
    find first unfed where unfed.ufecod = p-ufecod no-lock.
    p-ufenom = unfed.ufenom.

    {zoocep.in munic munic.loc_num cidnom
        12 p-locnom "munic.ufecod = p-ufecod" 69 munic.loc_cep 8 60}
    if p-retorno <> ""
    then do:
        p-locnum = int(p-retorno).
        find first munic where munic.loc_num = p-locnum no-lock.
        p-locnom = munic.cidnom.
        disp with frame f1.
    end.
    else do:
        update p-locnom with frame f1.
    end.
    {zoocep.in bairro bairro.codbai nome 12
        p-bainom "bairro.loc_num = p-locnum" 69 bairro.codbai 8 60}
    if p-retorno <> ""
    then do:
        p-bainum = int(p-retorno).
        find first bairro where bairro.codbai = p-bainum no-lock.
        p-bainom = bairro.nome.
        disp p-bainom with frame f1.
    end.
    else do:
        update p-bainom with frame f1.
    end.    
    {zoocep.in ceplog ceplog.log_num log_no 12 
        p-lognom "ceplog.loc_num = p-locnum" 69 ceplog.log_cep 8 67}  
    if p-retorno <> "" 
    then do:
        p-lognum = int(p-retorno).
        find first ceplog where ceplog.log_num = p-lognum no-lock.
        p-lognom = ceplog.log_no.
        disp p-lognom with frame f1.
    end.
    else do:
        update p-lognom with frame f1.
    end.
end.    
else do:
    find first unfed where unfed.ufecod = ceplog.ufecod no-lock.
    p-ufecod = unfed.ufecod.
    p-ufenom = unfed.ufenom.
    disp p-ufenom with frame f1.
    find first munic where munic.loc_num = ceplog.loc_num no-lock.
    p-locnum = munic.loc_num.
    p-locnom = munic.cidnom.
    disp p-locnom with frame f1.
    find next ceplog where ceplog.log_cep = p-cep no-lock no-error.
    if avail ceplog
    then do:
        for each tt-bairro: delete tt-bairro. end.
        for each bceplog where bceplog.log_cep = p-cep no-lock:
            find bairro where bairro.codbai = bceplog.bai_num_ini
                            no-lock no-error.
            if not avail bairro then next.
            find first tt-bairro where 
                       tt-bairro.codbai = bairro.codbai no-error.
            if not avail tt-bairro
            then do:
                create tt-bairro.
                buffer-copy bairro to tt-bairro.
            end.
        end.
        {zoocep.in tt-bairro tt-bairro.codbai  tt-bairro.bainom  12 p-bainom 
            true 69 tt-bairro.codbai 8 60}
        if p-retorno <> ""
        then do:
            p-bainum = int(p-retorno).
            find first bairro where bairro.codbai = p-bainum no-lock.
            p-bainom = bairro.bainom.
            disp p-bainom with frame f1.
        end.
        else do:
            update p-bainom with frame f1.
        end.                          
        
        {zoocep.in ceplog ceplog.log_num log_no 
         12 p-lognom "ceplog.log_cep = p-cep" 69 ceplog.log_cep 8 67}  
        if p-retorno <> "" 
        then do:
            p-lognum = int(p-retorno).
            find first ceplog where ceplog.log_num = p-lognum no-lock.
            p-lognom = ceplog.log_no.
            disp p-lognom with frame f1.
        end.
        else do:
            update p-lognom with frame f1.
        end.
    end.
    else do:
        find first bairro where bairro.codbai = ceplog.bai_num_ini no-lock.
        p-bainum = bairro.codbai.
        p-bainom = bairro.bainom.

        find first ceplog where ceplog.log_cep = p-cep no-lock.
        p-lognum = ceplog.log_num.
        p-lognom = ceplog.log_no.
    end.        
end. 
hide frame f1 no-pause.
