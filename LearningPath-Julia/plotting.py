#%%
import seaborn as sns
import numpy as np
sns.set()

x = np.linspace(0, 20, 100)
sns.lineplot(x, np.sin(x))
