import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.datasets import fetch_mldata
from sklearn.decomposition import PCA

fn_csv = '/Users/skyeong/data/IGD/Demographic/subjlist_igd.csv'
df = pd.read_csv(fn_csv, sep=',', header=0)
X = df[['IAT','ADHD','anxiety','depression','BIS_11']].as_matrix()
# X = df[['KWAIS','RSES','IAT','ADHD','anxiety','depression','BIS_11']].as_matrix()
y = df['Group']

# Check datasize
print (X.shape, y.shape)


feat_cols = [ 'pixel'+str(i) for i in range(X.shape[1]) ]

# Insert dataset to DataFrame
df = pd.DataFrame(X,columns=feat_cols)
df['label'] = y
df['label'] = df['label'].apply(lambda i: str(i))

X, y = None, None
print ('Size of the dataframe: {}'.format(df.shape))

# Random permutation
rndperm = np.random.permutation(df.shape[0])

# Plot the graph
# plt.gray()
# fig = plt.figure( figsize=(16,7) )
# for i in range(0,30):
#     ax = fig.add_subplot(3,10,i+1, title='Digit: ' + str(df.loc[rndperm[i],'label']) )
#     ax.matshow(df.loc[rndperm[i],feat_cols].values.reshape((28,28)).astype(float))
# plt.show()


pca = PCA(n_components=3)
pca_result = pca.fit_transform(df[feat_cols].values)

df['pca-one'] = pca_result[:,0]
df['pca-two'] = pca_result[:,1]
df['pca-three'] = pca_result[:,2]

print( 'Explained variation per principle component: {}'.format(pca.explained_variance_ratio_))

# Plot PCA components
from ggplot import *
chart1 = ggplot( df, aes(x='pca-one', y='pca-two', color='label') ) \
        + geom_point(size=75,alpha=0.8) \
        + ggtitle("First and Second Principal Components colored by digit")




# t-SNE approach
import time
from sklearn.manifold import TSNE

time_start = time.time()
tsne = TSNE(n_components=2, verbose=1, perplexity=30, n_iter=10000)
tsne_results = tsne.fit_transform(df)

print( 't-SNE done! Time elapsed: {} seconds'.format(time.time() - time_start) )

df_tsne = df.copy()
df_tsne['x-tsne'] = tsne_results[:,0]
df_tsne['y-tsne'] = tsne_results[:,1]

chart2 = ggplot( df_tsne, aes(x='x-tsne', y='y-tsne', color='label') ) \
        + geom_point(size=70,alpha=1) \
        + ggtitle("tSNE dimensions colored by digit")

df_tsne.to_csv('ccc.csv')
