
import re
import requests

import numpy as np

class Processor(object):

    def __init__(self):
        self.txt_url = "https://raw.githubusercontent.com/formcept/whiteboard/master/nbviewer/notebooks/data/harrypotter/Book%201%20-%20The%20Philosopher's%20Stone.txt"
        self._load_data()

    def _load_data(self):
        response = requests.get(self.txt_url)
        self.text = response.text

    def parse(self):    
        pattern = r"Page \| \d+ Harry Potter and the Philosophers Stone - J.K. Rowling"
        self.text = self.text.replace("\n", "")
        self.pages = re.split(pattern, self.text)
        self.pages_lower = [*map(str.lower, self.pages)]

        self.sentences_for_page = [re.split(r"(\.|\!|\?)", "".join(page)) for page in self.pages]
        self.sentences = list(np.concatenate(self.sentences_for_page).ravel())

        self.sentences_lower_for_page = [re.split(r"(\.|\!|\?)", "".join(page)) for page in self.pages_lower]
        self.sentences_lower = list(np.concatenate(self.sentences_lower_for_page).ravel())

        self.plain_text = re.sub(' +', ' ', " ".join(self.sentences_lower))        
