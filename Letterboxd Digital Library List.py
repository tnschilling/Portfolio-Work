#!/usr/bin/env python
# coding: utf-8

# In[17]:


import requests
import os
from os import path
import pandas as pd
import re


# In[18]:


def get_film_info(directory):
    movie_info = []

    for director_name in os.listdir(directory):
        director_path = os.path.join(directory, director_name)
        if os.path.isdir(director_path):
            for movie_name in os.listdir(director_path):
                movie_path = os.path.join(director_path, movie_name)
                if os.path.isdir(movie_path):
                    if '(' in movie_name and ')' in movie_name:
                        movie_info.append(movie_name + ' / ' + director_name)
    return movie_info


# In[19]:


hd_1 = r"F:/Movies"
film_list1 = get_film_info(hd_1)

hd_2 = r"G:/Movies"
film_list2 = get_film_info(hd_2)


# In[20]:


film_directory_list = film_list1 + film_list2
film_directory_df = pd.DataFrame(film_directory_list, columns=['Title'])

film_directory_df['Director'] = film_directory_df['Title'].str.split('/').str[1].str.strip()
film_directory_df['Year'] = film_directory_df['Title'].str.split('(').str[1].str.split(')').str[0]
film_directory_df['Title'] = film_directory_df['Title'].str.split('(').str[0].str.strip()


# In[21]:


film_directory_df


# In[ ]:





# In[ ]:




