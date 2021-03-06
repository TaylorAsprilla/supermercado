# Apriori

# Preprocesado de Datos
#install.packages("arules")
#install.packages("dplyr")
#install.packages("xlsx")
#install.packages("openxlsx")
#install.packages("writexl")

# Librerias
library(dplyr)
library(arules) 
library(arulesViz)
library(ggplot2)
library(openxlsx)
library(writexl)



# Importaci�n del DataSet
dataset = read.csv("data-v3.csv", header = TRUE,  sep = ";")
head(dataset)



# Productos por Trasacci�n
filtro = filter(dataset, dataset$numero == 124726)
pull(filtro, descrip)


# IMPORTACI�N DIRECTA DE LOS DATOS A UN OBJETO TIPO TRANSACTION
# ==============================================================================

transacciones = read.transactions(file = "data-v3.csv",
                                  format = "single",
                                  sep = ";",
                                  header = TRUE,
                                  cols = c("numero", "descrip"),
                                  rm.duplicates = TRUE)
transacciones
summary(transacciones)

# =================== Exploraci�n de Datos ==================================


# Gr�fico del Top 10 de Productos
itemFrequencyPlot(transacciones, topN = 10)


# 5 primeras columnas
colnames(transacciones)[1:5]

# 5 primeras filas
rownames(transacciones)[1:5]

# Exploraci�n de items
inspect(transacciones[1:5])

# Transformaci�n en un dataFrame
df_transacciones <- as(transacciones, Class = "data.frame")
df_transacciones

# Tama�o de cada transacci�n 
tamanyos <- size(transacciones)
summary(tamanyos)

quantile(tamanyos, probs = seq(0,1,0.1))

dataTamanios = as.data.frame(tamanyos)
dataTamanioTransacciones = subset(dataTamanios, tamanyos <30)

# Gr�fico del tama�o de las transacciones
ggplot(dataTamanioTransacciones )+
  geom_histogram(aes(x = tamanyos), bins=10,alpha = 0.8)+
  labs(title = "Distribuci�n del tama�o de las transacciones",
       x = "Tama�o") +
  theme_bw()
  


# Items m�s frecuentes
frecuencia_items <- itemFrequency(x = transacciones, type = "relative")
frecuencia_items2 = (sort(x = frecuencia_items, decreasing = TRUE))
head(frecuencia_items2, 6)



# Se calcula el soporte
soporte <- 50 / dim(transacciones)[1]
itemsets = apriori(data = transacciones,
                    parameter = list(support = soporte,
                                     minlen = 1,
                                     maxlen = 20,
                                     target = "frequent itemset"))

summary(itemsets)


# Se muestran los top 20 itemsets de mayor a menor soporte
top_20_itemsets <- sort(itemsets, by = "support", decreasing = TRUE)[1:20]
inspect(top_20_itemsets)



# Para representarlos con ggplot se convierte a dataframe 
top_20_itemsets_data = as(top_20_itemsets, Class = "data.frame")
top_20_itemsets_data

top_20_itemsets_data = filter( top_20_itemsets_data, items != '{PRODUCTOS VARIOS}')


write_xlsx(top_20_itemsets_data, "top_20_itemsets_data.xlsx")


# Gr�fico
ggplot(top_20_itemsets_data, aes(x = reorder(items, support), y = support)) +
geom_col() +
coord_flip() +
labs(title = "Itemsets m�s frecuentes", x = "itemsets") +
theme_bw()




# Se muestran los 20 itemsets m�s frecuentes formados por m�s de un item.
masDeUnItem = inspect(sort(itemsets[size(itemsets) > 1] , decreasing = TRUE)[1:30])

# Gr�fico
ggplot(masDeUnItem, aes(x = reorder(items, support), y = support)) +
  geom_col() +
  coord_flip() +
  labs(title = "Itemsets m�s frecuentes", x = "itemsets") +
  theme_bw()

# Para encontrar los subsets dentro de un conjunto de itemsets, se compara el
# conjunto de itemsets con sigo mismo.
subsets <- is.subset(x = itemsets, y = itemsets, sparse = FALSE)

# La suma de una matriz l�gica devuelve el n�mero de TRUEs
sum(subsets)


# Entrenar el algoritmo Apriori con el dataset y obtener las Reglas de Asociaci�n

soporte = 30 / dim(transacciones)[1]
soporte
confianza = 0.70
reglas <- apriori(data = transacciones,
                  parameter = list(support = soporte,
                                   confidence = confianza,
                                   # Se especifica que se creen reglas
                                   target = "rules"))

summary(reglas)


inspect(sort(x = reglas, decreasing = TRUE, by = "lift"))

plot(reglas, method = "graph", engine = "htmlwidget")

class(reglas)
dataReglas = DATAFRAME(reglas)
print (dataReglas)

# Exportar el Dataset
write_xlsx(dataReglas, "asociacion-supermercadoV2.xlsx")

