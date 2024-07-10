/*  cyber/chave_contrato.p                                              */
/*  programa que contem a definição de chave de contrato com o Cyber    */
def input  parameter par-rec-contrato   as recid.
def output parameter par-chave_contrato as char format "x(25)".

find cyber_contrato where recid(cyber_contrato) = par-rec-contrato no-lock.

par-chave_contrato = string(cyber_contrato.etbcod ,"999") +
                     string(cyber_contrato.contnum,"99999999999"). 
