import numpy

import model
import core
import theano
import theano.tensor
from SGD import Mini_Batch
import sys
sys.path.append(' /Users/anthony/.local/lib/python2.7/site-packages/theano/*')

# theano.config.compute_test_value ='warn'

def load_data(set_x, set_y, vset_x, vset_y):

    train_x = numpy.loadtxt(set_x, delimiter=',')
    train_y = numpy.loadtxt(set_y, delimiter=',')
    valid_x = numpy.loadtxt(vset_x, delimiter=',')
    valid_y = numpy.loadtxt(vset_y, delimiter=',')

    def shared_dataset(data_x, data_y, borrow=True):
        """ Function that loads the dataset into shared variables
        The reason we store our dataset in shared variables is to allow
        Theano to copy it into the GPU memory (when code is run on GPU).
        Since copying data into the GPU is slow, copying a minibatch everytime
        is needed (the default behaviour if the data is not in a shared
        variable) would lead to a large decrease in performance.
        """
        shared_x = theano.shared(numpy.asarray(data_x,
                                               dtype=theano.config.floatX),
                                 borrow=borrow)
        shared_y = theano.shared(numpy.asarray(data_y,
                                               dtype=theano.config.floatX),
                                 borrow=borrow)
        # When storing data on the GPU it has to be stored as floats
        # therefore we will store the labels as ``floatX`` as well
        # (``shared_y`` does exactly that). But during our computations
        # we need them as ints (we use labels as index, and if they are
        # floats it doesn't make sense) therefore instead of returning
        # ``shared_y`` we will have to cast it to int. This little hack
        # lets ous get around this issue
        return shared_x, shared_y

    train_set_x, train_set_y = shared_dataset(train_x, train_y)
    valid_set_x, valid_set_y = shared_dataset(valid_x, valid_y)

    rval = [(train_set_x, train_set_y), (valid_set_x, valid_set_y)]
    return rval

if __name__ == '__main__':
    tx_p = '/Users/anthony/Desktop/temp/train_x.dat'
    ty_p = '/Users/anthony/Desktop/temp/train_y.dat'
    vx_p = '/Users/anthony/Desktop/temp/valid_x.dat'
    vy_p = '/Users/anthony/Desktop/temp/valid_y.dat'
    n_input = 2622
    n_output = 20
    dataSet=load_data(tx_p, ty_p, vx_p, vy_p)
    cifar=model.Model(batch_size=20,lr=0.01,dataSet=dataSet,weight_decay=0.0)
    neure=[1000, 500, 200]
    batch_size=20
    cifar.add(core.DataLayer(batch_size,n_input))
    cifar.add(core.AutoEncodeLayer(n_input,neure[0],'relu','softplus',cost='squre',weight_init='Gaussian',gauss_std=0.3,level=0.0))
    cifar.add(core.DropoutLayer(0.2))
    cifar.add(core.FullyConnectedLayer(neure[0],neure[1],'relu','Gaussian',0.3))
    cifar.add(core.DropoutLayer(0.2))
    cifar.add(core.FullyConnectedLayer(neure[1],neure[2],'relu','Gaussian',0.001))
    cifar.add(core.DropoutLayer(0.2))
    cifar.add(core.SoftmaxLayer(neure[2],20))
    cifar.pretrain(batch_size=20,n_epoches=1)

    cifar.build_train_fn()
    cifar.build_vaild_fn()
    algorithm=Mini_Batch(model=cifar,n_epochs=10,load_param='params.pkl',save_param='params.pkl')
    algorithm.run()