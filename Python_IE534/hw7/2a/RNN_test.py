'''
File: RNN_test.py
Author: Yutong Dai (rothdyt@gmail.com)
File Created: Monday, 2018-10-29 20:31
Last Modified: Tuesday, 2018-10-30 18:09
--------------------------------------------
Desscription:
'''

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable

import time
import os
import sys
import io

from RNN_model import RNN_model
from utils import test

vocab_size = 8000

x_test = []
with io.open('../preprocessed_data/imdb_test.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for line in lines:
    line = line.strip()
    line = line.split(' ')
    line = np.asarray(line, dtype=np.int)
    # convert any token id greater than the dictionary size to the unknown token ID 0
    line[line > vocab_size] = 0
    x_test.append(line)

y_test = np.zeros((25000,))
# positive label
y_test[0:12500] = 1

# for unknown token
vocab_size += 1

