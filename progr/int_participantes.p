def var varq as char.
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vetb as char.
def var sparam as char.
def var varquivo as char.
def var vesc as char extent 1 format "x(25)".
def var vsc as char format "x(3)".
def var vtitvlpag like titulo.titvlpag.
def var vsep as char init "|" format "x".
def var vi as int.
vesc[1] = "PARTICIPANTES".
def var vindex as int.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

if opsys = "unix" and sparam = "AniTA"
then
repeat:
    vindex = vindex + 1.
    disp vesc no-label with frame f-esc 1 down centered width 80.
    choose field vesc with frame f-esc.
                
    vindex = frame-index.
                    
    case vindex:
        when 1 then vsc = "TQ_CPARTICIPANTES".
        otherwise leave.
    end case.
                   
    varquivo = "/admcom/decision/serv_" + vsc
               + string(day(today),"99")
               + string(month(today),"99")
               + string(year(today),"9999")
               + "_"
               + string(time)
               + ".txt".
                        
    output to value(varquivo).
        case vindex:
            when 1 then run put-01.
            otherwise leave.
        end case.
    output close.
   
end.
else do vi = 1 to 1:
    vindex = vi.
                    
    case vindex:
        when 1 then vsc = "TQ_CPARTICIPANTES".
        otherwise leave.
    end case.
                   
    varquivo = "/file_server/serv_" + vsc
               /*+ string(day(today),"99")
               + string(month(today),"99")
               + string(year(today),"9999")
               + "_"
               + string(time)*/
               + ".txt".
                        
    output to value(varquivo).
        case vindex:
            when 1 then run put-01.
            otherwise leave.
        end case.
    output close.
end.         

procedure put-01:

    for each serv_forne no-lock,
        each forne where forne.forcod = serv_forne.forcod no-lock:

        find first pais where
                   pais.paisnom = forne.forpais no-lock no-error.

        find first munic where
                   munic.cidnom = forne.formunic and
                   munic.ufecod = forne.ufecod no-lock no-error.

        put unformatted
            '001'                               vsep /*CodCiaNat*/
            forne.forcod                        vsep /*codigo*/
            forne.fornom                        vsep /*nome*/
            (if avail pais then pais.pais-sigla
             else "")                           vsep /*cod pais nat*/
            (if length(forne.forcgc) = 14 then
                string(forne.forcgc,"99999999999999")
            else "")                            vsep /*cnpj*/
            (if length(forne.forcgc) = 11 then        
                string(forne.forcgc,"99999999999")
            else "")                            vsep /*cpf*/
            forne.forinest                      vsep /*insc estadual*/
            forne.forinmun                      vsep /*insc municipal*/
            (if avail munic then munic.cidcod  
             else "")                           vsep /*cod municipio ibge nat*/
            forne.forrua                        vsep /*endereco*/
            forne.fornum                        vsep /*numero*/
            forne.forcomp                       vsep /*complemento*/
            forne.forbairro                     vsep /*bairro*/
            forne.forcep                        vsep /*cep*/
            forne.forfant                       vsep /*nomefantasia*/
            1                                   vsep /*ativo*/
            string(serv_forne.Ind_Org_Pub, "S/N") vsep /*ind orgao publico*/
            serv_forne.Ind_Opt_Simples_Nacional vsep /*optante simples naci*/
            serv_forne.Tipo_Nota_Servico        vsep /*tipo nota servico*/
            serv_forne.Cod_UF                   vsep /*cod uf nat*/
            string(serv_forne.Ind_Contribui_CPRB, "S/N") vsep /*ind contr cprb*/
            serv_forne.Ind_NIF            vsep /*ind nif*/
            string(serv_forne.Ind_Proc_AdmJud, "S/N")    vsep /*IndProcAdmJud*/
            string(serv_forne.Ind_Recup_Falencia, "S/N") vsep /*IndRecupFalenc*/
            string(serv_forne.Ind_Retencao_CS, "S/N")    vsep /*ind retencao cs*/
            string(serv_forne.Ind_Retencao_INSS, "S/N")  vsep /*retencao inns*/
            string(serv_forne.Ind_Retencao_IR, "S/N")    vsep /*retencao ir*/
            serv_forne.Inscricao_Classe         vsep /*inscricao classe*/
            serv_forne.Orgao_Classe             vsep /*orgao classe*/
            serv_forne.Tipo_Orgao_Publico       vsep /*tipo orgao publico*/
            skip.
    end.
end procedure.  
