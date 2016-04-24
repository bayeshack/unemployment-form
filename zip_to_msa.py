# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 18:00:09 2016

contains the function zip_to_msa(zip_code) which takes an 5 digit zip code as
string and returns a 5 digit MSA code as string
@author: to
"""
import numpy as np

#takes zip_code as 5digit string and returns MSA code as 5digit string
def zip_to_msa(zip_code):
	
	
	
	#read in
	arr_zip_msa = np.genfromtxt('./zip_msa.csv', dtype=str, delimiter ='\t', skip_header=8)
	
	#create dictionary mapping
	dict_zip2msa 	= dict([line[0],line[1]] for line in arr_zip_msa)
	#dict_msa2name 	= dict([line[1],line[2]] for line in arr_zip_msa)
	#print dict_msa2name[dict_zip2msa[zip_code]], ' = '
	return dict_zip2msa[zip_code]
	
	
#example	
#zip_code = '94103'
#print 'MSA of zip code ', str(zip_code),' -> ', zip_to_msa(zip_code)	
	
	
	
	



