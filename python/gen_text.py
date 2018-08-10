from textgenrnn import textgenrnn

textgen = textgenrnn(weights_path='rcoder_weights.hdf5',
                       vocab_path='rcoder_vocab.json',
                       config_path='rcoder_config.json')

temperatures = [5, 8, 10, 12, 15, 20]
files = [f'rcoder_text_temp_{t}.txt' for t in temperatures]

for i in range(len(temperatures)):
    file = files[i]
    temp = temperatures[i] / 10
    print("Write to text file", file)
    textgen.generate_to_file(file,
                             max_gen_length=50000,
                             temperature=temp)
