def new global shared var par-fuso-horario as char.
par-fuso-horario =
SUBSTRING(  STRING(DATETIME-TZ(DATE(STRING(DAY(today),"99") + "/" +
STRING(MONTH(today),"99") + "/" + STRING(YEAR(today),"9999")), MTIME,
TIMEZONE)),  24,6)
       .
