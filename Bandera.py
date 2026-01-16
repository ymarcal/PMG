import pandas as pd
import numpy as np
import os
os.environ["KERAS_BACKEND"] = "tensorflow"
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
import keras
from keras import layers
def prepara_df():
    local = 'C:\\Users\\Lenovo\\Desktop\\ITA\\Mestrado\\Dados Aceleração Nivelada AT-26\\Aceleracao_FL'
    files = ['050', '150', '300', '400']
    all_dfs = [pd.read_excel(local + file + '.xls').iloc[1:] for file in files]
    df = pd.concat(all_dfs, ignore_index=True)
    df.to_excel('Todos.xls', index=False, engine='openpyxl')
    return df

df = prepara_df()
X = np.array([df['W'], df['Zp'], df['Mach'], df['Ta'], df['CL']])
Y = np.array([df['CD'], df['T']])

model = keras.Sequential(
    [
        layers.Dense(2, activation="relu"),
        layers.Dense(3, activation="relu"),
        layers.Dense(4),
    ]
)

x = keras.ops.ones((1, 4))
y = model(x)
print("Number of weights after calling the model:", len(model.weights))  # 6