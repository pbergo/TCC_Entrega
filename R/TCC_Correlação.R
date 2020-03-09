# TCC PUC Minas Ciencia de Dados
# Pedro Bergo - 2019
# Identificação de Correlação entre Nr. Abastecimentos e Valor Unitário

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
#library(anomalize) #tidy anomaly detectiom
library(tidyverse) #tidyverse packages like dplyr, ggplot, tidyr
library(odbc)
library(DBI)
#library(caret)
#library(party)
library(zoo)
library(tseries)
library(dplyr)


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

# cria tabela de lookup para comparar os valores
df_lookup <- data.frame(stringsAsFactors=FALSE,dsc_tipgasto = c( "1 - ÁLCOOL (LITRO)", "2 - GASOLINA (LITRO)", "3 - GÁS NATURAL (M³)", "4 - DIESEL (LITRO)", "5 - QUEROSENE (LITRO)", "6 - ÓLEO LUBRIFICANTE (LITRO)", "8 - PEÇAS", "7 - GRAXA (QUILOGRAMA)", "9 - SERVIÇOS", "99 - OUTROS"), produto      = c( "ETANOL HIDRATADO",   "GASOLINA COMUM",       "GNV",                  "ÓLEO DIESEL",       "QUEROSENE",              "ÓLEO LUBRIFICANTE",             "PEÇAS",     "GRAXA",                  "SERVIÇOS",     "OUTROS") )
getproduto <- df_lookup$produto
names(getproduto) <- df_lookup$dsc_tipgasto


# le tabelas de limites
df_limits <- dbGetQuery(ImpalaCon, "SELECT * FROM limits") # SQL
df_limits_ano <- dbGetQuery(ImpalaCon, "SELECT * FROM limits_ano") # SQL


# Disconecta banco Impala para limpar memória
odbc::dbDisconnect(ImpalaCon)

########## Tratamento de dados fato_frota ##########
# Copia tabela frota original, para evitar repetir a leitura do banco
df_frota_trat <- df_frota
df_frota <- c()

# Converte colunas da tabela frota para o formato desejado
df_frota_trat$cod_unidade <- as.factor(df_frota_trat$cod_unidade)
df_frota_trat$num_anoexercicio <- as.numeric(df_frota_trat$num_anoexercicio)
df_frota_trat$num_mesexercicio <- as.numeric(df_frota_trat$num_mesexercicio)
df_frota_trat$keyveiculo <- as.factor(df_frota_trat$keyveiculo)
df_frota_trat$keytipogasto <- as.factor(df_frota_trat$keytipogasto)
df_frota_trat$dt_gasto <- as.Date(as.POSIXct(paste(paste(df_frota_trat$num_anoexercicio,df_frota_trat$num_mesexercicio,1,sep="-"), paste("00","00",sep=":"))))
df_frota_trat$dsc_tipogasto <- as.factor(getproduto[df_frota_trat$keytipogasto])
df_frota_trat$vlr_gasto_unit <- df_frota_trat$vlr_gasto / ifelse(df_frota_trat$qtd_utilizada==0,1,df_frota_trat$qtd_utilizada)

# Trata a tabela de limites para uso
df_limits$keytipogasto <- as.factor(df_limits$keytipogasto)
df_limits_ano$keytipogasto <- as.factor(df_limits_ano$keytipogasto)
df_limits_ano$ano <- as.factor(df_limits_ano$ano)

# gera tabela de gastos unitários ordenados
df_frota_gastos_unit <- df_frota_trat[order(df_frota_trat$dt_gasto),c("keymunicipio","pk_frota","keyveiculo","dt_gasto","num_anoexercicio","keytipogasto","vlr_gasto_unit")]

for (v_tipgasto in 1:length(levels(df_limits_ano$keytipogasto))) {
    v_li <- df_limits_ano[df_limits_ano$keytipogasto==levels(df_limits_ano$keytipogasto)[v_tipgasto] , 3]
    v_ls <- df_limits_ano[df_limits_ano$keytipogasto==levels(df_limits_ano$keytipogasto)[v_tipgasto] , 7]
    
    df_frota_gastos_corr <- df_frota_gastos_unit %>%
      filter(keytipogasto==levels(keytipogasto)[v_tipgasto] &
               (
                 (num_anoexercicio==levels(df_limits_ano$ano)[1] & vlr_gasto_unit>=v_li[1] & vlr_gasto_unit<=v_ls[1]) |
                 (num_anoexercicio==levels(df_limits_ano$ano)[2] & vlr_gasto_unit>=v_li[2] & vlr_gasto_unit<=v_ls[2]) |
                 (num_anoexercicio==levels(df_limits_ano$ano)[3] & vlr_gasto_unit>=v_li[3] & vlr_gasto_unit<=v_ls[3]) |
                 (num_anoexercicio==levels(df_limits_ano$ano)[4] & vlr_gasto_unit>=v_li[4] & vlr_gasto_unit<=v_ls[4]) |
                 (num_anoexercicio==levels(df_limits_ano$ano)[5] & vlr_gasto_unit>=v_li[5] & vlr_gasto_unit<=v_ls[5]) |
                 (num_anoexercicio==levels(df_limits_ano$ano)[6] & vlr_gasto_unit>=v_li[6] & vlr_gasto_unit<=v_ls[6])
               )
             ) %>%
      group_by(keytipogasto, keymunicipio, num_anoexercicio) %>%
      summarise(vlr_mediana = median(vlr_gasto_unit),
                vlr_media = mean(vlr_gasto_unit),
                nr_abast = length(pk_frota),
                nr_veiculos = length(unique(keyveiculo))
      )
    
    graf_disp <- ggplot(df_frota_gastos_corr[
      df_frota_gastos_corr$keytipogasto  == levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],], 
      aes(x=vlr_mediana, y=nr_abast)) +
      geom_point(aes(col=as.factor(num_anoexercicio))) +
      geom_smooth(method="loess", se = F) +
      labs(title = "Correlação Abastecimentos e Valor por Km por Município",
           subtitle = levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
           x = "Valor por Km", y = "Nr de Abastecimentos",
           caption = "Fonte: Dados Abertos do TCE/MG")+
      theme(legend.title = element_blank())
    plot(graf_disp)
    vFile <- paste("Grf",(16 + (v_tipgasto * 3) -2 ),
                   "-Correlação Abastecimentos e Vl Km - ",
                   levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
                   ".jpg",sep="")
    dev.copy(jpeg,filename=vFile);
    dev.off ();
    
    graf_disp <- ggplot(df_frota_gastos_corr[
      df_frota_gastos_corr$keytipogasto  == levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],], 
      aes(x=vlr_mediana, y=nr_veiculos)) +
      geom_point(aes(col=as.factor(num_anoexercicio))) +
      geom_smooth(method="loess", se = F) +
      labs(title = "Correlação Veículos e Valor por Km por Município",
           subtitle = levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
           x = "Valor por Km", y = "Nr de Veículos",
           caption = "Fonte: Dados Abertos do TCE/MG")+
      theme(legend.title = element_blank())
    plot(graf_disp)
    vFile <- paste("Grf",(16 + (v_tipgasto * 3)-1),
                   "-Correlação Veículos e Vl Km - ",
                   levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
                   ".jpg",sep="")
    dev.copy(jpeg,filename=vFile);
    dev.off ();

    graf_disp <- ggplot(df_frota_gastos_corr[
      df_frota_gastos_corr$keytipogasto  == levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],], 
      aes(y=nr_abast, x=nr_veiculos)) +
      geom_point(aes(col=as.factor(num_anoexercicio))) +
      geom_smooth(method="loess", se = F) +
      labs(title = "Correlação Abastecimentos e Veículos por Município",
           subtitle = levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
           y = "Nr de Abastecimentos", x = "Nr de Veículos",
           caption = "Fonte: Dados Abertos do TCE/MG")+
      theme(legend.title = element_blank())
    plot(graf_disp)
    vFile <- paste("Grf",(16 + (v_tipgasto * 3)),
                   "-Correlação Abastecimentos e Veículos - ",
                   levels(df_frota_gastos_corr$keytipogasto)[v_tipgasto],
                   ".jpg",sep="")
    dev.copy(jpeg,filename=vFile);
    dev.off ();
    
}

