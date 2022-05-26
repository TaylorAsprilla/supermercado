######### Borrar datos

rm(list = ls())
options(scipen=999)
#########  cargar las librerias

library(fpp2)
library(readxl)
library(lubridate)
library(tidyr)
library(dplyr)

#########  cargar datos

data <- read.csv("C:/Users/scorp/OneDrive/Desktop/Base_proyecto.csv")
data
nrow(data)
dim(data)

#########  Transformar los datos fecha y cantidad

attach(data)
data$fecha<- as.character(data$fecha)
data$fecha<- as.Date(data$fecha,format ="%Y%m%d" )
data$cantidad<- as.numeric(data$cantidad)

#########  Seleccionar datos
Dia<- data %>%
  select(descrip,cantidad,fecha)
names (Dia)[1] = "Producto"
Dia<-Dia[!Dia$cantidad > 1000, ]
Dia<-Dia[!Dia$Producto == "PRODUCTOS VARIOS", ]
Dia<-Dia[!Dia$Producto == "PRODUCTOS DE 1200", ]
#########  seleccionar y agrupar cantidades por mes
Ventas_mes<- Dia %>%
  mutate(Mes=format(fecha,"%m"),Año=format(fecha,"%Y"))%>%
  group_by(Producto , Año , Mes )%>%
  summarise(cantidad=sum(cantidad),.groups="drop")

Ventas_mes<-Ventas_mes[with(Ventas_mes,order(Ventas_mes$year)),]

#########  seleccionamos las ventas menores a 12 y las eliminamos
recuento<- Ventas_mes %>%
  group_by(Producto)%>%
  summarise(cantidad=n(),.groups="drop")

recuento<- filter(recuento, cantidad < 12 )
productos<- unique(recuento$Producto)


for (e in productos) {
  Ventas_mes<-Ventas_mes[!Ventas_mes$Producto == e,]

}

########### Serie de tiempo autoarima ########

productos<- unique(Ventas_mes$Producto)

for (e in productos) {

  St_producto <- filter(Ventas_mes, Producto == e)
  mesv=St_producto$Mes[1]
  añov=St_producto$Año[1]
  ST<- ts(St_producto[,4],start=c(añov,mesv),frequency = 12)
  #modelo_arima<- auto.arima(ST,d=1,D=1,stepwise=FALSE , approximation = FALSE,stationary = TRUE )
  modelo_arima<- auto.arima(ST)
  proy <- forecast(modelo_arima,h=3,level=c(90))
  
  pronostico <- as.data.frame(proy)
  
  pronostico<- pronostico %>%
    mutate(fecha_p=rownames(pronostico))
  rownames(pronostico)<- NULL
  pronostico <- select(pronostico, fecha_p, 'Point Forecast')
  names (pronostico)[2] = "cantidad"
  
  attach(pronostico)
  pronostico$fecha_p<- as.character(pronostico$fecha_p )
  pronostico$fecha_p<- dmy(paste("01 ", pronostico$fecha_p , sep =""))
  
  pronostico%>%mutate_if(is.numeric,round, digits=0)

  
  
  pronostico<- pronostico %>%
    mutate(Producto=e,Mes=format(fecha_p,"%m"),Año=format(fecha_p,"%Y"))
  
  pronostico <- select(pronostico,Producto , Año , Mes  , cantidad)
  Ventas_mes <- rbind(Ventas_mes, pronostico)

  
}












#install.packages("writexl")
library("writexl")
write_xlsx(Ventas_mes, "Ventas_mes6.xlsx")
#class(productos)
#productos<- unique(Ventas_mes$Producto)
#productos<- filter(productos, cantidad < 12 )
#length(productos)
#productos[3]

