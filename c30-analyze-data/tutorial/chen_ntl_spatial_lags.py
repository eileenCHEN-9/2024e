#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas
import geopandas
from libpysal import graph
import os
import geopandas as gpd


# In[3]:


os.chdir('F:/projects/2024/ursavas_alahmadi_chen/data/ntl_data')


# In[4]:


panel = (
    pandas.read_csv(
        'spatial.csv', 
        encoding = 'ISO-8859-9' # Turkish encoding
    )
    .set_index(['asdf_id', 'year'])
    
)


# In[5]:


geo = gpd.read_file("F:/projects/2024/informal/TUR_ADM1.geojson")


# In[6]:


w = (
    graph.Graph.build_contiguity(geo, rook=False)
    .transform('R')
)


# In[7]:


w.neighbors


# In[8]:


lags = pandas.DataFrame(index=panel.index, columns=panel.columns)

for year in panel.index.get_level_values('year').unique():
    for var in lags.columns:
        vals = panel.loc[pandas.IndexSlice[:, year], var]
        lags.loc[vals.index, var] = w.lag(vals)


# In[9]:


lags.to_csv('lagged_ntl_panel.csv')


# In[ ]:




