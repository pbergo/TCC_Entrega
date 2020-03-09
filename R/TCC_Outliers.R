# TCC PUC Minas Ciencia de Dados
# Pedro Bergo - 2019
# Identificação de Outliers
# Esse programa identifica os Outliers a partir da análise dos Quartis usando Boxplots
# Como saída, gera uma tabela contendo os limites para cada Ano e Combustível.

########## Inicia procedure e bibliotecas  ##########
getwd()
setwd("D:/PBergoWork/TCC/R")

# Instala pacotes necessário ao trabalho
#install.packages("nanodbc")
#install.packages("anomalize")
#install.packages("tidyverse")
#install.packages("tsoutliers")
#install.packages("expsmooth")
#install.packages("fma")
#install.packages("tseries")

# Carrega bibliotecas
library(anomalize) #tidy anomaly detectiom
library(tidyverse) #tidyverse packages like dplyr, ggplot, tidyr
library(odbc)
library(DBI)
library(caret)
library(party)
library(zoo)
library(tseries)

rm_accent <- function(str,pattern="all") {
  if(!is.character(str))
    str <- as.character(str)
  pattern <- unique(pattern)
  if(any(pattern=="Ç"))
    pattern[pattern=="Ç"] <- "ç"
  symbols <- c(
    acute = "áéíóúÁÉÍÓÚýÝ",
    grave = "àèìòùÀÈÌÒÙ",
    circunflex = "âêîôûÂÊÎÔÛ",
    tilde = "ãõÃÕñÑ",
    umlaut = "äëïöüÄËÏÖÜÿ",
    cedil = "çÇ"
  )
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  accentTypes <- c("´","`","^","~","¨","ç")
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str)
  return(str)
  
}

########## Le tabelas fato_frota do Impala ##########
# Conecta ao Cloudera Impala
ImpalaCon <- DBI::dbConnect(odbc::odbc(),
                            Driver = "Cloudera ODBC Driver for Impala",
                            Host   = "127.0.0.1",
                            Schema = "tcc_pbergo",
                            UID    = "cloudera", #rstudioapi::askForPassword("Database user"),
                            PWD    = "cloudera", #rstudioapi::askForPassword("Database password"),
                            Port   = 21050,
                            encoding = 'latin1')
# Le tabela de frota
#df_frota <- dbGetQuery(ImpalaCon, "SELECT fato_frota.*, UPPER(dw_munpib.nom_municipio)   AS nom_municipio FROM dw_frota LEFT JOIN dw_munpib ON (dw_frota.cod_municipio = dw_munpib.cod_municipio) LIMIT 100000") # SQL
#df_frota <- dbGetQuery(ImpalaCon, "INVALIDATE METADATA") # SQL
df_frota <- dbGetQuery(ImpalaCon, "SELECT fato_frota.* FROM fato_frota") # SQL

# Disconecta banco Impala para limpar memória
odbc::dbDisconnect(ImpalaCon)

########## Tratamento de dados fato_frota ##########
# Copia tabela frota original, para evitar repetir a leitura do banco
df_frota_trat <- df_frota
df_frota <- c()

# Converte colunas da tabela frota para o formato desejado
df_frota_trat$cod_unidade <- as.factor(df_frota_trat$cod_unidade)
df_frota_trat$num_anoexercicio <- as.factor(df_frota_trat$num_anoexercicio)
df_frota_trat$num_mesexercicio <- as.numeric(df_frota_trat$num_mesexercicio)
df_frota_trat$keyveiculo <- as.factor(df_frota_trat$keyveiculo)
df_frota_trat$keymunicipio <- as.factor(df_frota_trat$keymunicipio)
df_frota_trat$keytipogasto <- as.factor(df_frota_trat$keytipogasto)
df_frota_trat$dt_gasto <- as.Date(as.POSIXct(paste(paste(df_frota_trat$num_anoexercicio,df_frota_trat$num_mesexercicio,1,sep="-"), paste("00","00",sep=":"))))
df_frota_trat$dsc_tipogasto <- as.factor(getproduto[df_frota_trat$keytipogasto])


# gera tabela de gastos unitários ordenados
df_frota_gastos_unit <- df_frota_trat[order(df_frota_trat$dt_gasto),c("dt_gasto","keytipogasto","vlr_gasto_unit","qtd_utilizada","num_anoexercicio","pk_frota","keyveiculo")]

########## Plota resultados ##########
# Gastos Unitários

# Analisa estatisticas da tabela
summary(df_frota_gastos_unit)

#Tabela de Amplitude
dfstats <- data.frame(matrix(ncol=16, nrow=0))
colnames(dfstats) <- c("keytipogasto","num_anoexercicio",
                       "vlr_mediana","vlr_media","vlr_std","vlr_max","vlr_min","vlr_amplitude",
                       "km_mediana","km_media","km_std","km_max","km_min","km_amplitude",
                       "nr_abast","nr_veiculos")
for (v_tipgasto in 1:length(levels(df_frota_gastos_unit$keytipogasto))) {
  df_ampl <- df_frota_gastos_unit %>%
    filter(keytipogasto==levels(keytipogasto)[v_tipgasto]) %>%
    group_by(keytipogasto, num_anoexercicio) %>%
    summarise(
              vlr_mediana = median(vlr_gasto_unit),
              vlr_media = mean(vlr_gasto_unit),
              vlr_std = sd(vlr_gasto_unit),
              vlr_max = max(vlr_gasto_unit),
              vlr_min = min(vlr_gasto_unit),
              vlr_amplitude = (max(vlr_gasto_unit) - min(vlr_gasto_unit)),
              km_mediana = median(qtd_utilizada),
              km_media = mean(qtd_utilizada),
              km_std = sd(qtd_utilizada),
              km_max = max(qtd_utilizada),
              km_min = min(qtd_utilizada),
              km_amplitude = (max(qtd_utilizada) - min(qtd_utilizada)),
              nr_abast = length(pk_frota),
              nr_veiculos = length(unique(keyveiculo))
    )
  dfstats <- union_all(dfstats,df_ampl)
  df_amp <- NULL
}


# Histogramas
par(mfrow = c(2,2))
for (v_tipgasto in 1:length(levels(df_frota_gastos_unit$keytipogasto))) {
  hist(df_frota_gastos_unit[df_frota_gastos_unit$keytipogasto==levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto],3], 
       main=" ",
       breaks=50,
       col.main = "blue",
       col=2, border=1, xlab=" ", ylab="Freq")
  mtext("Histograma de Valor por Km", side=3, line=2, cex=1.3)
  mtext(levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto], side=3, cex=1, line=0.5, col="blue")
}
vFile <- "Grf01-Histogramade de Valor por Km.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();

par(mfrow = c(2,2))
for (v_tipgasto in 1:length(levels(df_frota_gastos_unit$keytipogasto))) {
  hist(df_frota_gastos_unit[df_frota_gastos_unit$keytipogasto==levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto],4], 
       main=" ",
       breaks=50,
       col.main = "blue",
       col=2, border=1, xlab=" ", ylab="Freq")
  mtext("Histograma de Km Rodado", side=3, line=2, cex=1.3)
  mtext(levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto], side=3, cex=1, line=0.5, col="blue")
}
vFile <- "Grf02-Histograma de Km Rodado.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();


# Boxplot por Tipo com Outliers
# Vl por Km
par(mfrow = c(1,1))
dfbox <- boxplot(df_frota_gastos_unit$vlr_gasto_unit ~ df_frota_gastos_unit$keytipogasto,
                 outline = TRUE,
                 boxfill="light gray",
                 outpch = 21:25, outlty = 2,
                 bg = "pink", lwd = 2,
                 medcol = "dark blue", medcex = 2, medpch = 20,
                 main="Distribuição de Vl por Km por Tipo",
                 col.main = "blue",
                 cex.axis = 0.7,
                 ylab="Valor por Km",xlab=" ")
tpar<-c(cex=0.4,pos=-0.4)
vFile <- "Grf03-Distribuição de Vl por Km por Tipo com Outliers.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();


# Km Rodada
par(mfrow = c(1,1))
dfbox <- boxplot(df_frota_gastos_unit$qtd_utilizada ~ df_frota_gastos_unit$keytipogasto,
                 outline = TRUE,
                 boxfill="light gray",
                 outpch = 21:25, outlty = 2,
                 bg = "pink", lwd = 2,
                 medcol = "dark blue", medcex = 2, medpch = 20,
                 main="Distribuição de Km Rodado por Tipo",
                 col.main = "blue",
                 cex.axis = 0.7,
                 ylab="Km Rodado",xlab=" ")
tpar<-c(cex=0.4,pos=-0.4)
vFile <- "Grf04-Distribuição de Km Rodado por Tipo com Outliers.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();


# Boxplot por Tipo sem Outliers
# Vl por Km
par(mfrow = c(1,1))
dfbox <- boxplot(df_frota_gastos_unit$vlr_gasto_unit ~ df_frota_gastos_unit$keytipogasto,
                 outline = FALSE,
                 boxfill="light gray",
                 outpch = 21:25, outlty = 2,
                 bg = "pink", lwd = 2,
                 medcol = "dark blue", medcex = 2, medpch = 20,
                 main="Distribuição de Gastos por Tipo",
                 col.main = "blue",
                 cex.axis = 0.7,
                 ylab="Valor por Km",xlab=" ")
tpar<-c(cex=0.4,pos=-0.4)
for (v_pos in 1:4) {
  for (v_stat in 1:5){
    text(y = dfbox$stats[v_stat,v_pos], labels = format(dfbox$stats[v_stat,v_pos], digits=3), x = (v_pos + .25), tpar) 
    
  }
}
vFile <- "Grf05-Distribuição de Vl por Km por Tipo sem Outliers.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();

# Gera Tabela de Limites por Vl por Km dos BoxPlots
dflimits <- dfbox$stats
dflimits <- as.data.frame(t(dflimits))
dflimits <- cbind(levels(df_frota_gastos_unit$keytipogasto), dflimits)
colnames(dflimits) <- c("TipoGasto","LI", "1Q", "MDN", "3Q", "LS")



# Km Rodado
par(mfrow = c(1,1))
dfbox <- boxplot(df_frota_gastos_unit$qtd_utilizada ~ df_frota_gastos_unit$keytipogasto,
                 outline = FALSE,
                 boxfill="light gray",
                 outpch = 21:25, outlty = 2,
                 bg = "pink", lwd = 2,
                 medcol = "dark blue", medcex = 2, medpch = 20,
                 main="Distribuição de Gastos por Tipo",
                 col.main = "blue",
                 cex.axis = 0.7,
                 ylab="Valor por Km",xlab=" ")
tpar<-c(cex=0.4,pos=-0.4)
for (v_pos in 1:4) {
  for (v_stat in 1:5){
    text(y = dfbox$stats[v_stat,v_pos], labels = format(dfbox$stats[v_stat,v_pos], digits=3), x = (v_pos + .25), tpar) 
    
  }
}
vFile <- "Grf06-Distribuição de Km Rodado por Tipo sem Outliers.jpg"
dev.copy(jpeg,filename=vFile);
dev.off ();

# Gera Tabela de Limites dos BoxPlots
dflimits_km <- dfbox$stats
dflimits_km <- as.data.frame(t(dflimits_km))
dflimits_km <- cbind(levels(df_frota_gastos_unit$keytipogasto), dflimits_km)
colnames(dflimits_km) <- c("TipoGasto","LI", "1Q", "MDN", "3Q", "LS")


# Boxplot por Ano sem Outliers
par(mfrow = c(1,1))
df_frota_gastos_unit$Ano <- format(df_frota_gastos_unit$dt_gasto,"%Y")

dflimits_ano <- data.frame(matrix(ncol=7,nrow = 0))
for (v_tipgasto in 1:length(levels(df_frota_gastos_unit$keytipogasto))) {
  # Calcula a Mediana por Período
  df_frota_plot <-  df_frota_gastos_unit %>%
    filter(keytipogasto==levels(keytipogasto)[v_tipgasto]) 
  
  dfbox <- boxplot(df_frota_plot$vlr_gasto_unit ~ df_frota_plot$Ano,
                 outline = FALSE,
                 boxfill="light gray",
                 outpch = 21:25, outlty = 2,
                 bg = "pink", lwd = 2,
                 medcol = "dark blue", medcex = 2, medpch = 20,
                 main="Distribuição de Gastos por Ano",
                 col.main = "blue",
                 cex.axis = 1,
                 ylab="Valor por Km",xlab=" ")
  mtext(levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto], side=3, cex=0.8, line=0.5, col="blue")
  tpar<-c(cex=0.6,pos=-0.4)
  for (v_pos in 1:6) {
    for (v_stat in 1:5){
      text(y = dfbox$stats[v_stat,v_pos], labels = format(dfbox$stats[v_stat,v_pos], digits=3), x = (v_pos + .25), tpar) 
      
    }
  }
  
  # Gera Tabela de Limites dos BoxPlots
  dfbox_ano <- dfbox$stats
  dfbox_ano <- as.data.frame(t(dfbox_ano))
  dfbox_ano <- cbind(levels(as.factor(df_frota_gastos_unit$Ano)), dfbox_ano)
  dfbox_ano$TipoGasto <- levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto]
  colnames(dfbox_ano) <- c("Ano","LI", "1Q", "MDN", "3Q", "LS","TipoGasto")
  dfbox_ano <- dfbox_ano[c("TipoGasto","Ano","LI", "1Q", "MDN", "3Q", "LS")]
  dflimits_ano <- rbind(dflimits_ano,dfbox_ano)
  
  vFile <- paste("Grf",(06 + v_tipgasto),
                 "-Distribuição de Gastos Anuais sem Outliers ",
                 levels(df_frota_gastos_unit$keytipogasto)[v_tipgasto],".jpg",sep="")
  dev.copy(jpeg,filename=vFile);
  dev.off ();
}


########## Grava tabelas limits e limits_ano do Impala ##########
# Conecta ao Cloudera Impala
ImpalaCon <- DBI::dbConnect(odbc::odbc(),
                            Driver = "Cloudera ODBC Driver for Impala",
                            Host   = "127.0.0.1",
                            UID    = "cloudera", #rstudioapi::askForPassword("Database user"),
                            PWD    = "cloudera", #rstudioapi::askForPassword("Database password"),
                            Port   = 21050,
                            encoding = 'latin1',
                            IgnoreTransactions=1)


# Apaga tabelas se existirem
query <- "DROP TABLE IF EXISTS tcc_pbergo.statistics "
dbSendQuery(ImpalaCon,query)

query <- "DROP TABLE IF EXISTS tcc_pbergo.limits "
dbSendQuery(ImpalaCon,query)

query <- "DROP TABLE IF EXISTS tcc_pbergo.limits_ano "
dbSendQuery(ImpalaCon,query)

query <- "DROP TABLE IF EXISTS tcc_pbergo.limits_km "
dbSendQuery(ImpalaCon,query)


# Cria tabelas
# stat - Estatíticas Gerais sobre os dados
query <- paste("CREATE TABLE IF NOT EXISTS tcc_pbergo.statistics ",
               "(keytipogasto STRING, ",
               "Ano STRING,",
               "vlr_mediana FLOAT, ",
               "vlr_media FLOAT, ",
               "vlr_std FLOAT, ",
               "vlr_max FLOAT, ",
               "vlr_min FLOAT, ",
               "vlr_ampl FLOAT, ",
               "km_mediana FLOAT, ",
               "km_media FLOAT, ",
               "km_std FLOAT, ",
               "km_max FLOAT, ",
               "km_min FLOAT, ",
               "km_ampl FLOAT, ",
               "nr_abast FLOAT, ",
               "nr_veiculos FLOAT ) ",
               "STORED AS PARQUET;",
               sep="")
dbSendQuery(ImpalaCon,query)


# limits - Limites Gerais
query <- paste("CREATE TABLE IF NOT EXISTS tcc_pbergo.limits ",
               "(keytipogasto STRING, ",
               "LI FLOAT, ",
               "1Q FLOAT, ",
               "MDN FLOAT, ",
               "3Q FLOAT, ",
               "LS FLOAT ) ",
               "STORED AS PARQUET;",
               sep="")
dbSendQuery(ImpalaCon,query)


# limits_ano - Limites Anuais
query <- paste("CREATE TABLE IF NOT EXISTS tcc_pbergo.limits_ano ",
               "(keytipogasto STRING, ",
               "Ano STRING, ",
               "LI FLOAT, ",
               "1Q FLOAT, ",
               "MDN FLOAT, ",
               "3Q FLOAT, ",
               "LS FLOAT ) ",
               "STORED AS PARQUET;",
               sep="")
dbSendQuery(ImpalaCon,query)


# limits de Km Rodado - Limites Gerais
query <- paste("CREATE TABLE IF NOT EXISTS tcc_pbergo.limits_km ",
               "(keytipogasto STRING, ",
               "LI FLOAT, ",
               "1Q FLOAT, ",
               "MDN FLOAT, ",
               "3Q FLOAT, ",
               "LS FLOAT ) ",
               "STORED AS PARQUET;",
               sep="")
dbSendQuery(ImpalaCon,query)



# Inclui Tabelas 
# stat - Estatíticas Gerais sobre os dados
for (v_reg in 1:NROW(dfstats)) {
  query <- paste("INSERT INTO tcc_pbergo.statistics",
                 "(`keytipogasto`,`Ano`, ",
                 "`vlr_mediana`,`vlr_media`,`vlr_std`,`vlr_max`,`vlr_min`,`vlr_ampl`, ",
                 "`km_mediana`,`km_media`,`km_std`,`km_max`,`km_min`,`km_ampl`, ",
                 "`nr_abast`,`nr_veiculos`) ",
                 "VALUES (", 
                 "'",dfstats[v_reg,1],"',",
                 "'",dfstats[v_reg,2],"',",
                 dfstats[v_reg,3],",",
                 dfstats[v_reg,4],",",
                 dfstats[v_reg,5],",",
                 dfstats[v_reg,6],",",
                 dfstats[v_reg,7],",",
                 dfstats[v_reg,8],",",
                 dfstats[v_reg,9],",",
                 dfstats[v_reg,10],",",
                 dfstats[v_reg,11],",",
                 dfstats[v_reg,12],",",
                 dfstats[v_reg,13],",",
                 dfstats[v_reg,14],",",
                 dfstats[v_reg,15],",",
                 dfstats[v_reg,16],
                 ")",sep="")
  dbSendQuery(ImpalaCon,query)
}
dbExistsTable(ImpalaCon, "statistics") # succeeds


# limits - Limites Gerais
for (v_reg in 1:NROW(dflimits)) {
  query <- paste("INSERT INTO tcc_pbergo.limits",
                 "(`keytipogasto`,`LI`,`1Q`, `MDN`,`3Q`,`LS`) ",
                 "VALUES (", 
                 "'",dflimits[v_reg,1],"',",
                 dflimits[v_reg,2],",",
                 dflimits[v_reg,3],",",
                 dflimits[v_reg,4],",",
                 dflimits[v_reg,5],",",
                 dflimits[v_reg,6],
                 ")",sep="")
  dbSendQuery(ImpalaCon,query)
}
dbExistsTable(ImpalaCon, "limits") # succeeds


# limits_ano - Limites Anuais
for (v_reg in 1:NROW(dflimits_ano)) {
  query <- paste("INSERT INTO tcc_pbergo.limits_ano",
                 "(`keytipogasto`, `Ano`, `LI`,`1Q`, `MDN`,`3Q`,`LS`) ",
                 "VALUES (", 
                 "'",dflimits_ano[v_reg,1],"',",
                 "'",dflimits_ano[v_reg,2],"',",
                 dflimits_ano[v_reg,3],",",
                 dflimits_ano[v_reg,4],",",
                 dflimits_ano[v_reg,5],",",
                 dflimits_ano[v_reg,6],",",
                 dflimits_ano[v_reg,7],
                 ")",sep="")
  dbSendQuery(ImpalaCon,query)
}
dbExistsTable(ImpalaCon, "limits_ano") # succeeds


# limits_km - Limites Gerais
for (v_reg in 1:NROW(dflimits_km)) {
  query <- paste("INSERT INTO tcc_pbergo.limits_km",
                 "(`keytipogasto`,`LI`,`1Q`, `MDN`,`3Q`,`LS`) ",
                 "VALUES (", 
                 "'",dflimits_km[v_reg,1],"',",
                 dflimits_km[v_reg,2],",",
                 dflimits_km[v_reg,3],",",
                 dflimits_km[v_reg,4],",",
                 dflimits_km[v_reg,5],",",
                 dflimits_km[v_reg,6],
                 ")",sep="")
  dbSendQuery(ImpalaCon,query)
}
dbExistsTable(ImpalaCon, "limits") # succeeds



# Disconecta banco Impala para limpar memória
odbc::dbDisconnect(ImpalaCon)




