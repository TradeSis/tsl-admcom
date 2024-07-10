def var varq as char.
def var sparam as char.
def var varquivo as char.
def var vesc as char extent 4 format "x(18)".
def var vsc as char format "x(3)".
def var vsep as char init "|" format "x".

assign vesc[1] = "PRODUTOS/SERVICOS "
       vesc[2] = "CODIGOS DE RECEITA"
       vesc[3] = "   PROCESSOS      "
       vesc[4] = "   PARTICIPANTES  ".

def var vindex as int.
def var vi as int.

sparam = SESSION:PARAMETER.

if num-entries(sparam,";") > 1 then 
    sparam = entry(2,sparam,";").

if opsys = "unix" and sparam = "AniTA"
then    
repeat:
    vindex = vindex + 1.
    disp vesc no-label with frame f-esc 1 down centered width 80.
    choose field vesc with frame f-esc.
    
    vindex = frame-index.

    case vindex:
        when 1 then vsc = "TQ_CITEM".
        when 2 then vsc = "TQ_CITEMCODIGORECEITA".
        when 3 then vsc = "TQ_CITEMPARTPROCADMJUD".
        when 4 then vsc = "TQ_CITEMPARTICIPANTE".
        otherwise leave.
    end case.            
        

    if opsys = "unix" then 
        varquivo = "/admcom/decision/serv_" 
                 + vsc  
                 /*+ "_"
                 + string(day(today),"99")
                 + string(month(today),"99")
                 + string(year(today),"9999")
                 + "_"
                 + string(time)*/
                 + ".txt".
    
    output to value(varquivo).
        case vindex:
            when 1 then run pi-exp-tq-citem.
            when 2 then run pi-exp-tq-citemcodigoreceita.
            when 3 then run pi-exp-tq-citempartprocadmjud.
            when 4 then run pi-exp-tq-citemparticipante.
        end case.
    output close.
end.
else do vi = 1 to 4:
    vindex = vi.

    case vindex:
        when 1 then vsc = "TQ_CITEM".
        when 2 then vsc = "TQ_CITEMCODIGORECEITA".
        when 3 then vsc = "TQ_CITEMPARTPROCADMJUD".
        when 4 then vsc = "TQ_CITEMPARTICIPANTE".
        otherwise leave.
    end case.            

    if opsys = "unix" then 
        varquivo = "/file_server/serv_" 
                 + vsc  
                 /*+ "_"
                 + string(day(today),"99")
                 + string(month(today),"99")
                 + string(year(today),"9999")
                 + "_"
                 + string(time)*/
                 + ".txt".
    
    output to value(varquivo).
        case vindex:
            when 1 then run pi-exp-tq-citem.
            when 2 then run pi-exp-tq-citemcodigoreceita.
            when 3 then run pi-exp-tq-citempartprocadmjud.
            when 4 then run pi-exp-tq-citemparticipante.
        end case.
    output close.

end.         

def var vcod-serv as char.

procedure pi-exp-tq-citem:
    for each Serv_Produ no-lock.
        vcod-serv = "SERV" + string(int(Serv_Produ.Codigo),"999999999").
        put unformatted 
            string("001"                             , "x(100)")     vsep
            string(vcod-serv                          , "x(60)")      vsep
            string(Serv_Produ.Descricao              , "x(255)")     vsep
            string("SV"                              , "x(6)")       vsep
            string(Serv_Produ.Cod_Tipo_Item          , "x(2)")       vsep
            string(Serv_Produ.Cod_Lista_Serv         , "9999999999") vsep
            string(Serv_Produ.Descricao_Longa        , "x(255)")     vsep
            string("SV"                              , "x(6)")       vsep
            string(Serv_Produ.Cod_NBS                , "x(15)")      vsep
            string(Serv_Produ.Cod_Tipo_Serv          , "9999999999") vsep
            string(Serv_Produ.Ind_Serv_Esp           , "99999")      vsep
            string(Serv_Produ.Tipo_Repasse           , "9")         
            skip.
    end.
end procedure.

procedure pi-exp-tq-citemcodigoreceita:
    for each PS_Cod_Receita no-lock.
        vcod-serv = "SERV" + string(int(PS_Cod_Receita.Cod_Item),"999999999").
        put unformatted                       
            string("001"                             , "x(100)")     vsep       
            string(PS_Cod_Receita.Cod_Receita        , "x(10)")      vsep       
            string(vcod-serv           , "x(60)")      vsep      
            string(PS_Cod_Receita.Var_Cod_Receita    , "x(4)")       vsep      
            string(PS_Cod_Receita.Cod_Imposto_Ret    , "x(50)")        
            skip.            
    end.
end procedure.

procedure pi-exp-tq-citemparticipante:
    for each PS_Participantes no-lock.
        vcod-serv = "SERV" + string(int(PS_Participantes.Cod_Item),"999999999").
        put unformatted
            string(vcod-serv         ,"x(60)")       vsep
            string(PS_Participantes.Cod_Parceiro     ,"x(30)")       vsep
            string("001"                             ,"x(100)")      vsep
            string(PS_Participantes.Descricao_Partic ,"x(255)")      vsep
            string(PS_Participantes.Ind_Forn_Alim    ,"S/N")         vsep
            string(PS_Participantes.Ind_Forn_Transp  ,"S/N")         vsep
            string(PS_Participantes.Ind_Outras_Desp  ,"S/N")         vsep
            string(PS_Participantes.Ind_Mat_Eqto     ,"S/N")         vsep
            string(PS_Participantes.Codigo_Receita_Nat,"x(10)")      vsep
            string(PS_Participantes.Cod_Imposto_Retido_Nat,"x(50)")  vsep
            string(PS_Participantes.Var_Cod_Receita_Nat,"x(4)")
            skip.
    end.            
end procedure.

procedure pi-exp-tq-citempartprocadmjud:
    for each PS_Processo no-lock.
        vcod-serv = "SERV" + string(int(PS_Processo.Cod_Item),"999999999").
        put unformatted
            string("001"                             ,"x(100)")      vsep
            string(vcod-serv              ,"x(60)")       vsep
            string(PS_Processo.Cod_Mun_IBGE          ,"9999999999")  vsep
            string(PS_Processo.Cod_Parceiro          ,"x(30)")       vsep
            string(PS_Processo.Cod_Suspensao         ,"x(14)")       vsep
            string(PS_Processo.Num_Processo          ,"x(30)")       vsep
            string(PS_Processo.Tipo_Processo,"1/2")                  vsep
            string(PS_Processo.Ind_Suspensao_Nat     ,"x(2)")
            skip.
    end.            
end procedure.



