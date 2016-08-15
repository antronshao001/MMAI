import pprint as p

import numpy

import theano
import theano as T

theano.config.compute_test_value ='warn'
W= theano.shared(value=numpy.array([[1,2],[3,4]],dtype=theano.config.floatX),name='b',borrow=True)
y= theano.shared(value=numpy.array([[5,6],[7,8]],dtype=theano.config.floatX),name='c',borrow=True)
b=[1,2]
y_pred=T.dot(y,W)+b
p.pprint(T.mean(T.neq(y_pred,y)))