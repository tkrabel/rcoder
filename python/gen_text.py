from textgenrnn import textgenrnn
from joblib import delayed, Parallel

textgen = textgenrnn(weights_path='rcoder_weights.hdf5',
                       vocab_path='rcoder_vocab.json',
                       config_path='rcoder_config.json')

temperatures = [5, 8, 10, 12, 15, 20]
files = [f'rcoder_text_temp_{t}.txt' for t in temperatures]

def generate_text(file, temperature):
    temp = temperature / 10
    print("Write to text file", file)
    textgen.generate_to_file(file,
                             max_gen_length=50000,
                             temperature=temp)
    return None

Parallel(n_jobs=6)(delayed(generate_text)(file=files[i], temperature=temperatures[i]) for i in range(len(temperatures)) )

# for i in range(len(temperatures)):
#     file = files[i]
#     temp = temperatures[i] / 10
    
