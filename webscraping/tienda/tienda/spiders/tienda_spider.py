# -*- coding: utf-8 -*-
"""
Created on Wed May 18 17:16:24 2022

@author: TaylorAsprilla
"""

import scrapy
from tienda.items import TiendaItem
from scrapy.linkextractors import LinkExtractor
from scrapy.exceptions import CloseSpider

# import LinkExtractor
# import Request
# from scrapy.linkextractors import LinkExtractor
# from scrapy.http import Request
import pandas as pd

class TiendaSpider(scrapy.Spider):
    # Nombre de la araña
    name = "tienda"    
    # Dominios permitidos
    allowed_domains = ['tiendasmetro.co']
    
    # URLs para comenzar a rastrear
    start_urls = [
        'https://www.tiendasmetro.co/supermercado/despensa/arroz-y-granos',
        'https://www.tiendasmetro.co/supermercado/despensa/arroz-y-granos?page=2',
        'https://www.tiendasmetro.co/supermercado/despensa/arroz-y-granos?page=3',
        'https://www.tiendasmetro.co/supermercado/despensa/arroz-y-granos?page=4',
        'https://www.tiendasmetro.co/supermercado/despensa/arroz-y-granos?page=5',      
        'https://www.tiendasmetro.co/supermercado/despensa/aceite',
        'https://www.tiendasmetro.co/supermercado/despensa/aceite?page=2',
        'https://www.tiendasmetro.co/supermercado/despensa/aceite?page=3',
        'https://www.tiendasmetro.co/supermercado/despensa/aceite?page=4',
        'https://www.tiendasmetro.co/supermercado/despensa/aceite?page=5',
        'https://www.tiendasmetro.co/supermercado/despensa/cafe',
        'https://www.tiendasmetro.co/supermercado/despensa/cafe?page=2',
        'https://www.tiendasmetro.co/supermercado/despensa/cafe?page=3',
        'https://www.tiendasmetro.co/supermercado/despensa/cafe?page=4',
        'https://www.tiendasmetro.co/supermercado/despensa/cafe?page=5',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas?page=2',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas?page=3',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas?page=4',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas?page=5',
        'https://www.tiendasmetro.co/supermercado/despensa/pastas?page=6',
        'https://www.tiendasmetro.co/supermercado/despensa/enlatados-y-conservas',
        'https://www.tiendasmetro.co/supermercado/despensa/enlatados-y-conservas?page=2',
        'https://www.tiendasmetro.co/supermercado/despensa/enlatados-y-conservas?page=3'
        'https://www.tiendasmetro.co/supermercado/despensa/enlatados-y-conservas?page=4'
        'https://www.tiendasmetro.co/supermercado/despensa/enlatados-y-conservas?page=5',
        'https://www.tiendasmetro.co/supermercado/lacteos-huevos-y-refrigerados',
        'https://www.tiendasmetro.co/supermercado/lacteos-huevos-y-refrigerados?page=2',
        'https://www.tiendasmetro.co/supermercado/lacteos-huevos-y-refrigerados?page=3',
        'https://www.tiendasmetro.co/supermercado/lacteos-huevos-y-refrigerados?page=4',
        'https://www.tiendasmetro.co/supermercado/lacteos-huevos-y-refrigerados?page=5',
        'https://www.tiendasmetro.co/supermercado/aseo-de-hogar',
        'https://www.tiendasmetro.co/supermercado/aseo-de-hogar?page=2',
        'https://www.tiendasmetro.co/supermercado/aseo-de-hogar?page=3',
        'https://www.tiendasmetro.co/supermercado/aseo-de-hogar?page=4',
        'https://www.tiendasmetro.co/supermercado/aseo-de-hogar?page=5',
        'https://www.tiendasmetro.co/supermercado/bebidas',
        'https://www.tiendasmetro.co/supermercado/bebidas?page=2',
        'https://www.tiendasmetro.co/supermercado/bebidas?page=3',
        'https://www.tiendasmetro.co/supermercado/bebidas?page=4',
        'https://www.tiendasmetro.co/supermercado/bebidas?page=5'
        
    ]
    
    def parse(self, response):
        print('Parseando................. ' + response.url)
        producto = TiendaItem()        
        
        # Extraemos el nombre del producto, la descripcion y su precio     
        producto['nombre'] = response.xpath('//*[@id="gallery-layout-container"]/div/section/a/article/div/div/div/h1/span/text()').extract()
        producto['precio'] = response.xpath('//*[@id="items-price"]/div/div/text()').getall()        
       
        self.to_excel(producto)      
        yield producto
        
        
    def to_excel(self,producto):
        
        user_list = list(zip( producto['nombre'], producto['precio']))
        df1 = pd.DataFrame(user_list,columns=["name","price"])       
        df2=pd.read_csv("infoScrapy.csv")
        df=pd.concat([df1,df2])#.reset_index(inplace=True)
        df.to_csv("infoScrapy.csv",index=False,encoding='utf8')
        
    
    