import numpy
import gensim
import PIL.Image as Image
import utils

traits = ['curious', 'intellectual', 'creative', 'narrow', 'responsible', 'organized', 'neat', 'hedonistic',
         'outgoing', 'withdrawn', 'silent', 'unsocial', 'cooperative', 'modest', 'irritable', 'impolite',
         'secure', 'hardy', 'unemotional', 'nervous']

input_path = '/Users/anthony/Desktop/temp/test_y.dat'
rank_x = numpy.loadtxt(input_path, delimiter=',') #input image tag (img_number, tag_number)
rank_x = [tags/numpy.sum(tags) if numpy.sum(tags)>0 else numpy.zeros(20) for tags in rank_x]

model = gensim.models.Word2Vec.load_word2vec_format("/Users/anthony/PycharmProjects/NEF_HW2/wiki_en_text.vector", binary=False)

trait_vectors = [model[trait] for trait in traits]
rank_y = [numpy.dot(img,trait_vectors) for img in rank_x ] #output image_language_vector(img_number, language_vector_number)
numpy.savetxt('ranking_model', rank_y, delimiter=',')

#################

test_trait = ['reliable','good']
consult_x = numpy.sum([model[test] for test in test_trait], axis=0)
ranking = numpy.dot(rank_y,consult_x)

indices = list(range(len(ranking)))
indices.sort(key=lambda x: ranking[x])
output = [0] * len(indices)
for i, x in enumerate(indices):
    output[x] = i

#img_array = [Image.open('/Users/anthony/Downloads/allImages/'+str(output[high])+'.jpg') for high in range(9)]
for i in range(9):
    image = Image.open('/Users/anthony/Downloads/allImages/'+str(output[i])+'.jpg')
    Image._show(image)
    #Image.fromarray(numpy.array(image)).save('ranking_good_reliable'+str(i))
    #image.save('ranking_good_reliable'+str(i))
    #img_array[i].save('ranking_good_reliable'+str(i)+'png')
#    raw_input()