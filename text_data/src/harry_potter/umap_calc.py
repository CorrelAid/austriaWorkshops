
import pretty_errors

import umap
import pickle

from tqdm import tqdm

import numpy as np
import pandas as pd

# import warnings
# warnings.simplefilter("ignore")


data_dir = "./data"
coords_file = "umap_embedding_coords.pk"

def _load_coords():
    try:
        with open(data_dir + "/" + coords_file, "rb") as fi:
            coords = pickle.load(fi)
    except Exception as e:
        coords = None
    return coords

def _save_umap_embeddings(embs):
    with open(data_dir + "/" + coords_file, "wb") as fi:
        pickle.dump(embs, fi)


def compute_umap(X):
    print("> Starting computation...")

    coords = _load_coords()
    if coords:
        print("> Found saved computation")
        return coords["x"], coords["y"]

    reducer = umap.UMAP()
    res = reducer.fit(X)
    
    embs = res.embedding_
    x_vals = []
    y_vals = []

    print("> Done")
    print("> Storing results...")
    for e in tqdm(embs):
        x_vals.append(e[0])
        y_vals.append(e[1])

    _save_umap_embeddings({
        "x": x_vals, 
        "y": y_vals
    })
    return x_vals, y_vals


def get_vis_df(x, y):    
    return pd.DataFrame(
        list({
            "x": x,
            "y": y
        } for x, y in zip(x,y)
        )
    )

