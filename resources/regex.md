# Regex
Seq|Name|Search|Replace
---|---|---|---
1|Prefix tables with **dbo**|`create table ([\w_\d]+)`|`create table dbo.$1`
2|Wrap table in BEGIN/END comments|`create table (dbo\.[\w_\d]+)([\r\n]+)[^;]*;`|`-- BEGIN: $1$2$0$2-- END $1`
3|Add to the start of a table block|`-- BEGIN: ([\w_\.\d]+)([\r\n]+)`|
4|Expand concept_name field|`(concept_[\w_]+name) varchar\(.*\) (not )?null`|`$1 varchar(4000) $2null`