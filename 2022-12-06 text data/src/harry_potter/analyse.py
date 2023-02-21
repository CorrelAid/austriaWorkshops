
import pickle

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import plotly.express as px

from sentence_transformers import SentenceTransformer

from process import Processor
from umap_calc import (
    compute_umap,
    get_vis_df
)


class Analyzer(object):

    def __init__(self):
        self.proc = Processor()
        self.proc.parse()
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        self.data_dir = "./data"
        self.emb_file = "sentence_embeddings.pk"
        self._load()

    def _load(self):
        try:
            with open(self.data_dir + "/" + self.emb_file, "rb") as fi:
                self.sentence_embeddings = pickle.load(fi)
        except Exception as e:
            self.sentence_embeddings = []

    def _save_embeddings(self, embs):
        with open(self.data_dir + "/" + self.emb_file, "wb") as fi:
            pickle.dump(embs, fi)

    def cooccurence(self):
        actors = ["ron", "harry", "hermione", "dudley"]
        occurences = []
        for sent in self.proc.pages_lower:
            occurences.append({
                actor: sent.count(actor) for actor in actors
            })
        occ_df = pd.DataFrame(occurences)
        occ_df.plot.line(
            title = "Page-wise Cooccurence line-plot",
            figsize = (15, 4)
        )
        plt.show()

    def sentence_plot(self):        
        if len(self.sentence_embeddings) <= 0:
            print("> Embeddings could not be loaded")
            print("> Obtaining embeddings...")
            self.sentence_embeddings = self.model.encode(self.proc.sentences)
            self._save_embeddings(self.sentence_embeddings)
        else:
            print("> Embeddings successfully loaded")

        x_coords, y_coords = compute_umap(self.sentence_embeddings)
        vis_df = get_vis_df(x_coords, y_coords)
                
        pages_for_sents = [[(idx+1)]*len(sent_li) for idx, sent_li in enumerate(self.proc.sentences_for_page)]
        pages_for_sents = list(np.concatenate(pages_for_sents).ravel())
        
        vis_df["page"] = pages_for_sents
        vis_df["sentence"] = list(np.concatenate(self.proc.sentences_for_page).ravel())
        
        vis_df.plot.scatter(
            x = "x",
            y = "y",
            figsize = (12, 10),
            title = "Scatterplot of sentence embeddings",
            c = vis_df.page,
            alpha = 0.4, 
            cmap = 'inferno'
        )
        plt.show()

        fig = px.scatter(
            vis_df,
            x = "x", 
            y = "y",
            color = "page",
            hover_data=["sentence"]
        )
        fig.show()





ana = Analyzer()
ana.sentence_plot()
# ana.cooccurence()